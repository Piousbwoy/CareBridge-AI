import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

// ─── ONBOARDING SHELL (Shared Minimalistic Layout) ────────────────────────────
class _OnboardingShell extends StatefulWidget {
  final int step;
  final int total;
  final VoidCallback onSkip;
  final VoidCallback onNext;
  final VoidCallback? onBack;
  final String heroImage;
  final Widget contentCard;
  final Color accentColor;

  const _OnboardingShell({
    required this.step,
    required this.total,
    required this.onSkip,
    required this.onNext,
    this.onBack,
    required this.heroImage,
    required this.contentCard,
    this.accentColor = const Color(0xFF1E68F6),
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
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
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
    const brandBlue = Color(0xFF1E68F6);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FE),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final totalH = constraints.maxHeight;
          final heroH = totalH * 0.42;
          final cardH = totalH * 0.62;

          return Stack(
            children: [
              // Hero Image (top 42%)
              Positioned(
                top: 0, left: 0, right: 0,
                height: heroH,
                child: Image.asset(
                  widget.heroImage,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFEBF3FC), Color(0xFFD6E6FE)],
                      ),
                    ),
                    child: Center(
                      child: Icon(Icons.favorite_rounded, color: brandBlue.withValues(alpha: 0.3), size: 80),
                    ),
                  ),
                ),
              ),

              // Soft White Gradient Blend Overlay
              Positioned(
                top: heroH * 0.5,
                left: 0, right: 0,
                height: heroH * 0.5,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        const Color(0xFFF6F9FE).withValues(alpha: 0.6),
                        const Color(0xFFF6F9FE),
                      ],
                    ),
                  ),
                ),
              ),

              // Top Nav Bar: Back Button + Step Badge
              Positioned(
                top: 0, left: 0, right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (widget.onBack != null) ...[
                              GestureDetector(
                                onTap: widget.onBack,
                                child: Container(
                                  width: 38, height: 38,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 1.5),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 14),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white, width: 1.5),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.favorite_rounded, color: brandBlue, size: 14),
                                  const SizedBox(width: 6),
                                  Text(
                                    'CareBridge AI',
                                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Text(
                            'Step ${widget.step} of ${widget.total}',
                            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF64748B)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Clean Sheet Container
              Positioned(
                bottom: 0, left: 0, right: 0,
                height: cardH,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(color: Color(0x0C0F172A), blurRadius: 30, offset: Offset(0, -10)),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Step indicator dots + Skip button
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: List.generate(widget.total, (i) => AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      margin: const EdgeInsets.only(right: 6),
                                      width: i == widget.step - 1 ? 28 : 8,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: i == widget.step - 1 ? brandBlue : const Color(0xFFE2E8F0),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    )),
                                  ),
                                  TextButton(
                                    onPressed: widget.onSkip,
                                    child: Text(
                                      'Skip',
                                      style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // Main Body Content Card
                              Expanded(child: SingleChildScrollView(child: widget.contentCard)),

                              const SizedBox(height: 12),

                              // Bottom Action Buttons
                              Row(
                                children: [
                                  if (widget.onBack != null) ...[
                                    Container(
                                      height: 52,
                                      margin: const EdgeInsets.only(right: 12),
                                      child: OutlinedButton(
                                        onPressed: widget.onBack,
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          padding: const EdgeInsets.symmetric(horizontal: 20),
                                        ),
                                        child: Text(
                                          'Back',
                                          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                                        ),
                                      ),
                                    ),
                                  ],
                                  Expanded(
                                    child: Container(
                                      height: 52,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF2575FC), Color(0xFF0052CC)],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: brandBlue.withValues(alpha: 0.3),
                                            blurRadius: 16,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: widget.onNext,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              widget.step == widget.total ? "Get Started" : 'Continue',
                                              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
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
    const brandBlue = Color(0xFF1E68F6);

    return _OnboardingShell(
      step: 1, total: 4,
      onSkip: onSkip, onNext: onNext,
      heroImage: 'assets/images/onboarding_1.png',
      contentCard: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: brandBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'WELCOME TO CAREBRIDGE AI',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: brandBlue, letterSpacing: 0.8),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your AI partner for safer births.',
            style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A), height: 1.2),
          ),
          const SizedBox(height: 10),
          Text(
            'Empowering Community Health Officers to identify high-risk mothers and infants early — anytime, anywhere, even without internet.',
            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B), height: 1.5),
          ),
          const SizedBox(height: 20),
          _FeaturePillClean(icon: Icons.psychology_rounded, color: brandBlue, label: 'AI Risk Triage (WHO & GHS IMCI Protocol)'),
          const SizedBox(height: 10),
          _FeaturePillClean(icon: Icons.wifi_off_rounded, color: const Color(0xFF0F172A), label: '100% Offline Mode — Zero Mobile Data'),
          const SizedBox(height: 10),
          _FeaturePillClean(icon: Icons.sms_rounded, color: const Color(0xFFD97706), label: 'Compressed 2G SMS Emergency Referrals'),
        ],
      ),
    );
  }
}

// ─── SCREEN 3: ONBOARDING WHY ─────────────────────────────────────────────────
class OnboardingWhyScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;
  final VoidCallback onSkip;
  const OnboardingWhyScreen({super.key, required this.onNext, this.onBack, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return _OnboardingShell(
      step: 2, total: 4,
      onSkip: onSkip, onNext: onNext, onBack: onBack,
      heroImage: 'assets/images/onboarding_2.png',
      contentCard: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'BUILT FOR FRONTLINE CARE',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFDC2626), letterSpacing: 0.8),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Built for where it matters most.',
            style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A), height: 1.2),
          ),
          const SizedBox(height: 14),
          _ReasonCardClean(
            icon: Icons.warning_amber_rounded, color: const Color(0xFFDC2626),
            title: 'Prioritise Critical Patients',
            body: 'AI scoring ranks household visits by clinical urgency so CHOs reach critical cases first.',
          ),
          const SizedBox(height: 10),
          _ReasonCardClean(
            icon: Icons.sync_rounded, color: const Color(0xFF1E68F6),
            title: 'Offline-First Storage',
            body: 'Encrypted local storage works seamlessly offline and auto-syncs when online.',
          ),
          const SizedBox(height: 10),
          _ReasonCardClean(
            icon: Icons.sms_rounded, color: const Color(0xFFD97706),
            title: '2G Emergency SMS',
            body: 'Compresses complete patient diagnostics into a tiny 60-character SMS payload.',
          ),
        ],
      ),
    );
  }
}

// ─── SCREEN 4: ONBOARDING PILLARS ─────────────────────────────────────────────
class OnboardingPillarsScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;
  final VoidCallback onSkip;
  const OnboardingPillarsScreen({super.key, required this.onNext, this.onBack, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return _OnboardingShell(
      step: 3, total: 4,
      onSkip: onSkip, onNext: onNext, onBack: onBack,
      heroImage: 'assets/images/onboarding_3.png',
      contentCard: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF1E68F6).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '3 CORE PILLARS',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF1E68F6), letterSpacing: 0.8),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'One mission. Three steps.',
            style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A), height: 1.2),
          ),
          const SizedBox(height: 14),
          _PillarCardClean(num: '01', icon: Icons.search_rounded, color: const Color(0xFFDC2626), title: 'Assess', body: 'Capture MUAC, breathing rate, and danger signs in under 5 mins.'),
          const SizedBox(height: 10),
          _PillarCardClean(num: '02', icon: Icons.bolt_rounded, color: const Color(0xFF1E68F6), title: 'AI Score', body: 'Instant risk calculation: URGENT, WATCH, or ROUTINE.'),
          const SizedBox(height: 10),
          _PillarCardClean(num: '03', icon: Icons.send_rounded, color: const Color(0xFFD97706), title: 'Act & Refer', body: 'Get instant clinical guidance or send 2G emergency SMS referrals.'),
        ],
      ),
    );
  }
}

// ─── SCREEN 5: ONBOARDING HOW IT WORKS ────────────────────────────────────────
class OnboardingWorkflowPreviewScreen extends StatelessWidget {
  final VoidCallback onGetStarted;
  final VoidCallback? onBack;
  const OnboardingWorkflowPreviewScreen({super.key, required this.onGetStarted, this.onBack});

  @override
  Widget build(BuildContext context) {
    return _OnboardingShell(
      step: 4, total: 4,
      onSkip: onGetStarted, onNext: onGetStarted, onBack: onBack,
      heroImage: 'assets/images/onboarding_4.png',
      contentCard: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'READY FOR FIELD CARE',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF059669), letterSpacing: 0.8),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Built for rural healthcare.',
            style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A), height: 1.2),
          ),
          const SizedBox(height: 10),
          Text(
            'Designed alongside Community Health Officers in Northern Ghana for high patient volume and low connectivity.',
            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B), height: 1.5),
          ),
          const SizedBox(height: 16),
          _WorkflowStepClean(num: 1, color: const Color(0xFFDC2626), title: 'Select Household', body: 'AI priority list highlights patients needing urgent attention.'),
          const SizedBox(height: 10),
          _WorkflowStepClean(num: 2, color: const Color(0xFF1E68F6), title: 'Run Assessment', body: 'Guided 26-parameter clinical evaluation at the doorstep.'),
          const SizedBox(height: 10),
          _WorkflowStepClean(num: 3, color: const Color(0xFFD97706), title: 'Act & Refer', body: 'Receive care protocols & send SMS referrals to district hospitals.'),
        ],
      ),
    );
  }
}

// ─── MINIMALISTIC REUSABLE COMPONENTS ───────────────────────────────────────
class _FeaturePillClean extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  const _FeaturePillClean({required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReasonCardClean extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String body;
  const _ReasonCardClean({required this.color, required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x080F172A), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                const SizedBox(height: 4),
                Text(body, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B), height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PillarCardClean extends StatelessWidget {
  final String num;
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  const _PillarCardClean({required this.num, required this.icon, required this.color, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x080F172A), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(body, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B), height: 1.4)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(num, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFFCBD5E1))),
        ],
      ),
    );
  }
}

class _WorkflowStepClean extends StatelessWidget {
  final int num;
  final Color color;
  final String title;
  final String body;
  const _WorkflowStepClean({required this.num, required this.color, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Center(child: Text('$num', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white))),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
              const SizedBox(height: 2),
              Text(body, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B), height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}
