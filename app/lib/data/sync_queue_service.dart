import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'local/database.dart';

/// Manages the offline-first sync queue.
/// Items are appended to this queue when assessments are completed offline.
/// Auto-sync fires when connectivity is detected (via ConnectivityPlus listener in main.dart).
class SyncQueueService {
  static final SyncQueueService _instance = SyncQueueService._internal();
  factory SyncQueueService() => _instance;
  SyncQueueService._internal();

  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  static const String _syncEndpoint = 'https://carebridge-api.pilot.ngrok.io/api/v1/sync';

  int get pendingCount => _getPendingListSync().length;
  DateTime? get lastSyncTime => _lastSyncTime;
  bool get isSyncing => _isSyncing;

  List<Map<String, dynamic>> _getPendingListSync() {
    // Synchronous helper for UI counters
    return [];
  }

  Future<List<Map<String, dynamic>>> getPendingQueue() async {
    return await AppDatabase.getPendingSyncQueue();
  }

  /// Called after each completed assessment to queue the record locally
  Future<void> enqueueAssessment({
    required String householdId,
    required String patientName,
    required String chpsZone,
    required String riskTier,
    required List<String> reasons,
    double? muacCm,
    int breathingRate = 40,
    double? hbLevel,
    bool isUrgentReferral = false,
  }) async {
    final record = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'household_id': householdId,
      'patient_name': patientName,
      'chps_zone': chpsZone,
      'risk_tier': riskTier,
      'triggered_reasons': reasons,
      'muac_cm': muacCm,
      'breathing_rate': breathingRate,
      'maternal_hb': hbLevel,
      'is_urgent_referral': isUrgentReferral,
      'timestamp': DateTime.now().toIso8601String(),
      'status': 'PENDING',
    };
    await AppDatabase.saveAssessment(record);
    if (kDebugMode) {
      print('📥 Assessment persisted locally in database for sync: $householdId');
    }
  }

  /// Fires automatically when connectivity returns
  Future<bool> attemptAutoSync({String chwId = 'CHW-001', String chpsZone = 'Bole CHPS Zone'}) async {
    final pending = await AppDatabase.getPendingSyncQueue();
    if (pending.isEmpty || _isSyncing) return false;

    _isSyncing = true;
    if (kDebugMode) print('🔄 Auto-sync triggered: uploading ${pending.length} queued records...');

    try {
      final payload = {
        'chw_id': chwId,
        'chps_zone': chpsZone,
        'assessments': pending,
      };

      final response = await http.post(
        Uri.parse(_syncEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        for (final item in pending) {
          final id = item['id']?.toString() ?? '';
          if (id.isNotEmpty) {
            await AppDatabase.markSyncQueueSuccess(id);
          }
        }
        _lastSyncTime = DateTime.now();
        if (kDebugMode) print('✅ Sync complete: ${pending.length} records uploaded.');
        return true;
      } else {
        if (kDebugMode) print('⚠️ Sync failed with status ${response.statusCode}. Queue retained.');
        return false;
      }
    } catch (e) {
      if (kDebugMode) print('⚠️ Sync attempt failed (offline): $e. Records remain queued in DB.');
      return false;
    } finally {
      _isSyncing = false;
    }
  }
}

/// CHW Override Audit Log — backed by AppDatabase table.
class OverrideAuditLog {
  static final OverrideAuditLog _instance = OverrideAuditLog._internal();
  factory OverrideAuditLog() => _instance;
  OverrideAuditLog._internal();

  Future<List<Map<String, dynamic>>> get entries async => await AppDatabase.getOverrideLogs();

  /// Records a CHW override. All fields are required except note.
  Future<void> record({
    required String ruleId,
    required String overriddenBy,
    required String originalTier,
    required String newTier,
    String? note,
  }) async {
    final entry = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'ruleId': ruleId,
      'overriddenBy': overriddenBy,
      'timestamp': DateTime.now().toIso8601String(),
      'note': note,
      'originalTier': originalTier,
      'newTier': newTier,
    };
    await AppDatabase.saveOverrideLog(entry);
    if (kDebugMode) {
      print('📋 Override logged to DB: $ruleId | $overriddenBy | ${entry['timestamp']}');
    }
  }
}
