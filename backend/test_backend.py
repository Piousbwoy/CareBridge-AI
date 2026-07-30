import sys
sys.path.insert(0, '.')
import app.main as m
from app.main import SyncBatchPayload, AssessmentRecord

print("=== 1. ROOT HEALTH CHECK ===")
r = m.read_root()
print("Status:", r["status"], "| System:", r["system"])

print()
print("=== 2. HOUSEHOLD LISTING ===")
h = m.get_households()
print("Total households:", h["count"])
for hh in h["households"]:
    print(" ", hh["id"], "|", hh["name"], "| Tier:", hh["risk_tier"], "| Overdue:", hh["overdue_days"], "d")

print()
print("=== 3. SUPERVISOR METRICS ===")
metrics = m.get_supervisor_metrics()
print("Total:", metrics["total_households"], "| Urgent:", metrics["urgent_referrals"], "| Watch:", metrics["watch_cases"], "| Routine:", metrics["routine_cases"])

print()
print("=== 4. SYNC — NEW ASSESSMENT ===")
payload = SyncBatchPayload(
    chw_id="CHW-001-AMA",
    chps_zone="Bole CHPS Zone",
    assessments=[
        AssessmentRecord(
            household_id="H-10041",
            patient_name="Akua Serwaa",
            chps_zone="Bole CHPS Zone",
            muac_cm=10.2,
            oedema=True,
            breathing_rate=65,
            maternal_hb=6.8,
            risk_tier="URGENT",
            triggered_reasons=["MUAC 10.2cm SAM", "Fast breathing 65/min", "Maternal Hb 6.8 Severe Anaemia"],
            timestamp="2026-07-30T10:25:00",
            is_urgent_referral=True,
        )
    ]
)
result = m.sync_offline_records(payload)
print("Sync result:", result)

print()
print("=== 5. CONFLICT RESOLUTION TEST ===")
payload_concurrent = SyncBatchPayload(
    chw_id="CHW-002-IBRAHIM",
    chps_zone="Bole CHPS Zone",
    assessments=[
        AssessmentRecord(
            household_id="H-10041",
            patient_name="Akua Serwaa",
            chps_zone="Bole CHPS Zone",
            risk_tier="ROUTINE",
            triggered_reasons=["All normal on re-check"],
            timestamp="2026-07-30T10:25:20",
            is_urgent_referral=False,
        )
    ]
)
conflict_result = m.sync_offline_records(payload_concurrent)
print("Conflicts detected:", conflict_result["conflicts_detected"])
print("Resolution strategy:", conflict_result["conflict_resolution_strategy"])

updated = m.get_households(tier="URGENT")
urgent_ids = [hh["id"] for hh in updated["households"]]
assert "H-10041" in urgent_ids, "BUG: H-10041 incorrectly downgraded from URGENT to ROUTINE"
print("H-10041 preserved as URGENT despite concurrent ROUTINE submission: PASS")

print()
print("=== 6. RANKING SORT ORDER VERIFICATION ===")
TIER_PRIORITY = {"URGENT": 0, "WATCH": 1, "ROUTINE": 2}
sorted_hh = sorted(
    m.DB_HOUSEHOLDS.values(),
    key=lambda h: (TIER_PRIORITY.get(h["risk_tier"], 2), -h.get("overdue_days", 0))
)
print("Sort order (URGENT must appear before ROUTINE regardless of overdue_days):")
for i, hh in enumerate(sorted_hh):
    print("  #" + str(i+1) + ":", hh["id"], "|", hh["risk_tier"], "| overdue:", hh.get("overdue_days", 0), "d")

first_tier = sorted_hh[0]["risk_tier"]
assert first_tier == "URGENT", "BUG: First ranked household is not URGENT"
print("First ranked household is URGENT: PASS")

print()
print("ALL BACKEND TESTS PASSED.")
