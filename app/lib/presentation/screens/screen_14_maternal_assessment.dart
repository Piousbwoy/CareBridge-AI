import 'package:flutter/material.dart';
import '../../core/theme.dart';

class MaternalAssessmentScreen extends StatefulWidget {
  final Function(double? hb, bool pallorProxy, Map<String, bool> maternalSigns) onCompleteAssessment;

  const MaternalAssessmentScreen({super.key, required this.onCompleteAssessment});

  @override
  State<MaternalAssessmentScreen> createState() => _MaternalAssessmentScreenState();
}

class _MaternalAssessmentScreenState extends State<MaternalAssessmentScreen> {
  bool _hasHbMeter = true;
  double _hbLevel = 8.4; // Moderate anaemia threshold (7.0 - 10.0)
  bool _pallorProxy = false;

  final Map<String, bool> _maternalSigns = {
    'vaginalBleeding': false,
    'maternalConvulsions': false,
    'severeHeadacheBlurredVision': false,
    'reducedAbsentFetalMovement': false,
  };

  @override
  Widget build(BuildContext context) {
    String hbTag = _hbLevel < 7.0
        ? 'Severe Anaemia'
        : _hbLevel <= 10.0
            ? 'Moderate Anaemia'
            : 'Normal';
    Color hbTagColor = _hbLevel < 7.0
        ? AppTheme.urgentRed
        : _hbLevel <= 10.0
            ? AppTheme.watchAmber
            : AppTheme.routineGreen;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('14. Maternal Assessment'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Domain D: Maternal Anaemia
              const Text(
                'D. Maternal Anaemia',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
              ),
              const SizedBox(height: 8),
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
                          'Hb Meter Available?',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                        ),
                        Switch(
                          value: _hasHbMeter,
                          activeColor: AppTheme.primaryNavy,
                          onChanged: (val) => setState(() => _hasHbMeter = val),
                        ),
                      ],
                    ),
                    const Divider(),
                    if (_hasHbMeter) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Haemoglobin (g/dL)',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: hbTagColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_hbLevel.toStringAsFixed(1)} g/dL · $hbTag',
                              style: TextStyle(fontWeight: FontWeight.bold, color: hbTagColor, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _hbLevel,
                        min: 4.0,
                        max: 15.0,
                        divisions: 110,
                        activeColor: hbTagColor,
                        onChanged: (val) => setState(() => _hbLevel = double.parse(val.toStringAsFixed(1))),
                      ),
                    ] else ...[
                      const Text(
                        'No Hb reading available? Use visual check:',
                        style: TextStyle(fontSize: 13, color: AppTheme.textMedium),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Conjunctiva / Palmar Pallor',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                          ),
                          Row(
                            children: [
                              ChoiceChip(
                                label: const Text('No'),
                                selected: !_pallorProxy,
                                onSelected: (sel) => setState(() => _pallorProxy = false),
                              ),
                              const SizedBox(width: 8),
                              ChoiceChip(
                                label: const Text('Yes'),
                                selected: _pallorProxy,
                                selectedColor: AppTheme.watchAmber,
                                labelStyle: TextStyle(color: _pallorProxy ? Colors.white : AppTheme.textDark),
                                onSelected: (sel) => setState(() => _pallorProxy = true),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Domain E: Maternal Danger Signs
              const Text(
                'E. Maternal Danger Signs',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
              ),
              const SizedBox(height: 4),
              const Text(
                'ANY ONE present = Automatic URGENT Triage.',
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
                    _buildToggleRow('Vaginal bleeding', 'vaginalBleeding'),
                    const Divider(height: 1),
                    _buildToggleRow('Convulsions', 'maternalConvulsions'),
                    const Divider(height: 1),
                    _buildToggleRow('Severe headache or blurred vision', 'severeHeadacheBlurredVision'),
                    const Divider(height: 1),
                    _buildToggleRow('Reduced or absent fetal movement', 'reducedAbsentFetalMovement'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    widget.onCompleteAssessment(
                      _hasHbMeter ? _hbLevel : null,
                      _pallorProxy,
                      _maternalSigns,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.urgentRed,
                  ),
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text(
                    'Generate AI Triage & Risk Result',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleRow(String title, String key) {
    final value = _maternalSigns[key] ?? false;
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
                onSelected: (sel) => setState(() => _maternalSigns[key] = false),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Yes'),
                selected: value,
                selectedColor: AppTheme.urgentRed,
                labelStyle: TextStyle(color: value ? Colors.white : AppTheme.textDark),
                onSelected: (sel) => setState(() => _maternalSigns[key] = true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
