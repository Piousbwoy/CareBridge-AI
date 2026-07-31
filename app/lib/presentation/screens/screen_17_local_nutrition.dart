import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class LocalNutritionScreen extends StatelessWidget {
  final VoidCallback onNextCarePlan;

  const LocalNutritionScreen({super.key, required this.onNextCarePlan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('17. Local Nutrition Guidance', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
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
                    // Header Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.accentTeal.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.accentTeal.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(color: AppTheme.accentTeal, shape: BoxShape.circle),
                            child: const Icon(Icons.rice_bowl_rounded, color: Colors.white, size: 26),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Northern Ghana Local Meal Guidance', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                                Text('High-energy, affordable local food guidance for maternal and child nutritional recovery.', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMedium, height: 1.3)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Featured Recipe Card: Enriched Koko Bowl
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Enriched Koko Bowl (Hausa Koko)', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: AppTheme.accentTeal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                  child: Text('High Energy', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.accentTeal)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('Fortified millet porridge with groundnut paste & egg yolk for weight gain.', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMedium)),
                            const SizedBox(height: 14),

                            Text('Ingredients (Locally Available)', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8, runSpacing: 8,
                              children: [
                                _IngredientChip('Fermented Millet (Koko)', Icons.grain_rounded),
                                _IngredientChip('Groundnut Paste', Icons.spa_rounded),
                                _IngredientChip('Cowpea Flour', Icons.eco_rounded),
                                _IngredientChip('Palm Oil / Egg Yolk', Icons.egg_alt_rounded),
                              ],
                            ),

                            const SizedBox(height: 14),
                            Text('How to Prepare:', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                            const SizedBox(height: 6),
                            Text('1. Prepare smooth millet koko with boiled water.\n2. Stir in 2 tablespoons of roasted groundnut paste.\n3. Add 1 whisked egg yolk while simmering.\n4. Feed child 3–4 times daily alongside breastfeeding.',
                                style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textDark, height: 1.5)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Additional Local Meals
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Alternative Recovery Meals', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                            const SizedBox(height: 10),
                            _MealItem(title: 'Millet & Groundnut Paste Stew', desc: 'Protein-dense mash suitable for infants 9+ months.'),
                            const Divider(height: 16),
                            _MealItem(title: 'Fortified Soybean & Maize Weanimix', desc: 'GHS approved complementary weaning blend for MAM cases.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Next Care Plan Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))]),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: onNextCarePlan,
                  icon: const Icon(Icons.assignment_turned_in_rounded, color: Colors.white),
                  label: Text('View Care Recommendations', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNavy,
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
}

class _IngredientChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _IngredientChip(this.label, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryNavy.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryNavy.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryNavy),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy)),
        ],
      ),
    );
  }
}

class _MealItem extends StatelessWidget {
  final String title;
  final String desc;
  const _MealItem({required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        const SizedBox(height: 2),
        Text(desc, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMedium)),
      ],
    );
  }
}
