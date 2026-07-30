from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import uvicorn
from datetime import datetime

app = FastAPI(
    title="CareBridge AI - Pilot Backend API",
    description="Sync server and supervisor REST API for CHPS frontline health triage in Northern Ghana.",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Data Schemas ---
class AssessmentRecord(BaseModel):
    household_id: str
    patient_name: str
    chps_zone: str
    muac_cm: Optional[float] = None
    oedema: bool = False
    breathing_rate: int = 40
    maternal_hb: Optional[float] = None
    risk_tier: str  # URGENT, WATCH, ROUTINE
    triggered_reasons: List[str]
    timestamp: str
    is_urgent_referral: bool = False

class SyncBatchPayload(BaseModel):
    chw_id: str
    chps_zone: str
    assessments: List[AssessmentRecord]

# --- In-Memory Pilot Database (keyed by household_id) ---
# Values: dict of household state. Key = household_id.
DB_HOUSEHOLDS: dict[str, dict] = {
    "H-10041": {
        "id": "H-10041", "name": "Akua Serwaa", "chps_zone": "Bole CHPS Zone",
        "risk_tier": "URGENT",
        "reasons": ["MUAC 10.5cm — SAM", "Fast breathing (62/min) in young infant"],
        "overdue_days": 21, "last_visit": "2026-07-09", "updated_at": "2026-07-09T08:00:00",
    },
    "H-10042": {
        "id": "H-10042", "name": "Abena Gyamfi's Baby", "chps_zone": "Bole CHPS Zone",
        "risk_tier": "WATCH", "reasons": ["MUAC 12.0cm — MAM"],
        "overdue_days": 14, "last_visit": "2026-07-16", "updated_at": "2026-07-16T09:00:00",
    },
    "H-10043": {
        "id": "H-10043", "name": "Hajia Mariama", "chps_zone": "Bole CHPS Zone",
        "risk_tier": "WATCH", "reasons": ["Maternal Hb 8.4 g/dL — Moderate Anaemia"],
        "overdue_days": 28, "last_visit": "2026-07-02", "updated_at": "2026-07-02T10:00:00",
    },
    "H-10044": {
        "id": "H-10044", "name": "Kofi Mensah's Baby", "chps_zone": "Bole CHPS Zone",
        "risk_tier": "ROUTINE", "reasons": ["All parameters normal"],
        "overdue_days": 0, "last_visit": "2026-07-25", "updated_at": "2026-07-25T07:00:00",
    },
}

CONFLICT_LOG: list[dict] = []

# --- Tier priority for conflict resolution ---
TIER_PRIORITY = {"URGENT": 0, "WATCH": 1, "ROUTINE": 2}


@app.get("/")
def read_root():
    return {
        "status": "online",
        "system": "CareBridge AI Pilot Sync Server",
        "version": "1.0.0",
        "time": datetime.now().isoformat(),
    }


@app.post("/api/v1/sync")
def sync_offline_records(payload: SyncBatchPayload):
    """
    Point 6 — Sync Conflict Resolution Strategy:
    When two CHWs submit assessments for the same household_id around the same time,
    the server uses LAST-WRITE-WINS by timestamp, with one safety override: if one
    submission carries a higher clinical severity (URGENT > WATCH > ROUTINE), that
    severity is always preserved in the merged record regardless of which timestamp
    is later. A ROUTINE result from a later timestamp can never silently downgrade
    an URGENT result from an earlier one. Both records are appended to CONFLICT_LOG
    for supervisor review.
    """
    processed = 0
    conflicts_detected = []

    for item in payload.assessments:
        hid = item.household_id
        incoming_ts = item.timestamp
        incoming_tier = item.risk_tier.upper()

        if hid in DB_HOUSEHOLDS:
            existing = DB_HOUSEHOLDS[hid]
            existing_ts = existing.get("updated_at", "")
            existing_tier = existing.get("risk_tier", "ROUTINE").upper()

            # Detect concurrent write — timestamps within 60 seconds of each other
            try:
                existing_dt = datetime.fromisoformat(existing_ts)
                incoming_dt = datetime.fromisoformat(incoming_ts)
                delta_seconds = abs((incoming_dt - existing_dt).total_seconds())
                is_concurrent = delta_seconds < 60
            except Exception:
                is_concurrent = False

            # Resolve: preserve highest severity, then latest timestamp wins body
            incoming_priority = TIER_PRIORITY.get(incoming_tier, 2)
            existing_priority = TIER_PRIORITY.get(existing_tier, 2)

            if is_concurrent:
                conflict_record = {
                    "household_id": hid,
                    "conflict_detected_at": datetime.now().isoformat(),
                    "submission_a": {"chw": existing.get("last_chw", "unknown"), "tier": existing_tier, "ts": existing_ts},
                    "submission_b": {"chw": payload.chw_id, "tier": incoming_tier, "ts": incoming_ts},
                    "resolution": "highest_severity_preserved",
                }
                conflicts_detected.append(conflict_record)
                CONFLICT_LOG.append(conflict_record)

            # Severity safety: if existing record is URGENT, never downgrade to WATCH/ROUTINE
            resolved_tier = existing_tier if existing_priority < incoming_priority else incoming_tier

            DB_HOUSEHOLDS[hid] = {
                "id": hid,
                "name": item.patient_name,
                "chps_zone": item.chps_zone,
                "risk_tier": resolved_tier,
                "reasons": item.triggered_reasons,
                "overdue_days": 0,
                "last_visit": item.timestamp[:10],
                "updated_at": incoming_ts,
                "last_chw": payload.chw_id,
            }
        else:
            # New household not yet in DB
            DB_HOUSEHOLDS[hid] = {
                "id": hid,
                "name": item.patient_name,
                "chps_zone": item.chps_zone,
                "risk_tier": item.risk_tier,
                "reasons": item.triggered_reasons,
                "overdue_days": 0,
                "last_visit": item.timestamp[:10],
                "updated_at": item.timestamp,
                "last_chw": payload.chw_id,
            }
        processed += 1

    return {
        "status": "success",
        "processed_count": processed,
        "conflicts_detected": len(conflicts_detected),
        "conflict_resolution_strategy": "last_write_wins_with_severity_preservation",
        "message": f"Synced {processed} records. {len(conflicts_detected)} concurrent conflict(s) logged for supervisor review.",
    }


@app.get("/api/v1/households")
def get_households(tier: Optional[str] = None):
    all_households = list(DB_HOUSEHOLDS.values())
    if tier:
        filtered = [h for h in all_households if h["risk_tier"].upper() == tier.upper()]
        return {"count": len(filtered), "households": filtered}
    return {"count": len(all_households), "households": all_households}


@app.get("/api/v1/chw/metrics")
def get_supervisor_metrics():
    all_h = list(DB_HOUSEHOLDS.values())
    urgent = len([h for h in all_h if h["risk_tier"] == "URGENT"])
    watch = len([h for h in all_h if h["risk_tier"] == "WATCH"])
    routine = len([h for h in all_h if h["risk_tier"] == "ROUTINE"])
    return {
        "chps_zone": "Bole CHPS Zone",
        "total_households": len(all_h),
        "urgent_referrals": urgent,
        "watch_cases": watch,
        "routine_cases": routine,
        "pending_conflict_reviews": len(CONFLICT_LOG),
        "sync_health": "100% Operational",
    }


@app.get("/api/v1/conflicts")
def get_conflict_log():
    """Returns all detected concurrent write conflicts for supervisor review."""
    return {"count": len(CONFLICT_LOG), "conflicts": CONFLICT_LOG}


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
