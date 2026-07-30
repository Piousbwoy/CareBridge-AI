import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/utils/sms_compressor.dart';

class ReferralActionScreen extends StatefulWidget {
  final String householdName;
  final String householdId;
  final List<String> autoReasons;
  final String riskTier;
  final VoidCallback onReferralComplete;

  const ReferralActionScreen({
    super.key,
    required this.householdName,
    required this.householdId,
    required this.autoReasons,
    required this.riskTier,
    required this.onReferralComplete,
  });

  @override
  State<ReferralActionScreen> createState() => _ReferralActionScreenState();
}

class _ReferralActionScreenState extends State<ReferralActionScreen> {
  final _facilityCtrl = TextEditingController(text: 'Bole District Hospital');
  final _chwNotesCtrl = TextEditingController();
  bool _useBitpackedHex = false;
  bool _smsCopied = false;

  String get _smsPayload {
    if (_useBitpackedHex) {
      return SMSCompressor.encodeBitpackedHex(
        householdIdNumber: 10041,
        muacMm: 105,
        oedema: true,
        rr: 62,
        hbGdlTimesTen: 84,
        riskTierCode: widget.riskTier == 'URGENT' ? 2 : 1,
        bitmaskDangerFlags: 0x8041,
      );
    } else {
      return SMSCompressor.compressReferral(
        householdId: widget.householdId,
        muacCm: 10.5,
        oedema: true,
        breathingRate: 62,
        hbLevel: 8.4,
        riskTier: widget.riskTier,
        ruleCodes: ['SAM', 'FAST_BR'],
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Auto-populate CHW clinical note directly from rules engine output (never manual typing)
    _chwNotesCtrl.text = 'Clinical Auto-Summary: ${widget.autoReasons.join("; ")}. Evaluated at CHPS point of care. Referral initiated to ${_facilityCtrl.text}.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('16. Referral Action & SMS', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
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
                        color: AppTheme.urgentRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.urgentRed.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(color: AppTheme.urgentRed, shape: BoxShape.circle),
                            child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('URGENT REFERRAL INITIATED', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.urgentRed, letterSpacing: 1.1)),
                                Text(widget.householdName, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                                Text('ID: ${widget.householdId}', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMedium)),
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
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.local_hospital_rounded, color: AppTheme.primaryNavy, size: 20),
                        isDense: true,
                      ),
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                    ),

                    const SizedBox(height: 16),

                    // Auto-populated Clinical Reasons
                    Text('Clinical Reasons (Auto-Populated)', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMedium)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.autoReasons.map((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: AppTheme.urgentRed, size: 16),
                              const SizedBox(width: 8),
                              Expanded(child: Text(r, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textDark))),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Low-Connectivity SMS Payload Preview Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(children: [
                                  const Icon(Icons.sms_outlined, color: AppTheme.accentTeal, size: 20),
                                  const SizedBox(width: 8),
                                  Text('2G SMS COMPACT PAYLOAD', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                                ]),
                                Row(children: [
                                  Text('60-Char Hex', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMedium)),
                                  Switch(
                                    value: _useBitpackedHex,
                                    onChanged: (v) => setState(() => _useBitpackedHex = v),
                                    activeThumbColor: AppTheme.accentTeal,
                                  ),
                                ]),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Referral submitted & SMS sent to ${_facilityCtrl.text}')),
                    );
                    widget.onReferralComplete();
                  },
                  icon: const Icon(Icons.send_rounded, color: Colors.white),
                  label: Text('Send Referral & SMS', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.urgentRed,
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
