import '../domain/models/clinical_models.dart';

class MockRepository {
  static final MockRepository _instance = MockRepository._internal();
  factory MockRepository() => _instance;
  MockRepository._internal();

  // CHW User Session
  String chwName = "Ama Akosua";
  String chwRole = "Community Health Officer (CHO)";
  String chwZone = "Bole CHPS Zone, Savannah Region";
  String pinCode = "1234";
  bool isDeviceConfigured = true;

  // Sync Queue State
  int pendingSyncCount = 3;
  DateTime lastSyncTime = DateTime.now().subtract(const Duration(hours: 4));

  // Seeded Households in Bole CHPS Zone
  final List<HouseholdModel> households = [
    HouseholdModel(
      id: 'H-10041',
      name: 'Akua Serwaa',
      chpsZone: 'Bole CHPS Zone',
      gpsCoordinates: '9.0305° N, 2.4744° W',
      address: 'Kapaibe, Bole District',
      phone: '+233 24 123 4567',
      lastVisitDate: DateTime.now().subtract(const Duration(days: 21)),
      daysOverdue: 21,
      currentRiskTier: RiskTier.URGENT,
      memberCount: 3,
    ),
    HouseholdModel(
      id: 'H-10042',
      name: 'Abena Gyamfi\'s Baby',
      chpsZone: 'Bole CHPS Zone',
      gpsCoordinates: '9.0320° N, 2.4750° W',
      address: 'Compound 14, Bole North',
      phone: '+233 50 987 6543',
      lastVisitDate: DateTime.now().subtract(const Duration(days: 14)),
      daysOverdue: 14,
      currentRiskTier: RiskTier.WATCH,
      memberCount: 2,
    ),
    HouseholdModel(
      id: 'H-10043',
      name: 'Hajia Mariama',
      chpsZone: 'Bole CHPS Zone',
      gpsCoordinates: '9.0280° N, 2.4710° W',
      address: 'Market Area Compound 3',
      phone: '+233 27 555 1234',
      lastVisitDate: DateTime.now().subtract(const Duration(days: 28)),
      daysOverdue: 28,
      currentRiskTier: RiskTier.WATCH,
      memberCount: 4,
    ),
    HouseholdModel(
      id: 'H-10044',
      name: 'Kofi Mensah\'s Baby',
      chpsZone: 'Bole CHPS Zone',
      gpsCoordinates: '9.0350° N, 2.4790° W',
      address: 'West Sector, Bole',
      phone: '+233 24 888 9900',
      lastVisitDate: DateTime.now().subtract(const Duration(days: 5)),
      daysOverdue: 0,
      currentRiskTier: RiskTier.ROUTINE,
      memberCount: 3,
    ),
    HouseholdModel(
      id: 'H-10045',
      name: 'Fatima Zohra',
      chpsZone: 'Bole CHPS Zone',
      gpsCoordinates: '9.0312° N, 2.4730° W',
      address: 'Zongo Quarter Compound 8',
      phone: '+233 54 321 8765',
      lastVisitDate: DateTime.now().subtract(const Duration(days: 35)),
      daysOverdue: 35,
      currentRiskTier: RiskTier.URGENT,
      memberCount: 5,
    ),
  ];

  // Seeded Household Members
  final List<MemberModel> members = [
    MemberModel(
      id: 'M-1',
      householdId: 'H-10041',
      name: 'Akua Serwaa',
      role: 'Pregnant Mother (32 wks)',
      ageMonths: 336,
      riskStatus: RiskTier.WATCH,
    ),
    MemberModel(
      id: 'M-2',
      householdId: 'H-10041',
      name: 'Kofi Serwaa',
      role: 'Husband',
      ageMonths: 420,
      riskStatus: RiskTier.ROUTINE,
    ),
    MemberModel(
      id: 'M-3',
      householdId: 'H-10041',
      name: 'Ama Serwaa',
      role: 'Child (14 months)',
      ageMonths: 14,
      latestMuacCm: 10.5,
      riskStatus: RiskTier.URGENT,
    ),
    MemberModel(
      id: 'M-4',
      householdId: 'H-10042',
      name: 'Abena Gyamfi',
      role: 'Mother',
      ageMonths: 288,
      riskStatus: RiskTier.ROUTINE,
    ),
    MemberModel(
      id: 'M-5',
      householdId: 'H-10042',
      name: 'Abena Gyamfi\'s Baby',
      role: 'Infant (9 months)',
      ageMonths: 9,
      latestMuacCm: 12.0,
      riskStatus: RiskTier.WATCH,
    ),
  ];

  // Historical MUAC trends for TFLite classifier test (H-10041 child)
  List<double> getHistoricalMUAC(String memberId) {
    if (memberId == 'M-3') {
      // Worsening trajectory: 12.2 -> 11.4 -> 10.5
      return [12.2, 11.4, 10.5];
    }
    return [13.0, 13.1, 13.0];
  }
}
