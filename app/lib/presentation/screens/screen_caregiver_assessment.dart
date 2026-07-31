import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../domain/models/clinical_models.dart';
import '../../domain/rules/imci_rules_engine.dart';
import '../../core/services/audio_service.dart';

class CaregiverAssessmentScreen extends StatefulWidget {
  final Function(AssessmentInput input, ClinicalRuleResult result) onAssessmentComplete;

  const CaregiverAssessmentScreen({super.key, required this.onAssessmentComplete});

  @override
  State<CaregiverAssessmentScreen> createState() => _CaregiverAssessmentScreenState();
}

class _CaregiverAssessmentScreenState extends State<CaregiverAssessmentScreen> {
  bool _cannotFeed = false;
  bool _vomitingAll = false;
  bool _hasConvulsions = false;
  bool _unusuallySleepy = false;
  bool _fastBreathing = false;
  bool _swollenFeet = false;
  bool _maternalBleeding = false;
  bool _maternalHeadache = false;

  ClinicalRuleResult? _result;

  void _evaluateCaregiverInput() {
    final input = AssessmentInput(
      convulsions: _hasConvulsions,
      unableToDrinkBreastfeed: _cannotFeed,
      vomitsEverything: _vomitingAll,
      lethargicOrUnconscious: _unusuallySleepy,
      isYoungInfant: _fastBreathing,
      breathingRate: _fastBreathing ? 62 : 40,
      bilateralOedema: _swollenFeet,
      pregnancyStatus: PregnancyStatus.currentlyPregnant,
      vaginalBleeding: _maternalBleeding,
      severeHeadacheBlurredVision: _maternalHeadache,
    );

    final res = IMCIRulesEngine.evaluate(input);
    setState(() {
      _result = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Health Check', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
      ),
      backgroundColor: AppTheme.backgroundLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryNavy,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(color: AppTheme.accentTeal.withValues(alpha: 0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.family_restroom_rounded, color: AppTheme.accentTeal, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Family & Child Safety Check', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text('Tap any symptoms you notice today for clear guidance.', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Text('Child & Baby Warning Signs', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
            const SizedBox(height: 10),

            _buildCheckTile(
              icon: Icons.no_food_rounded,
              title: 'Cannot drink or breastfeed',
              subtitle: 'Child refuses all food or liquids',
              value: _cannotFeed,
              onChanged: (v) { setState(() => _cannotFeed = v!); _evaluateCaregiverInput(); },
            ),
            _buildCheckTile(
              icon: Icons.sick_rounded,
              title: 'Vomiting everything',
              subtitle: 'Throws up immediately after eating or drinking',
              value: _vomitingAll,
              onChanged: (v) { setState(() => _vomitingAll = v!); _evaluateCaregiverInput(); },
            ),
            _buildCheckTile(
              icon: Icons.flash_on_rounded,
              title: 'Convulsions or fits',
              subtitle: 'Shaking, jerking movements or loss of consciousness',
              value: _hasConvulsions,
              onChanged: (v) { setState(() => _hasConvulsions = v!); _evaluateCaregiverInput(); },
            ),
            _buildCheckTile(
              icon: Icons.airline_seat_flat_rounded,
              title: 'Unusually sleepy or hard to wake',
              subtitle: 'Child is very weak, lethargic or unresponsive',
              value: _unusuallySleepy,
              onChanged: (v) { setState(() => _unusuallySleepy = v!); _evaluateCaregiverInput(); },
            ),
            _buildCheckTile(
              icon: Icons.speed_rounded,
              title: 'Breathing very fast or struggling',
              subtitle: 'Chest pulls in deeply when breathing',
              value: _fastBreathing,
              onChanged: (v) { setState(() => _fastBreathing = v!); _evaluateCaregiverInput(); },
            ),
            _buildCheckTile(
              icon: Icons.do_not_step_rounded,
              title: 'Swollen feet or ankles',
              subtitle: 'Pitting swelling on both feet',
              value: _swollenFeet,
              onChanged: (v) { setState(() => _swollenFeet = v!); _evaluateCaregiverInput(); },
            ),

            const SizedBox(height: 20),
            Text('Mother Health Warning Signs', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
            const SizedBox(height: 10),

            _buildCheckTile(
              icon: Icons.bloodtype_rounded,
              title: 'Vaginal bleeding',
              subtitle: 'Bleeding during pregnancy or heavy post-birth bleeding',
              value: _maternalBleeding,
              onChanged: (v) { setState(() => _maternalBleeding = v!); _evaluateCaregiverInput(); },
            ),
            _buildCheckTile(
              icon: Icons.visibility_off_rounded,
              title: 'Severe headache or blurred vision',
              subtitle: 'Constant bad headache or seeing spots',
              value: _maternalHeadache,
              onChanged: (v) { setState(() => _maternalHeadache = v!); _evaluateCaregiverInput(); },
            ),

            const SizedBox(height: 24),

            // Action Result Card
            if (_result != null) _buildResultActionCard(_result!),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: value ? AppTheme.urgentRed.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: value ? AppTheme.urgentRed : AppTheme.cardBorder),
      ),
      child: CheckboxListTile(
        secondary: Icon(icon, color: value ? AppTheme.urgentRed : AppTheme.primaryNavy),
        title: Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMedium)),
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.urgentRed,
      ),
    );
  }

  Widget _buildResultActionCard(ClinicalRuleResult res) {
    Color cardColor;
    IconData icon;
    String actionTitle;
    String actionDesc;

    switch (res.overallTier) {
      case RiskTier.URGENT:
        cardColor = AppTheme.urgentRed;
        icon = Icons.warning_amber_rounded;
        actionTitle = '🚨 Go to the clinic now';
        actionDesc = 'One or more dangerous signs detected. Please bring your child or mother to the nearest CHPS compound or hospital immediately.';
        break;
      case RiskTier.WATCH:
        cardColor = AppTheme.watchAmber;
        icon = Icons.error_outline_rounded;
        actionTitle = '⚠️ See a health worker in the next few days';
        actionDesc = 'Warning signs detected. Visit your local Community Health Officer soon for clinical assessment.';
        break;
      case RiskTier.ROUTINE:
      default:
        cardColor = AppTheme.routineGreen;
        icon = Icons.check_circle_outline_rounded;
        actionTitle = '✅ Continue routine care';
        actionDesc = 'No danger signs selected today. Keep up with routine feeding, clean water, and scheduled immunization visits.';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: cardColor, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(actionTitle, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: cardColor)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(actionDesc, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textDark, height: 1.4)),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () {
                final input = AssessmentInput(
                  convulsions: _hasConvulsions,
                  unableToDrinkBreastfeed: _cannotFeed,
                  vomitsEverything: _vomitingAll,
                  lethargicOrUnconscious: _unusuallySleepy,
                  isYoungInfant: _fastBreathing,
                  breathingRate: _fastBreathing ? 62 : 40,
                  bilateralOedema: _swollenFeet,
                  vaginalBleeding: _maternalBleeding,
                  severeHeadacheBlurredVision: _maternalHeadache,
                );
                widget.onAssessmentComplete(input, res);
              },
              icon: const Icon(Icons.save_rounded, color: Colors.white, size: 18),
              label: Text('Save Home Check Result', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
