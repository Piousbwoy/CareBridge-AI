import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/services/audio_service.dart';

class ChildAssessmentScreen extends StatefulWidget {
  final Function(double muac, bool oedema, Map<String, bool> dangerSigns) onNext;

  const ChildAssessmentScreen({super.key, required this.onNext});

  @override
  State<ChildAssessmentScreen> createState() => _ChildAssessmentScreenState();
}

class _ChildAssessmentScreenState extends State<ChildAssessmentScreen> {
  double _muac = 10.5;
  bool _oedema = false;

  final Map<String, bool> _dangerSigns = {
    'convulsions': false,
    'unableToDrinkBreastfeed': false,
    'vomitsEverything': false,
    'lethargicOrUnconscious': false,
    'severePalmarPallor': false,
    'stiffNeck': false,
  };

  @override
  Widget build(BuildContext context) {
    String muacTag = _muac < 11.5
        ? 'SAM (Severe)'
        : _muac <= 12.5
            ? 'MAM (Moderate)'
            : 'Normal';
    Color muacTagColor = _muac < 11.5
        ? AppTheme.urgentRed
        : _muac <= 12.5
            ? AppTheme.watchAmber
            : AppTheme.routineGreen;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('12. Child Assessment (6-59m)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_outlined),
            tooltip: 'Play Dagbani Audio Prompt',
            onPressed: () {
              LocalAudioService().playDagbaniAudio('muac');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Playing audio: MUAC assessment guide (Dagbani)')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section A: Malnutrition
              _buildSectionHeader('A. Child Malnutrition (6-59 months)'),
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
                          'MUAC (cm)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: muacTagColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$_muac cm · $muacTag',
                            style: TextStyle(fontWeight: FontWeight.bold, color: muacTagColor, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: _muac,
                      min: 8.0,
                      max: 18.0,
                      divisions: 100,
                      activeColor: muacTagColor,
                      label: '${_muac.toStringAsFixed(1)} cm',
                      onChanged: (val) => setState(() => _muac = double.parse(val.toStringAsFixed(1))),
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bilateral Pitting Oedema',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                              ),
                              Text(
                                'Thumb pressed 3 sec on both feet, indentation remains',
                                style: TextStyle(fontSize: 12, color: AppTheme.textMedium),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _oedema,
                          activeColor: AppTheme.urgentRed,
                          onChanged: (val) => setState(() => _oedema = val),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Section B: General Danger Signs
              _buildSectionHeader('B. Child General Danger Signs (Under 5)'),
              const Text(
                'ANY ONE present = automatic URGENT triage, overriding all else.',
                style: TextStyle(fontSize: 12, color: AppTheme.urgentRed, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Column(
                  children: [
                    _buildToggleRow('Convulsions during this illness', 'convulsions'),
                    const Divider(height: 1),
                    _buildToggleRow('Unable to drink or breastfeed', 'unableToDrinkBreastfeed'),
                    const Divider(height: 1),
                    _buildToggleRow('Vomits everything', 'vomitsEverything'),
                    const Divider(height: 1),
                    _buildToggleRow('Lethargic or unconscious', 'lethargicOrUnconscious'),
                    const Divider(height: 1),
                    _buildToggleRow('Severe palmar pallor', 'severePalmarPallor'),
                    const Divider(height: 1),
                    _buildToggleRow('Stiff neck', 'stiffNeck'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => widget.onNext(_muac, _oedema, _dangerSigns),
                  child: const Text('Next: Young Infant Assessment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
      ),
    );
  }

  Widget _buildToggleRow(String title, String key) {
    final value = _dangerSigns[key] ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: value ? FontWeight.bold : FontWeight.normal,
                color: value ? AppTheme.urgentRed : AppTheme.textDark,
              ),
            ),
          ),
          Row(
            children: [
              ChoiceChip(
                label: const Text('No'),
                selected: !value,
                onSelected: (sel) => setState(() => _dangerSigns[key] = false),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Yes'),
                selected: value,
                selectedColor: AppTheme.urgentRed,
                labelStyle: TextStyle(color: value ? Colors.white : AppTheme.textDark),
                onSelected: (sel) => setState(() => _dangerSigns[key] = true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
