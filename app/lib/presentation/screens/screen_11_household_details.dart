import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../data/mock_repository.dart';
import '../../domain/models/clinical_models.dart';
import '../../domain/algorithms/priority_scoring_engine.dart';

class HouseholdDetailsScreen extends StatelessWidget {
  final HouseholdModel household;
  final VoidCallback onStartAssessment;
  final VoidCallback onBack;

  const HouseholdDetailsScreen({
    super.key,
    required this.household,
    required this.onStartAssessment,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final repo = MockRepository();
    final householdMembers = repo.members.where((m) => m.householdId == household.id).toList();
    final priorityBand = PriorityScoringEngine.getPriorityBand(household.priorityScore);

    Color tierColor;
    switch (household.currentRiskTier) {
      case RiskTier.URGENT: tierColor = AppTheme.urgentRed; break;
      case RiskTier.WATCH: tierColor = AppTheme.watchAmber; break;
      case RiskTier.ROUTINE: tierColor = AppTheme.routineGreen; break;
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('11. Household Details', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: onBack,
        ),
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
                    // Household Header Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: tierColor.withValues(alpha: 0.3)),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(household.name, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: tierColor, borderRadius: BorderRadius.circular(8)),
                                child: Text('${household.currentRiskTier.name} RISK', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(children: [
                            Text('ID: ${household.id}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textMedium)),
                            const SizedBox(width: 12),
                            Text('· ${household.chpsZone}', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMedium)),
                          ]),
                          const SizedBox(height: 6),
                          Row(children: [
                            const Icon(Icons.location_on_rounded, size: 14, color: AppTheme.accentTeal),
                            const SizedBox(width: 4),
                            Text('GPS: ${household.gpsCoordinates}', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMedium)),
                          ]),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Algorithmic Priority Score Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [AppTheme.primaryNavy, AppTheme.primaryNavy.withValues(alpha: 0.85)]),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50, height: 50,
                            decoration: BoxDecoration(color: AppTheme.accentTeal, borderRadius: BorderRadius.circular(12)),
                            child: Center(
                              child: Text(
                                household.priorityScore.toStringAsFixed(0),
                                style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Text('PRIORITY INDEX: $priorityBand', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.accentTeal)),
                                ]),
                                const SizedBox(height: 2),
                                Text(
                                  household.daysOverdue > 0 ? '${household.daysOverdue} days overdue for routine visit' : 'Up to date with home visits',
                                  style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Household Members Section
                    Text('Household Members (${householdMembers.length})', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                    const SizedBox(height: 10),

                    ...householdMembers.map((m) {
                      Color statusColor;
                      switch (m.riskStatus) {
                        case RiskTier.URGENT: statusColor = AppTheme.urgentRed; break;
                        case RiskTier.WATCH: statusColor = AppTheme.watchAmber; break;
                        case RiskTier.ROUTINE: statusColor = AppTheme.routineGreen; break;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.cardBorder),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                              child: Icon(
                                m.role.contains('Mother') ? Icons.pregnant_woman_rounded : (m.role.contains('Child') || m.role.contains('Infant') ? Icons.child_care_rounded : Icons.person_rounded),
                                color: statusColor,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(m.name, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                                  Text(m.role, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMedium)),
                                  if (m.latestMuacCm != null)
                                    Text('MUAC: ${m.latestMuacCm!.toStringAsFixed(1)} cm', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                              child: Text(m.riskStatus.name, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 14),

                    // Address Info Box
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Household Location & Info', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                          const SizedBox(height: 8),
                          Row(children: [
                            const Icon(Icons.home_outlined, size: 16, color: AppTheme.textMedium),
                            const SizedBox(width: 8),
                            Expanded(child: Text(household.address, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textDark))),
                          ]),
                          const SizedBox(height: 6),
                          Row(children: [
                            const Icon(Icons.phone_outlined, size: 16, color: AppTheme.textMedium),
                            const SizedBox(width: 8),
                            Text(household.phone, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textDark)),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Start Triage Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))]),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: onStartAssessment,
                  icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                  label: Text('Start Clinical Assessment', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentTeal,
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
