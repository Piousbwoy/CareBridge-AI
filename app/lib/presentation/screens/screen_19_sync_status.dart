import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../data/mock_repository.dart';
import 'screen_20_21_profile_settings.dart';

class SyncStatusScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const SyncStatusScreen({super.key, required this.onLogout});

  @override
  State<SyncStatusScreen> createState() => _SyncStatusScreenState();
}

class _SyncStatusScreenState extends State<SyncStatusScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _triggerSync() async {
    setState(() => _isSyncing = true);
    await Future.delayed(const Duration(seconds: 2));
    final repo = MockRepository();
    repo.pendingSyncCount = 0;
    repo.lastSyncTime = DateTime.now();
    if (mounted) {
      setState(() => _isSyncing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sync completed successfully! All records sent to server.'),
          backgroundColor: AppTheme.routineGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = MockRepository();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('19. Sync & Settings'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentTeal,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(Icons.sync_rounded), text: 'Sync Status'),
            Tab(icon: Icon(Icons.settings_outlined), text: 'Profile & Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Sync Status Queue
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Network Banner Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: repo.pendingSyncCount > 0 ? AppTheme.watchAmberLight : AppTheme.routineGreenLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          repo.pendingSyncCount > 0 ? Icons.cloud_upload_outlined : Icons.cloud_done_outlined,
                          color: repo.pendingSyncCount > 0 ? AppTheme.watchAmber : AppTheme.routineGreen,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              repo.pendingSyncCount > 0 ? 'Pending Sync Queue' : 'All Data Synced',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${repo.pendingSyncCount} items queued for server upload',
                              style: const TextStyle(fontSize: 12, color: AppTheme.textMedium),
                            ),
                            Text(
                              'Last Synced: ${DateFormat('MMM dd, hh:mm a').format(repo.lastSyncTime)}',
                              style: const TextStyle(fontSize: 11, color: AppTheme.accentTeal, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isSyncing ? null : _triggerSync,
                    icon: _isSyncing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.sync),
                    label: Text(_isSyncing ? 'Syncing with Server...' : 'Sync Now'),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Queued Assessment Logs',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                ),
                const SizedBox(height: 10),
                _buildSyncQueueItem('Offline Risk Assessment', 'Akua Serwaa (H-10041)', '10:25 AM', 'URGENT'),
                _buildSyncQueueItem('Household Detail Update', 'Abena Gyamfi (H-10042)', '10:20 AM', 'WATCH'),
                _buildSyncQueueItem('Referral Note Created', 'Hajia Mariama (H-10043)', '09:45 AM', 'URGENT'),
              ],
            ),
          ),
          // Tab 2: Folded Profile & Settings
          ProfileSettingsTab(onLogout: widget.onLogout),
        ],
      ),
    );
  }

  Widget _buildSyncQueueItem(String type, String detail, String time, String badge) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.article_outlined, color: AppTheme.primaryNavy),
        title: Text(type, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
        subtitle: Text('$detail · Today, $time', style: const TextStyle(fontSize: 12, color: AppTheme.textMedium)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: badge == 'URGENT' ? AppTheme.urgentRedLight : AppTheme.watchAmberLight,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            badge,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: badge == 'URGENT' ? AppTheme.urgentRed : AppTheme.watchAmber,
            ),
          ),
        ),
      ),
    );
  }
}
