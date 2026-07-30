import 'package:flutter/material.dart';
import '../../core/theme.dart';

class AICareRecommendationsScreen extends StatelessWidget {
  final VoidCallback onFinishToHome;

  const AICareRecommendationsScreen({super.key, required this.onFinishToHome});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('18. AI Care Recommendations'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personalized Care Plan for Household',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.primaryNavy,
                    ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Actionable guidance for the CHW and caregiver:',
                style: TextStyle(fontSize: 13, color: AppTheme.textMedium),
              ),
              const SizedBox(height: 16),
              _buildCareCard(
                icon: Icons.access_time_filled,
                title: 'Increase Feeding Frequency',
                description: 'Feed child small, frequent energy-dense meals 3–4 times daily.',
              ),
              const SizedBox(height: 12),
              _buildCareCard(
                icon: Icons.sanitizer,
                title: 'Clean Water & Hand Hygiene',
                description: 'Ensure all drinking water is boiled or treated. Wash hands before feeding.',
              ),
              const SizedBox(height: 12),
              _buildCareCard(
                icon: Icons.thermostat,
                title: 'Monitor Fever & Diarrhea',
                description: 'Check body temperature daily. If fever exceeds 37.5°C, return to CHPS compound immediately.',
              ),
              const SizedBox(height: 12),
              _buildCareCard(
                icon: Icons.calendar_today,
                title: 'Follow-up Visit in 7 Days',
                description: 'Schedule a mandatory follow-up CHW home visit next week to re-measure MUAC.',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Caregiver advice SMS generated and queued!'),
                        backgroundColor: AppTheme.primaryNavy,
                      ),
                    );
                  },
                  icon: const Icon(Icons.sms_outlined),
                  label: const Text('Generate SMS for Caregiver', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: onFinishToHome,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.primaryNavy, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Complete & Return to Visit List', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCareCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryNavy.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryNavy, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 13, color: AppTheme.textMedium, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
