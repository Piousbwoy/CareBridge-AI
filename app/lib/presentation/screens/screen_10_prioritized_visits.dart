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

class _PrioritizedVisitsScreenState extends State<PrioritizedVisitsScreen>
    with SingleTickerProviderStateMixin {
  String _filter = 'ALL';
  final _repo = MockRepository();
  late AnimationController _headerCtrl;
  late Animation<double> _headerFade;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _headerFade = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerCtrl.forward();
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    super.dispose();
  }

  List<HouseholdModel> get _filtered {
    final all = List<HouseholdModel>.from(_repo.households);

    // Ensure strict Tier-First Priority Sorting (URGENT > WATCH > ROUTINE)
    all.sort((a, b) => b.priorityScore.compareTo(a.priorityScore));

    if (_filter == 'ALL') return all;
    return all.where((h) => h.currentRiskTier.name == _filter).toList();
  }

  void _showAddHouseholdDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Register New Household', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Household Head Name', prefixIcon: Icon(Icons.person_outline)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressCtrl,
                  decoration: const InputDecoration(labelText: 'Compound / Address', prefixIcon: Icon(Icons.home_outlined)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_outlined)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentTeal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                final newId = 'H-${10045 + _repo.households.length}';
                final h = HouseholdModel(
                  id: newId,
                  name: nameCtrl.text.trim(),
                  chpsZone: _repo.chwZone,
                  region: _repo.userRegion,
                  district: _repo.userDistrict,
                  gpsCoordinates: '9.0310° N, 2.4760° W',
                  address: addressCtrl.text.trim().isEmpty ? 'Compound, ${_repo.userDistrict}' : addressCtrl.text.trim(),
                  phone: phoneCtrl.text.trim().isEmpty ? '+233 24 000 0000' : phoneCtrl.text.trim(),
                  lastVisitDate: DateTime.now(),
                  daysOverdue: 0,
                  currentRiskTier: RiskTier.ROUTINE,
                  memberCount: 1,
                  priorityScore: 0.0,
                  muacVelocityCmPerWeek: 0.0,
                );
                _repo.addHousehold(h);
                // Also add household head as initial member
                _repo.addMember(MemberModel(
                  id: 'M-${DateTime.now().millisecondsSinceEpoch}',
                  householdId: newId,
                  name: nameCtrl.text.trim(),
                  role: 'Household Head',
                  category: PersonCategory.mother,
                  ageMonths: 300,
                  riskStatus: RiskTier.ROUTINE,
                ));
                Navigator.pop(ctx);
                setState(() {});
              },
              child: Text('Register', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final urgent = _repo.households.where((h) => h.currentRiskTier.name == 'URGENT').length;
    final watch = _repo.households.where((h) => h.currentRiskTier.name == 'WATCH').length;
    final routine = _repo.households.where((h) => h.currentRiskTier.name == 'ROUTINE').length;

    final isCaregiver = _repo.userRole == UserRole.caregiver;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHouseholdDialog(context),
        backgroundColor: AppTheme.accentTeal,
        icon: const Icon(Icons.add_home_rounded, color: Colors.white),
        label: Text('New Household', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Gradient Header ────────────────────────────────────────────
            FadeTransition(
              opacity: _headerFade,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.headerGradient,
                  boxShadow: [
                    BoxShadow(color: AppTheme.primaryNavy.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 4)),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting row
                    Row(
                      children: [
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(
                              'Hello, ${_repo.chwName} 👋',
                              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isCaregiver
                                  ? 'Caregiver Home Screening · ${_repo.userDistrict}, ${_repo.userRegion}'
                                  : '${_repo.chwZone}',
                              style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.7)),
                            ),
                          ]),
                        ),
                        // Mode pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isCaregiver ? AppTheme.watchAmber.withValues(alpha: 0.25) : AppTheme.routineGreen.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isCaregiver ? AppTheme.watchAmber.withValues(alpha: 0.5) : AppTheme.routineGreen.withValues(alpha: 0.4)),
                          ),
                          child: Row(children: [
                            Container(
                              width: 7, height: 7,
                              decoration: BoxDecoration(
                                color: isCaregiver ? AppTheme.watchAmber : AppTheme.routineGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isCaregiver ? 'Home Caregiver' : 'CHPS Clinical Mode',
                              style: GoogleFonts.inter(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700),
                            ),
                          ]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // ── Stats row ────────────────────────────────────────
                    Row(children: [
                      _StatCard(
                        label: 'Total',
                        sublabel: 'Households',
                        value: '${_repo.households.length}',
                        color: AppTheme.accentTeal,
                        icon: Icons.home_rounded,
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        label: 'Visits',
                        sublabel: 'Today',
                        value: '2',
                        color: Colors.white,
                        textColor: AppTheme.primaryNavy,
                        icon: Icons.directions_walk_rounded,
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        label: 'URGENT',
                        sublabel: 'Risk',
                        value: '$urgent',
                        color: AppTheme.urgentRed,
                        icon: Icons.warning_rounded,
                      ),
                    ]),
                    const SizedBox(height: 16),

                    // ── Filter tabs ──────────────────────────────────────
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: [
                        _FilterTab('ALL', _filter, () => setState(() => _filter = 'ALL')),
                        const SizedBox(width: 8),
                        _FilterTab('URGENT', _filter, () => setState(() => _filter = 'URGENT'),
                            color: AppTheme.urgentRed, count: urgent),
                        const SizedBox(width: 8),
                        _FilterTab('WATCH', _filter, () => setState(() => _filter = 'WATCH'),
                            color: AppTheme.watchAmber, count: watch),
                        const SizedBox(width: 8),
                        _FilterTab('ROUTINE', _filter, () => setState(() => _filter = 'ROUTINE'),
                            color: AppTheme.routineGreen, count: routine),
                      ]),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),

            // ── Household List ─────────────────────────────────────────────
            Expanded(
              child: _filtered.isEmpty
                  ? _EmptyState(filter: _filter)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      itemCount: _filtered.length,
                      itemBuilder: (ctx, i) {
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: Duration(milliseconds: 250 + i * 50),
                          curve: Curves.easeOutCubic,
                          builder: (context, v, child) => Opacity(
                            opacity: v,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - v)),
                              child: child,
                            ),
                          ),
                          child: _HouseholdCard(
                            household: _filtered[i],
                            onTap: () => widget.onSelectHousehold(_filtered[i]),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Gradient stat card ─────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String sublabel;
  final String value;
  final Color color;
  final Color? textColor;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.sublabel,
    required this.value,
    required this.color,
    required this.icon,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final tc = textColor ?? Colors.white;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: textColor != null ? 1 : 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 16, color: tc.withValues(alpha: 0.75)),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: tc)),
          Text('$label\n$sublabel',
              style: GoogleFonts.inter(fontSize: 10, color: tc.withValues(alpha: 0.7), height: 1.3)),
        ]),
      ),
    );
  }
}

// ── Filter tab ─────────────────────────────────────────────────────────────────
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
    final c = color ?? Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppTheme.normalAnim,
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? c : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? c : Colors.white.withValues(alpha: 0.25)),
          boxShadow: isSelected ? AppTheme.cardShadow(color: c, opacity: 0.3) : [],
        ),
        child: Row(children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? (color == null ? AppTheme.primaryNavy : Colors.white)
                  : Colors.white,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? (color == null ? AppTheme.primaryNavy : Colors.white)
                      : Colors.white,
                ),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}

// ── Premium household card with Category Badges ────────────────────────────────
class _HouseholdCard extends StatelessWidget {
  final HouseholdModel household;
  final VoidCallback onTap;
  const _HouseholdCard({required this.household, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final repo = MockRepository();
    final members = repo.getMembersForHousehold(household.id);

    Color tierColor;
    Color tierGlow;
    IconData tierIcon;
    switch (household.currentRiskTier.name) {
      case 'URGENT':
        tierColor = AppTheme.urgentRed;
        tierGlow = AppTheme.urgentRedGlow;
        tierIcon = Icons.warning_rounded;
        break;
      case 'WATCH':
        tierColor = AppTheme.watchAmber;
        tierGlow = AppTheme.watchAmberGlow;
        tierIcon = Icons.visibility_rounded;
        break;
      default:
        tierColor = AppTheme.routineGreen;
        tierGlow = AppTheme.routineGreenGlow;
        tierIcon = Icons.check_circle_rounded;
    }

    final parts = household.name.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : household.name.substring(0, 2).toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border(left: BorderSide(color: tierColor, width: 4)),
        boxShadow: AppTheme.cardShadow(),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Avatar circle with initials
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    color: tierColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: tierColor.withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: Center(
                    child: Text(initials,
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: tierColor)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(household.name,
                        style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                    const SizedBox(height: 3),
                    Text(household.id,
                        style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMedium)),
                    const SizedBox(height: 6),

                    // Member Category Badges (Mother/Newborn/Child)
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      children: [
                        ...members.map((m) {
                          String iconStr = '🧒';
                          if (m.category == PersonCategory.mother) iconStr = '🤰';
                          if (m.category == PersonCategory.newbornYoungInfant) iconStr = '👶';
                          if (m.category == PersonCategory.other) iconStr = '👤';
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(iconStr, style: const TextStyle(fontSize: 11)),
                          );
                        }),
                        if (household.daysOverdue > 0)
                          Container(
                            margin: const EdgeInsets.only(left: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: tierColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('${household.daysOverdue}d overdue',
                                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: tierColor)),
                          ),
                      ],
                    ),
                  ]),
                ),
                // Tier badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: tierColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: tierGlow, blurRadius: 8)],
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(tierIcon, size: 11, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(household.currentRiskTier.name,
                            style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                      ]),
                    ),
                    const SizedBox(height: 8),
                    const Icon(Icons.chevron_right_rounded, size: 18, color: AppTheme.textLight),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.search_off_rounded, size: 56, color: AppTheme.textLight),
        const SizedBox(height: 12),
        Text('No $filter households', style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textMedium, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text('All households are up to date', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textLight)),
      ]),
    );
  }
}
