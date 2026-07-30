import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/utils/sms_compressor.dart';
import '../../domain/models/clinical_models.dart';

class ReferralActionScreen extends StatefulWidget {
  final String householdId;
  final String patientName;
  final String riskTier;
  // Point 8: Reasons are auto-populated from the rules engine result, never manually typed
  final List<String> reasons;
  final double muacCm;
  final int breathingRate;
  final double hbLevel;
  final VoidCallback onViewNutrition;

  const ReferralActionScreen({
    super.key,
    required this.householdId,
    required this.patientName,
    required this.riskTier,
    required this.reasons,        // injected directly from ClinicalRuleResult.reasons
    required this.onViewNutrition,
    this.muacCm = 10.5,
    this.breathingRate = 40,
    this.hbLevel = 12.0,
  });

  @override
  State<ReferralActionScreen> createState() => _ReferralActionScreenState();
}

class _ReferralActionScreenState extends State<ReferralActionScreen> {
  String _selectedHospital = "Bole District Hospital";
  bool _smsSent = false;

  @override
  Widget build(BuildContext context) {
    // SMS payload built automatically from injected assessment values — never requires manual entry
    final compressedPayload = SMSCompressor.compressReferral(
      householdId: widget.householdId,
      muacCm: widget.muacCm,
      oedema: widget.reasons.any((r) => r.toLowerCase().contains('oedema')),
      breathingRate: widget.breathingRate,
      hbLevel: widget.hbLevel,
      riskTier: widget.riskTier,
      ruleCodes: _extractRuleCodes(widget.reasons),
    );

    // Point 8: Readable referral message body is generated directly from reasons list.
    // The CHW NEVER re-types clinical findings into the referral form.
    final readablePreview = SMSCompressor.generateReadablePreview(
      householdId: widget.householdId,
      patientName: widget.patientName,
      riskTier: widget.riskTier,
      reasons: widget.reasons,
      chpsZone: 'Bole CHPS Zone',
    );

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('16. Referral & Action'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Referral Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.urgentRedLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.urgentRed),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_hospital_rounded, color: AppTheme.urgentRed, size: 36),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Refer to District Hospital',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.urgentRed,
                            ),
                          ),
                          Text(
                            'Immediate Triage Required · Priority: ${widget.riskTier}',
                            style: const TextStyle(fontSize: 12, color: AppTheme.primaryNavy),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Point 8: Auto-populated clinical reasons (read from rules engine, not manually typed)
              const Text(
                'Clinical Reasons (auto-populated from assessment)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.urgentRedLight.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.urgentRed.withOpacity(0.3)),
                ),
                child: Column(
                  children: widget.reasons.map((reason) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.circle, size: 7, color: AppTheme.urgentRed),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            reason,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Target Referral Facility',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedHospital,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppTheme.surfaceWhite,
                ),
                items: const [
                  DropdownMenuItem(value: "Bole District Hospital", child: Text("Bole District Hospital")),
                  DropdownMenuItem(value: "Damongo District Hospital", child: Text("Damongo District Hospital")),
                  DropdownMenuItem(value: "Yendi Municipal Hospital", child: Text("Yendi Municipal Hospital")),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedHospital = val);
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Message Preview (auto-generated)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      readablePreview,
                      style: const TextStyle(fontSize: 13, color: AppTheme.textDark, height: 1.4),
                    ),
                    const Divider(height: 20),
                    const Text(
                      'Africa\'s Talking SMS Payload (Compressed — not encrypted):',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textMedium),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: SelectableText(
                        compressedPayload,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: AppTheme.primaryNavy,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _smsSent
                      ? null
                      : () {
                          setState(() => _smsSent = true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Compressed SMS queued to Africa\'s Talking API gateway!'),
                              backgroundColor: AppTheme.routineGreen,
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _smsSent ? AppTheme.routineGreen : AppTheme.primaryNavy,
                  ),
                  icon: Icon(_smsSent ? Icons.check_circle : Icons.send_to_mobile),
                  label: Text(
                    _smsSent ? 'SMS Queued & Sent (Compressed)' : 'Send via SMS (Compressed)',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: widget.onViewNutrition,
                  icon: const Icon(Icons.restaurant_menu_outlined, color: AppTheme.accentTeal),
                  label: const Text(
                    'Attach Local Nutrition Plan to Record',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.accentTeal),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _extractRuleCodes(List<String> reasons) {
    final codes = <String>[];
    for (final r in reasons) {
      if (r.contains('SAM')) codes.add('SAM');
      if (r.contains('MAM')) codes.add('MAM');
      if (r.contains('breathing')) codes.add('FAST_BR');
      if (r.contains('pallor') || r.contains('Pallor')) codes.add('PALLOR');
      if (r.contains('Anaemia')) codes.add('ANAEMIA');
      if (r.contains('fetal')) codes.add('FETAL_MVT');
    }
    return codes.isEmpty ? ['URG'] : codes;
  }
}
