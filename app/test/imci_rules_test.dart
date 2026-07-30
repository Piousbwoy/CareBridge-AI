import 'package:flutter_test/flutter_test.dart';
import 'package:carebridge_ai/domain/models/clinical_models.dart';
import 'package:carebridge_ai/domain/rules/imci_rules_engine.dart';
import 'package:carebridge_ai/domain/algorithms/priority_scoring_engine.dart';
import 'package:carebridge_ai/core/utils/sms_compressor.dart';

void main() {
  group('IMCI & GHS Rules Engine (26 Parameters across 7 Domains)', () {
    test('Child MUAC < 11.5cm triggers SAM URGENT', () {
      final input = AssessmentInput(muacCm: 10.5);
      final result = IMCIRulesEngine.evaluate(input);

      expect(result.overallTier, equals(RiskTier.URGENT));
      expect(result.reasons.any((r) => r.contains('Severe Acute Malnutrition (SAM)')), isTrue);
      expect(result.ghsProtocolCodes, contains('SAM_MUAC'));
    });

    test('Bilateral pitting oedema triggers SAM URGENT independently', () {
      final input = AssessmentInput(muacCm: 13.5, bilateralOedema: true);
      final result = IMCIRulesEngine.evaluate(input);

      expect(result.overallTier, equals(RiskTier.URGENT));
      expect(result.reasons.any((r) => r.contains('Bilateral pitting oedema')), isTrue);
      expect(result.ghsProtocolCodes, contains('SAM_OEDEMA'));
    });

    test('Child General Danger Sign (Convulsions) triggers URGENT unconditionally', () {
      final input = AssessmentInput(convulsions: true);
      final result = IMCIRulesEngine.evaluate(input);

      expect(result.overallTier, equals(RiskTier.URGENT));
      expect(result.reasons.any((r) => r.contains('History of convulsions')), isTrue);
    });

    test('Young Infant Fast Breathing >= 60/min triggers URGENT', () {
      final input = AssessmentInput(
        isYoungInfant: true,
        breathingRate: 64,
      );
      final result = IMCIRulesEngine.evaluate(input);

      expect(result.overallTier, equals(RiskTier.URGENT));
      expect(result.reasons.any((r) => r.contains('Young Infant Fast Breathing')), isTrue);
      expect(result.ghsProtocolCodes, contains('YI_FAST_BR'));
    });

    test('Maternal Preeclampsia proxy triggers URGENT', () {
      final input = AssessmentInput(
        severeHeadacheVisualDisturbance: true,
        elevatedBPProxy: true,
      );
      final result = IMCIRulesEngine.evaluate(input);

      expect(result.overallTier, equals(RiskTier.URGENT));
      expect(result.ghsProtocolCodes, contains('MAT_PREECLAMPSIA'));
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
      expect(result.reasons.first, contains('All assessed clinical parameters within normal ranges'));
    });
  });

  group('Priority Scoring Engine (0-100 Mathematical Matrix)', () {
    test('Calculates high priority score for URGENT tier with overdue penalty', () {
      final score = PriorityScoringEngine.calculatePriorityScore(
        riskTier: RiskTier.URGENT,
        daysOverdue: 21,
        muacVelocityCmPerWeek: -0.6,
        isSevereAnaemia: true,
      );

      expect(score > 80.0, isTrue);
      expect(PriorityScoringEngine.getPriorityBand(score), equals('CRITICAL'));
    });

    test('Applies exponential overdue decay penalty to ROUTINE tier', () {
      final freshScore = PriorityScoringEngine.calculatePriorityScore(
        riskTier: RiskTier.ROUTINE,
        daysOverdue: 0,
      );
      final overdueScore = PriorityScoringEngine.calculatePriorityScore(
        riskTier: RiskTier.ROUTINE,
        daysOverdue: 30,
      );

      expect(freshScore, equals(10.0));
      expect(overdueScore > freshScore, isTrue);
    });
  });

  group('SMS Compression Utility', () {
    test('Compresses referral into compact text payload', () {
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

    test('Encodes bit-packed 60-character hexadecimal payload for 2G networks', () {
      final hexPayload = SMSCompressor.encodeBitpackedHex(
        householdIdNumber: 10041,
        muacMm: 105,
        oedema: true,
        rr: 62,
        hbGdlTimesTen: 84,
        riskTierCode: 2,
        bitmaskDangerFlags: 0x8041,
      );

      expect(hexPayload.startsWith('CBHEX:'), isTrue);
      expect(hexPayload.length <= 60, isTrue);
    });
  });
}
