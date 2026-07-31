import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/services/audio_service.dart';
import '../../data/mock_repository.dart';
import '../../domain/models/clinical_models.dart';

// ─── SCREEN 12: CHILD ASSESSMENT (6–59 months) ─────────────────────────────────
// Role-Branching: CHW → Full IMCI clinical form | Caregiver → Plain danger-sign checklist
class ChildAssessmentScreen extends StatefulWidget {
  final double initialMuac;
  final bool initialOedema;
  final Map<String, bool> initialDangerSigns;
  final ScheduledVisitModel? visitContext;
  final Function(double muac, bool oedema, Map<String, bool> dangerSigns) onNext;
  final VoidCallback? onBack;

  const ChildAssessmentScreen({
    super.key,
    this.initialMuac = 13.0,
    this.initialOedema = false,
    this.initialDangerSigns = const {},
    this.visitContext,
    required this.onNext,
    this.onBack,
  });

  @override
  State<ChildAssessmentScreen> createState() => _ChildAssessmentScreenState();
}

class _ChildAssessmentScreenState extends State<ChildAssessmentScreen> {
  late double _muac;
  late bool _oedema;
  late Map<String, bool> _dangerSigns;
  bool _audioPlaying = false;
  final _audioService = LocalAudioService();
  final _repo = MockRepository();

  // Caregiver simplified signs — plain language keys
  static const _caregiverSigns = {
    'thin_arm': 'Does the child\'s arm look very thin or wasted?',
    'both_feet_swollen': 'Are both feet puffed up / swollen?',
    'seizures': 'Has the child had any fits or shaking today?',
    'cannot_drink': 'Is the child unable to drink or eat anything?',
    'vomits_all': 'Does the child vomit everything they take in?',
    'very_sleepy': 'Is the child unusually sleepy or hard to wake?',
  };

  // CHW clinical keys
  static const _chwClinicalSigns = {
    'convulsions': 'History of Convulsions',
    'unableToFeed': 'Unable to Drink or Breastfeed',
    'vomitsEverything': 'Vomits Everything',
    'lethargic': 'Lethargic or Unconscious',
    'pallor': 'Severe Palmar Pallor (Anaemia)',
    'stiffNeck': 'Stiff Neck (Meningism)',
  };

  static const _chwSubtitles = {
    'convulsions': 'Any fits or convulsions during this illness episode',
    'unableToFeed': 'Child too weak to take liquids or breastfeed',
    'vomitsEverything': 'Cannot keep any food or liquid down at all',
    'lethargic': 'Child abnormally sleepy or difficult to wake up',
    'pallor': 'Pale inner eyelid / palm — indicates severe anaemia',
    'stiffNeck': 'Unable to touch chin to chest — meningitis risk',
  };

  @override
  void initState() {
    super.initState();
    _muac = widget.initialMuac;
    _oedema = widget.initialOedema;
    _dangerSigns = Map.from(widget.initialDangerSigns);

    // Pre-fill all keys so state is never null
    for (final k in _chwClinicalSigns.keys) {
      _dangerSigns.putIfAbsent(k, () => false);
    }
    for (final k in _caregiverSigns.keys) {
      _dangerSigns.putIfAbsent(k, () => false);
    }
  }

  void _toggleAudio() async {
    if (_audioPlaying) {
      await _audioService.stopAudio();
      setState(() => _audioPlaying = false);
    } else {
      setState(() => _audioPlaying = true);
      await _audioService.playDagbaniInstruction('muac_instruction');
      if (mounted) setState(() => _audioPlaying = false);
    }
  }

  // Map caregiver plain-language signs → CHW clinical keys for the rules engine
  void _submitCaregiverForm() {
    final mapped = Map<String, bool>.from(_dangerSigns);
    // Translate caregiver answers to clinical keys
    mapped['convulsions'] = _dangerSigns['seizures'] ?? false;
    mapped['unableToFeed'] = _dangerSigns['cannot_drink'] ?? false;
    mapped['vomitsEverything'] = _dangerSigns['vomits_all'] ?? false;
    mapped['lethargic'] = _dangerSigns['very_sleepy'] ?? false;
    // MUAC proxy: if caregiver says arm is thin → set to 11.0 (SAM proxy)
    final muacProxy = (_dangerSigns['thin_arm'] ?? false) ? 11.0 : 13.0;
    final oedemProxy = _dangerSigns['both_feet_swollen'] ?? false;
    widget.onNext(muacProxy, oedemProxy, mapped);
  }

  @override
  Widget build(BuildContext context) {
    final isCaregiver = _repo.userRole == UserRole.caregiver;

    return isCaregiver
        ? _buildCaregiverView()
        : _buildCHWView();
  }

  // ─── CAREGIVER: Simple plain-language danger sign checklist ──────────────────
  Widget _buildCaregiverView() {
    final anyFlagged = _caregiverSigns.keys.any((k) => _dangerSigns[k] == true);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('Child Health Check', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        leading: widget.onBack != null
            ? IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: widget.onBack)
            : null,
        actions: [
          IconButton(
            icon: Icon(_audioPlaying ? Icons.volume_up_rounded : Icons.record_voice_over_rounded,
                color: Colors.white),
            onPressed: _toggleAudio,
            tooltip: 'Play in Dagbani',
          ),
        ],
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
                        gradient: LinearGradient(
                          colors: [AppTheme.accentTeal.withValues(alpha: 0.15), AppTheme.accentTeal.withValues(alpha: 0.05)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.accentTeal.withValues(alpha: 0.35)),
                      ),
                      child: Row(
                        children: [
                          const Text('🧒', style: TextStyle(fontSize: 32)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Child Danger Signs',
                                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                                const SizedBox(height: 4),
                                Text('Answer Yes / No / Not Sure for each question. Tap the speaker icon to hear in Dagbani.',
                                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMedium, height: 1.4)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    ..._caregiverSigns.entries.map((entry) =>
                        _CaregiverSignTile(
                          question: entry.value,
                          value: _dangerSigns[entry.key] ?? false,
                          onChanged: (val) => setState(() => _dangerSigns[entry.key] = val),
                        ),
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
                                'One or more danger signs are present. Please proceed to get the result.',
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

            // CTA
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
                  label: Text('Get Result', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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

  // ─── CHW: Full IMCI clinical form ─────────────────────────────────────────────
  Widget _buildCHWView() {
    final bool isSam = _muac < 11.5 || _oedema;
    final bool isMam = _muac >= 11.5 && _muac < 12.5 && !_oedema;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('Child Assessment (6–59m)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        leading: widget.onBack != null
            ? IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: widget.onBack)
            : null,
        actions: [
          IconButton(
            icon: Icon(_audioPlaying ? Icons.volume_up_rounded : Icons.volume_mute_rounded, color: Colors.white),
            onPressed: _toggleAudio,
            tooltip: 'Dagbani Audio Prompt',
          ),
        ],
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
                    // Section A header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppTheme.primaryNavy, borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text('SECTION A: MALNUTRITION ASSESSMENT',
                                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: AppTheme.accentTeal, borderRadius: BorderRadius.circular(6)),
                            child: Text('WHO IMCI', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // MUAC Slider
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('MUAC Measurement (cm)',
                                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isSam ? AppTheme.urgentRed : (isMam ? AppTheme.watchAmber : AppTheme.routineGreen),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isSam ? 'SAM (< 11.5)' : (isMam ? 'MAM (11.5–12.4)' : 'NORMAL (≥12.5)'),
                                    style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: Text(
                                '${_muac.toStringAsFixed(1)} cm',
                                style: GoogleFonts.outfit(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: isSam ? AppTheme.urgentRed : (isMam ? AppTheme.watchAmber : AppTheme.routineGreen),
                                ),
                              ),
                            ),
                            Slider(
                              value: _muac,
                              min: 8.0,
                              max: 18.0,
                              divisions: 100,
                              activeColor: isSam ? AppTheme.urgentRed : (isMam ? AppTheme.watchAmber : AppTheme.routineGreen),
                              onChanged: (val) => setState(() => _muac = val),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Bilateral Oedema
                    Card(
                      child: SwitchListTile(
                        title: Text('Bilateral Pitting Oedema',
                            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                        subtitle: Text('Swelling in both feet (SAM Independent Trigger)',
                            style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMedium)),
                        value: _oedema,
                        activeColor: AppTheme.urgentRed,
                        onChanged: (val) => setState(() => _oedema = val),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Section B header
                    Text('SECTION B: GENERAL DANGER SIGNS (UNDER 5)',
                        style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                    const SizedBox(height: 10),

                    ..._chwClinicalSigns.entries.map((entry) =>
                        _DangerSignTile(
                          title: entry.value,
                          subtitle: _chwSubtitles[entry.key] ?? '',
                          value: _dangerSigns[entry.key] ?? false,
                          onChanged: (val) => setState(() => _dangerSigns[entry.key] = val),
                        ),
                    ),
                  ],
                ),
              ),
            ),

            // Next Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))]),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => widget.onNext(_muac, _oedema, _dangerSigns),
                  icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                  label: Text('Continue to Infant Assessment',
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

// ─── Caregiver Yes/No/Not Sure Tile ──────────────────────────────────────────
class _CaregiverSignTile extends StatelessWidget {
  final String question;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CaregiverSignTile({
    required this.question,
    required this.value,
    required this.onChanged,
  });

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
          Switch(
            value: value,
            activeColor: AppTheme.urgentRed,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// ─── CHW Danger Sign Tile ─────────────────────────────────────────────────────
class _DangerSignTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _DangerSignTile({required this.title, required this.subtitle, required this.value, required this.onChanged});

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
        title: Text(title,
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold,
                color: value ? AppTheme.urgentRed : AppTheme.textDark)),
        subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMedium)),
        value: value,
        activeColor: AppTheme.urgentRed,
        onChanged: (val) => onChanged(val ?? false),
      ),
    );
  }
}
