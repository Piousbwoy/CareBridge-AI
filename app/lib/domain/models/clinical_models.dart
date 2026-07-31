enum UserRole {
  districtOfficer,
  frontlineHealthWorker,
  caregiver,
}

enum PersonCategory {
  mother,
  newbornYoungInfant,
  childUnder5,
  other,
}

enum PregnancyStatus {
  currentlyPregnant,
  postpartum,
  neither,
}

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

  // D. Maternal Anaemia & Obstetric Screening
  final PregnancyStatus pregnancyStatus;
  final double? maternalHb; // g/dL
  final bool conjunctivaPalmarPallorProxy;
  final bool severeHeadacheVisualDisturbance; // Preeclampsia proxy
  final bool elevatedBPProxy; // Systolic >= 140 or Diastolic >= 90

  // E. Maternal Danger Signs
  final bool vaginalBleeding;
  final bool maternalConvulsions;
  final bool severeHeadacheBlurredVision;
  final bool reducedAbsentFetalMovement;
  final bool postpartumHeavyBleeding; // PPH warning sign

  // F. System Overdue Parameters
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
    this.breathingRate = 0,
    this.severeChestIndrawing = false,
    this.noSpontaneousMovement = false,
    this.bodyTemp = 36.8,
    this.notFeedingWell = false,
    this.infantConvulsionsHistory = false,
    this.jaundiceEarlyOrYellowPalms = false,
    this.pregnancyStatus = PregnancyStatus.neither,
    this.maternalHb,
    this.conjunctivaPalmarPallorProxy = false,
    this.severeHeadacheVisualDisturbance = false,
    this.elevatedBPProxy = false,
    this.vaginalBleeding = false,
    this.maternalConvulsions = false,
    this.severeHeadacheBlurredVision = false,
    this.reducedAbsentFetalMovement = false,
    this.postpartumHeavyBleeding = false,
    this.weeksOverdue = 0,
  });
}

class ClinicalRuleResult {
  final RiskTier overallTier;
  final List<String> reasons;
  final List<String> ghsProtocolCodes;
  final String primaryRecommendation;
  final String actionSummary;
  final DateTime evaluatedAt;

  List<dynamic> get triggeredRules => ghsProtocolCodes;

  ClinicalRuleResult({
    required this.overallTier,
    required this.reasons,
    List<String>? ghsProtocolCodes,
    List<dynamic>? triggeredRules,
    String? primaryRecommendation,
    String? actionSummary,
    String? timestamp,
    DateTime? evaluatedAt,
  })  : ghsProtocolCodes = ghsProtocolCodes ?? (triggeredRules != null ? triggeredRules.map((e) => e.toString()).toList() : []),
        primaryRecommendation = primaryRecommendation ?? 'Follow standard GHS CHPS clinical protocols.',
        actionSummary = actionSummary ?? 'Triage Complete',
        evaluatedAt = evaluatedAt ?? DateTime.now();
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
  final String? region;
  final String? district;
  final String gpsCoordinates;
  final String address;
  final String phone;
  final DateTime lastVisitDate;
  final int daysOverdue;
  final RiskTier currentRiskTier;
  final int memberCount;
  final double priorityScore;
  final double muacVelocityCmPerWeek;

  HouseholdModel({
    required this.id,
    required this.name,
    required this.chpsZone,
    this.region = 'Savannah Region',
    this.district = 'Bole',
    required this.gpsCoordinates,
    required this.address,
    required this.phone,
    required this.lastVisitDate,
    required this.daysOverdue,
    required this.currentRiskTier,
    required this.memberCount,
    this.priorityScore = 50.0,
    this.muacVelocityCmPerWeek = 0.0,
  });
}

class MemberModel {
  final String id;
  final String householdId;
  final String name;
  final String role; // Pregnant Mother, Husband, Child, Infant
  final PersonCategory category;
  final int ageMonths;
  final double? latestMuacCm;
  final RiskTier riskStatus;
  final bool isTeenagePregnancy;

  MemberModel({
    required this.id,
    required this.householdId,
    required this.name,
    required this.role,
    this.category = PersonCategory.childUnder5,
    required this.ageMonths,
    this.latestMuacCm,
    required this.riskStatus,
    this.isTeenagePregnancy = false,
  });
}

class UserProfileModel {
  final String id;
  final String name;
  final UserRole role;
  final String region;
  final String district;
  final String phone;

  UserProfileModel({
    required this.id,
    required this.name,
    required this.role,
    required this.region,
    required this.district,
    required this.phone,
  });
}
