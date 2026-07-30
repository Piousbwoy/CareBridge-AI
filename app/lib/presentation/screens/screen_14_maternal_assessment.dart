import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class MaternalAssessmentScreen extends StatefulWidget {
  final double? initialHb;
  final bool initialPallorProxy;
  final Map<String, bool> initialMaternalSigns;
  final Function(double? hb, bool pallorProxy, Map<String, bool> maternalSigns)? onRunRulesEngine;
  final Function(double? hb, bool pallorProxy, Map<String, bool> maternalSigns)? onCompleteAssessment;
  final VoidCallback? onBack;

  const MaternalAssessmentScreen({
    super.key,
    this.initialHb,
    this.initialPallorProxy = false,
    this.initialMaternalSigns = const {},
    this.onRunRulesEngine,
    this.onCompleteAssessment,
    this.onBack,
  });

  @override
  State<MaternalAssessmentScreen> createState() => _MaternalAssessmentScreenState();
}

class _MaternalAssessmentScreenState extends State<MaternalAssessmentScreen> {
  late double _hb;
  late bool _hasHbTest;
  late bool _pallorProxy;
  late Map<String, bool> _maternalSigns;

  @override
  void initState() {
    super.initState();
    _hb = widget.initialHb ?? 11.5;
    _hasHbTest = widget.initialHb != null;
    _pallorProxy = widget.initialPallorProxy;
    _maternalSigns = Map.from(widget.initialMaternalSigns);

    _maternalSigns.putIfAbsent('bleeding', () => false);
    _maternalSigns.putIfAbsent('convulsions', () => false);
    _maternalSigns.putIfAbsent('headacheVision', () => false);
    _maternalSigns.putIfAbsent('reducedFetalMov', () => false);
    _maternalSigns.putIfAbsent('postpartumBleeding', () => false);
    _maternalSigns.putIfAbsent('elevatedBP', () => false);
  }

  void _triggerCompletion() {
    final hbVal = _hasHbTest ? _hb : null;
    if (widget.onRunRulesEngine != null) {
      widget.onRunRulesEngine!(hbVal, _pallorProxy, _maternalSigns);
    } else if (widget.onCompleteAssessment != null) {
      widget.onCompleteAssessment!(hbVal, _pallorProxy, _maternalSigns);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSevereAnaemia = _hasHbTest && _hb < 7.0;
    final bool isModAnaemia = _hasHbTest && _hb >= 7.0 && _hb < 11.0;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('14. Maternal Assessment', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        leading: widget.onBack != null ? IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: widget.onBack) : null,
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
                    // Header
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AppTheme.primaryNavy, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text('SECTION D & E: MATERNAL CARE (ANC/PNC)', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white), overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 8),
                          Text('GHS PROTOCOL', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentTeal)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Haemoglobin (Hb) Screening Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Haemoglobin Level (Hb)', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                                Checkbox(
                                  value: _hasHbTest,
                                  activeColor: AppTheme.accentTeal,
                                  onChanged: (v) => setState(() => _hasHbTest = v ?? true),
                                ),
                              ],
                            ),
                            if (_hasHbTest) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${_hb.toStringAsFixed(1)} g/dL',
                                      style: GoogleFonts.outfit(
                                        fontSize: 28, fontWeight: FontWeight.bold,
                                        color: isSevereAnaemia ? AppTheme.urgentRed : (isModAnaemia ? AppTheme.watchAmber : AppTheme.routineGreen),
                                      )),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isSevereAnaemia ? AppTheme.urgentRed : (isModAnaemia ? AppTheme.watchAmber : AppTheme.routineGreen),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      isSevereAnaemia ? 'SEVERE ANAEMIA (< 7.0)' : (isModAnaemia ? 'MODERATE (7.0 - 10.9)' : 'NORMAL (≥ 11.0)'),
                                      style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              Slider(
                                value: _hb,
                                min: 4.0, max: 15.0, divisions: 110,
                                activeColor: isSevereAnaemia ? AppTheme.urgentRed : (isModAnaemia ? AppTheme.watchAmber : AppTheme.routineGreen),
                                onChanged: (val) => setState(() => _hb = val),
                              ),
                            ] else ...[
                              Text('No Hb meter available? Use palmar / conjunctival pallor proxy below:', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMedium)),
                              const SizedBox(height: 8),
                              SwitchListTile(
                                title: Text('Conjunctival or Palmar Pallor', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold)),
                                value: _pallorProxy,
                                activeColor: AppTheme.watchAmber,
                                onChanged: (v) => setState(() => _pallorProxy = v),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Obstetric Danger Signs (Eclampsia, Bleeding, PPH)
                    Text('MATERNAL OBSTETRIC DANGER SIGNS', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                    const SizedBox(height: 10),

                    _MaternalSignTile(
                      title: 'Antepartum Vaginal Bleeding',
                      subtitle: 'Any vaginal bleeding during pregnancy',
                      value: _maternalSigns['bleeding'] ?? false,
                      onChanged: (v) => setState(() => _maternalSigns['bleeding'] = v),
                    ),
                    _MaternalSignTile(
                      title: 'Convulsions or Fits (Eclampsia Risk)',
                      subtitle: 'History of seizures or loss of consciousness',
                      value: _maternalSigns['convulsions'] ?? false,
                      onChanged: (v) => setState(() => _maternalSigns['convulsions'] = v),
                    ),
                    _MaternalSignTile(
                      title: 'Severe Headache or Blurred Vision',
                      subtitle: 'Persistent severe headache, epigastric pain or blurred vision (Preeclampsia)',
                      value: _maternalSigns['headacheVision'] ?? false,
                      onChanged: (v) => setState(() => _maternalSigns['headacheVision'] = v),
                    ),
                    _MaternalSignTile(
                      title: 'Elevated BP Proxy (Systolic ≥ 140 or Diastolic ≥ 90)',
                      subtitle: 'High blood pressure reading at point of care',
                      value: _maternalSigns['elevatedBP'] ?? false,
                      onChanged: (v) => setState(() => _maternalSigns['elevatedBP'] = v),
                    ),
                    _MaternalSignTile(
                      title: 'Reduced or Absent Fetal Movement',
                      subtitle: 'Mother reports baby moving less or stopped moving',
                      value: _maternalSigns['reducedFetalMov'] ?? false,
                      onChanged: (v) => setState(() => _maternalSigns['reducedFetalMov'] = v),
                    ),
                    _MaternalSignTile(
                      title: 'Postpartum Heavy Bleeding (PPH)',
                      subtitle: 'Soaking > 2 pads in 1 hour after delivery',
                      value: _maternalSigns['postpartumBleeding'] ?? false,
                      onChanged: (v) => setState(() => _maternalSigns['postpartumBleeding'] = v),
                    ),
                  ],
                ),
              ),
            ),

            // Run AI Engine Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))]),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _triggerCompletion,
                  icon: const Icon(Icons.psychology_rounded, color: Colors.white),
                  label: Text('Evaluate AI Triage Result', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
}

class _MaternalSignTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _MaternalSignTile({required this.title, required this.subtitle, required this.value, required this.onChanged});

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
