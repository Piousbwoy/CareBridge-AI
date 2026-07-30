import 'package:flutter/material.dart';
import '../../core/theme.dart';

class LocalNutritionScreen extends StatelessWidget {
  final VoidCallback onNextCarePlan;

  const LocalNutritionScreen({super.key, required this.onNextCarePlan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('17. Local Nutrition Guidance'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accentTeal.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.accentTeal.withOpacity(0.3)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.rice_bowl, color: AppTheme.accentTeal, size: 32),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI-Generated Local Meal Plan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryNavy,
                            ),
                          ),
                          Text(
                            'High-energy, affordable local meals tailored for Northern Ghana SAM/MAM recovery.',
                            style: TextStyle(fontSize: 12, color: AppTheme.textMedium),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Enriched Koko Recipe Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Enriched Koko Bowl',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.routineGreenLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Local High Energy',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.routineGreen),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Ingredients (Locally Available in Savannah/Northern Region):',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildIngredientChip('Fermented Millet / Sorghum Koko'),
                        _buildIngredientChip('Groundnut Paste (Peanut)'),
                        _buildIngredientChip('Cowpea / Beans Flour'),
                        _buildIngredientChip('Red Palm Oil'),
                        _buildIngredientChip('Mashed Ripe Plantain'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'How to Prepare:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '1. Cook enriched koko with water. Add groundnut paste and cowpea flour.\n'
                      '2. Stir well and add half a spoon of red palm oil before serving.\n'
                      '3. Serve warm 3–4 times daily alongside continued breastfeeding.',
                      style: TextStyle(fontSize: 13, color: AppTheme.textMedium, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: onNextCarePlan,
                  child: const Text('Next: AI Care Recommendations'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline, size: 14, color: AppTheme.accentTeal),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy)),
        ],
      ),
    );
  }
}
