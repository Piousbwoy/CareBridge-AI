import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class ProfileSettingsScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const ProfileSettingsScreen({super.key, required this.onLogout});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  bool _syncWifiOnly = true;
  bool _autoSyncOnline = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('20 & 21. Profile & Settings', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CHW Profile Header Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54, height: 54,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryNavy,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.accentTeal, width: 2),
                      ),
                      child: const Center(child: Icon(Icons.person_rounded, color: Colors.white, size: 30)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ama Akosua', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                          Text('Community Health Officer (CHO)', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMedium)),
                          Text('Bole CHPS Zone, Savannah Region', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.accentTeal, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Account & Security Options
              Text('ACCOUNT & SECURITY', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
              const SizedBox(height: 8),
              _SettingsTile(icon: Icons.person_outline_rounded, title: 'Edit Profile', onTap: () {}),
              _SettingsTile(icon: Icons.lock_outline_rounded, title: 'Change 4-Digit PIN', onTap: () {}),
              _SettingsTile(icon: Icons.translate_rounded, title: 'Language / Audio', subtitle: 'English & Dagbani Voice Prompts', onTap: () {}),

              const SizedBox(height: 16),

              // Data & Storage Security (Point 21 in UI map)
              Text('DATA & ENCRYPTED STORAGE', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            const Icon(Icons.security_rounded, color: AppTheme.routineGreen, size: 20),
                            const SizedBox(width: 8),
                            Text('Data Protection (SQLCipher)', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                          ]),
                          Text('1.2 GB / 5.0 GB', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMedium)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: const LinearProgressIndicator(value: 0.24, minHeight: 6, backgroundColor: AppTheme.cardBorder, valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentTeal)),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: Text('Sync Over Wi-Fi Only', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold)),
                        value: _syncWifiOnly,
                        activeThumbColor: AppTheme.accentTeal,
                        onChanged: (v) => setState(() => _syncWifiOnly = v),
                      ),
                      SwitchListTile(
                        title: Text('Auto-Sync When Online', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold)),
                        value: _autoSyncOnline,
                        activeThumbColor: AppTheme.accentTeal,
                        onChanged: (v) => setState(() => _autoSyncOnline = v),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: widget.onLogout,
                  icon: const Icon(Icons.logout_rounded, color: AppTheme.urgentRed),
                  label: Text('Log Out', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.urgentRed)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.urgentRed),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
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
        leading: Icon(icon, color: AppTheme.primaryNavy, size: 22),
        title: Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        subtitle: subtitle != null ? Text(subtitle!, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMedium)) : null,
        trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textMedium),
        onTap: onTap,
      ),
    );
  }
}
