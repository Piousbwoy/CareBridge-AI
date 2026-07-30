class SMSCompressor {
  /// Compresses referral parameters into a compact format suitable for SMS transport.
  /// Example output: CB|H:10041|C:105|ED:1|RR:62|HB:84|T:URG|R:SAM,FAST_BR,PALLOR
  static String compressReferral({
    required String householdId,
    required double muacCm,
    required bool oedema,
    required int breathingRate,
    required double hbLevel,
    required String riskTier,
    required List<String> ruleCodes,
  }) {
    final rulesJoined = ruleCodes.take(3).join(',');
    final muacStr = (muacCm * 10).toInt().toString(); // e.g. 10.5 -> 105
    final oedemaStr = oedema ? '1' : '0';
    final hbStr = (hbLevel * 10).toInt().toString(); // e.g. 8.4 -> 84

    return 'CB|H:$householdId|M:$muacStr|O:$oedemaStr|RR:$breathingRate|HB:$hbStr|T:${riskTier.substring(0, 3)}|R:$rulesJoined';
  }

  /// Expands compressed payload back into human-readable text preview for CHW verification
  static String generateReadablePreview({
    required String householdId,
    required String patientName,
    required String riskTier,
    required List<String> reasons,
    required String chpsZone,
  }) {
    final reasonBullets = reasons.map((r) => '• $r').join('\n');
    return 'CAREBRIDGE REFERRAL NOTICE ($chpsZone)\n'
        'Household: $householdId ($patientName)\n'
        'Priority: ${riskTier.toUpperCase()}\n'
        'Clinical Reasons:\n$reasonBullets\n'
        'Action Required: Immediate District Hospital Triage';
  }
}
