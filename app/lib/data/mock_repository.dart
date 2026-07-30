import '../domain/models/clinical_models.dart';
import '../domain/algorithms/priority_scoring_engine.dart';

class MockRepository {
  static final MockRepository _instance = MockRepository._internal();
  factory MockRepository() => _instance;
  MockRepository._internal();

  // CHW User Session
  String chwName = "Ama Abena";
  String chwRole = "Community Health Officer (CHO)";
  String chwZone = "Bole CHPS Zone, Savannah Region";
  String pinCode = "1234";
  bool isDeviceConfigured = true;

  // Sync Queue State
  int pendingSyncCount = 3;
  DateTime lastSyncTime = DateTime.now().subtract(const Duration(hours: 4));

  // Seeded Rural Households in Bole & Sawla CHPS Zones
  late final List<HouseholdModel> households = [
    HouseholdModel(
      id: 'H-10041',
      name: 'Akua Serwaa',
      chpsZone: 'Bole CHPS Zone',
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

  // Seeded Household Members
  late final List<MemberModel> members = [
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
      role: 'Young Infant (9 weeks)',
      ageMonths: 2,
      latestMuacCm: 12.0,
      riskStatus: RiskTier.WATCH,
    ),
    MemberModel(
      id: 'M-6',
      householdId: 'H-10043',
      name: 'Hajia Mariama',
      role: 'Teenage Pregnant Mother (17 yrs, 24 wks)',
      ageMonths: 204,
      riskStatus: RiskTier.WATCH,
      isTeenagePregnancy: true,
    ),
  ];

  // Historical MUAC trends for velocity calculations
  List<double> getHistoricalMUAC(String memberId) {
    if (memberId == 'M-3') {
      // Rapid drop: 12.2 -> 11.4 -> 10.5 cm
      return [12.2, 11.4, 10.5];
    }
    return [13.0, 13.1, 13.0];
  }
}
