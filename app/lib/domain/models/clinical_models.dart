enum RiskTier { URGENT, WATCH, ROUTINE }

enum TrendDirection { WORSENING, STABLE, IMPROVING, INSUFFICIENT_DATA }

class AssessmentInput {
  // A. Child Malnutrition (6-59m)
  final double? muacCm;
  final bool bilateralOedema;

  // B. Child General Danger Signs (Under 5)
  final bool convulsions;
  final bool unableToDrinkBreastfeed;
  final bool vomitsEverything;
  final bool lethargicOrUnconscious;
  final bool severePalmarPallor;
  final bool stiffNeck;

  // C. Young Infant Danger Signs (Under 2m)
  final bool isYoungInfant;
  final int breathingRate; // breaths per minute
  final bool severeChestIndrawing;
  final bool noSpontaneousMovement;
  final double bodyTemp; // Celsius
  final bool notFeedingWell;
  final bool infantConvulsionsHistory;
  final bool jaundiceEarlyOrYellowPalms;

  // D. Maternal Anaemia
  final double? maternalHb; // g/dL
  final bool conjunctivaPalmarPallorProxy;

  // E. Maternal Danger Signs
  final bool vaginalBleeding;
  final bool maternalConvulsions;
  final bool severeHeadacheBlurredVision;
  final bool reducedAbsentFetalMovement;

  // F. Root-Cause System Signal
  final int weeksOverdue;

  AssessmentInput({
    this.muacCm,
    this.bilateralOedema = false,
    this.convulsions = false,
    this.unableToDrinkBreastfeed = false,
    this.vomitsEverything = false,
    this.lethargicOrUnconscious = false,
    this.severePalmarPallor = false,
    this.stiffNeck = false,
    this.isYoungInfant = false,
    this.breathingRate = 40,
    this.severeChestIndrawing = false,
    this.noSpontaneousMovement = false,
    this.bodyTemp = 36.8,
    this.notFeedingWell = false,
    this.infantConvulsionsHistory = false,
    this.jaundiceEarlyOrYellowPalms = false,
    this.maternalHb,
    this.conjunctivaPalmarPallorProxy = false,
    this.vaginalBleeding = false,
    this.maternalConvulsions = false,
    this.severeHeadacheBlurredVision = false,
    this.reducedAbsentFetalMovement = false,
    this.weeksOverdue = 0,
  });
}

class RuleMatch {
  final String ruleId;
  final String domain;
  final RiskTier tier;
  final String reasonTemplate;
  final String formattedReason;

  RuleMatch({
    required this.ruleId,
    required this.domain,
    required this.tier,
    required this.reasonTemplate,
    required this.formattedReason,
  });
}

class ClinicalRuleResult {
  final RiskTier overallTier;
  final List<RuleMatch> triggeredRules;
  final List<String> reasons;
  final String timestamp;

  ClinicalRuleResult({
    required this.overallTier,
    required this.triggeredRules,
    required this.reasons,
    required this.timestamp,
  });
}

class TrendResult {
  final TrendDirection direction;
  final double probability;
  final String summary;
  final bool isModelAvailable;
  final String advisoryDisclaimer;

  TrendResult({
    required this.direction,
    required this.probability,
    required this.summary,
    this.isModelAvailable = true,
    this.advisoryDisclaimer =
        'Advisory only. Does not change the tier flag above — that flag is set by the rules engine and cannot be lowered by this model.',
  });
}

class HouseholdModel {
  final String id;
  final String name;
  final String chpsZone;
  final String gpsCoordinates;
  final String address;
  final String phone;
  final DateTime lastVisitDate;
  final int daysOverdue;
  final RiskTier currentRiskTier;
  final int memberCount;

  HouseholdModel({
    required this.id,
    required this.name,
    required this.chpsZone,
    required this.gpsCoordinates,
    required this.address,
    required this.phone,
    required this.lastVisitDate,
    required this.daysOverdue,
    required this.currentRiskTier,
    required this.memberCount,
  });
}

class MemberModel {
  final String id;
  final String householdId;
  final String name;
  final String role; // Pregnant Mother, Husband, Child, Infant
  final int ageMonths;
  final double? latestMuacCm;
  final RiskTier riskStatus;

  MemberModel({
    required this.id,
    required this.householdId,
    required this.name,
    required this.role,
    required this.ageMonths,
    this.latestMuacCm,
    required this.riskStatus,
  });
}
