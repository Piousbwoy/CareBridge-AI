import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../core/utils/sms_compressor.dart';
import '../../data/mock_repository.dart';
import '../../domain/models/clinical_models.dart';

class ReferralActionScreen extends StatefulWidget {
  final String householdName;
  final String? patientName;
  final String householdId;
  final String? memberId;
  final List<String>? autoReasons;
  final List<String>? reasons;
  final String riskTier;
  final double? muacCm;
  final int? breathingRate;
  final double? hbLevel;
  final bool? bilateralOedema;
  final VoidCallback? onReferralComplete;
  final VoidCallback? onViewNutrition;

  const ReferralActionScreen({
    super.key,
    this.householdName = 'Household Record',
    this.patientName,
    required this.householdId,
    this.memberId,
    this.autoReasons,
    this.reasons,
    required this.riskTier,
    this.muacCm,
    this.breathingRate,
    this.hbLevel,
    this.bilateralOedema,
    this.onReferralComplete,
    this.onViewNutrition,
  });

  @override
  State<ReferralActionScreen> createState() => _ReferralActionScreenState();
}

class _ReferralActionScreenState extends State<ReferralActionScreen> {
  late TextEditingController _facilityCtrl;
  late TextEditingController _facilityTierCtrl;
  late TextEditingController _chwNotesCtrl;
  final _repo = MockRepository();
  bool _useBitpackedHex = false;
  bool _smsCopied = false;

  late ReferralModel _currentReferral;

  String get displayName => widget.patientName ?? widget.householdName;
  List<String> get displayReasons => widget.autoReasons ?? widget.reasons ?? ['Clinical Assessment Triggered'];

  int get _parsedHouseholdId {
    final digits = widget.householdId.replaceAll(RegExp(r'\D'), '');
    return int.tryParse(digits) ?? 10000;
  }

  String get _smsPayload {
    final oedemaVal = widget.bilateralOedema ?? false;
    final muacVal = widget.muacCm ?? 12.0;
    final rrVal = widget.breathingRate ?? 40;
    final hbVal = widget.hbLevel ?? 11.5;

    if (_useBitpackedHex) {
      return SMSCompressor.encodeBitpackedHex(
        householdIdNumber: _parsedHouseholdId,
        muacMm: (muacVal * 10).round(),
        oedema: oedemaVal,
        rr: rrVal,
        hbGdlTimesTen: (hbVal * 10).round(),
        riskTierCode: widget.riskTier == 'URGENT' ? 2 : (widget.riskTier == 'WATCH' ? 1 : 0),
        bitmaskDangerFlags: 0x8041,
      );
    } else {
      return SMSCompressor.compressReferral(
        householdId: widget.householdId,
        muacCm: muacVal,
        oedema: oedemaVal,
        breathingRate: rrVal,
        hbLevel: hbVal,
        riskTier: widget.riskTier,
        ruleCodes: displayReasons.take(2).map((r) => r.split(':').first.replaceAll(' ', '_')).toList(),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    final isUrgent = widget.riskTier == 'URGENT';
    final initialFacility = isUrgent ? '${_repo.userDistrict} District Hospital' : '${_repo.userDistrict} CHPS Health Centre';
    final initialTier = isUrgent ? 'District Hospital (Tertiary Transfer)' : 'Health Centre / CHPS Clinic (Primary Transfer)';

    _facilityCtrl = TextEditingController(text: initialFacility);
    _facilityTierCtrl = TextEditingController(text: initialTier);

    final structuredNote = 'REFERRAL NOTE — GHS CHPS\n'
        'Patient: $displayName (${widget.householdId})\n'
        'Location: ${_repo.chwZone}\n'
        'Risk Tier: ${widget.riskTier}\n'
        'Danger Signs / Clinical Reasons:\n${displayReasons.map((r) => " • $r").join("\n")}\n'
        'Referring CHO: ${_repo.chwName}\n'
        'Facility Destination: $initialFacility ($initialTier)\n'
        'Date: ${DateTime.now().toString().substring(0, 16)}';

    _chwNotesCtrl = TextEditingController(text: structuredNote);

    final mId = widget.memberId ?? 'M-1';
    final existingRef = _repo.getReferralForMember(mId);

    if (existingRef != null) {
      _currentReferral = existingRef;
    } else {
      _currentReferral = _repo.createReferral(
        householdId: widget.householdId,
        memberId: mId,
        patientName: displayName,
        riskTier: widget.riskTier == 'URGENT' ? RiskTier.URGENT : RiskTier.WATCH,
        facilityName: initialFacility,
        facilityTier: initialTier,
        referralNote: structuredNote,
        dangerSigns: displayReasons,
      );
    }
  }

  @override
  void dispose() {
    _facilityCtrl.dispose();
    _facilityTierCtrl.dispose();
    _chwNotesCtrl.dispose();
    super.dispose();
  }

  Future<void> _launchSmsIntent() async {
    final smsUri = Uri(
      scheme: 'sms',
      path: '+233240000000', // District Emergency Referral Desk
      queryParameters: <String, String>{
        'body': _smsPayload,
      },
    );

    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        _copySmsPayloadToClipboard();
      }
    } catch (e) {
      _copySmsPayloadToClipboard();
    }
  }

  void _copySmsPayloadToClipboard() {
    Clipboard.setData(ClipboardData(text: _smsPayload));
    setState(() => _smsCopied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Compressed 2G SMS payload copied to clipboard. Ready to paste in SMS app.'),
        backgroundColor: AppTheme.primaryNavy,
      ),
    );
  }

  void _showUpdateStatusDialog() {
    ReferralStatus selected = _currentReferral.status;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Update Referral Status', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: ReferralStatus.values.map((status) {
                return RadioListTile<ReferralStatus>(
                  title: Text(status.displayName, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                  value: status,
                  groupValue: selected,
                  activeColor: AppTheme.accentTeal,
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selected = val);
                  },
                );
              }).toList(),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentTeal),
                onPressed: () {
                  _repo.updateReferralStatus(_currentReferral.id, selected);
                  setState(() {
                    _currentReferral = _currentReferral.copyWith(status: selected);
                  });
                  Navigator.pop(ctx);
                },
                child: Text('Save Status', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUrgent = widget.riskTier == 'URGENT';
    final tierColor = isUrgent ? AppTheme.urgentRed : AppTheme.watchAmber;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('Emergency Referral Action', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (widget.onReferralComplete != null) widget.onReferralComplete!();
            else Navigator.pop(context);
          },
        ),
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
                    // Header Status Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: tierColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: tierColor.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: tierColor, borderRadius: BorderRadius.circular(8)),
                                child: Text(
                                  widget.riskTier,
                                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                              GestureDetector(
                                onTap: _showUpdateStatusDialog,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppTheme.cardBorder),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.sync_alt_rounded, size: 12, color: AppTheme.accentTeal),
                                      const SizedBox(width: 4),
                                      Text(
                                        _currentReferral.status.displayName,
                                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Referral Action for $displayName',
                            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                          ),
                          Text('Household ID: ${widget.householdId} • Location: ${_repo.chwZone}',
                              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMedium)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Triggered Danger Signs Section
                    Text('IDENTIFIED CLINICAL DANGER SIGNS', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: displayReasons.map((r) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, size: 16, color: AppTheme.urgentRed),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(r, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Facility Destination (Auto-suggested per Risk Tier)
                    Text('REFERRAL FACILITY DESTINATION', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _facilityCtrl,
                      style: GoogleFonts.inter(fontSize: 13),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.local_hospital_rounded, color: tierColor, size: 18),
                        labelText: 'Facility Name',
                        helperText: 'Auto-routed based on clinical urgency tier ($widget.riskTier)',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _facilityTierCtrl,
                      readOnly: true,
                      style: GoogleFonts.inter(fontSize: 13),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.account_tree_rounded, color: AppTheme.accentTeal, size: 18),
                        labelText: 'Facility Level / Tier',
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Structured Referral Note
                    Text('STRUCTURED CLINICAL REFERRAL NOTE', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _chwNotesCtrl,
                      maxLines: 6,
                      style: GoogleFonts.inter(fontSize: 12),
                      decoration: const InputDecoration(
                        helperText: 'Complete structured summary generated from live assessment parameters.',
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 2G SMS Payload Section
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryNavy,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.sms_rounded, color: AppTheme.accentTeal, size: 18),
                                  const SizedBox(width: 6),
                                  Text(
                                    'COMPRESSED 2G SMS PAYLOAD',
                                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text('HEX', style: GoogleFonts.inter(fontSize: 10, color: Colors.white70)),
                                  Switch(
                                    value: _useBitpackedHex,
                                    activeThumbColor: AppTheme.accentTeal,
                                    onChanged: (v) => setState(() => _useBitpackedHex = v),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(10),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppTheme.accentTeal.withValues(alpha: 0.3)),
                            ),
                            child: SelectableText(
                              _smsPayload,
                              style: GoogleFonts.firaCode(fontSize: 12, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Size: ${_smsPayload.length} characters — Transmits over low-signal 2G SMS without mobile data.',
                            style: GoogleFonts.inter(fontSize: 10, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Actions Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _launchSmsIntent,
                      icon: const Icon(Icons.send_rounded, color: Colors.white),
                      label: Text(
                        _smsCopied ? 'Re-open SMS App' : 'Open SMS App & Send Referral',
                        style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tierColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _copySmsPayloadToClipboard,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.cardBorder),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text('Copy Payload', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                        ),
                      ),
                      if (widget.onViewNutrition != null) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: widget.onViewNutrition,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryNavy,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text('Meal Guidance', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
