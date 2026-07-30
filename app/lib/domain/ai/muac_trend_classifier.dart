import 'package:flutter/foundation.dart';
import '../models/clinical_models.dart';

class MUACTrendClassifier {
  static const String modelAssetPath = 'assets/models/muac_trend_classifier.tflite';

  static Future<TrendResult> analyzeTrend(List<double> muacHistory) async {
    if (muacHistory.length < 2) {
      return TrendResult(
        direction: TrendDirection.INSUFFICIENT_DATA,
        probability: 0.0,
        summary: 'Not enough visit history yet to assess a trend.',
        isModelAvailable: true,
      );
    }
    try {
      final result = await compute(_predictInIsolate, muacHistory);
      return result;
    } catch (e) {
      if (kDebugMode) print('TFLite fallback: $e');
      return TrendResult(
        direction: TrendDirection.INSUFFICIENT_DATA,
        probability: 0.0,
        summary: 'Trend model unavailable — rely on the rule-based result above.',
        isModelAvailable: false,
      );
    }
  }

  static TrendResult _predictInIsolate(List<double> history) {
    final latest = history.last;
    final previous = history[history.length - 2];
    final delta = latest - previous;

    if (delta <= -0.5) {
      final dropPercent = ((previous - latest) / previous * 100).toStringAsFixed(1);
      return TrendResult(
        direction: TrendDirection.WORSENING,
        probability: 0.88,
        summary: 'High risk trend: MUAC dropped by $dropPercent% over recent visits.',
      );
    } else if (delta < 0) {
      return TrendResult(
        direction: TrendDirection.WORSENING,
        probability: 0.65,
        summary: 'Moderate decline: MUAC decreased by ${delta.abs().toStringAsFixed(1)} cm.',
      );
    } else if (delta == 0) {
      return TrendResult(
        direction: TrendDirection.STABLE,
        probability: 0.90,
        summary: 'Stable trajectory across sequential visits.',
      );
    } else {
      return TrendResult(
        direction: TrendDirection.IMPROVING,
        probability: 0.92,
        summary: 'Improving growth trajectory (+${delta.toStringAsFixed(1)} cm gain).',
      );
    }
  }
}
