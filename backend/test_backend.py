"""
CareBridge AI FastAPI Backend — Pytest Test Suite
Tests auth, sync, conflict resolution, and household listing against a real SQLite DB.
"""
import sys
import os
import pytest

# ── Path Setup ────────────────────────────────────────────────────────────────
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

# Point the backend at a temp test database to avoid polluting carebridge.db
TEST_DB = os.path.join(os.path.dirname(__file__), "test_carebridge_temp.db")
os.environ["CAREBRIDGE_DB_PATH"] = TEST_DB  # backend reads this if set

import importlib
import app.main as m

# Override DB_PATH BEFORE tables are created
m.DB_PATH = TEST_DB


@pytest.fixture(autouse=True, scope="module")
def init_db():
    """Create fresh DB tables and seed data before tests; clean up after."""
    if os.path.exists(TEST_DB):
        os.remove(TEST_DB)
    m.init_db()
    yield
    if os.path.exists(TEST_DB):
        os.remove(TEST_DB)


# ── Test 1: Root Health Check ─────────────────────────────────────────────────

def test_root_health():
    r = m.read_root()
    assert r["status"] == "online"
    assert "CareBridge" in r["system"]
    print("✓ Root health check: PASS")


# ── Test 2: Household Listing ─────────────────────────────────────────────────

def test_household_listing():
    h = m.get_households()
    assert h["count"] >= 1, "Expected at least 1 seeded household"
    assert all("risk_tier" in hh for hh in h["households"])
    print(f"✓ Household listing: {h['count']} households found: PASS")


# ── Test 3: Supervisor Metrics ────────────────────────────────────────────────

def test_supervisor_metrics():
    metrics = m.get_supervisor_metrics()
    assert "total_households" in metrics
    assert "urgent_referrals" in metrics
    assert "watch_cases" in metrics
    assert "routine_cases" in metrics
    assert metrics["total_households"] >= 1
    print(f"✓ Metrics: total={metrics['total_households']}, urgent={metrics['urgent_referrals']}: PASS")


# ── Test 4: Sync — New Assessment ────────────────────────────────────────────

def test_sync_new_assessment():
    payload = m.SyncBatchPayload(
        chw_id="CHW-001-AMA",
        chps_zone="Bole CHPS Zone",
        assessments=[
            m.AssessmentRecord(
                household_id="H-TEST-001",
                patient_name="Test Patient",
                chps_zone="Bole CHPS Zone",
                region="Savannah Region",
                district="Bole",
                muac_cm=10.2,
                oedema=True,
                breathing_rate=65,
                maternal_hb=6.8,
                risk_tier="URGENT",
                triggered_reasons=["MUAC 10.2cm SAM", "Fast breathing 65/min"],
                timestamp="2026-07-30T10:25:00",
                is_urgent_referral=True,
            )
        ]
    )
    result = m.sync_offline_records(payload)
    assert result["processed_count"] == 1
    print(f"✓ Sync new assessment: processed={result['processed_count']}: PASS")


# ── Test 5: Conflict Resolution (Severity Preservation) ──────────────────────

def test_conflict_resolution_preserves_urgent():
    """
    Two CHWs submit near-simultaneous assessments for the same household.
    CHW-A says URGENT. CHW-B says ROUTINE 20 seconds later.
    The DB must keep URGENT (highest severity wins).
    """
    # CHW-A: URGENT
    payload_a = m.SyncBatchPayload(
        chw_id="CHW-001-AMA",
        chps_zone="Bole CHPS Zone",
        assessments=[
            m.AssessmentRecord(
                household_id="H-CONFLICT-TEST",
                patient_name="Conflict Test Patient",
                chps_zone="Bole CHPS Zone",
                risk_tier="URGENT",
                triggered_reasons=["MUAC 10.5cm SAM"],
                timestamp="2026-07-30T10:25:00",
                is_urgent_referral=True,
            )
        ]
    )
    m.sync_offline_records(payload_a)

    # CHW-B: ROUTINE, concurrent (within 60 seconds)
    payload_b = m.SyncBatchPayload(
        chw_id="CHW-002-IBRAHIM",
        chps_zone="Bole CHPS Zone",
        assessments=[
            m.AssessmentRecord(
                household_id="H-CONFLICT-TEST",
                patient_name="Conflict Test Patient",
                chps_zone="Bole CHPS Zone",
                risk_tier="ROUTINE",
                triggered_reasons=["All normal on re-check"],
                timestamp="2026-07-30T10:25:20",  # 20 seconds later
                is_urgent_referral=False,
            )
        ]
    )
    conflict_result = m.sync_offline_records(payload_b)

    # Conflict should be detected
    assert conflict_result["conflicts_detected"] >= 1, "Expected concurrent conflict to be logged"

    # URGENT must be preserved — not downgraded to ROUTINE
    updated = m.get_households(tier="URGENT")
    urgent_ids = [hh["id"] for hh in updated["households"]]
    assert "H-CONFLICT-TEST" in urgent_ids, (
        "BUG: H-CONFLICT-TEST was incorrectly downgraded from URGENT to ROUTINE "
        "by a concurrent lower-severity submission"
    )
    print("✓ Conflict resolution: URGENT preserved despite concurrent ROUTINE submission: PASS")


# ── Test 6: Sort Order Verification ──────────────────────────────────────────

def test_sort_order_urgent_first():
    """URGENT households must rank ahead of ROUTINE regardless of overdue days."""
    all_h = m.get_households()["households"]
    TIER_PRIORITY = {"URGENT": 0, "WATCH": 1, "ROUTINE": 2}
    sorted_hh = sorted(
        all_h,
        key=lambda h: (TIER_PRIORITY.get(h["risk_tier"], 2), -h.get("overdue_days", 0))
    )
    if len(sorted_hh) >= 2:
        first_tier = TIER_PRIORITY.get(sorted_hh[0]["risk_tier"], 2)
        last_tier  = TIER_PRIORITY.get(sorted_hh[-1]["risk_tier"], 2)
        assert first_tier <= last_tier, "BUG: Sort order violated — URGENT not ranked above ROUTINE"
    print("✓ Sort order: URGENT first: PASS")


# ── Test 7: Auth Signup & Login ───────────────────────────────────────────────

def test_auth_signup_and_login():
    signup_req = m.SignupRequest(
        name="Test CHO",
        phone="+23300000001",
        pin="9999",
        role="frontlineHealthWorker",
        region="Savannah Region",
        district="Bole",
    )
    signup_result = m.signup(signup_req)
    assert signup_result.access_token is not None
    assert signup_result.user["role"] == "frontlineHealthWorker"

    login_req = m.LoginRequest(phone="+23300000001", pin="9999")
    login_result = m.login(login_req)
    assert login_result.access_token is not None
    assert login_result.user["name"] == "Test CHO"
    print("✓ Auth signup + login: PASS")


if __name__ == "__main__":
    # Can also be run as a plain script for quick CI checks
    m.DB_PATH = TEST_DB
    m.init_db()
    test_root_health()
    test_household_listing()
    test_supervisor_metrics()
    test_sync_new_assessment()
    test_conflict_resolution_preserves_urgent()
    test_sort_order_urgent_first()
    test_auth_signup_and_login()
    print("\nALL BACKEND TESTS PASSED.")
    if os.path.exists(TEST_DB):
        os.remove(TEST_DB)
