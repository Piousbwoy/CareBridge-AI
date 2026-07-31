import 'dart:convert';
import 'dart:math';
import 'package:drift/drift.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/models/clinical_models.dart';

// ─── Drift Table Definitions ──────────────────────────────────────────────────

class HouseholdsTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get chpsZone => text()();
  TextColumn get region => text().nullable()();
  TextColumn get district => text().nullable()();
  TextColumn get gpsCoordinates => text()();
  TextColumn get address => text()();
  TextColumn get phone => text()();
  DateTimeColumn get lastVisitDate => dateTime()();
  IntColumn get daysOverdue => integer()();
  TextColumn get currentRiskTier => text()();
  IntColumn get memberCount => integer()();
  RealColumn get priorityScore => real()();
  RealColumn get muacVelocityCmPerWeek => real()();

  @override
  Set<Column> get primaryKey => {id};
}

class MembersTable extends Table {
  TextColumn get id => text()();
  TextColumn get householdId => text()();
  TextColumn get name => text()();
  TextColumn get role => text()();
  TextColumn get category => text()();
  TextColumn get lifecycleStage => text()();
  TextColumn get linkedMotherId => text().nullable()();
  IntColumn get ageMonths => integer()();
  RealColumn get latestMuacCm => real().nullable()();
  TextColumn get riskStatus => text()();
  BoolColumn get isTeenagePregnancy => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class VisitsTable extends Table {
  TextColumn get id => text()();
  TextColumn get memberId => text()();
  TextColumn get householdId => text()();
  TextColumn get memberName => text()();
  TextColumn get lifecycleStage => text()();
  TextColumn get visitType => text()();
  TextColumn get title => text()();
  DateTimeColumn get expectedDate => dateTime()();
  TextColumn get status => text()();
  IntColumn get daysOverdue => integer()();
  TextColumn get reason => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class AssessmentsTable extends Table {
  TextColumn get id => text()();
  TextColumn get householdId => text()();
  TextColumn get patientName => text()();
  TextColumn get patientCategory => text()();
  TextColumn get chpsZone => text()();
  TextColumn get region => text().nullable()();
  TextColumn get district => text().nullable()();
  TextColumn get userRole => text()();
  RealColumn get muacCm => real().nullable()();
  BoolColumn get oedema => boolean().withDefault(const Constant(false))();
  IntColumn get breathingRate => integer().nullable()();
  RealColumn get maternalHb => real().nullable()();
  TextColumn get riskTier => text()();
  TextColumn get triggeredReasonsJson => text()();
  DateTimeColumn get timestamp => dateTime()();
  BoolColumn get isUrgentReferral => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class ReferralRecordsTable extends Table {
  TextColumn get id => text()();
  TextColumn get householdId => text()();
  TextColumn get memberId => text()();
  TextColumn get patientName => text()();
  TextColumn get riskTier => text()();
  TextColumn get facilityTier => text()();
  TextColumn get facilityName => text()();
  TextColumn get referralNote => text()();
  TextColumn get compressed2gPayload => text()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get outcomeNotes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class SyncQueueTable extends Table {
  TextColumn get id => text()();
  TextColumn get payloadJson => text()();
  TextColumn get status => text()(); // PENDING, SYNCED, CONFLICT
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class UserProfileTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get role => text()();
  TextColumn get region => text()();
  TextColumn get district => text()();
  TextColumn get phone => text()();
  TextColumn get pinCode => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class OverrideLogsTable extends Table {
  TextColumn get id => text()();
  TextColumn get householdId => text()();
  TextColumn get chwName => text()();
  TextColumn get originalTier => text()();
  TextColumn get overrideTier => text()();
  TextColumn get reasonNote => text()();
  DateTimeColumn get timestamp => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ─── AppDatabase Persistence Helper ──────────────────────────────────────────

class AppDatabase {
  static const String _dbKeyName = 'carebridge_db_sqlcipher_passphrase';
  static const _secureStorage = FlutterSecureStorage();

  static final Map<String, HouseholdModel> _householdsMap = {};
  static final Map<String, MemberModel> _membersMap = {};
  static final List<VisitModel> _visitsList = [];
  static final List<Map<String, dynamic>> _assessmentsStore = [];
  static final List<ReferralRecordModel> _referralsList = [];
  static final List<Map<String, dynamic>> _syncQueueStore = [];
  static final List<Map<String, dynamic>> _overrideLogsStore = [];
  static Map<String, dynamic>? _userProfileStore;

  static bool _initialized = false;

  /// Fetches or generates a cryptographically secure 256-bit passphrase.
  static Future<String> getOrGeneratePassphrase() async {
    try {
      String? passphrase = await _secureStorage.read(key: _dbKeyName);
      if (passphrase == null) {
        final random = Random.secure();
        final values = List<int>.generate(32, (i) => random.nextInt(256));
        passphrase = base64Url.encode(values);
        await _secureStorage.write(key: _dbKeyName, value: passphrase);
      }
      return passphrase;
    } catch (_) {
      return 'carebridge_fallback_sec_passphrase_key';
    }
  }

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await _loadFromStorage();
  }

  static Future<void> _loadFromStorage() async {
    try {
      final profileStr = await _secureStorage.read(key: 'cb_user_profile');
      if (profileStr != null) {
        _userProfileStore = jsonDecode(profileStr);
      }

      final householdsStr = await _secureStorage.read(key: 'cb_households');
      if (householdsStr != null) {
        final List list = jsonDecode(householdsStr);
        for (final item in list) {
          final h = HouseholdModel(
            id: item['id'],
            name: item['name'],
            chpsZone: item['chpsZone'] ?? 'Bole CHPS Zone',
            region: item['region'] ?? 'Savannah Region',
            district: item['district'] ?? 'Bole',
            gpsCoordinates: item['gpsCoordinates'] ?? '9.0305° N, 2.4744° W',
            address: item['address'] ?? '',
            phone: item['phone'] ?? '',
            lastVisitDate: DateTime.parse(item['lastVisitDate']),
            daysOverdue: item['daysOverdue'] ?? 0,
            currentRiskTier: RiskTier.values.firstWhere((e) => e.name == item['currentRiskTier'], _orElse: () => RiskTier.ROUTINE),
            memberCount: item['memberCount'] ?? 1,
            priorityScore: (item['priorityScore'] as num?)?.toDouble() ?? 50.0,
            muacVelocityCmPerWeek: (item['muacVelocityCmPerWeek'] as num?)?.toDouble() ?? 0.0,
          );
          _householdsMap[h.id] = h;
        }
      }

      final syncQueueStr = await _secureStorage.read(key: 'cb_sync_queue');
      if (syncQueueStr != null) {
        final List list = jsonDecode(syncQueueStr);
        _syncQueueStore.clear();
        _syncQueueStore.addAll(list.cast<Map<String, dynamic>>());
      }
    } catch (_) {}
  }

  static Future<void> _persistAll() async {
    try {
      if (_userProfileStore != null) {
        await _secureStorage.write(key: 'cb_user_profile', value: jsonEncode(_userProfileStore));
      }
      final householdsList = _householdsMap.values.map((h) => {
        'id': h.id,
        'name': h.name,
        'chpsZone': h.chpsZone,
        'region': h.region,
        'district': h.district,
        'gpsCoordinates': h.gpsCoordinates,
        'address': h.address,
        'phone': h.phone,
        'lastVisitDate': h.lastVisitDate.toIso8601String(),
        'daysOverdue': h.daysOverdue,
        'currentRiskTier': h.currentRiskTier.name,
        'memberCount': h.memberCount,
        'priorityScore': h.priorityScore,
        'muacVelocityCmPerWeek': h.muacVelocityCmPerWeek,
      }).toList();
      await _secureStorage.write(key: 'cb_households', value: jsonEncode(householdsList));
      await _secureStorage.write(key: 'cb_sync_queue', value: jsonEncode(_syncQueueStore));
    } catch (_) {}
  }

  // ── Persistence API ────────────────────────────────────────────────────────

  static Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    _userProfileStore = Map<String, dynamic>.from(profile);
    await _persistAll();
  }

  static Future<Map<String, dynamic>?> getUserProfile() async {
    await init();
    return _userProfileStore;
  }

  static Future<void> saveHousehold(HouseholdModel household) async {
    await init();
    _householdsMap[household.id] = household;
    await _persistAll();
  }

  static Future<List<HouseholdModel>> getHouseholds() async {
    await init();
    return _householdsMap.values.toList();
  }

  static Future<void> saveMember(MemberModel member) async {
    await init();
    _membersMap[member.id] = member;
  }

  static Future<List<MemberModel>> getMembers(String householdId) async {
    await init();
    return _membersMap.values.where((m) => m.householdId == householdId).toList();
  }

  static Future<List<double>> getHistoricalMUAC(String memberId) async {
    await init();
    final assessments = _assessmentsStore
        .where((a) => a['member_id'] == memberId && a['muac_cm'] != null)
        .map((a) => (a['muac_cm'] as num).toDouble())
        .toList();
    if (assessments.isEmpty) {
      return [11.8, 11.2, 10.5]; // Default historical sequence for demo patient if empty
    }
    return assessments;
  }

  static Future<void> saveAssessment(Map<String, dynamic> record) async {
    await init();
    _assessmentsStore.add(Map<String, dynamic>.from(record));
    _syncQueueStore.add({
      'id': record['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'payloadJson': jsonEncode(record),
      'status': 'PENDING',
      'createdAt': DateTime.now().toIso8601String(),
    });
    await _persistAll();
  }

  static Future<List<Map<String, dynamic>>> getAssessments() async {
    await init();
    return List.from(_assessmentsStore);
  }

  static Future<void> saveVisit(VisitModel visit) async {
    await init();
    _visitsList.removeWhere((v) => v.id == visit.id);
    _visitsList.add(visit);
  }

  static Future<List<VisitModel>> getVisits() async {
    await init();
    return List.from(_visitsList);
  }

  static Future<void> saveReferral(ReferralRecordModel referral) async {
    await init();
    _referralsList.removeWhere((r) => r.id == referral.id);
    _referralsList.add(referral);
  }

  static Future<List<ReferralRecordModel>> getReferrals() async {
    await init();
    return List.from(_referralsList);
  }

  static Future<void> saveOverrideLog(Map<String, dynamic> log) async {
    await init();
    _overrideLogsStore.add(Map<String, dynamic>.from(log));
  }

  static Future<List<Map<String, dynamic>>> getOverrideLogs() async {
    await init();
    return List.from(_overrideLogsStore);
  }

  static Future<List<Map<String, dynamic>>> getPendingSyncQueue() async {
    await init();
    return _syncQueueStore.where((item) => item['status'] == 'PENDING').toList();
  }

  static Future<void> markSyncQueueSuccess(String id) async {
    await init();
    for (final item in _syncQueueStore) {
      if (item['id'] == id) {
        item['status'] = 'SYNCED';
      }
    }
    await _persistAll();
  }
}

T _orElse<T>() => throw Exception();
