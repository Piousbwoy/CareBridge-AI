import 'package:flutter/foundation.dart';
import '../domain/models/clinical_models.dart';
import '../domain/algorithms/priority_scoring_engine.dart';
import '../domain/services/care_schedule_engine.dart';
import 'local/database.dart';

enum SignInResult { success, noAccount, wrongPin }

/// Central dynamic repository for CareBridge AI.
/// Manages user profile session, live households, members, protocol schedules, and referrals.
class MockRepository extends ChangeNotifier {
  static final MockRepository _instance = MockRepository._internal();
  factory MockRepository() => _instance;
  MockRepository._internal() {
    _loadFromLocalDatabase();
    _initCareSchedules();
  }

  // User Profile Session
  String chwName = "";
  String chwRole = "Frontline Health Worker";
  UserRole userRole = UserRole.frontlineHealthWorker;
  String userRegion = "Savannah Region";
  String userDistrict = "Bole";
  String chwZone = "Bole CHPS Zone, Savannah Region";
  String pinCode = "";
  String userPhone = "";
  bool isDeviceConfigured = false;

  // Sync Queue State
  int pendingSyncCount = 3;
  DateTime lastSyncTime = DateTime.now().subtract(const Duration(hours: 4));

  // In-Memory Live State
  late final List<HouseholdModel> households = [
    HouseholdModel(
      id: 'H-10041',
      name: 'Akua Serwaa',
      chpsZone: 'Bole CHPS Zone',
      region: 'Savannah Region',
      district: 'Bole',
      gpsCoordinates: '9.0305° N, 2.4744° W',
      address: 'Kapaibe Compound 4, Bole',
      phone: '+233 24 123 4567',
      lastVisitDate: DateTime.now().subtract(const Duration(days: 21)),
      daysOverdue: 21,
      currentRiskTier: RiskTier.URGENT,
      memberCount: 3,
      priorityScore: PriorityScoringEngine.calculatePriorityScore(
        riskTier: RiskTier.URGENT,
        daysOverdue: 21,
        muacVelocityCmPerWeek: -0.6,
        isSevereAnaemia: true,
      ),
      muacVelocityCmPerWeek: -0.6,
    ),
    HouseholdModel(
      id: 'H-10042',
      name: 'Abena Gyamfi\'s Household',
      chpsZone: 'Bole CHPS Zone',
      region: 'Savannah Region',
      district: 'Bole',
      gpsCoordinates: '9.0320° N, 2.4750° W',
      address: 'Compound 14, Bole North',
      phone: '+233 50 987 6543',
      lastVisitDate: DateTime.now().subtract(const Duration(days: 14)),
      daysOverdue: 14,
      currentRiskTier: RiskTier.WATCH,
      memberCount: 2,
      priorityScore: PriorityScoringEngine.calculatePriorityScore(
        riskTier: RiskTier.WATCH,
        daysOverdue: 14,
        muacVelocityCmPerWeek: -0.3,
        isYoungInfant: true,
      ),
      muacVelocityCmPerWeek: -0.3,
    ),
    HouseholdModel(
      id: 'H-10043',
      name: 'Hajia Mariama',
      chpsZone: 'Sawla CHPS Zone',
      region: 'Savannah Region',
      district: 'Sawla-Tuna-Kalba',
      gpsCoordinates: '9.0280° N, 2.4710° W',
      address: 'Market Area Compound 3, Sawla',
      phone: '+233 27 555 1212',
      lastVisitDate: DateTime.now().subtract(const Duration(days: 35)),
      daysOverdue: 35,
      currentRiskTier: RiskTier.WATCH,
      memberCount: 4,
      priorityScore: PriorityScoringEngine.calculatePriorityScore(
        riskTier: RiskTier.WATCH,
        daysOverdue: 35,
        isTeenagePregnancy: true,
      ),
      muacVelocityCmPerWeek: 0.0,
    ),
    HouseholdModel(
      id: 'H-10044',
      name: 'Kofi Mensah\'s Household',
      chpsZone: 'Damongo CHPS Zone',
      region: 'Savannah Region',
      district: 'West Gonja Municipal',
      gpsCoordinates: '9.0350° N, 2.4780° W',
      address: 'Zongo Street Compound 12, Damongo',
      phone: '+233 20 111 2233',
      lastVisitDate: DateTime.now().subtract(const Duration(days: 7)),
      daysOverdue: 0,
      currentRiskTier: RiskTier.ROUTINE,
      memberCount: 5,
      priorityScore: PriorityScoringEngine.calculatePriorityScore(
        riskTier: RiskTier.ROUTINE,
        daysOverdue: 0,
      ),
      muacVelocityCmPerWeek: 0.2,
    ),
  ];

  late final List<MemberModel> members = [
    MemberModel(
      id: 'M-1',
      householdId: 'H-10041',
      name: 'Akua Serwaa',
      role: 'Pregnant Mother (32 wks)',
      category: PersonCategory.mother,
      lifecycleStage: LifecycleStage.pregnant,
      eddDate: DateTime.now().add(const Duration(days: 56)),
      ageMonths: 336,
      riskStatus: RiskTier.WATCH,
    ),
    MemberModel(
      id: 'M-2',
      householdId: 'H-10041',
      name: 'Kofi Serwaa',
      role: 'Husband',
      category: PersonCategory.other,
      lifecycleStage: LifecycleStage.womanReproductiveAge,
      ageMonths: 420,
      riskStatus: RiskTier.ROUTINE,
    ),
    MemberModel(
      id: 'M-3',
      householdId: 'H-10041',
      name: 'Ama Serwaa',
      role: 'Child (14 months)',
      category: PersonCategory.childUnder5,
      lifecycleStage: LifecycleStage.childUnder5,
      linkedMotherId: 'M-1',
      birthDate: DateTime.now().subtract(const Duration(days: 420)),
      ageMonths: 14,
      latestMuacCm: 10.5,
      riskStatus: RiskTier.URGENT,
    ),
    MemberModel(
      id: 'M-4',
      householdId: 'H-10042',
      name: 'Abena Gyamfi',
      role: 'Mother',
      category: PersonCategory.mother,
      lifecycleStage: LifecycleStage.postpartum,
      deliveryDate: DateTime.now().subtract(const Duration(days: 14)),
      ageMonths: 288,
      riskStatus: RiskTier.ROUTINE,
    ),
    MemberModel(
      id: 'M-5',
      householdId: 'H-10042',
      name: 'Abena Gyamfi\'s Baby',
      role: 'Young Infant (2 weeks)',
      category: PersonCategory.newbornYoungInfant,
      lifecycleStage: LifecycleStage.newborn,
      linkedMotherId: 'M-4',
      birthDate: DateTime.now().subtract(const Duration(days: 14)),
      ageMonths: 1,
      latestMuacCm: 12.0,
      riskStatus: RiskTier.WATCH,
    ),
    MemberModel(
      id: 'M-6',
      householdId: 'H-10043',
      name: 'Hajia Mariama',
      role: 'Teenage Pregnant Mother (17 yrs, 24 wks)',
      category: PersonCategory.mother,
      lifecycleStage: LifecycleStage.pregnant,
      eddDate: DateTime.now().add(const Duration(days: 112)),
      ageMonths: 204,
      riskStatus: RiskTier.WATCH,
      isTeenagePregnancy: true,
    ),
  ];

  final List<ScheduledVisitModel> scheduledVisits = [];
  final List<ReferralModel> referrals = [];

  // Historical MUAC trends per member
  final Map<String, List<double>> _muacHistoryMap = {
    'M-3': [12.2, 11.4, 10.5],
  };

  void _initCareSchedules() {
    scheduledVisits.clear();
    for (final member in members) {
      final h = households.firstWhere(
        (house) => house.id == member.householdId,
        orElse: () => households.first,
      );
      final list = CareScheduleEngine.generateScheduleForMember(member: member, household: h);
      scheduledVisits.addAll(list);
    }

    // Seed initial referral record for demo continuity
    referrals.add(ReferralModel(
      id: 'REF-10041',
      householdId: 'H-10041',
      memberId: 'M-3',
      patientName: 'Ama Serwaa',
      riskTier: RiskTier.URGENT,
      facilityName: 'Bole District Hospital',
      facilityTier: 'District Hospital',
      referralNote: 'URGENT: MUAC 10.5cm — Severe Acute Malnutrition (SAM) with fast breathing (62/min). Referred by CHW Ama Abena.',
      dangerSigns: ['MUAC 10.5cm — SAM', 'Fast breathing (62/min) in young infant'],
      status: ReferralStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ));
  }

  void _loadFromLocalDatabase() async {
    final profile = await AppDatabase.getUserProfile();
    if (profile != null) {
      chwName = profile['name'] ?? chwName;
      userRegion = profile['region'] ?? userRegion;
      userDistrict = profile['district'] ?? userDistrict;
      chwZone = '$userDistrict CHPS Zone, $userRegion';
      pinCode = profile['pinCode'] ?? pinCode;
      userPhone = _normalizePhone(profile['phone'] ?? '');
      isDeviceConfigured = pinCode.isNotEmpty && userPhone.isNotEmpty;
      if (profile['role'] != null) {
        userRole = UserRole.values.firstWhere(
          (r) => r.name == profile['role'],
          orElse: () => UserRole.frontlineHealthWorker,
        );
      }
      notifyListeners();
    }
  }

  // ── Dynamic Actions ──────────────────────────────────────────────────────────

  void setUserProfile({
    required String name,
    required UserRole role,
    required String region,
    required String district,
    required String pin,
    String phone = '',
  }) {
    chwName = name;
    userRole = role;
    userRegion = region;
    userDistrict = district;
    chwZone = '$district CHPS Zone, $region';
    pinCode = pin;
    userPhone = _normalizePhone(phone);
    isDeviceConfigured = true;

    final profileMap = {
      'name': name,
      'role': role.name,
      'region': region,
      'district': district,
      'pinCode': pin,
      'phone': phone,
    };

    AppDatabase.saveUserAccount(profileMap);
    AppDatabase.saveUserProfile(profileMap);
    notifyListeners();
  }

  static String _normalizePhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.startsWith('233')) return digits;
    if (digits.startsWith('0') && digits.length >= 9) return '233${digits.substring(1)}';
    return digits;
  }

  SignInResult signIn({required String phone, required String pin}) {
    final incoming = _normalizePhone(phone);

    // 1. Check local DB persistent user accounts store
    final storedAccount = AppDatabase.getUserAccountSync(incoming);
    if (storedAccount != null) {
      final savedPin = storedAccount['pinCode'] ?? '';
      if (pin != savedPin) return SignInResult.wrongPin;

      // Load matching account into active session
      setUserProfile(
        name: storedAccount['name'] ?? chwName,
        role: UserRole.values.firstWhere(
          (r) => r.name == storedAccount['role'],
          orElse: () => UserRole.frontlineHealthWorker,
        ),
        region: storedAccount['region'] ?? userRegion,
        district: storedAccount['district'] ?? userDistrict,
        pin: savedPin,
        phone: storedAccount['phone'] ?? phone,
      );
      return SignInResult.success;
    }

    // 2. Check current active session user
    if (userPhone.isNotEmpty && (incoming == userPhone || incoming.endsWith(userPhone))) {
      if (pin != pinCode) return SignInResult.wrongPin;
      return SignInResult.success;
    }

    // 3. Fallback demo account match (e.g. 0241234567 / +233241234567)
    if (incoming.contains('241234567') || incoming.contains('240000000')) {
      if (pin == '1234' || pin == pinCode || pin.isNotEmpty) {
        setUserProfile(
          name: chwName,
          role: userRole,
          region: userRegion,
          district: userDistrict,
          pin: pin,
          phone: phone,
        );
        return SignInResult.success;
      }
      return SignInResult.wrongPin;
    }

    return SignInResult.noAccount;
  }

  void addHousehold(HouseholdModel newHousehold) {
    households.add(newHousehold);
    notifyListeners();
  }

  void addMember(MemberModel newMember) {
    members.add(newMember);

    final hIndex = households.indexWhere((h) => h.id == newMember.householdId);
    if (hIndex != -1) {
      final oldH = households[hIndex];
      households[hIndex] = HouseholdModel(
        id: oldH.id,
        name: oldH.name,
        chpsZone: oldH.chpsZone,
        region: oldH.region,
        district: oldH.district,
        gpsCoordinates: oldH.gpsCoordinates,
        address: oldH.address,
        phone: oldH.phone,
        lastVisitDate: oldH.lastVisitDate,
        daysOverdue: oldH.daysOverdue,
        currentRiskTier: oldH.currentRiskTier,
        memberCount: oldH.memberCount + 1,
        priorityScore: oldH.priorityScore,
        muacVelocityCmPerWeek: oldH.muacVelocityCmPerWeek,
      );
      
      // Generate schedule for new member
      final newVisits = CareScheduleEngine.generateScheduleForMember(member: newMember, household: households[hIndex]);
      scheduledVisits.addAll(newVisits);
    }
    notifyListeners();
  }

  void completeScheduledVisit(String visitId) {
    final idx = scheduledVisits.indexWhere((v) => v.id == visitId);
    if (idx != -1) {
      scheduledVisits[idx] = scheduledVisits[idx].copyWith(
        status: VisitStatus.completed,
        completedDate: DateTime.now(),
      );
      notifyListeners();
    }
  }

  ScheduledVisitModel addUnscheduledVisit({
    required MemberModel member,
    required String dangerSignReason,
  }) {
    final h = households.firstWhere(
      (house) => house.id == member.householdId,
      orElse: () => households.first,
    );
    final visit = CareScheduleEngine.createUnscheduledVisit(
      member: member,
      household: h,
      reportedDangerSign: dangerSignReason,
    );
    scheduledVisits.insert(0, visit);
    notifyListeners();
    return visit;
  }

  ReferralModel createReferral({
    required String householdId,
    required String memberId,
    required String patientName,
    required RiskTier riskTier,
    required String facilityName,
    required String facilityTier,
    required String referralNote,
    required List<String> dangerSigns,
  }) {
    final ref = ReferralModel(
      id: 'REF-${DateTime.now().millisecondsSinceEpoch}',
      householdId: householdId,
      memberId: memberId,
      patientName: patientName,
      riskTier: riskTier,
      facilityName: facilityName,
      facilityTier: facilityTier,
      referralNote: referralNote,
      dangerSigns: dangerSigns,
      status: ReferralStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Remove old referral for same member if exists, replace with latest
    referrals.removeWhere((r) => r.memberId == memberId);
    referrals.insert(0, ref);
    notifyListeners();
    return ref;
  }

  void updateReferralStatus(String referralId, ReferralStatus newStatus) {
    final idx = referrals.indexWhere((r) => r.id == referralId);
    if (idx != -1) {
      referrals[idx] = referrals[idx].copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  void recordAssessment({
    required String householdId,
    String? memberId,
    required RiskTier tier,
    double? muac,
    List<String> reasons = const [],
    String? activeVisitId,
  }) {
    if (activeVisitId != null) {
      completeScheduledVisit(activeVisitId);
    } else if (memberId != null) {
      // Complete matching active visit for member if any
      final matchingIdx = scheduledVisits.indexWhere(
        (v) => v.memberId == memberId && (v.status == VisitStatus.due || v.status == VisitStatus.overdue),
      );
      if (matchingIdx != -1) {
        completeScheduledVisit(scheduledVisits[matchingIdx].id);
      }
    }

    if (memberId != null) {
      final mIndex = members.indexWhere((m) => m.id == memberId);
      if (mIndex != -1) {
        final oldM = members[mIndex];
        members[mIndex] = MemberModel(
          id: oldM.id,
          householdId: oldM.householdId,
          name: oldM.name,
          role: oldM.role,
          category: oldM.category,
          lifecycleStage: oldM.lifecycleStage,
          linkedMotherId: oldM.linkedMotherId,
          eddDate: oldM.eddDate,
          deliveryDate: oldM.deliveryDate,
          birthDate: oldM.birthDate,
          stageHistory: oldM.stageHistory,
          ageMonths: oldM.ageMonths,
          latestMuacCm: muac ?? oldM.latestMuacCm,
          riskStatus: tier,
          isTeenagePregnancy: oldM.isTeenagePregnancy,
        );

        if (muac != null) {
          _muacHistoryMap.putIfAbsent(memberId, () => []);
          _muacHistoryMap[memberId]!.add(muac);
        }
      }
    }

    final hIndex = households.indexWhere((h) => h.id == householdId);
    if (hIndex != -1) {
      final oldH = households[hIndex];
      final newScore = PriorityScoringEngine.calculatePriorityScore(
        riskTier: tier,
        daysOverdue: 0,
      );

      households[hIndex] = HouseholdModel(
        id: oldH.id,
        name: oldH.name,
        chpsZone: oldH.chpsZone,
        region: oldH.region,
        district: oldH.district,
        gpsCoordinates: oldH.gpsCoordinates,
        address: oldH.address,
        phone: oldH.phone,
        lastVisitDate: DateTime.now(),
        daysOverdue: 0,
        currentRiskTier: tier,
        memberCount: oldH.memberCount,
        priorityScore: newScore,
        muacVelocityCmPerWeek: oldH.muacVelocityCmPerWeek,
      );
    }

    AppDatabase.saveAssessment({
      'id': 'ASS-${DateTime.now().millisecondsSinceEpoch}',
      'householdId': householdId,
      'patientName': memberId ?? householdId,
      'patientCategory': 'ASSESSMENT',
      'chpsZone': chwZone,
      'region': userRegion,
      'district': userDistrict,
      'userRole': userRole.name,
      'muacCm': muac,
      'riskTier': tier.name,
      'triggeredReasonsJson': reasons.join(', '),
      'timestamp': DateTime.now().toIso8601String(),
    });

    pendingSyncCount++;
    lastSyncTime = DateTime.now();
    notifyListeners();
  }

  List<MemberModel> getMembersForHousehold(String householdId) {
    return members.where((m) => m.householdId == householdId).toList();
  }

  List<ScheduledVisitModel> getScheduledVisitsForHousehold(String householdId) {
    return scheduledVisits.where((v) => v.householdId == householdId).toList();
  }

  ReferralModel? getReferralForMember(String memberId) {
    try {
      return referrals.firstWhere((r) => r.memberId == memberId);
    } catch (_) {
      return null;
    }
  }

  List<double> getHistoricalMUAC(String memberId) {
    return _muacHistoryMap[memberId] ?? [13.0, 13.1, 13.0];
  }
}
