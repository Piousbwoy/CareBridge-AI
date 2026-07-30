import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../domain/models/clinical_models.dart';

class AIRiskResultScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    Color bannerBg;
    Color bannerText = Colors.white;
    IconData bannerIcon;
    String statusTitle;

    switch (ruleResult.overallTier) {
      case RiskTier.URGENT:
        bannerBg = AppTheme.urgentRed;
        bannerIcon = Icons.warning_amber_rounded;
        statusTitle = 'RISK STATUS: URGENT';
        break;
      case RiskTier.WATCH:
        bannerBg = AppTheme.watchAmber;
        bannerIcon = Icons.visibility_outlined;
        statusTitle = 'RISK STATUS: WATCH';
        break;
      case RiskTier.ROUTINE:
        bannerBg = AppTheme.routineGreen;
        bannerIcon = Icons.check_circle_outline;
        statusTitle = 'RISK STATUS: ROUTINE';
        break;
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('15. AI Risk Result', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. High-Impact Status Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      decoration: BoxDecoration(
                        color: bannerBg,
                        boxShadow: [BoxShadow(color: bannerBg.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                            child: Icon(bannerIcon, color: bannerText, size: 36),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('CRITICAL AI ASSESSMENT', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 1.1)),
                                const SizedBox(height: 2),
                                Text(statusTitle, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: bannerText)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 2. Clinical Reason-First Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                const Icon(Icons.shield_outlined, color: AppTheme.primaryNavy, size: 20),
                                const SizedBox(width: 8),
                                Text('WHY THIS IS FLAGGED', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                              ]),
                              const Divider(height: 20),
                              ...ruleResult.reasons.map((reason) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      width: 8, height: 8,
                                      decoration: BoxDecoration(color: bannerBg, shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(reason, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark, height: 1.4)),
                                    ),
                                  ],
                                ),
                              )),
                              if (ruleResult.ghsProtocolCodes.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 6, runSpacing: 6,
                                  children: ruleResult.ghsProtocolCodes.map((code) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryNavy.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: AppTheme.primaryNavy.withValues(alpha: 0.15)),
                                    ),
                                    child: Text('GHS: $code', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                                  )).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 3. Clinical Recommendation Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                const Icon(Icons.medical_services_outlined, color: AppTheme.accentTeal, size: 20),
                                const SizedBox(width: 8),
                                Text('CLINICAL RECOMMENDATION', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.accentTeal)),
                              ]),
                              const SizedBox(height: 10),
                              Text(ruleResult.primaryRecommendation, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textDark, height: 1.5)),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 4. Trend Outlook (Layer 2 Model Advisory)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Card(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.trending_down_rounded, color: AppTheme.watchAmber, size: 20),
                                  const SizedBox(width: 8),
                                  Text('TREND OUTLOOK (Layer 2 AI)', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.watchAmber)),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(color: AppTheme.watchAmber.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                                    child: Text('Model Advisory', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.watchAmber)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(trendResult.summary, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                              const SizedBox(height: 6),
                              Text(trendResult.advisoryDisclaimer, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMedium, fontStyle: FontStyle.italic, height: 1.3)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 5. Action Buttons (Refer vs Override with Audit)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: onOverride,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.textMedium),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Override, add note', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: onRefer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: bannerBg,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Refer Patient', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
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
