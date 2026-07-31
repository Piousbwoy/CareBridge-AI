import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/utils/sms_compressor.dart';

class ReferralActionScreen extends StatefulWidget {
  final String householdName;
  final String? patientName;
  final String householdId;
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
  final _facilityCtrl = TextEditingController(text: 'Bole District Hospital');
  final _chwNotesCtrl = TextEditingController();
  bool _useBitpackedHex = false;
  bool _smsCopied = false;

  String get displayName => widget.patientName ?? widget.householdName;
  List<String> get displayReasons => widget.autoReasons ?? widget.reasons ?? ['Clinical Assessment Completed'];

  int get _parsedHouseholdId {
    final digits = widget.householdId.replaceAll(RegExp(r'\D'), '');
    return int.tryParse(digits) ?? 10000;
  }

  String get _smsPayload {
    final oedemaVal = widget.bilateralOedema ?? false;
    final muacVal = widget.muacCm ?? 0.0;
    final rrVal = widget.breathingRate ?? 0;
    final hbVal = widget.hbLevel ?? 0.0;

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
    _chwNotesCtrl.text = 'Clinical Auto-Summary: ${displayReasons.join("; ")}. Evaluated at CHPS point of care. Referral initiated to ${_facilityCtrl.text}.';
  }

  void _onComplete() {
    if (widget.onReferralComplete != null) {
      widget.onReferralComplete!();
    } else if (widget.onViewNutrition != null) {
      widget.onViewNutrition!();
    }
  }

  @override
  Widget build(BuildContext context) {
    Color tierColor = AppTheme.urgentRed;
    if (widget.riskTier == 'WATCH') tierColor = AppTheme.watchAmber;
    if (widget.riskTier == 'ROUTINE') tierColor = AppTheme.routineGreen;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('Referral Action & SMS', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        elevation: 0,
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
                    // Header Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: tierColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: tierColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: tierColor, shape: BoxShape.circle),
                            child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${widget.riskTier} REFERRAL INITIATED',
                                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: tierColor, letterSpacing: 1.1)),
                                Text(displayName, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                                Text('Household ID: ${widget.householdId}', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMedium)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Target Facility Input
                    Text('Target Referral Facility', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMedium)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _facilityCtrl,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.local_hospital_outlined, color: AppTheme.accentTeal),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorder)),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Reasons List Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.cardBorder),
                        boxShadow: AppTheme.cardShadow(),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Clinical Reasons for Referral:', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                          const SizedBox(height: 8),
                          ...displayReasons.map((r) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded, size: 14, color: AppTheme.accentTeal),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(r, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textDark))),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Bit-packed SMS Payload Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Compressed SMS Payload (2G)', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                                Row(
                                  children: [
                                    Text('Bit-packed Hex', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMedium)),
                                    Switch(
                                      value: _useBitpackedHex,
                                      onChanged: (v) => setState(() => _useBitpackedHex = v),
                                      activeColor: AppTheme.accentTeal,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryNavy.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.primaryNavy.withValues(alpha: 0.1)),
                              ),
                              child: Text(
                                _smsPayload,
                                style: GoogleFonts.firaCode(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${_smsPayload.length} chars (1 SMS segment)', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.routineGreen, fontWeight: FontWeight.w600)),
                                TextButton.icon(
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: _smsPayload));
                                    setState(() => _smsCopied = true);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('SMS payload copied to clipboard!')),
                                    );
                                  },
                                  icon: Icon(_smsCopied ? Icons.check : Icons.copy, size: 14),
                                  label: Text(_smsCopied ? 'Copied' : 'Copy SMS'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Trigger Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _smsPayload));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Referral payload copied — paste into SMS app for ${_facilityCtrl.text}')),
                    );
                    _onComplete();
                  },
                  icon: const Icon(Icons.copy_rounded, color: Colors.white),
                  label: Text('Copy Referral SMS Payload', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tierColor,
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
