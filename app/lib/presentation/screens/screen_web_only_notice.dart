import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class WebOnlyNoticeScreen extends StatelessWidget {
  final VoidCallback? onSignOut;
  final VoidCallback? onBack;

  const WebOnlyNoticeScreen({super.key, this.onSignOut, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.accentTeal.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.accentTeal, width: 2),
                ),
                child: const Icon(Icons.desktop_windows_rounded, color: AppTheme.accentTeal, size: 40),
              ),
              const SizedBox(height: 24),
              Text(
                'Supervisor Web Access Only',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                'District Health Officer & Regional Supervisor accounts are optimized for regional oversight on desktop browsers.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white70, height: 1.5),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: Column(
                  children: [
                    Text(
                      'CareBridge Supervisor Web Dashboard:',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70),
                    ),
                    const SizedBox(height: 6),
                    SelectableText(
                      'http://localhost:3000',
                      style: GoogleFonts.firaCode(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.accentTeal),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity, height: 50,
                child: OutlinedButton.icon(
                  onPressed: onSignOut ?? onBack,
                  icon: const Icon(Icons.logout_rounded, color: Colors.white),
                  label: Text('Sign Out / Switch Account', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
