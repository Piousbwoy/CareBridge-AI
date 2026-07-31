import '../models/clinical_models.dart';
import '../algorithms/priority_scoring_engine.dart';
import 'database.dart';

class DatabaseSeeder {
  static Future<void> seedIfEmpty() async {
    final existingProfile = await AppDatabase.getUserProfile();
    if (existingProfile != null) return; // Already seeded / configured

    // Seed default user profile
    await AppDatabase.saveUserProfile({
      'id': 'CHW-001',
      'name': 'Ama Abena',
      'role': 'frontlineHealthWorker',
      'region': 'Savannah Region',
      'district': 'Bole',
      'phone': '+233 24 123 4567',
      'pinCode': '1234',
    });

    // Seed initial households
    final initialHouseholds = [
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
        gpsCoordinates: '9.0800° N, 1.8100° W',
        address: 'Damongo Sector 2, West Gonja',
        phone: '+233 20 888 9900',
        lastVisitDate: DateTime.now().subtract(const Duration(days: 42)),
        daysOverdue: 42,
        currentRiskTier: RiskTier.ROUTINE,
        memberCount: 3,
        priorityScore: PriorityScoringEngine.calculatePriorityScore(
          riskTier: RiskTier.ROUTINE,
          daysOverdue: 42,
        ),
        muacVelocityCmPerWeek: 0.0,
      ),
    ];

    for (final h in initialHouseholds) {
      await AppDatabase.saveHousehold(h);
    }

    // Seed initial members
    final initialMembers = [
      MemberModel(
        id: 'M-101',
        householdId: 'H-10041',
        name: 'Akua Serwaa',
        role: 'Pregnant Mother',
        category: PersonCategory.mother,
        lifecycleStage: LifecycleStage.pregnant,
        ageMonths: 288,
        riskStatus: RiskTier.URGENT,
        isTeenagePregnancy: false,
      ),
      MemberModel(
        id: 'M-102',
        householdId: 'H-10041',
        name: 'Kofi Junior',
        role: 'Child (14m)',
        category: PersonCategory.childUnder5,
        lifecycleStage: LifecycleStage.childUnder5,
        linkedMotherId: 'M-101',
        ageMonths: 14,
        latestMuacCm: 10.5,
        riskStatus: RiskTier.URGENT,
      ),
      MemberModel(
        id: 'M-103',
        householdId: 'H-10042',
        name: 'Abena Gyamfi',
        role: 'Mother & Infant Pair',
        category: PersonCategory.mother,
        lifecycleStage: LifecycleStage.postpartum,
        ageMonths: 264,
        riskStatus: RiskTier.WATCH,
      ),
      MemberModel(
        id: 'M-104',
        householdId: 'H-10042',
        name: 'Baby Gyamfi',
        role: 'Young Infant (1m)',
        category: PersonCategory.newbornYoungInfant,
        lifecycleStage: LifecycleStage.newborn,
        linkedMotherId: 'M-103',
        ageMonths: 1,
        riskStatus: RiskTier.WATCH,
      ),
      MemberModel(
        id: 'M-105',
        householdId: 'H-10043',
        name: 'Hajia Mariama',
        role: 'Teenage Pregnant Mother',
        category: PersonCategory.mother,
        lifecycleStage: LifecycleStage.pregnant,
        ageMonths: 204, // 17 years old
        riskStatus: RiskTier.WATCH,
        isTeenagePregnancy: true,
      ),
    ];

    for (final m in initialMembers) {
      await AppDatabase.saveMember(m);
    }
  }
}
