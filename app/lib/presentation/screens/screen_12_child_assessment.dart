import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/services/audio_service.dart';

class ChildAssessmentScreen extends StatefulWidget {
  final double initialMuac;
  final bool initialOedema;
  final Map<String, bool> initialDangerSigns;
  final Function(double muac, bool oedema, Map<String, bool> dangerSigns) onNext;
  final VoidCallback? onBack;

  const ChildAssessmentScreen({
    super.key,
    this.initialMuac = 10.5,
    this.initialOedema = false,
    this.initialDangerSigns = const {},
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

  @override
  void initState() {
    super.initState();
    _muac = widget.initialMuac;
    _oedema = widget.initialOedema;
    _dangerSigns = Map.from(widget.initialDangerSigns);

    _dangerSigns.putIfAbsent('convulsions', () => false);
    _dangerSigns.putIfAbsent('unableToFeed', () => false);
    _dangerSigns.putIfAbsent('vomitsEverything', () => false);
    _dangerSigns.putIfAbsent('lethargic', () => false);
    _dangerSigns.putIfAbsent('pallor', () => false);
    _dangerSigns.putIfAbsent('stiffNeck', () => false);
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

  @override
  Widget build(BuildContext context) {
    final bool isSam = _muac < 11.5 || _oedema;
    final bool isMam = _muac >= 11.5 && _muac < 12.5 && !_oedema;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('12. Child Assessment (6–59m)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
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
                    // Section A: Malnutrition (6-59m)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppTheme.primaryNavy, borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text('SECTION A: MALNUTRITION ASSESSMENT', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white), overflow: TextOverflow.ellipsis),
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

                    // MUAC Tape Measurement Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('MUAC Measurement (cm)', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isSam ? AppTheme.urgentRed : (isMam ? AppTheme.watchAmber : AppTheme.routineGreen),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isSam ? 'SAM (< 11.5 cm)' : (isMam ? 'MAM (11.5 - 12.4)' : 'NORMAL (≥ 12.5)'),
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

                    // Bilateral Oedema Toggle
                    Card(
                      child: SwitchListTile(
                        title: Text('Bilateral Pitting Oedema', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                        subtitle: Text('Swelling in both feet (SAM Independent Trigger)', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMedium)),
                        value: _oedema,
                        activeColor: AppTheme.urgentRed,
                        onChanged: (val) => setState(() => _oedema = val),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Section B: General Danger Signs
                    Text('SECTION B: GENERAL DANGER SIGNS (UNDER 5)', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                    const SizedBox(height: 10),

                    _DangerSignTile(
                      title: 'History of Convulsions',
                      subtitle: 'Any fits or convulsions during this illness episode',
                      value: _dangerSigns['convulsions'] ?? false,
                      onChanged: (val) => setState(() => _dangerSigns['convulsions'] = val),
                    ),
                    _DangerSignTile(
                      title: 'Unable to Drink or Breastfeed',
                      subtitle: 'Child too weak to take liquids or breastfeed',
                      value: _dangerSigns['unableToFeed'] ?? false,
                      onChanged: (val) => setState(() => _dangerSigns['unableToFeed'] = val),
                    ),
                    _DangerSignTile(
                      title: 'Vomits Everything',
                      subtitle: 'Cannot keep any food or liquid down at all',
                      value: _dangerSigns['vomitsEverything'] ?? false,
                      onChanged: (val) => setState(() => _dangerSigns['vomitsEverything'] = val),
                    ),
                    _DangerSignTile(
                      title: 'Lethargic or Unconscious',
                      subtitle: 'Child abnormally sleepy or difficult to wake up',
                      value: _dangerSigns['lethargic'] ?? false,
                      onChanged: (val) => setState(() => _dangerSigns['lethargic'] = val),
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
                  onPressed: () => widget.onNext(_muac, _oedema, _dangerSigns),
                  icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                  label: Text('Continue to Infant Assessment', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
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
        title: Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: value ? AppTheme.urgentRed : AppTheme.textDark)),
        subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMedium)),
        value: value,
        activeColor: AppTheme.urgentRed,
        onChanged: (val) => onChanged(val ?? false),
      ),
    );
  }
}
