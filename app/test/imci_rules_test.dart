import 'package:flutter_test/flutter_test.dart';
import 'package:carebridge_ai/domain/models/clinical_models.dart';
import 'package:carebridge_ai/domain/rules/imci_rules_engine.dart';
import 'package:carebridge_ai/core/utils/sms_compressor.dart';

void main() {
  group('IMCI Rules Engine (23 Parameters across 6 Domains)', () {
    test('Child MUAC < 11.5cm triggers SAM URGENT', () {
      final input = AssessmentInput(muacCm: 10.5);
      final result = IMCIRulesEngine.evaluate(input);

      expect(result.overallTier, equals(RiskTier.URGENT));
      expect(result.reasons.any((r) => r.contains('Severe Acute Malnutrition (SAM)')), isTrue);
    });

    test('Bilateral pitting oedema triggers SAM URGENT independently', () {
      final input = AssessmentInput(muacCm: 13.5, bilateralOedema: true);
      final result = IMCIRulesEngine.evaluate(input);

      expect(result.overallTier, equals(RiskTier.URGENT));
      expect(result.reasons.any((r) => r.contains('Bilateral pitting oedema')), isTrue);
    });

    test('Child General Danger Sign (Convulsions) triggers URGENT unconditionally', () {
      final input = AssessmentInput(convulsions: true);
      final result = IMCIRulesEngine.evaluate(input);

      expect(result.overallTier, equals(RiskTier.URGENT));
      expect(result.reasons.any((r) => r.contains('History of convulsions')), isTrue);
    });

    test('Young Infant Fast Breathing > 60/min triggers URGENT', () {
      final input = AssessmentInput(
        isYoungInfant: true,
        breathingRate: 64,
      );
      final result = IMCIRulesEngine.evaluate(input);

      expect(result.overallTier, equals(RiskTier.URGENT));
      expect(result.reasons.any((r) => r.contains('Fast breathing (64/min > 60/min)')), isTrue);
    });

    test('Maternal Hb < 7.0 g/dL triggers Severe Anaemia URGENT', () {
      final input = AssessmentInput(maternalHb: 6.5);
      final result = IMCIRulesEngine.evaluate(input);

      expect(result.overallTier, equals(RiskTier.URGENT));
      expect(result.reasons.any((r) => r.contains('Severe Anaemia')), isTrue);
    });

    test('Maternal Danger Sign (Reduced Fetal Movement) triggers URGENT', () {
      final input = AssessmentInput(reducedAbsentFetalMovement: true);
      final result = IMCIRulesEngine.evaluate(input);

      expect(result.overallTier, equals(RiskTier.URGENT));
      expect(result.reasons.any((r) => r.contains('Reduced or absent fetal movement')), isTrue);
    });

    test('Routine parameters yield ROUTINE tier with clear explanation', () {
      final input = AssessmentInput(
        muacCm: 14.0,
        bilateralOedema: false,
        breathingRate: 42,
        maternalHb: 12.5,
      );
      final result = IMCIRulesEngine.evaluate(input);

      expect(result.overallTier, equals(RiskTier.ROUTINE));
      expect(result.reasons.first, contains('All clinical parameters within normal ranges'));
    });
  });

  group('SMS Compression Utility', () {
    test('Compresses referral into compact payload', () {
      final payload = SMSCompressor.compressReferral(
        householdId: 'H-10041',
        muacCm: 10.5,
        oedema: true,
        breathingRate: 62,
        hbLevel: 8.4,
        riskTier: 'URGENT',
        ruleCodes: ['SAM', 'FAST_BR'],
      );

      expect(payload, contains('CB|H:H-10041|M:105|O:1|RR:62|HB:84|T:URG|R:SAM,FAST_BR'));
      expect(payload.length < 140, isTrue);
    });
  });
}
