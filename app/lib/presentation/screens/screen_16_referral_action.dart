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
  final VoidCallback? onReferralComplete;
  final VoidCallback? onViewNutrition;

  const ReferralActionScreen({
    super.key,
    this.householdName = 'Akua Serwaa',
    this.patientName,
    required this.householdId,
    this.autoReasons,
    this.reasons,
    required this.riskTier,
    this.muacCm,
    this.breathingRate,
    this.hbLevel,
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
  List<String> get displayReasons => widget.autoReasons ?? widget.reasons ?? ['MUAC 10.5cm — SAM (Severe Acute Malnutrition)', 'Fast Breathing (62/min)'];

  String get _smsPayload {
    if (_useBitpackedHex) {
      return SMSCompressor.encodeBitpackedHex(
        householdIdNumber: 10041,
        muacMm: ((widget.muacCm ?? 10.5) * 10).round(),
        oedema: true,
        rr: widget.breathingRate ?? 62,
        hbGdlTimesTen: ((widget.hbLevel ?? 8.4) * 10).round(),
        riskTierCode: widget.riskTier == 'URGENT' ? 2 : 1,
        bitmaskDangerFlags: 0x8041,
      );
    } else {
      return SMSCompressor.compressReferral(
        householdId: widget.householdId,
        muacCm: widget.muacCm ?? 10.5,
        oedema: true,
        breathingRate: widget.breathingRate ?? 62,
        hbLevel: widget.hbLevel ?? 8.4,
        riskTier: widget.riskTier,
        ruleCodes: ['SAM', 'FAST_BR'],
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
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('Referral Action & Emergency SMS', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppTheme.urgentRedLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.urgentRed.withValues(alpha: 0.3)),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.urgentRed,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: AppTheme.urgentRed.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4)),
                              ],
                            ),
                            child: const Icon(Icons.send_rounded, color: Colors.white, size: 26),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('URGENT EMERGENCY DISPATCH', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.urgentRed, letterSpacing: 1.1)),
                                const SizedBox(height: 2),
                                Text(displayName, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                                Text('Household ID: ${widget.householdId}', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMedium)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Target Facility Input
                    Text('Target Referral Facility', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _facilityCtrl,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.local_hospital_rounded, color: AppTheme.primaryNavy, size: 20),
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.cardBorder)),
                      ),
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                    ),

                    const SizedBox(height: 18),

                    // Auto-populated Clinical Reasons
                    Text('Clinical Indicators (Auto-Triaged)', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.cardBorder),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: displayReasons.map((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: AppTheme.urgentRed, size: 18),
                              const SizedBox(width: 10),
                              Expanded(child: Text(r, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark))),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Low-Connectivity 2G SMS Payload Preview Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.cardBorder),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.sms_outlined, color: AppTheme.accentTeal, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text('2G SMS COMPACT PAYLOAD', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy), overflow: TextOverflow.ellipsis),
                              ),
                              const SizedBox(width: 4),
                              Text('60-Char Hex', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMedium)),
                              Transform.scale(
                                scale: 0.8,
                                child: Switch(
                                  value: _useBitpackedHex,
                                  onChanged: (v) => setState(() => _useBitpackedHex = v),
                                  activeThumbColor: AppTheme.accentTeal,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Terminal Dark Code Box
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F2027),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.accentTeal.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              _smsPayload,
                              style: GoogleFonts.firaCode(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.accentTealGlow),
                            ),
                          ),

                          const SizedBox(height: 10),

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
                                icon: Icon(_smsCopied ? Icons.check : Icons.copy, size: 14, color: AppTheme.accentTeal),
                                label: Text(_smsCopied ? 'Copied' : 'Copy Payload', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accentTeal)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Trigger Button
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, -4))],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Referral submitted & SMS sent to ${_facilityCtrl.text}')),
                    );
                    _onComplete();
                  },
                  icon: const Icon(Icons.send_rounded, color: Colors.white),
                  label: Text('Send Emergency Referral & SMS', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.urgentRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
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
