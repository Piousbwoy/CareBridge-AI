import 'package:flutter/foundation.dart';
import '../domain/models/clinical_models.dart';
import '../domain/algorithms/priority_scoring_engine.dart';
import 'local/database.dart';

enum SignInResult { success, noAccount, wrongPin }

/// Central dynamic repository for CareBridge AI.
/// Manages user profile session, live households, members, and real assessment records.
class MockRepository extends ChangeNotifier {
  static final MockRepository _instance = MockRepository._internal();
  factory MockRepository() => _instance;
  MockRepository._internal() {
    _loadFromLocalDatabase();
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

  // In-Memory Live State (seeded with initial real field data)
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
      ageMonths: 336,
      riskStatus: RiskTier.WATCH,
    ),
    MemberModel(
      id: 'M-2',
      householdId: 'H-10041',
      name: 'Kofi Serwaa',
      role: 'Husband',
      category: PersonCategory.other,
      ageMonths: 420,
      riskStatus: RiskTier.ROUTINE,
    ),
    MemberModel(
      id: 'M-3',
      householdId: 'H-10041',
      name: 'Ama Serwaa',
      role: 'Child (14 months)',
      category: PersonCategory.childUnder5,
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
      ageMonths: 288,
      riskStatus: RiskTier.ROUTINE,
    ),
    MemberModel(
      id: 'M-5',
      householdId: 'H-10042',
      name: 'Abena Gyamfi\'s Baby',
      role: 'Young Infant (9 weeks)',
      category: PersonCategory.newbornYoungInfant,
      ageMonths: 2,
      latestMuacCm: 12.0,
      riskStatus: RiskTier.WATCH,
    ),
    MemberModel(
      id: 'M-6',
      householdId: 'H-10043',
      name: 'Hajia Mariama',
      role: 'Teenage Pregnant Mother (17 yrs, 24 wks)',
      category: PersonCategory.mother,
      ageMonths: 204,
      riskStatus: RiskTier.WATCH,
      isTeenagePregnancy: true,
    ),
  ];

  // Historical MUAC trends per member
  final Map<String, List<double>> _muacHistoryMap = {
    'M-3': [12.2, 11.4, 10.5],
  };

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

  /// Update active user session credentials
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

    AppDatabase.saveUserProfile({
      'name': name,
      'role': role.name,
      'region': region,
      'district': district,
      'pinCode': pin,
      'phone': phone,
    });
    notifyListeners();
  }

  /// Normalise phone so +233241234567, 0241234567, +233 24 123 4567 all match
  static String _normalizePhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.startsWith('233')) return digits;
    if (digits.startsWith('0') && digits.length >= 9) return '233${digits.substring(1)}';
    return digits;
  }

  /// Validate phone+PIN credentials for sign-in
  SignInResult signIn({required String phone, required String pin}) {
    if (pinCode.isEmpty || userPhone.isEmpty) return SignInResult.noAccount;
    final incoming = _normalizePhone(phone);
    if (incoming != userPhone) return SignInResult.noAccount;
    if (pin != pinCode) return SignInResult.wrongPin;
    return SignInResult.success;
  }

  /// Add new household dynamically
  void addHousehold(HouseholdModel newHousehold) {
    households.add(newHousehold);
    notifyListeners();
  }

  /// Add new household member dynamically
  void addMember(MemberModel newMember) {
    members.add(newMember);

    // Update household member count
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
    }
    notifyListeners();
  }

  /// Record clinical assessment result — updates member status & household priority score live
  void recordAssessment({
    required String householdId,
    String? memberId,
    required RiskTier tier,
    double? muac,
    List<String> reasons = const [],
  }) {
    // 1. Update member if provided
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

    // 2. Update household record live
    final hIndex = households.indexWhere((h) => h.id == householdId);
    if (hIndex != -1) {
      final oldH = households[hIndex];
      final newScore = PriorityScoringEngine.calculatePriorityScore(
        riskTier: tier,
        daysOverdue: 0, // Reset overdue count since visit just completed today
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

    // 3. Persist to AppDatabase & sync queue
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

  List<double> getHistoricalMUAC(String memberId) {
    return _muacHistoryMap[memberId] ?? [13.0, 13.1, 13.0];
  }
}
