import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../data/mock_repository.dart';
import '../../domain/models/clinical_models.dart';

// ─── SCREEN 9/10: HOME DASHBOARD + PRIORITIZED VISITS ─────────────────────────
class PrioritizedVisitsScreen extends StatefulWidget {
  final Function(HouseholdModel) onSelectHousehold;
  const PrioritizedVisitsScreen({super.key, required this.onSelectHousehold});

  @override
  State<PrioritizedVisitsScreen> createState() => _PrioritizedVisitsScreenState();
}

class _PrioritizedVisitsScreenState extends State<PrioritizedVisitsScreen> {
  String _filter = 'ALL';
  final _repo = MockRepository();

  List<HouseholdModel> get _filtered {
    final all = _repo.households;
    if (_filter == 'ALL') return all;
    return all.where((h) => h.currentRiskTier.name == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final urgent = _repo.households.where((h) => h.currentRiskTier.name == 'URGENT').length;
    final watch = _repo.households.where((h) => h.currentRiskTier.name == 'WATCH').length;
    final routine = _repo.households.where((h) => h.currentRiskTier.name == 'ROUTINE').length;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top Luxury Header Banner
            Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.luxuryHeaderGradient,
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4)),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('CHO Ama Abena', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentTeal.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.accentTeal.withValues(alpha: 0.4)),
                                ),
                                child: Text('OFFICER', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.accentTealGlow, letterSpacing: 0.5)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, color: AppTheme.accentTeal, size: 14),
                              const SizedBox(width: 4),
                              Text('Bole CHPS Zone · Savannah Region', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppTheme.accentTealGlow, shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text('Offline Ready', style: GoogleFonts.inter(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Luxury Summary Metric Cards
                  Row(
                    children: [
                      _StatChip(label: 'Total Visits', value: '${_repo.households.length}', color: Colors.white, icon: Icons.people_alt_rounded),
                      const SizedBox(width: 10),
                      _StatChip(label: 'URGENT', value: '$urgent', color: AppTheme.urgentRed, icon: Icons.warning_amber_rounded),
                      const SizedBox(width: 10),
                      _StatChip(label: 'WATCH', value: '$watch', color: AppTheme.watchAmber, icon: Icons.visibility_rounded),
                      const SizedBox(width: 10),
                      _StatChip(label: 'ROUTINE', value: '$routine', color: AppTheme.accentTeal, icon: Icons.check_circle_outline_rounded),
                    ],
                  ),
                ],
              ),
            ),

            // Filter Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterTab('ALL', _filter, () => setState(() => _filter = 'ALL')),
                    const SizedBox(width: 8),
                    _FilterTab('URGENT', _filter, () => setState(() => _filter = 'URGENT'), color: AppTheme.urgentRed, count: urgent),
                    const SizedBox(width: 8),
                    _FilterTab('WATCH', _filter, () => setState(() => _filter = 'WATCH'), color: AppTheme.watchAmber, count: watch),
                    const SizedBox(width: 8),
                    _FilterTab('ROUTINE', _filter, () => setState(() => _filter = 'ROUTINE'), color: AppTheme.routineGreen, count: routine),
                  ],
                ),
              ),
            ),

            const Divider(height: 1, color: AppTheme.cardBorderSubtle),

            // Household List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                itemCount: _filtered.length,
                itemBuilder: (ctx, i) => _HouseholdCard(
                  household: _filtered[i],
                  onTap: () => widget.onSelectHousehold(_filtered[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _StatChip({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 14),
                const SizedBox(width: 4),
                Text(value, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 2),
            Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final String selected;
  final VoidCallback onTap;
  final Color? color;
  final int? count;
  const _FilterTab(this.label, this.selected, this.onTap, {this.color, this.count});

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == label;
    final c = color ?? AppTheme.primaryNavy;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? c : AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? c : AppTheme.cardBorder),
          boxShadow: isSelected ? [BoxShadow(color: c.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))] : [],
        ),
        child: Row(
          children: [
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppTheme.textMedium,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withValues(alpha: 0.28) : c.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('$count', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : c)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HouseholdCard extends StatelessWidget {
  final HouseholdModel household;
  final VoidCallback onTap;
  const _HouseholdCard({required this.household, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color tierColor;
    IconData tierIcon;
    String tierLabel;

    switch (household.currentRiskTier.name) {
      case 'URGENT':
        tierColor = AppTheme.urgentRed;
        tierIcon = Icons.warning_amber_rounded;
        tierLabel = 'URGENT ATTENTION';
        break;
      case 'WATCH':
        tierColor = AppTheme.watchAmber;
        tierIcon = Icons.visibility_rounded;
        tierLabel = 'WATCH LIST';
        break;
      default:
        tierColor = AppTheme.routineGreen;
        tierIcon = Icons.check_circle_outline_rounded;
        tierLabel = 'ROUTINE CARE';
    }

    final priorityScore = (100 - (household.daysOverdue * 3.5)).clamp(20, 98).round();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: AppTheme.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left Risk Color Accent Pillar
              Container(
                width: 6,
                color: tierColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Household Name + Tier Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              household.name,
                              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: tierColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: tierColor.withValues(alpha: 0.25)),
                            ),
                            child: Row(
                              children: [
                                Icon(tierIcon, color: tierColor, size: 13),
                                const SizedBox(width: 4),
                                Text(
                                  tierLabel,
                                  style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: tierColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Location + Days Overdue
                      Row(
                        children: [
                          const Icon(Icons.maps_home_work_outlined, size: 14, color: AppTheme.textMedium),
                          const SizedBox(width: 4),
                          Text('${household.subZone} · ${household.householdCode}', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMedium)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: household.daysOverdue > 14 ? AppTheme.urgentRed.withValues(alpha: 0.08) : AppTheme.backgroundLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${household.daysOverdue}d Overdue',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: household.daysOverdue > 14 ? AppTheme.urgentRed : AppTheme.textMedium,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Priority Meter & Action CTA
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Priority Index', style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textLight, fontWeight: FontWeight.w500)),
                                    Text('$priorityScore/100', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: tierColor)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: priorityScore / 100.0,
                                    minHeight: 5,
                                    backgroundColor: AppTheme.cardBorderSubtle,
                                    valueColor: AlwaysStoppedAnimation<Color>(tierColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            height: 38,
                            child: ElevatedButton(
                              onPressed: onTap,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: tierColor == AppTheme.urgentRed ? AppTheme.urgentRed : AppTheme.primaryNavy,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                elevation: 0,
                              ),
                              child: Row(
                                children: [
                                  Text('Assess', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
                                ],
                              ),
                            ),
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
    );
  }
}
