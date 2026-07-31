import 'dart:convert';
import 'dart:math';
import 'package:drift/drift.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
  TextColumn get category => text()(); // mother, newbornYoungInfant, childUnder5, other
  IntColumn get ageMonths => integer()();
  RealColumn get latestMuacCm => real().nullable()();
  TextColumn get riskStatus => text()();
  BoolColumn get isTeenagePregnancy => boolean().withDefault(const Constant(false))();

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
  TextColumn get role => text()(); // districtOfficer, frontlineHealthWorker, caregiver
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

  // In-memory fallback persistence stores for cross-platform preview
  static final List<Map<String, dynamic>> _householdsStore = [];
  static final List<Map<String, dynamic>> _membersStore = [];
  static final List<Map<String, dynamic>> _assessmentsStore = [];
  static final List<Map<String, dynamic>> _syncQueueStore = [];
  static final List<Map<String, dynamic>> _overrideLogsStore = [];
  static Map<String, dynamic>? _userProfileStore;

  /// Fetches or generates a cryptographically secure 256-bit passphrase stored in Android Keystore.
  static Future<String> getOrGeneratePassphrase() async {
    String? passphrase = await _secureStorage.read(key: _dbKeyName);
    if (passphrase == null) {
      final random = Random.secure();
      final values = List<int>.generate(32, (i) => random.nextInt(256));
      passphrase = base64Url.encode(values);
      await _secureStorage.write(key: _dbKeyName, value: passphrase);
    }
    return passphrase;
  }

  // ── Persistence API ────────────────────────────────────────────────────────

  static Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    _userProfileStore = Map<String, dynamic>.from(profile);
  }

  static Future<Map<String, dynamic>?> getUserProfile() async {
    return _userProfileStore;
  }

  static Future<void> saveAssessment(Map<String, dynamic> record) async {
    _assessmentsStore.add(Map<String, dynamic>.from(record));
    _syncQueueStore.add({
      'id': record['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'payloadJson': jsonEncode(record),
      'status': 'PENDING',
      'createdAt': DateTime.now().toIsoformatString(),
    });
  }

  static Future<List<Map<String, dynamic>>> getAssessments() async {
    return List.from(_assessmentsStore);
  }

  static Future<void> saveOverrideLog(Map<String, dynamic> log) async {
    _overrideLogsStore.add(Map<String, dynamic>.from(log));
  }

  static Future<List<Map<String, dynamic>>> getOverrideLogs() async {
    return List.from(_overrideLogsStore);
  }

  static Future<List<Map<String, dynamic>>> getPendingSyncQueue() async {
    return _syncQueueStore.where((item) => item['status'] == 'PENDING').toList();
  }
}

extension DateTimeIso on DateTime {
  String toIsoformatString() => toIso8601String();
}
