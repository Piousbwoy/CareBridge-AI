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
            // Top Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Hello, Ama Abena 👋', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                          Text('Bole CHPS Zone', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMedium)),
                        ]),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: AppTheme.routineGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                        child: Row(children: [
                          Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppTheme.routineGreen, shape: BoxShape.circle)),
                          const SizedBox(width: 5),
                          Text('Offline Mode', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.routineGreen, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Stats row
                  Row(children: [
                    _StatChip(label: 'Total\nHouseholds', value: '${_repo.households.length}', color: AppTheme.primaryNavy),
                    const SizedBox(width: 8),
                    _StatChip(label: 'Visits\nToday', value: '2', color: AppTheme.accentTeal),
                    const SizedBox(width: 8),
                    _StatChip(label: 'URGENT', value: '$urgent', color: AppTheme.urgentRed),
                  ]),
                  const SizedBox(height: 14),
                  // Filter tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      _FilterTab('ALL', _filter, () => setState(() => _filter = 'ALL')),
                      const SizedBox(width: 8),
                      _FilterTab('URGENT', _filter, () => setState(() => _filter = 'URGENT'), color: AppTheme.urgentRed, count: urgent),
                      const SizedBox(width: 8),
                      _FilterTab('WATCH', _filter, () => setState(() => _filter = 'WATCH'), color: AppTheme.watchAmber, count: watch),
                      const SizedBox(width: 8),
                      _FilterTab('ROUTINE', _filter, () => setState(() => _filter = 'ROUTINE'), color: AppTheme.routineGreen, count: routine),
                    ]),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            // Household List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _filtered.length,
                itemBuilder: (ctx, i) => _HouseholdCard(household: _filtered[i], onTap: () => widget.onSelectHousehold(_filtered[i])),
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
  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(children: [
          Text(value, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text(label, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textMedium, height: 1.2)),
        ]),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? c : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? c : AppTheme.cardBorder),
        ),
        child: Row(children: [
          Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : c)),
          if (count != null) ...[
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.3) : c.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('$count', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : c)),
            ),
          ],
        ]),
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
    switch (household.currentRiskTier.name) {
      case 'URGENT': tierColor = AppTheme.urgentRed; tierIcon = Icons.warning_rounded; break;
      case 'WATCH': tierColor = AppTheme.watchAmber; tierIcon = Icons.visibility_rounded; break;
      default: tierColor = AppTheme.routineGreen; tierIcon = Icons.check_circle_rounded;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: tierColor.withValues(alpha: 0.3)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
        ),
        child: Row(
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(color: tierColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(tierIcon, color: tierColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(household.name, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                const SizedBox(height: 3),
                Text(household.id, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMedium)),
                const SizedBox(height: 4),
                Row(children: [
                  Text('${household.memberCount} members', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMedium)),
                  if (household.daysOverdue > 0) ...[
                    const SizedBox(width: 8),
                    Text('· ${household.daysOverdue}d overdue', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: tierColor)),
                  ],
                ]),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: tierColor, borderRadius: BorderRadius.circular(8)),
              child: Text(household.currentRiskTier.name,
                  style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
