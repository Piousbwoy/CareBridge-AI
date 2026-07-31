#!/usr/bin/env python3
"""
seed_demo_data.py
─────────────────
Standalone script to populate CareBridge AI's SQLite database
with realistic Northern Ghana pilot households for live demonstrations.

Usage:
    python seed_demo_data.py               # adds demo rows (skips existing)
    python seed_demo_data.py --reset       # wipes households & re-seeds cleanly

Run from the backend/ directory (or adjust DB_PATH below).
"""

import argparse
import hashlib
import json
import os
import sqlite3

DB_PATH = os.path.join(os.path.dirname(__file__), "app", "carebridge.db")

DEMO_HOUSEHOLDS = [
    # (id, name, category, chps_zone, region, district, risk_tier, reasons, overdue_days, last_visit, updated_at, last_chw)
    ("H-10041", "Akua Serwaa",        "child",   "Bole CHPS Zone",    "Savannah Region", "Bole",
     "URGENT",  ["MUAC 10.5cm — Severe Acute Malnutrition (SAM)", "Fast breathing 62/min in young infant"],
     21, "2026-07-09", "2026-07-09T08:00:00", "Ama Abena"),

    ("H-10042", "Abena Gyamfi's Baby", "newborn", "Bole CHPS Zone",   "Savannah Region", "Bole",
     "WATCH",   ["MUAC 12.0cm — Moderate Acute Malnutrition (MAM)"],
     14, "2026-07-16", "2026-07-16T09:00:00", "Ama Abena"),

    ("H-10043", "Hajia Mariama",       "mother",  "Bole CHPS Zone",   "Savannah Region", "Bole",
     "WATCH",   ["Maternal Hb 8.4 g/dL — Moderate Anaemia", "Pallor proxy positive"],
     28, "2026-07-02", "2026-07-02T10:00:00", "Ama Abena"),

    ("H-10044", "Kofi Mensah's Baby",  "child",   "Bole CHPS Zone",   "Savannah Region", "Bole",
     "ROUTINE", ["All clinical parameters within normal range"],
     0,  "2026-07-25", "2026-07-25T07:00:00", "Ama Abena"),

    ("H-10045", "Fatima Zohra",        "mother",  "Damongo CHPS Zone","Savannah Region", "West Gonja Municipal",
     "URGENT",  ["Vaginal bleeding reported", "Overdue 35 days — no CHO contact"],
     35, "2026-07-10", "2026-07-10T08:15:00", "Ibrahim Fuseini"),

    ("H-10046", "Yaa Asantewaa",       "mother",  "Bole CHPS Zone",   "Savannah Region", "Bole",
     "URGENT",  ["Severe headache & blurred vision — pre-eclampsia suspected", "Currently 36 weeks pregnant"],
     12, "2026-07-19", "2026-07-19T11:00:00", "Ama Abena"),

    ("H-10047", "Baby Seidu",          "newborn", "Tamale CHPS Zone", "Northern Region", "Tamale Metro",
     "URGENT",  ["Jaundice — yellow palms (Day 2)", "Temperature 38.1°C — neonatal sepsis risk"],
     7,  "2026-07-24", "2026-07-24T06:30:00", "Fatima Andani"),

    ("H-10048", "Ramatu Issah",        "child",   "Savelugu CHPS Zone","Northern Region","Savelugu",
     "WATCH",   ["MUAC 11.5cm — borderline MAM", "Cough > 21 days"],
     10, "2026-07-21", "2026-07-21T09:45:00", "Fatima Andani"),

    ("H-10049", "Adiza Mohammed",      "mother",  "Bole CHPS Zone",   "Savannah Region", "Bole",
     "ROUTINE", ["Hb 10.8 g/dL — mild anaemia, routine iron supplementation"],
     2,  "2026-07-29", "2026-07-29T14:00:00", "Ama Abena"),

    ("H-10050", "Asibi Yakubu's Baby", "child",   "Damongo CHPS Zone","Savannah Region", "West Gonja Municipal",
     "ROUTINE", ["All indicators normal. Growth on track."],
     0,  "2026-07-30", "2026-07-30T08:00:00", "Ibrahim Fuseini"),
]

DEMO_USERS = [
    # (phone, id, name, role, region, district, pin)
    ("+233241234567", "USR-101", "Ama Abena",        "frontlineHealthWorker", "Savannah Region", "Bole",          "1234"),
    ("+233509876543", "USR-102", "Dr. Ibrahim Fuseini", "districtOfficer",    "Savannah Region", "Bole",          "1234"),
    ("+233201112222", "USR-103", "Fatima Andani",     "frontlineHealthWorker","Northern Region", "Tamale Metro",  "1234"),
]


def hash_pin(pin: str) -> tuple[str, str]:
    salt = bytes.fromhex("11223344556677889900aabbccddeeff")
    hashed = hashlib.pbkdf2_hmac("sha256", pin.encode(), salt, 100000)
    return hashed.hex(), salt.hex()


def seed(reset: bool = False):
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    cur = conn.cursor()

    # Ensure tables exist (in case init_db hasn't run yet)
    cur.executescript("""
        CREATE TABLE IF NOT EXISTS users (
            phone TEXT PRIMARY KEY, id TEXT NOT NULL, name TEXT NOT NULL,
            hashed_pin TEXT NOT NULL, salt TEXT NOT NULL,
            role TEXT NOT NULL, region TEXT NOT NULL, district TEXT NOT NULL
        );
        CREATE TABLE IF NOT EXISTS households (
            id TEXT PRIMARY KEY, name TEXT NOT NULL, patient_category TEXT DEFAULT 'child',
            chps_zone TEXT NOT NULL, region TEXT DEFAULT 'Savannah Region',
            district TEXT DEFAULT 'Bole', risk_tier TEXT DEFAULT 'ROUTINE',
            reasons TEXT DEFAULT '[]', overdue_days INTEGER DEFAULT 0,
            last_visit TEXT, updated_at TEXT, last_chw TEXT
        );
        CREATE TABLE IF NOT EXISTS conflict_log (
            id INTEGER PRIMARY KEY AUTOINCREMENT, household_id TEXT NOT NULL,
            conflict_detected_at TEXT NOT NULL, submission_a TEXT NOT NULL,
            submission_b TEXT NOT NULL, resolution TEXT NOT NULL
        );
    """)

    if reset:
        cur.execute("DELETE FROM households")
        cur.execute("DELETE FROM conflict_log")
        print("🗑️  Wiped existing households and conflict log.")

    # Insert users (skip existing)
    for phone, uid, name, role, region, district, pin in DEMO_USERS:
        existing = cur.execute("SELECT id FROM users WHERE phone=?", (phone,)).fetchone()
        if existing:
            print(f"  ↳ User {phone} already exists — skipped.")
            continue
        h, s = hash_pin(pin)
        cur.execute("INSERT INTO users VALUES (?,?,?,?,?,?,?,?)",
                    (phone, uid, name, h, s, role, region, district))
        print(f"  ✅ Added user: {name} ({role})")

    # Insert households
    for row in DEMO_HOUSEHOLDS:
        hid = row[0]
        existing = cur.execute("SELECT id FROM households WHERE id=?", (hid,)).fetchone()
        if existing and not reset:
            print(f"  ↳ Household {hid} already exists — skipped.")
            continue
        cur.execute(
            "INSERT OR REPLACE INTO households VALUES (?,?,?,?,?,?,?,?,?,?,?,?)",
            (*row[:7], json.dumps(row[7]), *row[8:]),
        )
        print(f"  ✅ Seeded household: {row[0]} — {row[1]} [{row[6]}]")

    conn.commit()
    conn.close()
    print(f"\n✨ Done. Database: {DB_PATH}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Seed CareBridge AI demo data")
    parser.add_argument("--reset", action="store_true", help="Wipe existing households before seeding")
    args = parser.parse_args()
    seed(reset=args.reset)
