import hashlib
import json
import os
import secrets
import sqlite3
from contextlib import asynccontextmanager, contextmanager
from datetime import datetime
from typing import Dict, List, Optional

from fastapi import FastAPI, HTTPException, Header, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import uvicorn

# ── SQLite Database Setup ──────────────────────────────────────────────────────

DB_PATH = os.path.join(os.path.dirname(__file__), "carebridge.db")

def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA journal_mode=WAL")
    return conn

def init_db():
    conn = get_db()
    cur = conn.cursor()

    cur.executescript("""
        CREATE TABLE IF NOT EXISTS users (
            phone       TEXT PRIMARY KEY,
            id          TEXT NOT NULL,
            name        TEXT NOT NULL,
            hashed_pin  TEXT NOT NULL,
            salt        TEXT NOT NULL,
            role        TEXT NOT NULL,
            region      TEXT NOT NULL,
            district    TEXT NOT NULL
        );

        CREATE TABLE IF NOT EXISTS households (
            id                TEXT PRIMARY KEY,
            name              TEXT NOT NULL,
            patient_category  TEXT DEFAULT 'child',
            chps_zone         TEXT NOT NULL,
            region            TEXT DEFAULT 'Savannah Region',
            district          TEXT DEFAULT 'Bole',
            risk_tier         TEXT DEFAULT 'ROUTINE',
            reasons           TEXT DEFAULT '[]',
            overdue_days      INTEGER DEFAULT 0,
            last_visit        TEXT,
            updated_at        TEXT,
            last_chw          TEXT
        );

        CREATE TABLE IF NOT EXISTS conflict_log (
            id                    INTEGER PRIMARY KEY AUTOINCREMENT,
            household_id          TEXT NOT NULL,
            conflict_detected_at  TEXT NOT NULL,
            submission_a          TEXT NOT NULL,
            submission_b          TEXT NOT NULL,
            resolution            TEXT NOT NULL
        );
    """)
    conn.commit()

    # Seed default users if table is empty
    existing = cur.execute("SELECT COUNT(*) FROM users").fetchone()[0]
    if existing == 0:
        _seed_default_users(cur)
        conn.commit()

    # Seed demo households if table is empty
    existing_h = cur.execute("SELECT COUNT(*) FROM households").fetchone()[0]
    if existing_h == 0:
        _seed_demo_households(cur)
        conn.commit()

    conn.close()

def _seed_default_users(cur):
    def make_user(phone, uid, name, role, region, district, pin="1234"):
        hashed, salt = hash_password(pin)
        cur.execute(
            "INSERT INTO users VALUES (?,?,?,?,?,?,?,?)",
            (phone, uid, name, hashed, salt, role, region, district),
        )

    make_user("+233241234567", "USR-101", "Ama Abena", "frontlineHealthWorker", "Savannah Region", "Bole")
    make_user("+233509876543", "USR-102", "Dr. Ibrahim Fuseini", "districtOfficer", "Savannah Region", "Bole")

def _seed_demo_households(cur):
    demo = [
        ("H-10041", "Akua Serwaa", "child", "Bole CHPS Zone", "Savannah Region", "Bole",
         "URGENT", ["MUAC 10.5cm — SAM", "Fast breathing (62/min) in young infant"], 21,
         "2026-07-09", "2026-07-09T08:00:00", "Ama Abena"),
        ("H-10042", "Abena Gyamfi's Baby", "newborn", "Bole CHPS Zone", "Savannah Region", "Bole",
         "WATCH", ["MUAC 12.0cm — MAM"], 14, "2026-07-16", "2026-07-16T09:00:00", "Ama Abena"),
        ("H-10043", "Hajia Mariama", "mother", "Bole CHPS Zone", "Savannah Region", "Bole",
         "WATCH", ["Maternal Hb 8.4 g/dL — Moderate Anaemia"], 28,
         "2026-07-02", "2026-07-02T10:00:00", "Ama Abena"),
        ("H-10044", "Kofi Mensah's Baby", "child", "Bole CHPS Zone", "Savannah Region", "Bole",
         "ROUTINE", ["All clinical parameters normal"], 0, "2026-07-25", "2026-07-25T07:00:00", "Ama Abena"),
        ("H-10045", "Fatima Zohra", "mother", "Damongo CHPS Zone", "Savannah Region",
         "West Gonja Municipal", "URGENT", ["Vaginal bleeding reported", "Overdue 35 days"],
         35, "2026-07-10", "2026-07-10T08:15:00", "Ibrahim Fuseini"),
    ]
    for row in demo:
        hid, name, cat, zone, region, dist, tier, reasons, overdue, lv, ua, chw = row
        cur.execute(
            "INSERT INTO households VALUES (?,?,?,?,?,?,?,?,?,?,?,?)",
            (hid, name, cat, zone, region, dist, tier, json.dumps(reasons), overdue, lv, ua, chw),
        )

# ── App Setup ──────────────────────────────────────────────────────────────────

@asynccontextmanager
async def lifespan(application: FastAPI):
    init_db()
    yield

app = FastAPI(
    title="CareBridge AI - Pilot Backend API",
    description="Sync server, authentication, and supervisor REST API for CHPS frontline health triage in Northern Ghana.",
    version="2.1.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# In-memory session store (tokens map to user dicts); lightweight, acceptable for pilot
DB_SESSIONS: Dict[str, dict] = {}
TIER_PRIORITY = {"URGENT": 0, "WATCH": 1, "ROUTINE": 2}

# ── Auth & Data Schemas ────────────────────────────────────────────────────────

class SignupRequest(BaseModel):
    name: str
    phone: str
    pin: str
    role: str
    region: str
    district: str

class LoginRequest(BaseModel):
    phone: str
    pin: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: dict

class UserResponse(BaseModel):
    id: str
    name: str
    phone: str
    role: str
    region: str
    district: str

class AssessmentRecord(BaseModel):
    household_id: str
    patient_name: str
    patient_category: str = "child"
    chps_zone: str
    region: Optional[str] = "Savannah Region"
    district: Optional[str] = "Bole"
    user_role: Optional[str] = "frontlineHealthWorker"
    muac_cm: Optional[float] = None
    oedema: bool = False
    breathing_rate: Optional[int] = 40
    maternal_hb: Optional[float] = None
    risk_tier: str
    triggered_reasons: List[str]
    timestamp: str
    is_urgent_referral: bool = False

class SyncBatchPayload(BaseModel):
    chw_id: str
    chps_zone: str
    region: Optional[str] = "Savannah Region"
    district: Optional[str] = "Bole"
    assessments: List[AssessmentRecord]

# ── Hashing Utilities ──────────────────────────────────────────────────────────

def hash_password(password: str, salt: bytes = None) -> tuple[str, str]:
    if salt is None:
        salt = os.urandom(16)
    hashed = hashlib.pbkdf2_hmac('sha256', password.encode('utf-8'), salt, 100000)
    return hashed.hex(), salt.hex()

def verify_password(password: str, hashed_hex: str, salt_hex: str) -> bool:
    salt = bytes.fromhex(salt_hex)
    rehashed, _ = hash_password(password, salt)
    return rehashed == hashed_hex

# ── Auth Helper Dependency ─────────────────────────────────────────────────────

def get_current_user(authorization: Optional[str] = Header(None)):
    if not authorization or not authorization.startswith("Bearer "):
        # Dev fallback: return the default CHO user from DB
        conn = get_db()
        row = conn.execute("SELECT * FROM users WHERE phone=?", ("+233241234567",)).fetchone()
        conn.close()
        if row:
            return dict(row)
        raise HTTPException(status_code=401, detail="No authorization header and no fallback user.")
    token = authorization.split(" ")[1]
    if token not in DB_SESSIONS:
        raise HTTPException(status_code=401, detail="Invalid or expired authentication session token.")
    return DB_SESSIONS[token]

def _row_to_household(row) -> dict:
    d = dict(row)
    d["reasons"] = json.loads(d.get("reasons") or "[]")
    return d

# ── Endpoints ─────────────────────────────────────────────────────────────────

@app.get("/")
def read_root():
    return {
        "status": "online",
        "system": "CareBridge AI Pilot Sync & Authentication Server",
        "version": "2.1.0",
        "persistence": "SQLite (carebridge.db)",
        "time": datetime.now().isoformat(),
    }

@app.post("/api/v1/auth/signup", response_model=TokenResponse)
def signup(req: SignupRequest):
    phone_clean = req.phone.replace(" ", "")
    conn = get_db()
    existing = conn.execute("SELECT id FROM users WHERE phone=?", (phone_clean,)).fetchone()
    if existing:
        conn.close()
        raise HTTPException(status_code=400, detail="User account with this phone number already exists.")

    hashed_hex, salt_hex = hash_password(req.pin)
    user_id = f"USR-{secrets.token_hex(4)}"
    conn.execute(
        "INSERT INTO users VALUES (?,?,?,?,?,?,?,?)",
        (phone_clean, user_id, req.name, hashed_hex, salt_hex, req.role, req.region, req.district),
    )
    conn.commit()
    conn.close()

    user_data = {
        "id": user_id, "name": req.name, "phone": phone_clean,
        "role": req.role, "region": req.region, "district": req.district,
    }
    token = secrets.token_urlsafe(32)
    DB_SESSIONS[token] = user_data
    return TokenResponse(access_token=token, user=user_data)

@app.post("/api/v1/auth/login", response_model=TokenResponse)
def login(req: LoginRequest):
    phone_clean = req.phone.replace(" ", "")
    conn = get_db()
    user = conn.execute("SELECT * FROM users WHERE phone=?", (phone_clean,)).fetchone()

    if not user:
        # Suffix fallback match (handles partial phone formats)
        all_users = conn.execute("SELECT * FROM users").fetchall()
        for u in all_users:
            if u["phone"].endswith(phone_clean[-8:]):
                user = u
                break

    conn.close()

    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials. Phone number not found.")
    if not verify_password(req.pin, user["hashed_pin"], user["salt"]):
        raise HTTPException(status_code=401, detail="Invalid Security PIN.")

    user_data = {
        "id": user["id"], "name": user["name"], "phone": user["phone"],
        "role": user["role"], "region": user["region"], "district": user["district"],
    }
    token = secrets.token_urlsafe(32)
    DB_SESSIONS[token] = user_data
    return TokenResponse(access_token=token, user=user_data)

@app.get("/api/v1/auth/me", response_model=UserResponse)
def get_me(user: dict = Depends(get_current_user)):
    return UserResponse(
        id=user["id"], name=user["name"], phone=user["phone"],
        role=user["role"], region=user["region"], district=user["district"],
    )

@app.post("/api/v1/sync")
def sync_offline_records(payload: SyncBatchPayload):
    processed = 0
    conflicts_detected = []
    conn = get_db()

    for item in payload.assessments:
        hid = item.household_id
        incoming_ts = item.timestamp
        incoming_tier = item.risk_tier.upper()

        existing_row = conn.execute("SELECT * FROM households WHERE id=?", (hid,)).fetchone()

        if existing_row:
            existing = dict(existing_row)
            existing_ts = existing.get("updated_at", "")
            existing_tier = existing.get("risk_tier", "ROUTINE").upper()

            try:
                existing_dt = datetime.fromisoformat(existing_ts)
                incoming_dt = datetime.fromisoformat(incoming_ts)
                is_concurrent = abs((incoming_dt - existing_dt).total_seconds()) < 60
            except Exception:
                is_concurrent = False

            if is_concurrent:
                conflict = {
                    "household_id": hid,
                    "conflict_detected_at": datetime.now().isoformat(),
                    "submission_a": json.dumps({"chw": existing.get("last_chw", "unknown"), "tier": existing_tier, "ts": existing_ts}),
                    "submission_b": json.dumps({"chw": payload.chw_id, "tier": incoming_tier, "ts": incoming_ts}),
                    "resolution": "highest_severity_preserved",
                }
                conn.execute(
                    "INSERT INTO conflict_log (household_id, conflict_detected_at, submission_a, submission_b, resolution) VALUES (?,?,?,?,?)",
                    (conflict["household_id"], conflict["conflict_detected_at"],
                     conflict["submission_a"], conflict["submission_b"], conflict["resolution"]),
                )
                conflicts_detected.append(conflict)

            ep = TIER_PRIORITY.get(existing_tier, 2)
            ip = TIER_PRIORITY.get(incoming_tier, 2)
            resolved_tier = existing_tier if ep < ip else incoming_tier

            conn.execute(
                """UPDATE households SET name=?, patient_category=?, chps_zone=?, region=?, district=?,
                   risk_tier=?, reasons=?, overdue_days=0, last_visit=?, updated_at=?, last_chw=?
                   WHERE id=?""",
                (item.patient_name, item.patient_category, item.chps_zone,
                 item.region or "Savannah Region", item.district or "Bole",
                 resolved_tier, json.dumps(item.triggered_reasons),
                 incoming_ts[:10], incoming_ts, payload.chw_id, hid),
            )
        else:
            conn.execute(
                "INSERT INTO households VALUES (?,?,?,?,?,?,?,?,?,?,?,?)",
                (hid, item.patient_name, item.patient_category, item.chps_zone,
                 item.region or "Savannah Region", item.district or "Bole",
                 item.risk_tier, json.dumps(item.triggered_reasons),
                 0, incoming_ts[:10], incoming_ts, payload.chw_id),
            )

        processed += 1

    conn.commit()
    conn.close()

    return {
        "status": "success",
        "processed_count": processed,
        "conflicts_detected": len(conflicts_detected),
        "conflict_resolution_strategy": "last_write_wins_with_severity_preservation",
        "message": f"Synced {processed} records. {len(conflicts_detected)} concurrent conflict(s) logged for supervisor review.",
    }

@app.get("/api/v1/households")
def get_households(
    tier: Optional[str] = None,
    category: Optional[str] = None,
    region: Optional[str] = None,
    district: Optional[str] = None,
):
    conn = get_db()
    query = "SELECT * FROM households WHERE 1=1"
    params = []
    if tier and tier.upper() != "ALL":
        query += " AND UPPER(risk_tier)=?"
        params.append(tier.upper())
    if category and category.upper() != "ALL":
        query += " AND LOWER(patient_category)=?"
        params.append(category.lower())
    if region and region.upper() != "ALL":
        query += " AND LOWER(region)=?"
        params.append(region.lower())
    if district and district.upper() != "ALL":
        query += " AND LOWER(district)=?"
        params.append(district.lower())

    rows = conn.execute(query, params).fetchall()
    conn.close()
    households = [_row_to_household(r) for r in rows]
    return {"count": len(households), "households": households}

@app.get("/api/v1/chw/metrics")
def get_supervisor_metrics(
    region: Optional[str] = None,
    district: Optional[str] = None,
):
    conn = get_db()
    query = "SELECT * FROM households WHERE 1=1"
    params = []
    if region and region.upper() != "ALL":
        query += " AND LOWER(region)=?"
        params.append(region.lower())
    if district and district.upper() != "ALL":
        query += " AND LOWER(district)=?"
        params.append(district.lower())

    rows = conn.execute(query, params).fetchall()
    conn.close()
    all_h = [dict(r) for r in rows]

    def count_by_tier(tier):
        return [h for h in all_h if h["risk_tier"].upper() == tier]

    def breakdown(items):
        return {
            "mothers":  sum(1 for i in items if i.get("patient_category") == "mother"),
            "newborns": sum(1 for i in items if i.get("patient_category") == "newborn"),
            "children": sum(1 for i in items if i.get("patient_category") == "child"),
        }

    urgent = count_by_tier("URGENT")
    watch  = count_by_tier("WATCH")
    routine = count_by_tier("ROUTINE")

    # Conflict count from DB
    conn2 = get_db()
    conflict_count = conn2.execute("SELECT COUNT(*) FROM conflict_log").fetchone()[0]
    conn2.close()

    return {
        "region":                region or "Savannah Region",
        "district":              district or "Bole",
        "total_households":      len(all_h),
        "urgent_referrals":      len(urgent),
        "urgent_breakdown":      breakdown(urgent),
        "watch_cases":           len(watch),
        "watch_breakdown":       breakdown(watch),
        "routine_cases":         len(routine),
        "routine_breakdown":     breakdown(routine),
        "pending_conflict_reviews": conflict_count,
        "sync_health":           "100% Operational",
    }

@app.get("/api/v1/conflicts")
def get_conflict_log():
    conn = get_db()
    rows = conn.execute("SELECT * FROM conflict_log ORDER BY id DESC").fetchall()
    conn.close()
    conflicts = []
    for r in rows:
        conflicts.append({
            "id": r["id"],
            "household_id": r["household_id"],
            "conflict_detected_at": r["conflict_detected_at"],
            "submission_a": json.loads(r["submission_a"]),
            "submission_b": json.loads(r["submission_b"]),
            "resolution": r["resolution"],
        })
    return {"count": len(conflicts), "conflicts": conflicts}

@app.delete("/api/v1/admin/reset-demo-data")
def reset_demo_data():
    """Dev-only: wipe and re-seed demo households for clean demo presentations."""
    conn = get_db()
    conn.execute("DELETE FROM households")
    conn.execute("DELETE FROM conflict_log")
    _seed_demo_households(conn.cursor())
    conn.commit()
    conn.close()
    return {"status": "ok", "message": "Demo data reset. 5 households re-seeded."}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
