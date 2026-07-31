import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../data/mock_repository.dart';
import '../../domain/models/clinical_models.dart';

// ─── SCREEN 10: PRIORITIZED VISITS & GHS PROTOCOL CARE SCHEDULE ────────────────
class PrioritizedVisitsScreen extends StatefulWidget {
  final Function(HouseholdModel) onSelectHousehold;
  final Function(ScheduledVisitModel visit)? onSelectScheduledVisit;

  const PrioritizedVisitsScreen({
    super.key,
    required this.onSelectHousehold,
    this.onSelectScheduledVisit,
  });

  @override
  State<PrioritizedVisitsScreen> createState() => _PrioritizedVisitsScreenState();
}

class _PrioritizedVisitsScreenState extends State<PrioritizedVisitsScreen>
    with SingleTickerProviderStateMixin {
  String _viewMode = 'SCHEDULE'; // 'SCHEDULE' or 'HOUSEHOLDS'
  String _filter = 'ALL';
  final _repo = MockRepository();
  late AnimationController _headerCtrl;
  late Animation<double> _headerFade;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _headerFade = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerCtrl.forward();
    _repo.addListener(_onRepoChanged);
  }

  void _onRepoChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepoChanged);
    _headerCtrl.dispose();
    super.dispose();
  }

  List<HouseholdModel> get _filteredHouseholds {
    final all = List<HouseholdModel>.from(_repo.households);
    all.sort((a, b) => b.priorityScore.compareTo(a.priorityScore));
    if (_filter == 'ALL') return all;
    return all.where((h) => h.currentRiskTier.name == _filter).toList();
  }

  List<ScheduledVisitModel> get _filteredVisits {
    final all = List<ScheduledVisitModel>.from(_repo.scheduledVisits);
    // Sort overdue first, then due, then upcoming, then completed
    all.sort((a, b) {
      final statusWeight = {
        VisitStatus.overdue: 0,
        VisitStatus.due: 1,
        VisitStatus.upcoming: 2,
        VisitStatus.completed: 3,
        VisitStatus.missed: 4,
      };
      final weightA = statusWeight[a.status] ?? 5;
      final weightB = statusWeight[b.status] ?? 5;
      if (weightA != weightB) return weightA.compareTo(weightB);
      return b.daysOverdue.compareTo(a.daysOverdue);
    });

    if (_filter == 'ALL') return all;
    if (_filter == 'OVERDUE') return all.where((v) => v.status == VisitStatus.overdue || v.status == VisitStatus.due).toList();
    if (_filter == 'COMPLETED') return all.where((v) => v.status == VisitStatus.completed).toList();
    return all;
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
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
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
              },
              child: Text('Register', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showAdHocVisitDialog(BuildContext context) {
    if (_repo.members.isEmpty) return;
    MemberModel selectedMember = _repo.members.first;
    final reasonCtrl = TextEditingController(text: 'Caregiver reported sudden fever / breathing difficulty');

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Icon(Icons.bolt_rounded, color: AppTheme.urgentRed),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Unscheduled / Ad-hoc Visit',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryNavy),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Family Member:', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMedium)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<MemberModel>(
                        value: selectedMember,
                        isExpanded: true,
                        items: _repo.members.map((m) {
                          return DropdownMenuItem(
                            value: m,
                            child: Text('${m.name} (${m.role})', style: GoogleFonts.inter(fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => selectedMember = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('Reported Danger Sign / Reason:', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMedium)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: reasonCtrl,
                    maxLines: 2,
                    style: GoogleFonts.inter(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Describe reported symptom or reason for walk-in visit...',
                      isDense: true,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.urgentRed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  final reason = reasonCtrl.text.trim().isEmpty ? 'Ad-hoc walk-in danger sign' : reasonCtrl.text.trim();
                  final unscheduledVisit = _repo.addUnscheduledVisit(
                    member: selectedMember,
                    dangerSignReason: reason,
                  );
                  Navigator.pop(ctx);
                  if (widget.onSelectScheduledVisit != null) {
                    widget.onSelectScheduledVisit!(unscheduledVisit);
                  }
                },
                child: Text('Start Assessment', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final urgentCount = _repo.households.where((h) => h.currentRiskTier == RiskTier.URGENT).length;
    final overdueVisitsCount = _repo.scheduledVisits.where((v) => v.status == VisitStatus.overdue).length;
    final dueVisitsCount = _repo.scheduledVisits.where((v) => v.status == VisitStatus.due).length;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _viewMode == 'SCHEDULE' ? _showAdHocVisitDialog(context) : _showAddHouseholdDialog(context),
        backgroundColor: _viewMode == 'SCHEDULE' ? AppTheme.urgentRed : AppTheme.accentTeal,
        icon: Icon(_viewMode == 'SCHEDULE' ? Icons.bolt_rounded : Icons.add_home_rounded, color: Colors.white),
        label: Text(
          _viewMode == 'SCHEDULE' ? '+ Ad-hoc Visit' : '+ New Household',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
        ),
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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good Day, ${_repo.chwName} 👋',
                                style: GoogleFonts.outfit(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_repo.chwZone}',
                                style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.75)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.routineGreen.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.routineGreen.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            'CHPS Active',
                            style: GoogleFonts.inter(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Mode Switcher Tabs (Protocol Schedule vs Household List)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _TabButton(
                              label: 'Care Schedule ($overdueVisitsCount Overdue)',
                              active: _viewMode == 'SCHEDULE',
                              activeColor: AppTheme.accentTeal,
                              onTap: () => setState(() { _viewMode = 'SCHEDULE'; _filter = 'ALL'; }),
                            ),
                          ),
                          Expanded(
                            child: _TabButton(
                              label: 'Households (${_repo.households.length})',
                              active: _viewMode == 'HOUSEHOLDS',
                              activeColor: AppTheme.primaryNavy,
                              onTap: () => setState(() { _viewMode = 'HOUSEHOLDS'; _filter = 'ALL'; }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Filters Bar ──────────────────────────────────────────
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _viewMode == 'SCHEDULE'
                            ? [
                                _FilterChip('ALL', _filter, () => setState(() => _filter = 'ALL')),
                                const SizedBox(width: 6),
                                _FilterChip('OVERDUE / DUE', _filter, () => setState(() => _filter = 'OVERDUE'),
                                    color: AppTheme.urgentRed, count: overdueVisitsCount + dueVisitsCount),
                                const SizedBox(width: 6),
                                _FilterChip('COMPLETED', _filter, () => setState(() => _filter = 'COMPLETED'),
                                    color: AppTheme.routineGreen),
                              ]
                            : [
                                _FilterChip('ALL', _filter, () => setState(() => _filter = 'ALL')),
                                const SizedBox(width: 6),
                                _FilterChip('URGENT', _filter, () => setState(() => _filter = 'URGENT'),
                                    color: AppTheme.urgentRed, count: urgentCount),
                                const SizedBox(width: 6),
                                _FilterChip('WATCH', _filter, () => setState(() => _filter = 'WATCH'),
                                    color: AppTheme.watchAmber),
                                const SizedBox(width: 6),
                                _FilterChip('ROUTINE', _filter, () => setState(() => _filter = 'ROUTINE'),
                                    color: AppTheme.routineGreen),
                              ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Main List Content ──────────────────────────────────────────
            Expanded(
              child: _viewMode == 'SCHEDULE' ? _buildScheduleList() : _buildHouseholdsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleList() {
    final visits = _filteredVisits;
    if (visits.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.event_available_rounded, size: 48, color: AppTheme.textLight),
              const SizedBox(height: 12),
              Text('No scheduled visits match filter', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
              Text('All protocol touches up to date.', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMedium)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: visits.length,
      itemBuilder: (context, index) {
        final visit = visits[index];
        final isOverdue = visit.status == VisitStatus.overdue;
        final isDue = visit.status == VisitStatus.due;
        final isCompleted = visit.status == VisitStatus.completed;

        final badgeColor = isOverdue
            ? AppTheme.urgentRed
            : isDue
                ? AppTheme.watchAmber
                : isCompleted
                    ? AppTheme.routineGreen
                    : AppTheme.textMedium;

        final statusLabel = isOverdue
            ? '${visit.daysOverdue} DAYS OVERDUE'
            : isDue
                ? 'DUE TODAY'
                : isCompleted
                    ? 'COMPLETED'
                    : 'UPCOMING';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isOverdue ? AppTheme.urgentRed.withValues(alpha: 0.5) : AppTheme.cardBorder,
              width: isOverdue ? 1.5 : 1.0,
            ),
          ),
          elevation: 1,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              if (widget.onSelectScheduledVisit != null) {
                widget.onSelectScheduledVisit!(visit);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          statusLabel,
                          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          visit.contactName,
                          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentTeal),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (visit.isUnscheduled)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.urgentRed.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('Unscheduled', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.urgentRed)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    visit.title,
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person_rounded, size: 14, color: AppTheme.textMedium),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${visit.memberName} • ${visit.householdName}',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 14, color: AppTheme.textMedium),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            visit.reasonText,
                            style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMedium),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Due: ${visit.dueDate.toString().substring(0, 10)}',
                        style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMedium),
                      ),
                      Row(
                        children: [
                          Text(
                            isCompleted ? 'View Result' : 'Start Assessment',
                            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accentTeal),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_rounded, size: 14, color: AppTheme.accentTeal),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHouseholdsList() {
    final households = _filteredHouseholds;
    if (households.isEmpty) {
      return Center(
        child: Text('No households registered in this filter.', style: GoogleFonts.inter(color: AppTheme.textMedium)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: households.length,
      itemBuilder: (context, index) {
        final household = households[index];
        final isUrgent = household.currentRiskTier == RiskTier.URGENT;
        final isWatch = household.currentRiskTier == RiskTier.WATCH;
        final color = isUrgent ? AppTheme.urgentRed : isWatch ? AppTheme.watchAmber : AppTheme.routineGreen;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: color.withValues(alpha: 0.4), width: isUrgent ? 1.5 : 1.0),
          ),
          elevation: 1,
          child: ListTile(
            contentPadding: const EdgeInsets.all(14),
            onTap: () => widget.onSelectHousehold(household),
            leading: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Center(child: Icon(Icons.home_rounded, color: color, size: 24)),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    household.name,
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    household.currentRiskTier.name,
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('${household.address} • ${household.memberCount} members', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textDark)),
                const SizedBox(height: 2),
                Text('Priority Score: ${household.priorityScore.toStringAsFixed(1)} | Overdue: ${household.daysOverdue} days',
                    style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMedium)),
              ],
            ),
            trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textMedium),
          ),
        );
      },
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  const _TabButton({required this.label, required this.active, required this.activeColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: active ? Colors.white : Colors.white.withValues(alpha: 0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String currentFilter;
  final VoidCallback onTap;
  final Color? color;
  final int? count;

  const _FilterChip(this.label, this.currentFilter, this.onTap, {this.color, this.count});

  @override
  Widget build(BuildContext context) {
    final isSelected = currentFilter == label || (label == 'OVERDUE / DUE' && currentFilter == 'OVERDUE');
    final chipColor = color ?? AppTheme.accentTeal;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? chipColor : Colors.white.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.85),
              ),
            ),
            if (count != null && count! > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Text(
                  '$count',
                  style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: chipColor),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
