import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

// ─── SCREEN 2: ONBOARDING WELCOME ─────────────────────────────────────────────
class OnboardingWelcomeScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;
  const OnboardingWelcomeScreen({super.key, required this.onNext, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return _OnboardingShell(
      step: 1, total: 4,
      onSkip: onSkip, onNext: onNext,
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF0A2540), Color(0xFF00A896)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [BoxShadow(color: AppTheme.primaryNavy.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: const Icon(Icons.medical_services_rounded, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 28),
          Text('Welcome to\nCareBridge AI',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy, height: 1.2)),
          const SizedBox(height: 14),
          Text('Your AI health companion for a safer pregnancy & a healthier child.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textMedium, height: 1.6)),
          const SizedBox(height: 28),
          _FeatureBadge(icon: Icons.psychology_rounded, color: AppTheme.accentTeal, label: 'AI-Powered Risk Triage'),
          const SizedBox(height: 10),
          _FeatureBadge(icon: Icons.wifi_off_rounded, color: AppTheme.primaryNavy, label: 'Works 100% Offline'),
          const SizedBox(height: 10),
          _FeatureBadge(icon: Icons.sms_rounded, color: AppTheme.watchAmber, label: 'Instant SMS Referrals'),
          const SizedBox(height: 24),
          Text("You're not alone. We're here to support you every step.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMedium, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}

// ─── SCREEN 3: ONBOARDING WHY ─────────────────────────────────────────────────
class OnboardingWhyScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;
  const OnboardingWhyScreen({super.key, required this.onNext, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return _OnboardingShell(
      step: 2, total: 4,
      onSkip: onSkip, onNext: onNext,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text('Three reasons why\nCareBridge AI?',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy, height: 1.2)),
          const SizedBox(height: 24),
          _ReasonCard(
            color: AppTheme.urgentRed,
            icon: Icons.warning_amber_rounded,
            title: 'Prioritise the Critical',
            body: 'AI risk scoring helps CHWs focus on those who need help most.',
          ),
          const SizedBox(height: 12),
          _ReasonCard(
            color: AppTheme.primaryNavy,
            icon: Icons.sync_rounded,
            title: 'Offline-First',
            body: 'Fully offline. Syncs automatically when back online.',
          ),
          const SizedBox(height: 12),
          _ReasonCard(
            color: AppTheme.watchAmber,
            icon: Icons.sms_rounded,
            title: 'SMS Fallback',
            body: 'When data is limited, SMS ensures timely referrals every time.',
          ),
        ],
      ),
    );
  }
}

// ─── SCREEN 4: ONBOARDING PILLARS ─────────────────────────────────────────────
class OnboardingPillarsScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;
  const OnboardingPillarsScreen({super.key, required this.onNext, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return _OnboardingShell(
      step: 3, total: 4,
      onSkip: onSkip, onNext: onNext,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text('3 Core Pillars.\n1 Mission.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy, height: 1.2)),
          const SizedBox(height: 24),
          _PillarTile(num: '01', icon: Icons.search_rounded, color: AppTheme.urgentRed, title: 'Assess',
              body: 'Collect key data and symptoms in minutes.'),
          const SizedBox(height: 12),
          _PillarTile(num: '02', icon: Icons.bolt_rounded, color: AppTheme.accentTeal, title: 'AI Score',
              body: 'Instant risk scoring at the point of care.'),
          const SizedBox(height: 12),
          _PillarTile(num: '03', icon: Icons.send_rounded, color: AppTheme.watchAmber, title: 'Act & Refer',
              body: 'Get recommendations and refer if urgent.'),
        ],
      ),
    );
  }
}

// ─── SCREEN 5: ONBOARDING HOW IT WORKS ────────────────────────────────────────
class OnboardingWorkflowPreviewScreen extends StatelessWidget {
  final VoidCallback onGetStarted;
  const OnboardingWorkflowPreviewScreen({super.key, required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppTheme.accentTeal, borderRadius: BorderRadius.circular(20)),
                child: Text('Simple. Smart. Life-Saving.',
                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(height: 20),
              Text('How It Works',
                  style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
              const SizedBox(height: 24),
              _WorkflowStep(num: 1, icon: Icons.person_search_rounded, color: AppTheme.urgentRed,
                  title: 'Assess', body: 'Collect patient data and symptoms quickly at the household.'),
              const SizedBox(height: 12),
              _WorkflowStep(num: 2, icon: Icons.psychology_rounded, color: AppTheme.accentTeal,
                  title: 'AI Score', body: 'Instant risk scoring at the point of care — no internet needed.'),
              const SizedBox(height: 12),
              _WorkflowStep(num: 3, icon: Icons.send_rounded, color: AppTheme.watchAmber,
                  title: 'Act & Refer', body: 'Get care recommendations or refer if urgent via compressed SMS.'),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: onGetStarted,
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentTeal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: Text("Let's Get Started", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 8),
              Text('Local Mode Ready · Works Offline', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── SHARED ONBOARDING SHELL ───────────────────────────────────────────────────
class _OnboardingShell extends StatelessWidget {
  final int step;
  final int total;
  final VoidCallback onSkip;
  final VoidCallback onNext;
  final Widget child;
  const _OnboardingShell({required this.step, required this.total, required this.onSkip, required this.onNext, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: List.generate(total, (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(right: 6),
                    width: i == step - 1 ? 20 : 8, height: 8,
                    decoration: BoxDecoration(
                      color: i == step - 1 ? AppTheme.primaryNavy : AppTheme.cardBorder,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ))),
                  TextButton(
                    onPressed: onSkip,
                    child: Text('Skip', style: GoogleFonts.inter(color: AppTheme.textMedium, fontSize: 13)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(child: SingleChildScrollView(child: child)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: onNext,
                  child: Text(step == total ? 'Get Started' : 'Next →', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── SHARED WIDGETS ────────────────────────────────────────────────────────────
class _FeatureBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  const _FeatureBadge({required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
      ]),
    );
  }
}

class _ReasonCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String body;
  const _ReasonCard({required this.color, required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          const SizedBox(height: 4),
          Text(body, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMedium, height: 1.5)),
        ])),
      ]),
    );
  }
}

class _PillarTile extends StatelessWidget {
  final String num;
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  const _PillarTile({required this.num, required this.icon, required this.color, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          Text(body, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMedium)),
        ])),
        Text(num, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: color.withValues(alpha: 0.2))),
      ]),
    );
  }
}

class _WorkflowStep extends StatelessWidget {
  final int num;
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  const _WorkflowStep({required this.num, required this.icon, required this.color, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text('$num', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: color))),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          Text(body, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMedium, height: 1.4)),
        ])),
        Icon(icon, color: color, size: 28),
      ]),
    );
  }
}
