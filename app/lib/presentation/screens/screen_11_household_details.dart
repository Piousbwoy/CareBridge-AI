import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../data/mock_repository.dart';
import '../../domain/models/clinical_models.dart';

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

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('Household: ${household.id}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Household Header Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            household.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryNavy,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: household.currentRiskTier == RiskTier.URGENT
                                ? AppTheme.urgentRedLight
                                : household.currentRiskTier == RiskTier.WATCH
                                    ? AppTheme.watchAmberLight
                                    : AppTheme.routineGreenLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            household.currentRiskTier.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: household.currentRiskTier == RiskTier.URGENT
                                  ? AppTheme.urgentRed
                                  : household.currentRiskTier == RiskTier.WATCH
                                      ? AppTheme.watchAmber
                                      : AppTheme.routineGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.location_on_outlined, 'Address', household.address),
                    _buildInfoRow(Icons.gps_fixed, 'GPS Coordinates', household.gpsCoordinates),
                    _buildInfoRow(Icons.phone_outlined, 'Phone', household.phone),
                    _buildInfoRow(
                      Icons.history,
                      'Last Visit',
                      '${DateFormat('MMM dd, yyyy').format(household.lastVisitDate)} (${household.daysOverdue} days ago)',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Household Members',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                  ),
                  Text(
                    '${householdMembers.length} Registered',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMedium),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (householdMembers.isEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('No members registered yet under this household.'),
                  ),
                ),
              ] else ...[
                ...householdMembers.map((member) => _buildMemberCard(member)).toList(),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: onStartAssessment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentTeal,
                  ),
                  icon: const Icon(Icons.add_task),
                  label: const Text(
                    'Start Rapid Assessment (Child + Mother)',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.textMedium),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontSize: 13, color: AppTheme.textMedium)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(MemberModel member) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.primaryNavy.withOpacity(0.1),
              child: Icon(
                member.role.contains('Child') || member.role.contains('Infant')
                    ? Icons.child_care
                    : Icons.person_outline,
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${member.role} · ${member.ageMonths} months old',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMedium),
                  ),
                  if (member.latestMuacCm != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.straighten, size: 12, color: AppTheme.urgentRed),
                        const SizedBox(width: 4),
                        Text(
                          'MUAC: ${member.latestMuacCm} cm',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: member.latestMuacCm! < 11.5 ? AppTheme.urgentRed : AppTheme.watchAmber,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: member.riskStatus == RiskTier.URGENT ? AppTheme.urgentRedLight : AppTheme.routineGreenLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                member.riskStatus.name,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: member.riskStatus == RiskTier.URGENT ? AppTheme.urgentRed : AppTheme.routineGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
