import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../widgets/breathing_timer_widget.dart';

class YoungInfantAssessmentScreen extends StatefulWidget {
  final int initialBreathingRate;
  final double initialTemp;
  final Map<String, bool> initialInfantSigns;
  final Function(int rr, double temp, Map<String, bool> infantSigns) onNext;
  final VoidCallback onBack;

  const YoungInfantAssessmentScreen({
    super.key,
    required this.initialBreathingRate,
    required this.initialTemp,
    required this.initialInfantSigns,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<YoungInfantAssessmentScreen> createState() => _YoungInfantAssessmentScreenState();
}

class _YoungInfantAssessmentScreenState extends State<YoungInfantAssessmentScreen> {
  late int _breathingRate;
  late double _temp;
  late Map<String, bool> _infantSigns;

  @override
  void initState() {
    super.initState();
    _breathingRate = widget.initialBreathingRate;
    _temp = widget.initialTemp;
    _infantSigns = Map.from(widget.initialInfantSigns);

    _infantSigns.putIfAbsent('chestIndrawing', () => false);
    _infantSigns.putIfAbsent('noMovement', () => false);
    _infantSigns.putIfAbsent('poorFeeding', () => false);
    _infantSigns.putIfAbsent('jaundice', () => false);
  }

  @override
  Widget build(BuildContext context) {
    final bool isFastBreathing = _breathingRate >= 60;
    final bool isHypothermia = _temp < 35.5;
    final bool isFever = _temp >= 37.5;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('13. Young Infant (< 2 Months)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: widget.onBack),
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
                    // Section Header
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AppTheme.primaryNavy, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('SECTION C: YOUNG INFANT DANGER SIGNS', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text('< 60 DAYS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentTeal)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Breathing Timer Widget Integration
                    BreathingTimerWidget(
                      initialRate: _breathingRate,
                      onRateChanged: (rate) => setState(() => _breathingRate = rate),
                    ),

                    const SizedBox(height: 12),

                    // Body Temperature Assessment
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Body Temperature (°C)', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isHypothermia ? AppTheme.urgentRed : (isFever ? AppTheme.watchAmber : AppTheme.routineGreen),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isHypothermia ? 'HYPOTHERMIA (< 35.5°C)' : (isFever ? 'FEVER (≥ 37.5°C)' : 'NORMAL (35.5 - 37.4°C)'),
                                    style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: Text(
                                '${_temp.toStringAsFixed(1)} °C',
                                style: GoogleFonts.outfit(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: isHypothermia ? AppTheme.urgentRed : (isFever ? AppTheme.watchAmber : AppTheme.routineGreen),
                                ),
                              ),
                            ),
                            Slider(
                              value: _temp,
                              min: 34.0,
                              max: 40.0,
                              divisions: 60,
                              activeColor: isHypothermia ? AppTheme.urgentRed : (isFever ? AppTheme.watchAmber : AppTheme.routineGreen),
                              onChanged: (val) => setState(() => _temp = val),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Infant Specific Danger Signs
                    Text('CRITICAL INFANT CLINICAL SIGNS', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                    const SizedBox(height: 10),

                    _InfantSignTile(
                      title: 'Severe Chest Indrawing',
                      subtitle: 'Lower chest wall sucks in deeply when infant breathes in',
                      value: _infantSigns['chestIndrawing'] ?? false,
                      onChanged: (v) => setState(() => _infantSigns['chestIndrawing'] = v),
                    ),
                    _InfantSignTile(
                      title: 'No Spontaneous Movement',
                      subtitle: 'Infant moves only when stimulated or not at all',
                      value: _infantSigns['noMovement'] ?? false,
                      onChanged: (v) => setState(() => _infantSigns['noMovement'] = v),
                    ),
                    _InfantSignTile(
                      title: 'Not Feeding Well',
                      subtitle: 'Infant stops feeding completely or feeds poorly',
                      value: _infantSigns['poorFeeding'] ?? false,
                      onChanged: (v) => setState(() => _infantSigns['poorFeeding'] = v),
                    ),
                    _InfantSignTile(
                      title: 'Severe Jaundice',
                      subtitle: 'Yellow palms or soles at any age, or yellow skin < 24h',
                      value: _infantSigns['jaundice'] ?? false,
                      onChanged: (v) => setState(() => _infantSigns['jaundice'] = v),
                    ),
                  ],
                ),
              ),
            ),

            // Next Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))]),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => widget.onNext(_breathingRate, _temp, _infantSigns),
                  icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                  label: Text('Continue to Maternal Assessment', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
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

class _InfantSignTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _InfantSignTile({required this.title, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: value ? AppTheme.urgentRed.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: value ? AppTheme.urgentRed.withValues(alpha: 0.4) : AppTheme.cardBorder),
      ),
      child: CheckboxListTile(
        title: Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: value ? AppTheme.urgentRed : AppTheme.textDark)),
        subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMedium)),
        value: value,
        activeColor: AppTheme.urgentRed,
        onChanged: (v) => onChanged(v ?? false),
      ),
    );
  }
}
