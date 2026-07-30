import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/mock_repository.dart';

class ProfileSettingsTab extends StatefulWidget {
  final VoidCallback onLogout;

  const ProfileSettingsTab({super.key, required this.onLogout});

  @override
  State<ProfileSettingsTab> createState() => _ProfileSettingsTabState();
}

class _ProfileSettingsTabState extends State<ProfileSettingsTab> {
  bool _syncWifiOnly = true;
  bool _autoSyncOnline = true;
  String _selectedLanguage = "Dagbani";

  @override
  Widget build(BuildContext context) {
    final repo = MockRepository();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.primaryNavy,
                  child: Text(
                    repo.chwName.substring(0, 1),
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        repo.chwName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                      ),
                      Text(
                        repo.chwRole,
                        style: const TextStyle(fontSize: 12, color: AppTheme.textMedium),
                      ),
                      Text(
                        repo.chwZone,
                        style: const TextStyle(fontSize: 11, color: AppTheme.accentTeal, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Security & Data Encryption',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Row(
                      children: [
                        Icon(Icons.shield_outlined, color: AppTheme.routineGreen, size: 20),
                        SizedBox(width: 10),
                        Text('Local Storage Security', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Text('SQLCipher Active', style: TextStyle(fontSize: 12, color: AppTheme.routineGreen, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Row(
                      children: [
                        Icon(Icons.storage_outlined, color: AppTheme.primaryNavy, size: 20),
                        SizedBox(width: 10),
                        Text('Local Cache Storage', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Text('1.2 GB / 5.0 GB', style: TextStyle(fontSize: 12, color: AppTheme.textMedium)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'App Preferences',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language_outlined, color: AppTheme.primaryNavy),
                  title: const Text('Audio Prompt Language', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  trailing: DropdownButton<String>(
                    value: _selectedLanguage,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: "Dagbani", child: Text("Dagbani")),
                      DropdownMenuItem(value: "English", child: Text("English")),
                      DropdownMenuItem(value: "Waala", child: Text("Waala")),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedLanguage = val);
                    },
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.wifi, color: AppTheme.primaryNavy),
                  title: const Text('Sync Over Wi-Fi Only', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  value: _syncWifiOnly,
                  activeColor: AppTheme.accentTeal,
                  onChanged: (val) => setState(() => _syncWifiOnly = val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.autorenew, color: AppTheme.primaryNavy),
                  title: const Text('Auto-Sync When Signal Returns', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  value: _autoSyncOnline,
                  activeColor: AppTheme.accentTeal,
                  onChanged: (val) => setState(() => _autoSyncOnline = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: widget.onLogout,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.urgentRed),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.logout, color: AppTheme.urgentRed),
              label: const Text(
                'Log Out & Clear Session',
                style: TextStyle(color: AppTheme.urgentRed, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
