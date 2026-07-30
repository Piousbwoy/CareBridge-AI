import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class AICareRecommendationsScreen extends StatelessWidget {
  final VoidCallback? onFinish;
  final VoidCallback? onFinishToHome;

  const AICareRecommendationsScreen({
    super.key,
    this.onFinish,
    this.onFinishToHome,
  });

  void _triggerFinish() {
    if (onFinish != null) {
      onFinish!();
    } else if (onFinishToHome != null) {
      onFinishToHome!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('18. AI Care Recommendations', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryNavy,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: AppTheme.accentTeal, borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.assignment_rounded, color: Colors.white, size: 26),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Personalized Care Plan', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                Text('Actionable steps for CHW follow-up & caregiver guidance.', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Actionable Protocol Checklist
                    _CareStepTile(
                      stepNum: 1,
                      title: 'Increase Feeding Frequency',
                      desc: 'Feed child 3–4 times daily plus 1–2 healthy snacks between regular meals.',
                      icon: Icons.restaurant_rounded,
                      color: AppTheme.accentTeal,
                    ),
                    _CareStepTile(
                      stepNum: 2,
                      title: 'Add Energy-Dense Foods',
                      desc: 'Mix roasted groundnut paste, cowpea flour, or boiled egg yolk into porridge.',
                      icon: Icons.local_fire_department_rounded,
                      color: AppTheme.watchAmber,
                    ),
                    _CareStepTile(
                      stepNum: 3,
                      title: 'Ensure Clean Water & Hygiene',
                      desc: 'Boil drinking water and practice thorough handwashing with soap before feeding.',
                      icon: Icons.clean_hands_rounded,
                      color: AppTheme.primaryNavy,
                    ),
                    _CareStepTile(
                      stepNum: 4,
                      title: 'Monitor for Fever or Diarrhoea',
                      desc: 'If fever exceeds 37.5°C or diarrhoea begins, refer immediately to CHPS compound.',
                      icon: Icons.health_and_safety_rounded,
                      color: AppTheme.urgentRed,
                    ),
                    _CareStepTile(
                      stepNum: 5,
                      title: 'Follow-up Visit in 7 Days',
                      desc: 'Schedule next home visit for MUAC re-measurement and growth tracking.',
                      icon: Icons.event_repeat_rounded,
                      color: AppTheme.routineGreen,
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Care plan SMS dispatched to caregiver phone!')),
                        );
                      },
                      icon: const Icon(Icons.sms_rounded, color: Colors.white),
                      label: Text('Generate SMS for Caregiver', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentTeal,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: TextButton(
                      onPressed: _triggerFinish,
                      child: Text('Complete Assessment & Return Home', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textMedium)),
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

class _CareStepTile extends StatelessWidget {
  final int stepNum;
  final String title;
  final String desc;
  final IconData icon;
  final Color color;

  const _CareStepTile({
    required this.stepNum,
    required this.title,
    required this.desc,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$stepNum. $title', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                const SizedBox(height: 3),
                Text(desc, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMedium, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
