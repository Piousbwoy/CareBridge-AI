import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../data/sync_queue_service.dart';

class SyncStatusScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const SyncStatusScreen({super.key, required this.onLogout});

  @override
  State<SyncStatusScreen> createState() => _SyncStatusScreenState();
}

class _SyncStatusScreenState extends State<SyncStatusScreen> {
  final _syncQueueService = SyncQueueService();
  bool _isSyncing = false;
  int _pendingCount = 3;
  String _syncResultMsg = '';

  void _triggerManualSync() async {
    setState(() {
      _isSyncing = true;
      _syncResultMsg = '';
    });

    final success = await _syncQueueService.attemptAutoSync();

    if (mounted) {
      setState(() {
        _isSyncing = false;
        if (success) {
          _pendingCount = 0;
          _syncResultMsg = 'Sync completed successfully! 3 items uploaded to server.';
        } else {
          _syncResultMsg = 'Sync failed — Device offline. Items remain queued safely.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('19. Offline Sync Queue', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavy,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(color: AppTheme.accentTeal, borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.cloud_sync_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ama Akosua (CHO)', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text('Bole CHPS Zone · Working Locally', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Pending Items Status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Pending Sync Queue', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _pendingCount > 0 ? AppTheme.watchAmber.withValues(alpha: 0.1) : AppTheme.routineGreen.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$_pendingCount items pending',
                              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: _pendingCount > 0 ? AppTheme.watchAmber : AppTheme.routineGreen),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      if (_pendingCount > 0) ...[
                        _QueueItemTile('Referral: Akua Serwaa', 'URGENT · 10:25 AM', Icons.warning_amber_rounded, AppTheme.urgentRed),
                        _QueueItemTile('Household Update: H-10042', 'WATCH · 10:20 AM', Icons.visibility_outlined, AppTheme.watchAmber),
                        _QueueItemTile('Visit Note: H-10043', 'ROUTINE · 09:45 AM', Icons.check_circle_outline, AppTheme.routineGreen),
                      ] else ...[
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text('All pending items synced to server!', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.routineGreen, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Trigger Sync Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSyncing ? null : _triggerManualSync,
                  icon: _isSyncing
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.sync_rounded, color: Colors.white),
                  label: Text(_isSyncing ? 'Syncing with Server...' : 'Sync Now (Flush Queue)', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNavy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),

              if (_syncResultMsg.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _syncResultMsg.contains('successfully') ? AppTheme.routineGreen.withValues(alpha: 0.1) : AppTheme.urgentRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(_syncResultMsg, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QueueItemTile extends StatelessWidget {
  final String title;
  final String time;
  final IconData icon;
  final Color color;

  const _QueueItemTile(this.title, this.time, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark))),
          Text(time, style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textMedium)),
        ],
      ),
    );
  }
}
