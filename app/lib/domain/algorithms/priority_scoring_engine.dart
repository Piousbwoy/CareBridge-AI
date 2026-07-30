import 'dart:math';
import '../models/clinical_models.dart';

/// Algorithmic Household & Patient Prioritization Engine
/// Computes a dynamic priority score P(h) in range [0.0, 100.0] using:
/// 1. Clinical Risk Tier Base Weight (URGENT = 60, WATCH = 35, ROUTINE = 10)
/// 2. Non-Linear Overdue Penalty: 40 * (1 - e^(-0.08 * days_overdue))
/// 3. MUAC Loss Velocity Penalty: Up to +25 pts for rapid MUAC drop (>0.5 cm/wk)
/// 4. Vulnerability Multiplier: Young Infant (<2m) = +15 pts, Severe Anaemia = +20 pts
class PriorityScoringEngine {
  static double calculatePriorityScore({
    required RiskTier riskTier,
    required int daysOverdue,
    double muacVelocityCmPerWeek = 0.0,
    bool isYoungInfant = false,
    bool isSevereAnaemia = false,
    bool isTeenagePregnancy = false,
  }) {
    // 1. Base score from clinical triage tier
    double baseScore = 10.0;
    switch (riskTier) {
      case RiskTier.URGENT:
        baseScore = 60.0;
        break;
      case RiskTier.WATCH:
        baseScore = 35.0;
        break;
      case RiskTier.ROUTINE:
        baseScore = 10.0;
        break;
    }

    // 2. Exponential overdue penalty (asymptotic curve capping at +40 pts)
    final overdueDays = max(0, daysOverdue);
    final overduePenalty = 40.0 * (1.0 - exp(-0.08 * overdueDays));

    // 3. MUAC velocity penalty (drop > 0.5 cm/week gets max penalty)
    double velocityPenalty = 0.0;
    if (muacVelocityCmPerWeek < -0.5) {
      velocityPenalty = 25.0;
    } else if (muacVelocityCmPerWeek < 0) {
      velocityPenalty = (muacVelocityCmPerWeek.abs() / 0.5) * 20.0;
    }

    // 4. Vulnerability bonuses
    double vulnerabilityBonus = 0.0;
    if (isYoungInfant) vulnerabilityBonus += 15.0;
    if (isSevereAnaemia) vulnerabilityBonus += 20.0;
    if (isTeenagePregnancy) vulnerabilityBonus += 10.0;

    // 5. Total clamped score [0, 100]
    final total = baseScore + overduePenalty + velocityPenalty + vulnerabilityBonus;
    return min(100.0, max(0.0, total));
  }

  /// Categorizes score into visual urgency priority band
  static String getPriorityBand(double score) {
    if (score >= 75.0) return 'CRITICAL';
    if (score >= 50.0) return 'HIGH';
    if (score >= 30.0) return 'MEDIUM';
    return 'LOW';
  }
}
