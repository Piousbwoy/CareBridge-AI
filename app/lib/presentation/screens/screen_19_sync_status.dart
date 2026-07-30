import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../data/sync_queue_service.dart';
import '../../data/mock_repository.dart';

class SyncStatusScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const SyncStatusScreen({super.key, required this.onLogout});

  @override
  State<SyncStatusScreen> createState() => _SyncStatusScreenState();
}

class _SyncStatusScreenState extends State<SyncStatusScreen> {
  int _activeSubTab = 0; // 0 = Sync Queue, 1 = Profile & Settings
  final _syncQueueService = SyncQueueService();
  final _repo = MockRepository();
  bool _isSyncing = false;
  int _pendingCount = 3;
  String _syncResultMsg = '';

  // Settings State
  bool _syncWifiOnly = false;
  bool _autoSyncOnline = true;
  String _selectedLanguage = 'English & Dagbani';

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
          _syncResultMsg = 'Sync completed successfully! All items uploaded to central GHS server.';
        } else {
          _syncResultMsg = 'Sync failed — Device offline. Items remain safely queued in encrypted storage.';
        }
      });
    }
  }

  void _showChangePinDialog() {
    final currentPinCtrl = TextEditingController();
    final newPinCtrl = TextEditingController();
    final confirmPinCtrl = TextEditingController();
    String? pinError;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.lock_reset_rounded, color: AppTheme.primaryNavy),
              const SizedBox(width: 8),
              Text('Change 4-Digit PIN', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Enter your security PIN credentials below to update your login PIN.', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMedium)),
                const SizedBox(height: 14),
                TextField(
                  controller: currentPinCtrl,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  decoration: const InputDecoration(labelText: 'Current PIN', isDense: true, prefixIcon: Icon(Icons.lock_outline_rounded, size: 18)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: newPinCtrl,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  decoration: const InputDecoration(labelText: 'New 4-Digit PIN', isDense: true, prefixIcon: Icon(Icons.key_rounded, size: 18)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: confirmPinCtrl,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  decoration: const InputDecoration(labelText: 'Confirm New PIN', isDense: true, prefixIcon: Icon(Icons.key_rounded, size: 18)),
                ),
                if (pinError != null) ...[
                  const SizedBox(height: 6),
                  Text(pinError!, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.urgentRed)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMedium)),
            ),
            ElevatedButton(
              onPressed: () {
                if (currentPinCtrl.text != _repo.pinCode) {
                  setDialogState(() => pinError = 'Current PIN is incorrect');
                  return;
                }
                if (newPinCtrl.text.length != 4) {
                  setDialogState(() => pinError = 'New PIN must be exactly 4 digits');
                  return;
                }
                if (newPinCtrl.text != confirmPinCtrl.text) {
                  setDialogState(() => pinError = 'New PIN and Confirmation do not match');
                  return;
                }

                _repo.pinCode = newPinCtrl.text;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Security PIN successfully updated!')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentTeal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text('Update PIN', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('Sync & Settings', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Segmented Header Switcher
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _TabButton(
                      label: '2G Sync Queue',
                      icon: Icons.cloud_sync_rounded,
                      isSelected: _activeSubTab == 0,
                      onTap: () => setState(() => _activeSubTab = 0),
                    ),
                  ),
                  Expanded(
                    child: _TabButton(
                      label: 'Settings',
                      icon: Icons.tune_rounded,
                      isSelected: _activeSubTab == 1,
                      onTap: () => setState(() => _activeSubTab = 1),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: _activeSubTab == 0 ? _buildSyncQueueTab() : _buildProfileSettingsTab(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncQueueTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CHO Officer Status Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryNavy,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: AppTheme.accentTeal, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_repo.chwName, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('${_repo.chwZone} · Local Mode', style: GoogleFonts.inter(fontSize: 11, color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Queue Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Pending Sync Items', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: _pendingCount > 0 ? AppTheme.watchAmber.withValues(alpha: 0.12) : AppTheme.routineGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$_pendingCount items pending',
                        style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: _pendingCount > 0 ? AppTheme.watchAmber : AppTheme.routineGreen),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (_pendingCount > 0) ...[
                  _QueueItemTile('Referral: Akua Serwaa (H-10041)', 'URGENT · 10:25 AM', Icons.warning_amber_rounded, AppTheme.urgentRed),
                  _QueueItemTile('Assessment: Abena Gyamfi (H-10042)', 'WATCH · 10:20 AM', Icons.visibility_outlined, AppTheme.watchAmber),
                  _QueueItemTile('Routine Check: Hajia Mariama (H-10043)', 'ROUTINE · 09:45 AM', Icons.check_circle_outline, AppTheme.routineGreen),
                ] else ...[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text('All pending items synced to GHS server!', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.routineGreen, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Manual Sync Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _isSyncing ? null : _triggerManualSync,
            icon: _isSyncing
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.sync_rounded, color: Colors.white),
            label: Text(_isSyncing ? 'Syncing Queue...' : 'Sync Now (Flush Queue)', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryNavy,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    );
  }

  Widget _buildProfileSettingsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile Info Header Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavy,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.accentTeal, width: 2),
                ),
                child: const Center(child: Icon(Icons.person_rounded, color: Colors.white, size: 28)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_repo.chwName, style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                    Text(_repo.chwRole, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMedium)),
                    Text(_repo.chwZone, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.accentTeal, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Security & Account Settings
        Text('SECURITY & AUTHENTICATION', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy, letterSpacing: 0.5)),
        const SizedBox(height: 8),

        _SettingsTile(
          icon: Icons.lock_reset_rounded,
          title: 'Change 4-Digit Security PIN',
          subtitle: 'Update your offline login credential',
          onTap: _showChangePinDialog,
        ),

        _SettingsTile(
          icon: Icons.record_voice_over_rounded,
          title: 'Audio Language Prompts',
          subtitle: 'Current: $_selectedLanguage',
          onTap: () {
            setState(() {
              _selectedLanguage = _selectedLanguage.contains('Dagbani') ? 'English Only' : 'English & Dagbani';
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Audio prompts updated to: $_selectedLanguage')),
            );
          },
        ),

        const SizedBox(height: 14),

        // Encrypted Storage & Data Options
        Text('SYNC SETTINGS', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy, letterSpacing: 0.5)),
        const SizedBox(height: 8),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.settings_rounded, color: AppTheme.accentTeal, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('Sync Settings', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy), overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: const LinearProgressIndicator(value: 0.24, minHeight: 6, backgroundColor: AppTheme.cardBorder, valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentTeal)),
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Sync Over Wi-Fi Only', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold)),
                  value: _syncWifiOnly,
                  activeThumbColor: AppTheme.accentTeal,
                  onChanged: (v) => setState(() => _syncWifiOnly = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Auto-Sync On Network Detect', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold)),
                  value: _autoSyncOnline,
                  activeThumbColor: AppTheme.accentTeal,
                  onChanged: (v) => setState(() => _autoSyncOnline = v),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 18),

        // Logout Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout_rounded, color: AppTheme.urgentRed, size: 20),
            label: Text('Log Out of Device', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.urgentRed)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.urgentRed),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({required this.label, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryNavy : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : AppTheme.textMedium),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppTheme.textMedium)),
          ],
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

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsTile({required this.icon, required this.title, this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryNavy, size: 20),
        title: Text(title, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        subtitle: subtitle != null ? Text(subtitle!, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMedium)) : null,
        trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textMedium, size: 18),
        onTap: onTap,
      ),
    );
  }
}
