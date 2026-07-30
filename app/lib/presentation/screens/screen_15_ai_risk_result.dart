import 'package:flutter/material.dart';
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
    Color bannerText;
    IconData bannerIcon;
    String statusTitle;

    switch (ruleResult.overallTier) {
      case RiskTier.URGENT:
        bannerBg = AppTheme.urgentRed;
        bannerText = Colors.white;
        bannerIcon = Icons.warning_amber_rounded;
        statusTitle = 'RISK STATUS: URGENT';
        break;
      case RiskTier.WATCH:
        bannerBg = AppTheme.watchAmber;
        bannerText = Colors.white;
        bannerIcon = Icons.visibility_outlined;
        statusTitle = 'RISK STATUS: WATCH';
        break;
      case RiskTier.ROUTINE:
        bannerBg = AppTheme.routineGreen;
        bannerText = Colors.white;
        bannerIcon = Icons.check_circle_outline;
        statusTitle = 'RISK STATUS: ROUTINE';
        break;
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('15. AI Risk Result (Reason-First)'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. STATUS BAND (Full-Width, Color-Coded)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      color: bannerBg,
                      child: Row(
                        children: [
                          Icon(bannerIcon, color: bannerText, size: 40),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  statusTitle,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: bannerText,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'WHO IMCI / Ghana Health Service Protocol',
                                  style: TextStyle(fontSize: 12, color: bannerText.withOpacity(0.9)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 2. WHY THIS IS FLAGGED (Reasoning List from reason_template)
                          const Text(
                            'WHY THIS IS FLAGGED',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: AppTheme.urgentRed,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceWhite,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.cardBorder),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: ruleResult.reasons.map((reason) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.circle, size: 8, color: AppTheme.urgentRed),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          reason,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.primaryNavy,
                                            height: 1.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // 3. TREND OUTLOOK CARD (Visually & Structurally Separate)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.watchAmberLight.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.watchAmber.withOpacity(0.4)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.trending_down_rounded, color: AppTheme.watchAmber, size: 22),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'TREND OUTLOOK (Model Advisory)',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryNavy,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (trendResult.probability > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.watchAmber,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '${(trendResult.probability * 100).toInt()}% conf.',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  trendResult.summary,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryNavy,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Advisory only. Does not change the ${ruleResult.overallTier.name} flag above — that flag is set by the rules engine and cannot be lowered by this model.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                    color: AppTheme.textMedium.withOpacity(0.9),
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 4. TWO EQUAL-WEIGHT BUTTONS (Refer & Override)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppTheme.surfaceWhite,
                border: Border(top: BorderSide(color: AppTheme.cardBorder)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: onRefer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.urgentRed,
                        ),
                        child: const Text('Refer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: onOverride,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.primaryNavy, width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Override, add note',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
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
