import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../widgets/breathing_timer_widget.dart';

class YoungInfantAssessmentScreen extends StatefulWidget {
  final Function(int rr, double temp, Map<String, bool> infantSigns) onNext;

  const YoungInfantAssessmentScreen({super.key, required this.onNext});

  @override
  State<YoungInfantAssessmentScreen> createState() => _YoungInfantAssessmentScreenState();
}

class _YoungInfantAssessmentScreenState extends State<YoungInfantAssessmentScreen> {
  int _breathingRate = 62; // Fast breathing threshold > 60
  double _temp = 37.8; // Fever threshold >= 37.5

  final Map<String, bool> _infantSigns = {
    'severeChestIndrawing': false,
    'noSpontaneousMovement': false,
    'notFeedingWell': false,
    'infantConvulsionsHistory': false,
    'jaundiceEarlyOrYellowPalms': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('13. Young Infant Assessment (<2m)'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'C. Young Infant Danger Signs (Under 2 Months)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
              ),
              const SizedBox(height: 4),
              const Text(
                'ANY ONE sign present = Automatic URGENT Triage.',
                style: TextStyle(fontSize: 12, color: AppTheme.urgentRed, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              // 60-Second Breathing Tap Timer Widget
              BreathingTimerWidget(
                onTimerComplete: (count, isFast) {
                  setState(() {
                    _breathingRate = count;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Temperature Slider Container
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
                          'Axillary Body Temp (°C)',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _temp >= 37.5 || _temp < 35.5
                                ? AppTheme.urgentRedLight
                                : AppTheme.routineGreenLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${_temp.toStringAsFixed(1)} °C ${_temp >= 37.5 ? '(Fever)' : _temp < 35.5 ? '(Hypothermia)' : '(Normal)'}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: _temp >= 37.5 || _temp < 35.5 ? AppTheme.urgentRed : AppTheme.routineGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _temp,
                      min: 34.0,
                      max: 41.0,
                      divisions: 70,
                      activeColor: _temp >= 37.5 || _temp < 35.5 ? AppTheme.urgentRed : AppTheme.accentTeal,
                      onChanged: (val) => setState(() => _temp = double.parse(val.toStringAsFixed(1))),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Additional Infant Toggles
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Column(
                  children: [
                    _buildToggleRow('Severe chest in-drawing', 'severeChestIndrawing'),
                    const Divider(height: 1),
                    _buildToggleRow('No spontaneous movement', 'noSpontaneousMovement'),
                    const Divider(height: 1),
                    _buildToggleRow('Not feeding well', 'notFeedingWell'),
                    const Divider(height: 1),
                    _buildToggleRow('History of convulsions', 'infantConvulsionsHistory'),
                    const Divider(height: 1),
                    _buildToggleRow('Jaundice (24h) or yellow palms/soles', 'jaundiceEarlyOrYellowPalms'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => widget.onNext(_breathingRate, _temp, _infantSigns),
                  child: const Text('Next: Maternal Assessment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleRow(String title, String key) {
    final value = _infantSigns[key] ?? false;
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
                onSelected: (sel) => setState(() => _infantSigns[key] = false),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Yes'),
                selected: value,
                selectedColor: AppTheme.urgentRed,
                labelStyle: TextStyle(color: value ? Colors.white : AppTheme.textDark),
                onSelected: (sel) => setState(() => _infantSigns[key] = true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
