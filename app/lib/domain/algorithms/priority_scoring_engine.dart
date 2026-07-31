import 'dart:math';
import '../models/clinical_models.dart';

/// Algorithmic Household & Patient Prioritization Engine
/// Guarantees Risk-Tier-First Ordering (URGENT > WATCH > ROUTINE)
/// Score tiers:
/// - URGENT: [1000.0, 1100.0]
/// - WATCH: [500.0, 600.0]
/// - ROUTINE: [0.0, 100.0]
/// Sub-score factors break ties WITHIN the same tier:
/// 1. Non-Linear Overdue Penalty: 40 * (1 - e^(-0.08 * days_overdue))
/// 2. MUAC Loss Velocity Penalty: Up to +25 pts for rapid MUAC drop (>0.5 cm/wk)
/// 3. Vulnerability Multiplier: Young Infant (<2m) = +15 pts, Severe Anaemia = +20 pts
class PriorityScoringEngine {
  static double calculatePriorityScore({
    required RiskTier riskTier,
    required int daysOverdue,
    double muacVelocityCmPerWeek = 0.0,
    bool isYoungInfant = false,
    bool isSevereAnaemia = false,
    bool isTeenagePregnancy = false,
  }) {
    // 1. Tier Base Weight (Guarantees Risk Tier First Ordering)
    double tierBase = 0.0;
    switch (riskTier) {
      case RiskTier.URGENT:
        tierBase = 1000.0;
        break;
      case RiskTier.WATCH:
        tierBase = 500.0;
        break;
      case RiskTier.ROUTINE:
        tierBase = 0.0;
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

    // Sub-tier score range [0.0, 100.0]
    final subScore = min(100.0, max(0.0, overduePenalty + velocityPenalty + vulnerabilityBonus));

    // Total score combining Tier Base + Sub-score
    return tierBase + subScore;
  }

  /// Categorizes score into visual urgency priority band
  static String getPriorityBand(double score) {
    if (score >= 1000.0) return 'CRITICAL';
    if (score >= 500.0) return 'HIGH';
    if (score >= 50.0) return 'MEDIUM';
    return 'LOW';
  }
}
