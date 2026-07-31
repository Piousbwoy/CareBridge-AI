import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../data/mock_repository.dart';
import '../../domain/models/clinical_models.dart';

// ─── SCREEN 14: MATERNAL ASSESSMENT (ANC/PNC) ──────────────────────────────────
// Role-Branching & Pregnancy Status Branching:
//   CHW → Full clinical form with Hb slider + pregnancy status selector
//   Caregiver → Plain danger-sign checklist + pregnancy status selector
class MaternalAssessmentScreen extends StatefulWidget {
  final double? initialHb;
  final bool initialPallorProxy;
  final Map<String, bool> initialMaternalSigns;
  final PregnancyStatus initialPregnancyStatus;
  final ScheduledVisitModel? visitContext;
  final Function(double? hb, bool pallorProxy, Map<String, bool> maternalSigns, PregnancyStatus status)? onRunRulesEngine;
  final Function(double? hb, bool pallorProxy, Map<String, bool> maternalSigns, PregnancyStatus status)? onCompleteAssessment;
  final VoidCallback? onBack;

  const MaternalAssessmentScreen({
    super.key,
    this.initialHb,
    this.initialPallorProxy = false,
    this.initialMaternalSigns = const {},
    this.initialPregnancyStatus = PregnancyStatus.currentlyPregnant,
    this.visitContext,
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
  late PregnancyStatus _pregnancyStatus;
  final _repo = MockRepository();

  // Caregiver plain-language questions → clinical key mapping
  static const _caregiverQuestions = {
    'bleeding_now': 'Is there any bleeding from the vagina?',
    'fits_today': 'Has she had any fits or shaking today?',
    'bad_headache': 'Does she have a very severe headache that won\'t go away?',
    'cannot_see': 'Is her vision blurred or are there spots in her eyes?',
    'baby_not_moving': 'Has the baby stopped moving inside (if currently pregnant)?',
    'soaking_blood': 'Is she soaking more than 2 pads with blood in an hour (after delivery)?',
    'looks_pale': 'Do the inside of her eyelids or palms look very pale (white)?',
  };

  @override
  void initState() {
    super.initState();
    _hb = widget.initialHb ?? 11.5;
    _hasHbTest = widget.initialHb != null;
    _pallorProxy = widget.initialPallorProxy;
    _pregnancyStatus = widget.initialPregnancyStatus;
    _maternalSigns = Map.from(widget.initialMaternalSigns);

    _maternalSigns.putIfAbsent('bleeding', () => false);
    _maternalSigns.putIfAbsent('convulsions', () => false);
    _maternalSigns.putIfAbsent('headacheVision', () => false);
    _maternalSigns.putIfAbsent('reducedFetalMov', () => false);
    _maternalSigns.putIfAbsent('postpartumBleeding', () => false);
    _maternalSigns.putIfAbsent('elevatedBP', () => false);

    for (final k in _caregiverQuestions.keys) {
      _maternalSigns.putIfAbsent(k, () => false);
    }
  }

  void _triggerCompletion() {
    final hbVal = _hasHbTest ? _hb : null;
    if (widget.onRunRulesEngine != null) {
      widget.onRunRulesEngine!(hbVal, _pallorProxy, _maternalSigns, _pregnancyStatus);
    } else if (widget.onCompleteAssessment != null) {
      widget.onCompleteAssessment!(hbVal, _pallorProxy, _maternalSigns, _pregnancyStatus);
    }
  }

  void _submitCaregiverForm() {
    final mapped = Map<String, bool>.from(_maternalSigns);
    mapped['bleeding'] = _maternalSigns['bleeding_now'] ?? false;
    mapped['convulsions'] = _maternalSigns['fits_today'] ?? false;
    mapped['headacheVision'] = (_maternalSigns['bad_headache'] ?? false) || (_maternalSigns['cannot_see'] ?? false);
    mapped['reducedFetalMov'] = (_pregnancyStatus == PregnancyStatus.currentlyPregnant)
        ? (_maternalSigns['baby_not_moving'] ?? false)
        : false;
    mapped['postpartumBleeding'] = (_pregnancyStatus == PregnancyStatus.postpartum)
        ? (_maternalSigns['soaking_blood'] ?? false)
        : false;

    final pallor = _maternalSigns['looks_pale'] ?? false;

    if (widget.onRunRulesEngine != null) {
      widget.onRunRulesEngine!(null, pallor, mapped, _pregnancyStatus);
    } else if (widget.onCompleteAssessment != null) {
      widget.onCompleteAssessment!(null, pallor, mapped, _pregnancyStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCaregiver = _repo.userRole == UserRole.caregiver;
    return isCaregiver ? _buildCaregiverView() : _buildCHWView();
  }

  // ─── Pregnancy Status Selector Card ─────────────────────────────────────────
  Widget _buildStatusSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryNavy.withValues(alpha: 0.2)),
        boxShadow: AppTheme.cardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_pin_rounded, color: AppTheme.primaryNavy, size: 20),
              const SizedBox(width: 8),
              Text(
                'What is her pregnancy status today?',
                style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('🤰 Currently Pregnant'),
                selected: _pregnancyStatus == PregnancyStatus.currentlyPregnant,
                selectedColor: AppTheme.primaryNavy,
                labelStyle: TextStyle(
                  color: _pregnancyStatus == PregnancyStatus.currentlyPregnant ? Colors.white : AppTheme.textDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                onSelected: (sel) {
                  if (sel) setState(() => _pregnancyStatus = PregnancyStatus.currentlyPregnant);
                },
              ),
              ChoiceChip(
                label: const Text('👶 Postpartum (≤ 6 wks)'),
                selected: _pregnancyStatus == PregnancyStatus.postpartum,
                selectedColor: AppTheme.accentTeal,
                labelStyle: TextStyle(
                  color: _pregnancyStatus == PregnancyStatus.postpartum ? Colors.white : AppTheme.textDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                onSelected: (sel) {
                  if (sel) setState(() => _pregnancyStatus = PregnancyStatus.postpartum);
                },
              ),
              ChoiceChip(
                label: const Text('👤 Neither / Routine'),
                selected: _pregnancyStatus == PregnancyStatus.neither,
                selectedColor: AppTheme.textMedium,
                labelStyle: TextStyle(
                  color: _pregnancyStatus == PregnancyStatus.neither ? Colors.white : AppTheme.textDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                onSelected: (sel) {
                  if (sel) setState(() => _pregnancyStatus = PregnancyStatus.neither);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── CAREGIVER VIEW ─────────────────────────────────────────────────────────
  Widget _buildCaregiverView() {
    final anyFlagged = _caregiverQuestions.keys.any((k) => _maternalSigns[k] == true);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('Mother\'s Health Check', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
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
                          const Color(0xFFFCE4EC).withValues(alpha: 0.8),
                          const Color(0xFFF8BBD0).withValues(alpha: 0.4),
                        ]),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.urgentRed.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        children: [
                          const Text('🤰', style: TextStyle(fontSize: 32)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Mother\'s Warning Signs',
                                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                                const SizedBox(height: 4),
                                Text('Answer Yes or No for each question. Questions update based on pregnancy status.',
                                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMedium, height: 1.4)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // First question: Status selector
                    _buildStatusSelector(),

                    // General maternal questions (applicable to all)
                    _SimpleToggleTile(
                      question: _caregiverQuestions['bleeding_now']!,
                      value: _maternalSigns['bleeding_now'] ?? false,
                      onChanged: (v) => setState(() => _maternalSigns['bleeding_now'] = v),
                    ),
                    _SimpleToggleTile(
                      question: _caregiverQuestions['fits_today']!,
                      value: _maternalSigns['fits_today'] ?? false,
                      onChanged: (v) => setState(() => _maternalSigns['fits_today'] = v),
                    ),
                    _SimpleToggleTile(
                      question: _caregiverQuestions['bad_headache']!,
                      value: _maternalSigns['bad_headache'] ?? false,
                      onChanged: (v) => setState(() => _maternalSigns['bad_headache'] = v),
                    ),
                    _SimpleToggleTile(
                      question: _caregiverQuestions['cannot_see']!,
                      value: _maternalSigns['cannot_see'] ?? false,
                      onChanged: (v) => setState(() => _maternalSigns['cannot_see'] = v),
                    ),
                    _SimpleToggleTile(
                      question: _caregiverQuestions['looks_pale']!,
                      value: _maternalSigns['looks_pale'] ?? false,
                      onChanged: (v) => setState(() => _maternalSigns['looks_pale'] = v),
                    ),

                    // Status-Gated Questions
                    if (_pregnancyStatus == PregnancyStatus.currentlyPregnant)
                      _SimpleToggleTile(
                        question: _caregiverQuestions['baby_not_moving']!,
                        value: _maternalSigns['baby_not_moving'] ?? false,
                        onChanged: (v) => setState(() => _maternalSigns['baby_not_moving'] = v),
                      ),

                    if (_pregnancyStatus == PregnancyStatus.postpartum)
                      _SimpleToggleTile(
                        question: _caregiverQuestions['soaking_blood']!,
                        value: _maternalSigns['soaking_blood'] ?? false,
                        onChanged: (v) => setState(() => _maternalSigns['soaking_blood'] = v),
                      ),

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
                                'Danger signs are present. Please get the result now.',
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

  // ─── CHW CLINICAL VIEW ──────────────────────────────────────────────────────
  Widget _buildCHWView() {
    final bool isSevereAnaemia = _hasHbTest && _hb < 7.0;
    final bool isModAnaemia = _hasHbTest && _hb >= 7.0 && _hb < 11.0;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('Maternal Assessment', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
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
                    if (widget.visitContext != null) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.accentTeal.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.accentTeal.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.event_note_rounded, color: AppTheme.accentTeal, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PRE-LOADED VISIT CONTEXT',
                                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.accentTeal),
                                  ),
                                  Text(
                                    '${widget.visitContext!.contactName}: ${widget.visitContext!.title}',
                                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AppTheme.primaryNavy, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text('SECTION D & E: MATERNAL CARE (ANC/PNC)',
                                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 8),
                          Text('GHS PROTOCOL', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentTeal)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // 1. Pregnancy Status Selector
                    _buildStatusSelector(),

                    // 2. Hb Screening Card (Applies across all statuses)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Haemoglobin Level (Hb)',
                                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                                Row(
                                  children: [
                                    Text('Hb Test Done?', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMedium)),
                                    Checkbox(
                                      value: _hasHbTest,
                                      activeColor: AppTheme.accentTeal,
                                      onChanged: (v) => setState(() => _hasHbTest = v ?? true),
                                    ),
                                  ],
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
                                      isSevereAnaemia ? 'SEVERE (<7.0)' : (isModAnaemia ? 'MODERATE (7–10.9)' : 'NORMAL (≥11.0)'),
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
                              const SizedBox(height: 8),
                              Text('No Hb meter? Use palmar / conjunctival pallor proxy below:',
                                  style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMedium)),
                              const SizedBox(height: 8),
                              SwitchListTile(
                                title: Text('Conjunctival or Palmar Pallor',
                                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold)),
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

                    // 3. Obstetric Danger Signs (Filtered by Pregnancy Status)
                    if (_pregnancyStatus != PregnancyStatus.neither) ...[
                      Text(
                        _pregnancyStatus == PregnancyStatus.currentlyPregnant
                            ? 'ANTENATAL OBSTETRIC DANGER SIGNS'
                            : 'POSTPARTUM OBSTETRIC DANGER SIGNS',
                        style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                      ),
                      const SizedBox(height: 10),

                      _MaternalSignTile(
                        title: 'Vaginal Bleeding',
                        subtitle: _pregnancyStatus == PregnancyStatus.currentlyPregnant
                            ? 'Any vaginal bleeding during pregnancy'
                            : 'Heavy vaginal bleeding after delivery',
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

                      if (_pregnancyStatus == PregnancyStatus.currentlyPregnant)
                        _MaternalSignTile(
                          title: 'Reduced or Absent Fetal Movement',
                          subtitle: 'Mother reports baby moving less or stopped moving',
                          value: _maternalSigns['reducedFetalMov'] ?? false,
                          onChanged: (v) => setState(() => _maternalSigns['reducedFetalMov'] = v),
                        ),

                      if (_pregnancyStatus == PregnancyStatus.postpartum)
                        _MaternalSignTile(
                          title: 'Postpartum Heavy Bleeding (PPH)',
                          subtitle: 'Soaking > 2 pads in 1 hour after delivery',
                          value: _maternalSigns['postpartumBleeding'] ?? false,
                          onChanged: (v) => setState(() => _maternalSigns['postpartumBleeding'] = v),
                        ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.routineGreen.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.routineGreen.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, color: AppTheme.routineGreen, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Non-pregnant / Routine Status selected. Obstetric-only questions are hidden. Anaemia screening above applies.',
                                style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textDark, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                  onPressed: _triggerCompletion,
                  icon: const Icon(Icons.psychology_rounded, color: Colors.white),
                  label: Text('Evaluate AI Triage Result',
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
}

// ─── Simple toggle tile for Caregiver ─────────────────────────────────────────
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
