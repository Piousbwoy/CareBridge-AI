import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

// ─── ONBOARDING SHELL (shared) ──────────────────────────────────────────────────
class _OnboardingShell extends StatefulWidget {
  final int step;
  final int total;
  final VoidCallback onSkip;
  final VoidCallback onNext;
  final String heroImage;
  final Widget contentCard;
  final Color accentColor;

  const _OnboardingShell({
    required this.step,
    required this.total,
    required this.onSkip,
    required this.onNext,
    required this.heroImage,
    required this.contentCard,
    this.accentColor = AppTheme.accentTeal,
  });

  @override
  State<_OnboardingShell> createState() => _OnboardingShellState();
}

class _OnboardingShellState extends State<_OnboardingShell> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Hero image — top 55% of screen
          Positioned(
            top: 0, left: 0, right: 0,
            height: MediaQuery.of(context).size.height * 0.55,
            child: Image.asset(widget.heroImage, fit: BoxFit.cover),
          ),

          // Gradient from image to white card
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            left: 0, right: 0,
            height: MediaQuery.of(context).size.height * 0.25,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.white.withValues(alpha: 0.95), Colors.white],
                ),
              ),
            ),
          ),

          // Content panel slides up from bottom
          Positioned(
            bottom: 0, left: 0, right: 0,
            height: MediaQuery.of(context).size.height * 0.58,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
              ),
              child: SafeArea(
                top: false,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Step dots + skip
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: List.generate(widget.total, (i) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 350),
                                  margin: const EdgeInsets.only(right: 6),
                                  width: i == widget.step - 1 ? 22 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: i == widget.step - 1 ? widget.accentColor : const Color(0xFFDDE3EA),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                )),
                              ),
                              TextButton(
                                onPressed: widget.onSkip,
                                child: Text('Skip', style: GoogleFonts.inter(color: AppTheme.textMedium, fontSize: 13, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Content card
                          Expanded(child: SingleChildScrollView(child: widget.contentCard)),

                          // Next / CTA button
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20, top: 8),
                            child: SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: widget.onNext,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: widget.accentColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      widget.step == widget.total ? "Let's Get Started" : 'Continue',
                                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Top safe area nav bar overlay on image
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(children: [
                      const Icon(Icons.favorite_rounded, color: AppTheme.accentTeal, size: 14),
                      const SizedBox(width: 5),
                      Text('CareBridge AI', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    ]),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('${widget.step} / ${widget.total}', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
      heroImage: 'assets/images/onboarding_1.png',
      accentColor: AppTheme.accentTeal,
      contentCard: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: AppTheme.accentTeal.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
            child: Text('Welcome', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accentTeal)),
          ),
          const SizedBox(height: 10),
          Text('Your AI partner\nfor safer births.', style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy, height: 1.2)),
          const SizedBox(height: 10),
          Text('CareBridge AI helps Community Health Officers identify at-risk mothers and children before emergencies happen — even without internet.', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMedium, height: 1.6)),
          const SizedBox(height: 20),
          _FeaturePill(icon: Icons.psychology_rounded, color: AppTheme.accentTeal, label: 'AI-Powered Risk Triage (WHO IMCI)'),
          const SizedBox(height: 8),
          _FeaturePill(icon: Icons.wifi_off_rounded, color: AppTheme.primaryNavy, label: 'Works 100% Offline — No Data Needed'),
          const SizedBox(height: 8),
          _FeaturePill(icon: Icons.sms_rounded, color: AppTheme.watchAmber, label: 'Compressed 2G SMS Referrals'),
          const SizedBox(height: 16),
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
      heroImage: 'assets/images/onboarding_2.png',
      accentColor: AppTheme.primaryNavy,
      contentCard: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: AppTheme.urgentRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
            child: Text('Why CareBridge?', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.urgentRed)),
          ),
          const SizedBox(height: 10),
          Text('Built for where\nit matters most.', style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy, height: 1.2)),
          const SizedBox(height: 16),
          _ReasonCard2(
            icon: Icons.warning_amber_rounded, color: AppTheme.urgentRed,
            title: 'Prioritise the Critical',
            body: 'AI risk scoring ensures CHOs act first on the highest-risk households — not the nearest.',
          ),
          const SizedBox(height: 10),
          _ReasonCard2(
            icon: Icons.sync_rounded, color: AppTheme.primaryNavy,
            title: 'Offline-First Architecture',
            body: 'Full functionality without a data connection. Encrypted queue syncs automatically when reconnected.',
          ),
          const SizedBox(height: 10),
          _ReasonCard2(
            icon: Icons.sms_rounded, color: AppTheme.watchAmber,
            title: 'SMS Fallback Protocol',
            body: 'When data is zero, 60-character hex payloads carry a full referral to the district hospital.',
          ),
          const SizedBox(height: 16),
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
      heroImage: 'assets/images/onboarding_3.png',
      accentColor: AppTheme.watchAmber,
      contentCard: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: AppTheme.watchAmber.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
            child: Text('3 Core Pillars', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.watchAmber)),
          ),
          const SizedBox(height: 10),
          Text('One mission.\nThree powerful tools.', style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy, height: 1.2)),
          const SizedBox(height: 16),
          _PillarCard2(num: '01', icon: Icons.search_rounded, color: AppTheme.urgentRed, title: 'Assess', body: 'Collect MUAC, breathing rate, danger signs in under 5 minutes.'),
          const SizedBox(height: 10),
          _PillarCard2(num: '02', icon: Icons.bolt_rounded, color: AppTheme.accentTeal, title: 'AI Score', body: 'Instant GHS-aligned triage result. URGENT, WATCH, or ROUTINE.'),
          const SizedBox(height: 10),
          _PillarCard2(num: '03', icon: Icons.send_rounded, color: AppTheme.watchAmber, title: 'Act & Refer', body: 'Guided care plan and compressed SMS referral in one tap.'),
          const SizedBox(height: 16),
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
    return _OnboardingShell(
      step: 4, total: 4,
      onSkip: onGetStarted, onNext: onGetStarted,
      heroImage: 'assets/images/onboarding_4.png',
      accentColor: AppTheme.accentTeal,
      contentCard: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: AppTheme.accentTeal.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
            child: Text('You\'re ready', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accentTeal)),
          ),
          const SizedBox(height: 10),
          Text('A workflow built\nfor rural field care.', style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy, height: 1.2)),
          const SizedBox(height: 8),
          Text('Every feature was designed around the real conditions CHOs face in the field — limited time, low connectivity, and high patient load.', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMedium, height: 1.6)),
          const SizedBox(height: 16),
          _WorkflowStep2(num: 1, color: AppTheme.urgentRed, title: 'Select Household', body: 'AI-sorted priority list surfaces the most critical visits first.'),
          const SizedBox(height: 8),
          _WorkflowStep2(num: 2, color: AppTheme.accentTeal, title: 'Run Clinical Assessment', body: '26-parameter WHO/GHS triage engine at point of care.'),
          const SizedBox(height: 8),
          _WorkflowStep2(num: 3, color: AppTheme.watchAmber, title: 'Act, Refer & Sync', body: 'Compressed SMS referral + care plan + offline queue sync.'),
          const SizedBox(height: 16),
          Center(
            child: Text('Local Mode Ready · Ghana Health Service Protocol', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight)),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── SHARED WIDGETS ────────────────────────────────────────────────────────────
class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  const _FeaturePill({required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark))),
      ]),
    );
  }
}

class _ReasonCard2 extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String body;
  const _ReasonCard2({required this.color, required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          const SizedBox(height: 3),
          Text(body, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMedium, height: 1.5)),
        ])),
      ]),
    );
  }
}

class _PillarCard2 extends StatelessWidget {
  final String num;
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  const _PillarCard2({required this.num, required this.icon, required this.color, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Row(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          Text(body, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMedium, height: 1.4)),
        ])),
        Text(num, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: color.withValues(alpha: 0.2))),
      ]),
    );
  }
}

class _WorkflowStep2 extends StatelessWidget {
  final int num;
  final Color color;
  final String title;
  final String body;
  const _WorkflowStep2({required this.num, required this.color, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Center(child: Text('$num', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white))),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            Text(body, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMedium, height: 1.4)),
          ]),
        ),
      ],
    );
  }
}
