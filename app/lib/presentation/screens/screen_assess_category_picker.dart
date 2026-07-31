import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../domain/models/clinical_models.dart';

/// Screen that appears when the user taps the Assess tab without a
/// pre-loaded visit context.  Lets the CHW choose which patient category
/// to assess: Child Under 5, Newborn / Young Infant, or Maternal.
class AssessCategoryPickerScreen extends StatelessWidget {
  /// Called with the chosen category so the parent shell can route
  /// to the correct assessment form.
  final void Function(PersonCategory category) onCategorySelected;

  const AssessCategoryPickerScreen({super.key, required this.onCategorySelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              decoration: BoxDecoration(
                color: AppTheme.primaryNavy,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New Assessment',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select the patient category to begin clinical triage',
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WHO IS BEING ASSESSED?',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textMedium,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _CategoryCard(
                      icon: Icons.child_care_rounded,
                      color: const Color(0xFF00897B),
                      label: 'Child Under 5',
                      sublabel: 'Ages 2 – 59 months',
                      description:
                          'MUAC measurement, bilateral oedema, WHO IMCI danger signs, '
                          'breathing rate assessment, and EPI schedule check.',
                      badge: 'IMCI Protocol',
                      badgeColor: const Color(0xFF00897B),
                      onTap: () => onCategorySelected(PersonCategory.childUnder5),
                    ),
                    const SizedBox(height: 14),

                    _CategoryCard(
                      icon: Icons.baby_changing_station_rounded,
                      color: const Color(0xFF7B1FA2),
                      label: 'Newborn / Young Infant',
                      sublabel: 'Ages 0 – 2 months',
                      description:
                          'Young infant danger signs (chest indrawing, jaundice, feeding), '
                          'temperature, breathing rate, and newborn PNC schedule.',
                      badge: 'Young Infant Form',
                      badgeColor: const Color(0xFF7B1FA2),
                      onTap: () => onCategorySelected(PersonCategory.newbornYoungInfant),
                    ),
                    const SizedBox(height: 14),

                    _CategoryCard(
                      icon: Icons.pregnant_woman_rounded,
                      color: AppTheme.urgentRed,
                      label: 'Maternal',
                      sublabel: 'Pregnant, postpartum, or woman of reproductive age',
                      description:
                          'Haemoglobin / pallor proxy, danger signs (bleeding, convulsions, '
                          'reduced fetal movement), ANC / PNC contact tracking.',
                      badge: 'Maternal Protocol',
                      badgeColor: AppTheme.urgentRed,
                      onTap: () => onCategorySelected(PersonCategory.mother),
                    ),

                    const SizedBox(height: 28),

                    // WHO guideline note
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.accentTeal.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.accentTeal.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded, color: AppTheme.accentTeal, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'All assessments follow WHO IMCI / GHS national protocols. '
                              'Clinical rule results are generated fully offline — no internet required at point of care.',
                              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textDark, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Private reusable card widget ───────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String sublabel;
  final String description;
  final String badge;
  final Color badgeColor;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.sublabel,
    required this.description,
    required this.badge,
    required this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              // Icon circle
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 16),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            label,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            badge,
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: badgeColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sublabel,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.textMedium,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
