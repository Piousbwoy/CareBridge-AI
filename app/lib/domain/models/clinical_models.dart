import 'package:flutter/foundation.dart';

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

enum LifecycleStage {
  womanReproductiveAge, // 15–49y, non-pregnant — preconception/anaemia, family planning
  pregnant,             // Tracked by trimester + EDD
  postpartum,           // First 6 weeks after delivery
  newborn,              // 0–2 months
  childUnder5,          // 2–59 months
}

enum PregnancyStatus {
  currentlyPregnant,
  postpartum,
  neither,
}

enum RiskTier { URGENT, WATCH, ROUTINE }

enum TrendDirection { WORSENING, STABLE, IMPROVING, INSUFFICIENT_DATA }

enum VisitStatus {
  upcoming,
  due,
  overdue,
  completed,
  missed,
}

enum ReferralStatus {
  pending,
  patient_reached_facility,
  patient_did_not_attend,
  returned_with_treatment_plan,
}

extension ReferralStatusExtension on ReferralStatus {
  String get displayName {
    switch (this) {
      case ReferralStatus.pending:
        return 'Pending Transfer / SMS Sent';
      case ReferralStatus.patient_reached_facility:
        return 'Patient Reached Facility';
      case ReferralStatus.patient_did_not_attend:
        return 'Patient Did Not Attend (Defaulted)';
      case ReferralStatus.returned_with_treatment_plan:
        return 'Returned with Treatment Plan';
    }
  }
}

class StageTransitionRecord {
  final LifecycleStage stage;
  final DateTime transitionDate;
  final String note;

  StageTransitionRecord({
    required this.stage,
    required this.transitionDate,
    required this.note,
  });
}

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
  final LifecycleStage lifecycleStage;
  final String? linkedMotherId;
  final DateTime? eddDate;
  final DateTime? deliveryDate;
  final DateTime? birthDate;
  final List<StageTransitionRecord> stageHistory;
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
    LifecycleStage? lifecycleStage,
    this.linkedMotherId,
    this.eddDate,
    this.deliveryDate,
    this.birthDate,
    List<StageTransitionRecord>? stageHistory,
    required this.ageMonths,
    this.latestMuacCm,
    required this.riskStatus,
    this.isTeenagePregnancy = false,
  })  : lifecycleStage = lifecycleStage ?? _inferLifecycleStage(category),
        stageHistory = stageHistory ?? [
          StageTransitionRecord(
            stage: lifecycleStage ?? _inferLifecycleStage(category),
            transitionDate: DateTime.now().subtract(Duration(days: ageMonths * 30)),
            note: 'Initial stage assignment on CHPS registration',
          ),
        ];

  static LifecycleStage _inferLifecycleStage(PersonCategory category) {
    switch (category) {
      case PersonCategory.mother:
        return LifecycleStage.pregnant;
      case PersonCategory.newbornYoungInfant:
        return LifecycleStage.newborn;
      case PersonCategory.childUnder5:
        return LifecycleStage.childUnder5;
      case PersonCategory.other:
      default:
        return LifecycleStage.womanReproductiveAge;
    }
  }
}

class ScheduledVisitModel {
  final String id;
  final String memberId;
  final String householdId;
  final String memberName;
  final String householdName;
  final LifecycleStage lifecycleStage;
  final String title;
  final String contactName;
  final DateTime dueDate;
  final VisitStatus status;
  final String reasonText;
  final bool isUnscheduled;
  final DateTime? completedDate;

  int get daysOverdue {
    if (status == VisitStatus.completed) return 0;
    final diff = DateTime.now().difference(dueDate).inDays;
    return diff > 0 ? diff : 0;
  }

  ScheduledVisitModel({
    required this.id,
    required this.memberId,
    required this.householdId,
    required this.memberName,
    required this.householdName,
    required this.lifecycleStage,
    required this.title,
    required this.contactName,
    required this.dueDate,
    required this.status,
    required this.reasonText,
    this.isUnscheduled = false,
    this.completedDate,
  });

  ScheduledVisitModel copyWith({
    VisitStatus? status,
    DateTime? completedDate,
  }) {
    return ScheduledVisitModel(
      id: id,
      memberId: memberId,
      householdId: householdId,
      memberName: memberName,
      householdName: householdName,
      lifecycleStage: lifecycleStage,
      title: title,
      contactName: contactName,
      dueDate: dueDate,
      status: status ?? this.status,
      reasonText: reasonText,
      isUnscheduled: isUnscheduled,
      completedDate: completedDate ?? this.completedDate,
    );
  }
}

class ReferralModel {
  final String id;
  final String householdId;
  final String memberId;
  final String patientName;
  final RiskTier riskTier;
  final String facilityName;
  final String facilityTier; // 'District Hospital', 'Health Centre / CHPS Clinic'
  final String referralNote;
  final List<String> dangerSigns;
  final ReferralStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReferralModel({
    required this.id,
    required this.householdId,
    required this.memberId,
    required this.patientName,
    required this.riskTier,
    required this.facilityName,
    required this.facilityTier,
    required this.referralNote,
    required this.dangerSigns,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  ReferralModel copyWith({
    ReferralStatus? status,
    DateTime? updatedAt,
  }) {
    return ReferralModel(
      id: id,
      householdId: householdId,
      memberId: memberId,
      patientName: patientName,
      riskTier: riskTier,
      facilityName: facilityName,
      facilityTier: facilityTier,
      referralNote: referralNote,
      dangerSigns: dangerSigns,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
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
