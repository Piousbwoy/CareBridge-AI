import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Manages the offline-first sync queue.
/// Items are appended to this queue when assessments are completed offline.
/// Auto-sync fires when connectivity is detected (via ConnectivityPlus listener in main.dart).
class SyncQueueService {
  static final SyncQueueService _instance = SyncQueueService._internal();
  factory SyncQueueService() => _instance;
  SyncQueueService._internal();

  final List<Map<String, dynamic>> _pendingQueue = [];
  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  // Point 9: Referral items enqueued locally while offline — no network required
  static const String _syncEndpoint = 'https://carebridge-api.pilot.ngrok.io/api/v1/sync';

  int get pendingCount => _pendingQueue.length;
  DateTime? get lastSyncTime => _lastSyncTime;
  bool get isSyncing => _isSyncing;

  /// Called after each completed assessment to queue the record locally
  void enqueueAssessment({
    required String householdId,
    required String patientName,
    required String chpsZone,
    required String riskTier,
    required List<String> reasons,
    double? muacCm,
    int breathingRate = 40,
    double? hbLevel,
    bool isUrgentReferral = false,
  }) {
    final record = {
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
      'synced': false,
    };
    _pendingQueue.add(record);
    if (kDebugMode) {
      print('📥 Assessment queued locally for sync: $householdId (${_pendingQueue.length} total pending)');
    }
  }

  /// Point 9: Fires automatically when connectivity returns — called by ConnectivityPlus stream listener
  Future<void> attemptAutoSync({String chwId = 'CHW-001', String chpsZone = 'Bole CHPS Zone'}) async {
    if (_pendingQueue.isEmpty || _isSyncing) return;

    _isSyncing = true;
    if (kDebugMode) print('🔄 Auto-sync triggered: uploading ${_pendingQueue.length} queued records...');

    try {
      final payload = {
        'chw_id': chwId,
        'chps_zone': chpsZone,
        'assessments': _pendingQueue,
      };

      final response = await http.post(
        Uri.parse(_syncEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final count = _pendingQueue.length;
        _pendingQueue.clear();
        _lastSyncTime = DateTime.now();
        if (kDebugMode) print('✅ Sync complete: $count records uploaded.');
      } else {
        if (kDebugMode) print('⚠️ Sync failed with status ${response.statusCode}. Queue retained.');
      }
    } catch (e) {
      // Network unavailable — queue retained, will retry on next connectivity event
      if (kDebugMode) print('⚠️ Sync attempt failed (offline): $e. Records remain queued.');
    } finally {
      _isSyncing = false;
    }
  }
}

/// CHW Override Audit Log — in-memory with schema matching the DB table definition.
/// Schema: ruleId, overriddenBy, timestamp, note (optional), originalTier, newTier
class OverrideAuditLog {
  static final OverrideAuditLog _instance = OverrideAuditLog._internal();
  factory OverrideAuditLog() => _instance;
  OverrideAuditLog._internal();

  final List<Map<String, dynamic>> _log = [];

  List<Map<String, dynamic>> get entries => List.unmodifiable(_log);

  /// Records a CHW override. All fields are required except note.
  void record({
    required String ruleId,
    required String overriddenBy,
    required String originalTier,
    required String newTier,
    String? note,
  }) {
    final entry = {
      'ruleId': ruleId,          // e.g. 'RULE_A1_SAM_MUAC'
      'overriddenBy': overriddenBy, // CHW name or ID
      'timestamp': DateTime.now().toIso8601String(),
      'note': note,              // Optional CHW justification text
      'originalTier': originalTier, // 'URGENT' | 'WATCH' | 'ROUTINE'
      'newTier': newTier,
    };
    _log.add(entry);
    if (kDebugMode) {
      print('📋 Override logged: $ruleId | $overriddenBy | ${entry['timestamp']} | note: $note');
    }
  }
}
