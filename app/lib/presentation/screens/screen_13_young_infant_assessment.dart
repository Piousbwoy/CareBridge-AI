import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../data/mock_repository.dart';
import '../../domain/models/clinical_models.dart';
import '../widgets/breathing_timer_widget.dart';

// ─── SCREEN 13: YOUNG INFANT ASSESSMENT (< 2 Months) ──────────────────────────
// Role-Branching: CHW → Full clinical form | Caregiver → Plain yes/no questions
class YoungInfantAssessmentScreen extends StatefulWidget {
  final int initialBreathingRate;
  final double initialTemp;
  final Map<String, bool> initialInfantSigns;
  final Function(int rr, double temp, Map<String, bool> infantSigns) onNext;
  final VoidCallback? onBack;

  const YoungInfantAssessmentScreen({
    super.key,
    this.initialBreathingRate = 40,
    this.initialTemp = 36.8,
    this.initialInfantSigns = const {},
    required this.onNext,
    this.onBack,
  });

  @override
  State<YoungInfantAssessmentScreen> createState() => _YoungInfantAssessmentScreenState();
}

class _YoungInfantAssessmentScreenState extends State<YoungInfantAssessmentScreen> {
  late int _breathingRate;
  late double _temp;
  late Map<String, bool> _infantSigns;
  final _repo = MockRepository();

  // Caregiver plain-language questions → clinical key mapping
  static const _caregiverQuestions = {
    'chest_pulling': 'Does the baby\'s chest pull in when breathing?',
    'not_moving': 'Is the baby very still and not moving on its own?',
    'not_feeding': 'Has the baby refused to feed or breastfeed today?',
    'yellow_skin': 'Does the baby\'s skin or eyes look yellow?',
    'feels_cold': 'Does the baby\'s body feel unusually cold to touch?',
    'feels_hot': 'Does the baby\'s body feel burning hot / feverish?',
  };

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

    for (final k in _caregiverQuestions.keys) {
      _infantSigns.putIfAbsent(k, () => false);
    }
  }

  void _submitCaregiverForm() {
    // Map caregiver answers to clinical keys for the rules engine
    final mapped = Map<String, bool>.from(_infantSigns);
    mapped['chestIndrawing'] = _infantSigns['chest_pulling'] ?? false;
    mapped['noMovement'] = _infantSigns['not_moving'] ?? false;
    mapped['poorFeeding'] = _infantSigns['not_feeding'] ?? false;
    mapped['jaundice'] = _infantSigns['yellow_skin'] ?? false;

    // Derive temperature from yes/no: hypothermia proxy = 35.0, fever proxy = 38.5
    final tempProxy = (_infantSigns['feels_cold'] ?? false)
        ? 35.0
        : (_infantSigns['feels_hot'] ?? false)
            ? 38.5
            : 36.8;

    widget.onNext(_breathingRate, tempProxy, mapped);
  }

  @override
  Widget build(BuildContext context) {
    final isCaregiver = _repo.userRole == UserRole.caregiver;
    return isCaregiver ? _buildCaregiverView() : _buildCHWView();
  }

  // ─── CAREGIVER: Plain questions ─────────────────────────────────────────────
  Widget _buildCaregiverView() {
    final anyFlagged = _caregiverQuestions.keys.any((k) => _infantSigns[k] == true);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('Newborn Health Check', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        leading: widget.onBack != null
            ? IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: widget.onBack)
            : null,
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
                    // Intro card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          const Color(0xFFE3F2FD).withValues(alpha: 0.8),
                          const Color(0xFFBBDEFB).withValues(alpha: 0.4),
                        ]),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.accentTeal.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Text('👶', style: TextStyle(fontSize: 32)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Newborn Danger Signs',
                                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                                const SizedBox(height: 4),
                                Text('Answer Yes or No for your newborn. If you\'re not sure, tap Yes to be safe.',
                                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMedium, height: 1.4)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    ..._caregiverQuestions.entries.map((entry) => _SimpleToggleTile(
                          question: entry.value,
                          value: _infantSigns[entry.key] ?? false,
                          onChanged: (val) => setState(() => _infantSigns[entry.key] = val),
                        )),

                    if (anyFlagged)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.urgentRed.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.urgentRed.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_rounded, color: AppTheme.urgentRed, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Warning signs present. Get result to know what to do.',
                                style: GoogleFonts.inter(fontSize: 13, color: AppTheme.urgentRed, fontWeight: FontWeight.w600, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))]),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _submitCaregiverForm,
                  icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                  label: Text('Get Result',
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentTeal,
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

  // ─── CHW: Full clinical form ────────────────────────────────────────────────
  Widget _buildCHWView() {
    final bool isFastBreathing = _breathingRate >= 60;
    final bool isHypothermia = _temp < 35.5;
    final bool isFever = _temp >= 37.5;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('13. Young Infant (< 2 Months)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        leading: widget.onBack != null
            ? IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: widget.onBack)
            : null,
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
                        children: [
                          Expanded(
                            child: Text('SECTION C: YOUNG INFANT DANGER SIGNS',
                                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 8),
                          Text('< 60 DAYS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentTeal)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Breathing Rate
                    BreathingTimerWidget(
                      initialRate: _breathingRate,
                      onRateChanged: (rate) => setState(() => _breathingRate = rate),
                    ),

                    if (isFastBreathing)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.urgentRed.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('⚠️ Fast breathing detected (≥ 60 bpm) — SEVERE PNEUMONIA risk',
                            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.urgentRed, fontWeight: FontWeight.w600)),
                      ),

                    const SizedBox(height: 12),

                    // Temperature
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Body Temperature (°C)',
                                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isHypothermia ? AppTheme.urgentRed : (isFever ? AppTheme.watchAmber : AppTheme.routineGreen),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isHypothermia ? 'HYPOTHERMIA (<35.5°C)' : (isFever ? 'FEVER (≥37.5°C)' : 'NORMAL'),
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

                    Text('CRITICAL INFANT CLINICAL SIGNS',
                        style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
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

            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))]),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => widget.onNext(_breathingRate, _temp, _infantSigns),
                  icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                  label: Text('Continue to Maternal Assessment',
                      style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
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

// ─── Simple toggle tile for Caregiver ────────────────────────────────────────
class _SimpleToggleTile extends StatelessWidget {
  final String question;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SimpleToggleTile({required this.question, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: value ? AppTheme.urgentRed.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: value ? AppTheme.urgentRed.withValues(alpha: 0.4) : AppTheme.cardBorder),
        boxShadow: AppTheme.cardShadow(),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(question,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: value ? AppTheme.urgentRed : AppTheme.textDark,
                    height: 1.4)),
          ),
          const SizedBox(width: 12),
          Switch(value: value, activeColor: AppTheme.urgentRed, onChanged: onChanged),
        ],
      ),
    );
  }
}

// ─── CHW clinical sign tile ────────────────────────────────────────────────────
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
