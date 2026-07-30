/// SMS Payload Compressor for Ultra-Low Bandwidth 2G Environments
/// Converts maternal & child assessment findings into sub-140 character strings or 60-char hex bit-packed payloads.
class SMSCompressor {
  /// Compresses referral into human-readable compact pipe-delimited payload (< 120 chars)
  static String compressReferral({
    required String householdId,
    required double? muacCm,
    required bool oedema,
    required int breathingRate,
    required double? hbLevel,
    required String riskTier,
    required List<String> ruleCodes,
  }) {
    final cleanHid = householdId.replaceAll(' ', '');
    final mStr = muacCm != null ? (muacCm * 10).round().toString() : 'N';
    final oStr = oedema ? '1' : '0';
    final hbStr = hbLevel != null ? (hbLevel * 10).round().toString() : 'N';
    final tStr = riskTier.substring(0, 3).toUpperCase();
    final cStr = ruleCodes.take(3).join(',');

    return 'CB|H:$cleanHid|M:$mStr|O:$oStr|RR:$breathingRate|HB:$hbStr|T:$tStr|R:$cStr';
  }

  /// Compact Bit-Packed Hexadecimal Encoder (60 chars max)
  /// Packs booleans & numeric values into a raw byte array for 1-cent 2G SMS transmission
  static String encodeBitpackedHex({
    required int householdIdNumber,
    required int muacMm, // MUAC in mm
    required bool oedema,
    required int rr, // Respiratory rate
    required int hbGdlTimesTen, // Hb * 10
    required int riskTierCode, // 0 = ROUTINE, 1 = WATCH, 2 = URGENT
    required int bitmaskDangerFlags, // 16-bit flag bitmask
  }) {
    // 8-byte packed structure:
    // [0..1]: Household ID (16-bit)
    // [2]: MUAC mm (8-bit)
    // [3]: RR (8-bit)
    // [4]: Hb * 10 (8-bit)
    // [5]: (RiskTier << 4) | (Oedema ? 1 : 0) (8-bit)
    // [6..7]: Danger Flags Bitmask (16-bit)
    final bytes = List<int>.filled(8, 0);

    bytes[0] = (householdIdNumber >> 8) & 0xFF;
    bytes[1] = householdIdNumber & 0xFF;
    bytes[2] = muacMm & 0xFF;
    bytes[3] = rr & 0xFF;
    bytes[4] = hbGdlTimesTen & 0xFF;
    bytes[5] = ((riskTierCode & 0x0F) << 4) | (oedema ? 1 : 0);
    bytes[6] = (bitmaskDangerFlags >> 8) & 0xFF;
    bytes[7] = bitmaskDangerFlags & 0xFF;

    final hexBuffer = StringBuffer('CBHEX:');
    for (final b in bytes) {
      hexBuffer.write(b.toRadixString(16).padLeft(2, '0').toUpperCase());
    }
    return hexBuffer.toString();
  }
}
