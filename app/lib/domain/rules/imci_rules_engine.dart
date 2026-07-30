import '../models/clinical_models.dart';

/// Layer 1 Deterministic Rules Engine
/// Implements WHO IMCI & Ghana Health Service (GHS) Clinical Guidelines
/// Covers 26 clinical parameters across 7 domains with deterministic outputs.
class IMCIRulesEngine {
  static ClinicalRuleResult evaluate(AssessmentInput input) {
    final List<String> reasons = [];
    final List<String> codes = [];
    bool isUrgent = false;
    bool isWatch = false;

    // ──────────────────────────────────────────────────────────────────────────
    // DOMAIN A: CHILD MALNUTRITION (6–59 months)
    // ──────────────────────────────────────────────────────────────────────────
    if (input.bilateralOedema) {
      isUrgent = true;
      reasons.add('Bilateral pitting oedema (SAM with Oedema)');
      codes.add('SAM_OEDEMA');
    }

    if (input.muacCm != null) {
      if (input.muacCm! < 11.5) {
        isUrgent = true;
        reasons.add('Severe Acute Malnutrition (SAM): MUAC ${input.muacCm!.toStringAsFixed(1)} cm (< 11.5 cm)');
        codes.add('SAM_MUAC');
      } else if (input.muacCm! >= 11.5 && input.muacCm! < 12.5) {
        isWatch = true;
        reasons.add('Moderate Acute Malnutrition (MAM): MUAC ${input.muacCm!.toStringAsFixed(1)} cm (11.5 - 12.4 cm)');
        codes.add('MAM_MUAC');
      }
    }

    // ──────────────────────────────────────────────────────────────────────────
    // DOMAIN B: CHILD GENERAL DANGER SIGNS (Under 5s)
    // ──────────────────────────────────────────────────────────────────────────
    if (input.convulsions) {
      isUrgent = true;
      reasons.add('General Danger Sign: History of convulsions during this illness');
      codes.add('GDS_CONVULSIONS');
    }
    if (input.unableToDrinkBreastfeed) {
      isUrgent = true;
      reasons.add('General Danger Sign: Unable to drink or breastfeed');
      codes.add('GDS_UNABLE_FEED');
    }
    if (input.vomitsEverything) {
      isUrgent = true;
      reasons.add('General Danger Sign: Vomits everything');
      codes.add('GDS_VOMIT_ALL');
    }
    if (input.lethargicOrUnconscious) {
      isUrgent = true;
      reasons.add('General Danger Sign: Lethargic or unconscious');
      codes.add('GDS_LETHARGIC');
    }
    if (input.severePalmarPallor) {
      isUrgent = true;
      reasons.add('Severe Palmar Pallor (Severe Anaemia Risk)');
      codes.add('GDS_PALLOR');
    }
    if (input.stiffNeck) {
      isUrgent = true;
      reasons.add('Stiff Neck (Meningitis Signal)');
      codes.add('GDS_STIFF_NECK');
    }

    // ──────────────────────────────────────────────────────────────────────────
    // DOMAIN C: YOUNG INFANT DANGER SIGNS (Under 2 months)
    // ──────────────────────────────────────────────────────────────────────────
    if (input.isYoungInfant) {
      if (input.breathingRate >= 60) {
        isUrgent = true;
        reasons.add('Young Infant Fast Breathing: ${input.breathingRate} breaths/min (≥ 60/min)');
        codes.add('YI_FAST_BR');
      }
      if (input.severeChestIndrawing) {
        isUrgent = true;
        reasons.add('Young Infant: Severe chest indrawing');
        codes.add('YI_CHEST_INDRAWING');
      }
      if (input.noSpontaneousMovement) {
        isUrgent = true;
        reasons.add('Young Infant: No spontaneous movement');
        codes.add('YI_NO_MOVEMENT');
      }
      if (input.bodyTemp >= 37.5) {
        isWatch = true;
        reasons.add('Young Infant Fever: ${input.bodyTemp.toStringAsFixed(1)}°C (≥ 37.5°C)');
        codes.add('YI_FEVER');
      } else if (input.bodyTemp < 35.5) {
        isUrgent = true;
        reasons.add('Young Infant Hypothermia: ${input.bodyTemp.toStringAsFixed(1)}°C (< 35.5°C)');
        codes.add('YI_HYPOTHERMIA');
      }
      if (input.notFeedingWell) {
        isUrgent = true;
        reasons.add('Young Infant: Not feeding well');
        codes.add('YI_POOR_FEEDING');
      }
      if (input.infantConvulsionsHistory) {
        isUrgent = true;
        reasons.add('Young Infant: History of convulsions');
        codes.add('YI_CONVULSIONS');
      }
      if (input.jaundiceEarlyOrYellowPalms) {
        isUrgent = true;
        reasons.add('Young Infant: Severe Jaundice (Yellow palms/soles)');
        codes.add('YI_JAUNDICE');
      }
    }

    // ──────────────────────────────────────────────────────────────────────────
    // DOMAIN D: MATERNAL ANAEMIA & OBSTETRIC SCREENING
    // ──────────────────────────────────────────────────────────────────────────
    if (input.maternalHb != null) {
      if (input.maternalHb! < 7.0) {
        isUrgent = true;
        reasons.add('Maternal Severe Anaemia: Hb ${input.maternalHb!.toStringAsFixed(1)} g/dL (< 7.0 g/dL)');
        codes.add('MAT_SEVERE_ANAEMIA');
      } else if (input.maternalHb! >= 7.0 && input.maternalHb! < 11.0) {
        isWatch = true;
        reasons.add('Maternal Moderate Anaemia: Hb ${input.maternalHb!.toStringAsFixed(1)} g/dL (7.0 - 10.9 g/dL)');
        codes.add('MAT_MOD_ANAEMIA');
      }
    }

    if (input.conjunctivaPalmarPallorProxy && input.maternalHb == null) {
      isWatch = true;
      reasons.add('Maternal Anaemia Signal: Conjunctival or palmar pallor observed');
      codes.add('MAT_PALLOR_PROXY');
    }

    if (input.severeHeadacheVisualDisturbance && input.elevatedBPProxy) {
      isUrgent = true;
      reasons.add('GHS Obstetric Alert: Severe Headache + Elevated BP (Preeclampsia Risk)');
      codes.add('MAT_PREECLAMPSIA');
    }

    // ──────────────────────────────────────────────────────────────────────────
    // DOMAIN E: MATERNAL DANGER SIGNS & PPH
    // ──────────────────────────────────────────────────────────────────────────
    if (input.vaginalBleeding) {
      isUrgent = true;
      reasons.add('Maternal Obstetric Danger Sign: Antepartum Vaginal Bleeding');
      codes.add('MAT_BLEEDING');
    }
    if (input.maternalConvulsions) {
      isUrgent = true;
      reasons.add('Maternal Obstetric Danger Sign: Convulsions / Fits (Eclampsia)');
      codes.add('MAT_ECLAMPSIA');
    }
    if (input.severeHeadacheBlurredVision) {
      isUrgent = true;
      reasons.add('Maternal Danger Sign: Severe headache or blurred vision');
      codes.add('MAT_HEADACHE_VISION');
    }
    if (input.reducedAbsentFetalMovement) {
      isUrgent = true;
      reasons.add('Maternal Danger Sign: Reduced or absent fetal movement');
      codes.add('MAT_REDUCED_FETAL_MOV');
    }
    if (input.postpartumHeavyBleeding) {
      isUrgent = true;
      reasons.add('Postpartum Danger Sign: Heavy vaginal bleeding (PPH Risk)');
      codes.add('MAT_PPH_BLEEDING');
    }

    // ──────────────────────────────────────────────────────────────────────────
    // DOMAIN F: SYSTEM OVERDUE SIGNAL
    // ──────────────────────────────────────────────────────────────────────────
    if (input.weeksOverdue >= 3 && !isUrgent) {
      isWatch = true;
      reasons.add('Care Continuity Signal: Overdue for home visit by ${input.weeksOverdue} weeks');
      codes.add('SYS_OVERDUE_VISIT');
    }

    // ──────────────────────────────────────────────────────────────────────────
    // OVERALL TIER DETERMINATION
    // ──────────────────────────────────────────────────────────────────────────
    final RiskTier tier;
    final String recommendation;
    final String action;

    if (isUrgent) {
      tier = RiskTier.URGENT;
      recommendation = 'REFER IMMEDIATELY to District Hospital / Health Centre. Provide pre-referral treatment per GHS guidelines.';
      action = 'Urgent Referral Required';
    } else if (isWatch) {
      tier = RiskTier.WATCH;
      recommendation = 'Schedule follow-up visit within 3-5 days. Provide targeted nutrition & iron/folic acid guidance.';
      action = 'Close Follow-up Required';
    } else {
      tier = RiskTier.ROUTINE;
      reasons.add('All assessed clinical parameters within normal ranges per GHS/WHO IMCI guidelines.');
      codes.add('ROUTINE_NORMAL');
      recommendation = 'Continue routine CHPS home visits, monthly MUAC monitoring, and standard ANC/PNC care.';
      action = 'Routine Care';
    }

    return ClinicalRuleResult(
      overallTier: tier,
      reasons: reasons,
      ghsProtocolCodes: codes,
      primaryRecommendation: recommendation,
      actionSummary: action,
    );
  }
}
