import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../data/mock_repository.dart';
import '../../domain/models/clinical_models.dart';

// ─── SCREEN 15: AI RISK RESULT ──────────────────────────────────────────────────
// Role-Branching:
//   Caregiver  → 3 plain-language action cards (with Dagbani audio indicator)
//   CHW        → Full clinical tier, GHS codes, trend outlook, override audit
class AIRiskResultScreen extends StatefulWidget {
  final ClinicalRuleResult ruleResult;
  final TrendResult trendResult;
  final VoidCallback onRefer;
  final VoidCallback onOverride;

  const AIRiskResultScreen({
    super.key,
    required this.ruleResult,
    required this.trendResult,
    required this.onRefer,
    required this.onOverride,
  });

  @override
  State<AIRiskResultScreen> createState() => _AIRiskResultScreenState();
}

class _AIRiskResultScreenState extends State<AIRiskResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _scaleBadge;
  late Animation<double> _fadeSections;
  bool _dagbaniPlaying = false;
  final _repo = MockRepository();

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _scaleBadge = CurvedAnimation(parent: _animCtrl, curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack));
    _fadeSections = CurvedAnimation(parent: _animCtrl, curve: const Interval(0.4, 1.0, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCaregiver = _repo.userRole == UserRole.caregiver;
    return isCaregiver ? _buildCaregiverResult() : _buildCHWResult();
  }

  // ─── CAREGIVER: 3-action plain language output ───────────────────────────────
  Widget _buildCaregiverResult() {
    final tier = widget.ruleResult.overallTier;

    // Map tier to the 3 plain-language actions
    String actionTitle;
    String actionSubtitle;
    String actionIcon;
    Color actionColor;
    List<String> actionSteps;

    switch (tier) {
      case RiskTier.URGENT:
        actionTitle = 'Go to the clinic NOW';
        actionSubtitle = 'There are serious warning signs that need a health worker right away.';
        actionIcon = '🚨';
        actionColor = AppTheme.urgentRed;
        actionSteps = [
          'Go to the nearest health centre or hospital immediately',
          'Do not wait — go today, even at night',
          'Tell the nurse or doctor all the warning signs you answered "Yes" to',
          'If you cannot go, call a health worker now',
        ];
        break;
      case RiskTier.WATCH:
        actionTitle = 'See a health worker in the next few days';
        actionSubtitle = 'Some warning signs need attention soon, but you don\'t need to rush tonight.';
        actionIcon = '⚠️';
        actionColor = AppTheme.watchAmber;
        actionSteps = [
          'Visit the health post within the next 2–3 days',
          'Watch for the warning signs getting worse',
          'If a new danger sign appears, go immediately',
          'Make sure the child or mother continues eating and drinking',
        ];
        break;
      case RiskTier.ROUTINE:
        actionTitle = 'Continue routine care at home';
        actionSubtitle = 'No danger signs found right now. Keep watching and come for your scheduled visit.';
        actionIcon = '✅';
        actionColor = AppTheme.routineGreen;
        actionSteps = [
          'Continue breastfeeding and ensure good nutrition',
          'Come for the next scheduled health visit as planned',
          'Watch for any new signs and come to the clinic if they appear',
          'Keep the home clean and wash hands regularly',
        ];
        break;
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('What To Do Next', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        elevation: 0,
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppTheme.navyGradient)),
        actions: [
          IconButton(
            icon: Icon(_dagbaniPlaying ? Icons.volume_up_rounded : Icons.record_voice_over_rounded, color: Colors.white),
            onPressed: () => setState(() => _dagbaniPlaying = !_dagbaniPlaying),
            tooltip: 'Hear in Dagbani',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // ── Hero Action Banner ─────────────────────────────────
                    ScaleTransition(
                      scale: _scaleBadge,
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: actionColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: actionColor.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8)),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(actionIcon, style: const TextStyle(fontSize: 52)),
                            const SizedBox(height: 12),
                            Text(
                              actionTitle,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, height: 1.3),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              actionSubtitle,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withValues(alpha: 0.9), height: 1.5),
                            ),
                            if (_dagbaniPlaying) ...[
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.volume_up_rounded, size: 16, color: Colors.white),
                                  const SizedBox(width: 6),
                                  Text('Playing in Dagbani…',
                                      style: GoogleFonts.inter(fontSize: 12, color: Colors.white, fontStyle: FontStyle.italic)),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // ── Step-by-Step Instructions ──────────────────────────
                    FadeTransition(
                      opacity: _fadeSections,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('What to do:',
                                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                            const SizedBox(height: 10),

                            ...actionSteps.asMap().entries.map((entry) => Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: actionColor.withValues(alpha: 0.2)),
                                    boxShadow: AppTheme.cardShadow(),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 28, height: 28,
                                        decoration: BoxDecoration(color: actionColor, borderRadius: BorderRadius.circular(8)),
                                        child: Center(
                                          child: Text('${entry.key + 1}',
                                              style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(entry.value,
                                            style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textDark, height: 1.5)),
                                      ),
                                    ],
                                  ),
                                )),

                            // Danger signs summary if any
                            if (widget.ruleResult.reasons.isNotEmpty && tier != RiskTier.ROUTINE) ...[
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: actionColor.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: actionColor.withValues(alpha: 0.25)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Signs detected:', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: actionColor)),
                                    const SizedBox(height: 8),
                                    ...widget.ruleResult.reasons.take(3).map((r) => Padding(
                                          padding: const EdgeInsets.only(bottom: 4),
                                          child: Row(
                                            children: [
                                              Icon(Icons.circle, size: 6, color: actionColor),
                                              const SizedBox(width: 8),
                                              Expanded(child: Text(r, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textDark, height: 1.4))),
                                            ],
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Done button ───────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, -4))],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: widget.onRefer,
                  icon: const Icon(Icons.home_rounded, color: Colors.white),
                  label: Text('Done — Back to Household List',
                      style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: actionColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── CHW: Full clinical tier result ──────────────────────────────────────────
  Widget _buildCHWResult() {
    Color tierColor;
    Color tierGlow;
    Color tierLight;
    IconData tierIcon;
    String statusTitle;

    switch (widget.ruleResult.overallTier) {
      case RiskTier.URGENT:
        tierColor = AppTheme.urgentRed;
        tierGlow = AppTheme.urgentRedGlow;
        tierLight = AppTheme.urgentRedLight;
        tierIcon = Icons.warning_amber_rounded;
        statusTitle = 'URGENT RISK';
        break;
      case RiskTier.WATCH:
        tierColor = AppTheme.watchAmber;
        tierGlow = AppTheme.watchAmberGlow;
        tierLight = AppTheme.watchAmberLight;
        tierIcon = Icons.visibility_outlined;
        statusTitle = 'WATCH RISK';
        break;
      case RiskTier.ROUTINE:
        tierColor = AppTheme.routineGreen;
        tierGlow = AppTheme.routineGreenGlow;
        tierLight = AppTheme.routineGreenLight;
        tierIcon = Icons.check_circle_outline;
        statusTitle = 'ROUTINE STATUS';
        break;
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('AI Risk Assessment', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        elevation: 0,
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppTheme.navyGradient)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // ── Animated Hero Banner ──────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                      decoration: BoxDecoration(
                        color: tierColor,
                        boxShadow: [BoxShadow(color: tierGlow, blurRadius: 20, offset: const Offset(0, 6))],
                      ),
                      child: Column(
                        children: [
                          ScaleTransition(
                            scale: _scaleBadge,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 110, height: 110,
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.1)),
                                ),
                                Container(
                                  width: 88, height: 88,
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.15)),
                                ),
                                Container(
                                  width: 68, height: 68,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.25),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                                  ),
                                  child: Icon(tierIcon, color: Colors.white, size: 36),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'CLINICAL AI TRIAGE',
                            style: GoogleFonts.inter(
                                fontSize: 11, fontWeight: FontWeight.bold,
                                color: Colors.white.withValues(alpha: 0.75), letterSpacing: 1.5),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            statusTitle,
                            style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: FadeTransition(
                        opacity: _fadeSections,
                        child: Column(
                          children: [
                            // ── Why Flagged Card ────────────────────────
                            _SectionCard(
                              icon: Icons.shield_outlined,
                              iconColor: tierColor,
                              title: 'WHY THIS IS FLAGGED',
                              child: Column(
                                children: widget.ruleResult.reasons.map((reason) => Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: tierColor.withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: tierColor.withValues(alpha: 0.15)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(top: 3),
                                        width: 8, height: 8,
                                        decoration: BoxDecoration(color: tierColor, shape: BoxShape.circle),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(reason,
                                            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600,
                                                color: AppTheme.textDark, height: 1.4)),
                                      ),
                                    ],
                                  ),
                                )).toList(),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // ── Protocol codes ──────────────────────────
                            if (widget.ruleResult.ghsProtocolCodes.isNotEmpty) ...[
                              _SectionCard(
                                icon: Icons.medical_information_outlined,
                                iconColor: AppTheme.primaryNavy,
                                title: 'GHS PROTOCOL CODES',
                                child: Wrap(
                                  spacing: 8, runSpacing: 8,
                                  children: widget.ruleResult.ghsProtocolCodes.map((code) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryNavy.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppTheme.primaryNavy.withValues(alpha: 0.2)),
                                    ),
                                    child: Text('GHS: $code',
                                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryNavy)),
                                  )).toList(),
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],

                            // ── Clinical Recommendation ─────────────────
                            _SectionCard(
                              icon: Icons.medical_services_outlined,
                              iconColor: AppTheme.accentTeal,
                              title: 'CLINICAL RECOMMENDATION',
                              accent: AppTheme.accentTeal,
                              child: Text(
                                widget.ruleResult.primaryRecommendation,
                                style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textDark, height: 1.6),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // ── Trend Outlook ───────────────────────────
                            _SectionCard(
                              icon: Icons.trending_down_rounded,
                              iconColor: AppTheme.watchAmber,
                              title: 'TREND OUTLOOK (Layer 2 Heuristic)',
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.watchAmber.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('Rule-based Advisory',
                                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold,
                                        color: AppTheme.watchAmber)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.trendResult.summary,
                                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600,
                                          color: AppTheme.textDark, height: 1.4)),
                                  const SizedBox(height: 8),
                                  Text(widget.trendResult.advisoryDisclaimer,
                                      style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMedium,
                                          fontStyle: FontStyle.italic, height: 1.4)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Action Buttons ─────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, -4))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: widget.onOverride,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppTheme.textMedium.withValues(alpha: 0.5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text('Override & add note',
                            style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: widget.onRefer,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: tierColor,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: tierGlow, blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        child: Center(
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.send_rounded, color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Text('Refer Patient',
                                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section card ──────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;
  final Color? accent;
  final Widget? trailing;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
    this.accent,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: AppTheme.cardShadow(),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(title,
                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy,
                      letterSpacing: 0.3)),
            ),
            if (trailing != null) trailing!,
          ]),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
