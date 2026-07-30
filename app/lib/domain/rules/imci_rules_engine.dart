import 'package:intl/intl.dart';
import '../models/clinical_models.dart';

class IMCIRulesEngine {
  static const String engineVersion = "2.1.0-WHO-IMCI-GHS";

  /// Evaluates an AssessmentInput against all 23 parameters across 6 domains.
  /// Guarantees that every triggered rule provides its own reason_template string.
  static ClinicalRuleResult evaluate(AssessmentInput input) {
    final List<RuleMatch> triggered = [];

    // --- DOMAIN A: CHILD MALNUTRITION (6-59 months) ---
    if (input.muacCm != null) {
      if (input.muacCm! < 11.5) {
        triggered.add(RuleMatch(
          ruleId: 'RULE_A1_SAM_MUAC',
          domain: 'Child Malnutrition',
          tier: RiskTier.URGENT,
          reasonTemplate: 'MUAC {muac} cm — Severe Acute Malnutrition (SAM)',
          formattedReason: 'MUAC ${input.muacCm!.toStringAsFixed(1)} cm — Severe Acute Malnutrition (SAM)',
        ));
      } else if (input.muacCm! >= 11.5 && input.muacCm! <= 12.5) {
        triggered.add(RuleMatch(
          ruleId: 'RULE_A2_MAM_MUAC',
          domain: 'Child Malnutrition',
          tier: RiskTier.WATCH,
          reasonTemplate: 'MUAC {muac} cm — Moderate Acute Malnutrition (MAM)',
          formattedReason: 'MUAC ${input.muacCm!.toStringAsFixed(1)} cm — Moderate Acute Malnutrition (MAM)',
        ));
      }
    }

    if (input.bilateralOedema) {
      triggered.add(RuleMatch(
        ruleId: 'RULE_A3_OEDEMA_SAM',
        domain: 'Child Malnutrition',
        tier: RiskTier.URGENT,
        reasonTemplate: 'Bilateral pitting oedema present — Severe Acute Malnutrition (SAM)',
        formattedReason: 'Bilateral pitting oedema present (3s thumb press) — SAM',
      ));
    }

    // --- DOMAIN B: CHILD GENERAL DANGER SIGNS (Under 5) ---
    if (input.convulsions) {
      triggered.add(RuleMatch(
        ruleId: 'RULE_B1_CONVULSIONS',
        domain: 'Child Danger Signs',
        tier: RiskTier.URGENT,
        reasonTemplate: 'History of convulsions during current illness',
        formattedReason: 'History of convulsions during current illness',
      ));
    }

    if (input.unableToDrinkBreastfeed) {
      triggered.add(RuleMatch(
        ruleId: 'RULE_B2_UNABLE_TO_FEED',
        domain: 'Child Danger Signs',
        tier: RiskTier.URGENT,
        reasonTemplate: 'Unable to drink or breastfeed',
        formattedReason: 'Unable to drink or breastfeed',
      ));
    }

    if (input.vomitsEverything) {
      triggered.add(RuleMatch(
        ruleId: 'RULE_B3_VOMITS_EVERYTHING',
        domain: 'Child Danger Signs',
        tier: RiskTier.URGENT,
        reasonTemplate: 'Vomits everything consumed',
        formattedReason: 'Vomits everything consumed',
      ));
    }

    if (input.lethargicOrUnconscious) {
      triggered.add(RuleMatch(
        ruleId: 'RULE_B4_LETHARGIC',
        domain: 'Child Danger Signs',
        tier: RiskTier.URGENT,
        reasonTemplate: 'Lethargic or unconscious state',
        formattedReason: 'Lethargic or unconscious state',
      ));
    }

    if (input.severePalmarPallor) {
      triggered.add(RuleMatch(
        ruleId: 'RULE_B5_SEVERE_PALMAR_PALLOR',
        domain: 'Child Danger Signs',
        tier: RiskTier.URGENT,
        reasonTemplate: 'Severe palmar pallor observed',
        formattedReason: 'Severe palmar pallor observed',
      ));
    }

    if (input.stiffNeck) {
      triggered.add(RuleMatch(
        ruleId: 'RULE_B6_STIFF_NECK',
        domain: 'Child Danger Signs',
        tier: RiskTier.URGENT,
        reasonTemplate: 'Stiff neck detected',
        formattedReason: 'Stiff neck detected',
      ));
    }

    // --- DOMAIN C: YOUNG INFANT DANGER SIGNS (Under 2 months) ---
    if (input.isYoungInfant) {
      if (input.breathingRate > 60) {
        triggered.add(RuleMatch(
          ruleId: 'RULE_C1_FAST_BREATHING',
          domain: 'Young Infant Danger Signs',
          tier: RiskTier.URGENT,
          reasonTemplate: 'Fast breathing ({rr}/min > 60/min) in young infant',
          formattedReason: 'Fast breathing (${input.breathingRate}/min > 60/min) in young infant',
        ));
      }

      if (input.severeChestIndrawing) {
        triggered.add(RuleMatch(
          ruleId: 'RULE_C2_CHEST_INDRAWING',
          domain: 'Young Infant Danger Signs',
          tier: RiskTier.URGENT,
          reasonTemplate: 'Severe chest in-drawing observed',
          formattedReason: 'Severe chest in-drawing observed',
        ));
      }

      if (input.noSpontaneousMovement) {
        triggered.add(RuleMatch(
          ruleId: 'RULE_C3_NO_MOVEMENT',
          domain: 'Young Infant Danger Signs',
          tier: RiskTier.URGENT,
          reasonTemplate: 'No spontaneous movement detected',
          formattedReason: 'No spontaneous movement detected',
        ));
      }

      if (input.bodyTemp >= 37.5) {
        triggered.add(RuleMatch(
          ruleId: 'RULE_C4_FEVER',
          domain: 'Young Infant Danger Signs',
          tier: RiskTier.URGENT,
          reasonTemplate: 'Fever ({temp}°C ≥ 37.5°C) in young infant',
          formattedReason: 'Fever (${input.bodyTemp.toStringAsFixed(1)}°C ≥ 37.5°C) in young infant',
        ));
      } else if (input.bodyTemp < 35.5) {
        triggered.add(RuleMatch(
          ruleId: 'RULE_C5_HYPOTHERMIA',
          domain: 'Young Infant Danger Signs',
          tier: RiskTier.URGENT,
          reasonTemplate: 'Low body temperature ({temp}°C < 35.5°C)',
          formattedReason: 'Low body temperature (${input.bodyTemp.toStringAsFixed(1)}°C < 35.5°C)',
        ));
      }

      if (input.notFeedingWell) {
        triggered.add(RuleMatch(
          ruleId: 'RULE_C6_NOT_FEEDING',
          domain: 'Young Infant Danger Signs',
          tier: RiskTier.URGENT,
          reasonTemplate: 'Not feeding well',
          formattedReason: 'Not feeding well',
        ));
      }

      if (input.infantConvulsionsHistory) {
        triggered.add(RuleMatch(
          ruleId: 'RULE_C7_INFANT_CONVULSIONS',
          domain: 'Young Infant Danger Signs',
          tier: RiskTier.URGENT,
          reasonTemplate: 'History of convulsions in young infant',
          formattedReason: 'History of convulsions in young infant',
        ));
      }

      if (input.jaundiceEarlyOrYellowPalms) {
        triggered.add(RuleMatch(
          ruleId: 'RULE_C8_JAUNDICE',
          domain: 'Young Infant Danger Signs',
          tier: RiskTier.URGENT,
          reasonTemplate: 'Jaundice within 24h or yellow palms/soles',
          formattedReason: 'Jaundice within 24 hours or yellow palms/soles',
        ));
      }
    }

    // --- DOMAIN D: MATERNAL ANAEMIA ---
    if (input.maternalHb != null) {
      if (input.maternalHb! < 7.0) {
        triggered.add(RuleMatch(
          ruleId: 'RULE_D1_SEVERE_ANAEMIA',
          domain: 'Maternal Health',
          tier: RiskTier.URGENT,
          reasonTemplate: 'Maternal Hb {hb} g/dL — Severe Anaemia',
          formattedReason: 'Maternal Hb ${input.maternalHb!.toStringAsFixed(1)} g/dL — Severe Anaemia',
        ));
      } else if (input.maternalHb! >= 7.0 && input.maternalHb! <= 10.0) {
        triggered.add(RuleMatch(
          ruleId: 'RULE_D2_MODERATE_ANAEMIA',
          domain: 'Maternal Health',
          tier: RiskTier.WATCH,
          reasonTemplate: 'Maternal Hb {hb} g/dL — Moderate Anaemia',
          formattedReason: 'Maternal Hb ${input.maternalHb!.toStringAsFixed(1)} g/dL — Moderate Anaemia',
        ));
      }
    } else if (input.conjunctivaPalmarPallorProxy) {
      triggered.add(RuleMatch(
        ruleId: 'RULE_D3_PALLOR_PROXY',
        domain: 'Maternal Health',
        tier: RiskTier.WATCH,
        reasonTemplate: 'Conjunctiva / Palmar Pallor observed (No Hb meter)',
        formattedReason: 'Conjunctiva / Palmar Pallor visual fallback proxy',
      ));
    }

    // --- DOMAIN E: MATERNAL DANGER SIGNS ---
    if (input.vaginalBleeding) {
      triggered.add(RuleMatch(
        ruleId: 'RULE_E1_VAGINAL_BLEEDING',
        domain: 'Maternal Danger Signs',
        tier: RiskTier.URGENT,
        reasonTemplate: 'Vaginal bleeding reported / observed',
        formattedReason: 'Vaginal bleeding reported / observed',
      ));
    }

    if (input.maternalConvulsions) {
      triggered.add(RuleMatch(
        ruleId: 'RULE_E2_MATERNAL_CONVULSIONS',
        domain: 'Maternal Danger Signs',
        tier: RiskTier.URGENT,
        reasonTemplate: 'Maternal convulsions reported / observed',
        formattedReason: 'Maternal convulsions reported / observed',
      ));
    }

    if (input.severeHeadacheBlurredVision) {
      triggered.add(RuleMatch(
        ruleId: 'RULE_E3_HEADACHE_VISION',
        domain: 'Maternal Danger Signs',
        tier: RiskTier.URGENT,
        reasonTemplate: 'Severe headache or blurred vision (Pre-eclampsia signal)',
        formattedReason: 'Severe headache or blurred vision',
      ));
    }

    if (input.reducedAbsentFetalMovement) {
      triggered.add(RuleMatch(
        ruleId: 'RULE_E4_FETAL_MOVEMENT',
        domain: 'Maternal Danger Signs',
        tier: RiskTier.URGENT,
        reasonTemplate: 'Reduced or absent fetal movement reported',
        formattedReason: 'Reduced or absent fetal movement',
      ));
    }

    // --- DOMAIN F: ROOT-CAUSE SYSTEM SIGNAL ---
    if (input.weeksOverdue >= 3) {
      triggered.add(RuleMatch(
        ruleId: 'RULE_F1_OVERDUE_VISIT',
        domain: 'System / Continuity',
        tier: RiskTier.WATCH,
        reasonTemplate: 'Household visit overdue by {weeks} weeks',
        formattedReason: 'Overdue visit: ${input.weeksOverdue} weeks since last contact',
      ));
    }

    // --- DETERMINE AUTHORITATIVE OVERALL TIER ---
    RiskTier overall = RiskTier.ROUTINE;
    if (triggered.any((r) => r.tier == RiskTier.URGENT)) {
      overall = RiskTier.URGENT;
    } else if (triggered.any((r) => r.tier == RiskTier.WATCH)) {
      overall = RiskTier.WATCH;
    }

    final reasonStrings = triggered.map((r) => r.formattedReason).toList();
    if (reasonStrings.isEmpty) {
      reasonStrings.add('All clinical parameters within normal ranges. Routine care schedule.');
    }

    return ClinicalRuleResult(
      overallTier: overall,
      triggeredRules: triggered,
      reasons: reasonStrings,
      timestamp: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
    );
  }
}
