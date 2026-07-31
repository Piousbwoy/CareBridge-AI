import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/clinical_models.dart';

class CareScheduleEngine {
  static Map<String, dynamic>? _scheduleConfig;

  static Future<void> loadScheduleConfig() async {
    if (_scheduleConfig != null) return;
    try {
      final jsonString = await rootBundle.loadString('assets/reference/care_schedule.json');
      _scheduleConfig = jsonDecode(jsonString);
    } catch (_) {
      // Fallback default config if asset loading fails
      _scheduleConfig = {
        'anc_schedule': [
          { 'contact': 1, 'week_start': 8, 'week_end': 12, 'title': 'ANC Contact 1' },
          { 'contact': 2, 'week_start': 20, 'week_end': 24, 'title': 'ANC Contact 2' },
          { 'contact': 3, 'week_start': 28, 'week_end': 30, 'title': 'ANC Contact 3' },
          { 'contact': 4, 'week_start': 32, 'week_end': 34, 'title': 'ANC Contact 4' }
        ],
        'pnc_schedule': [
          { 'contact': 1, 'days_after_birth': 2, 'title': 'PNC Contact 1 (Within 48 Hours)' },
          { 'contact': 2, 'days_after_birth': 6, 'title': 'PNC Contact 2 (Day 6)' },
          { 'contact': 3, 'days_after_birth': 42, 'title': 'PNC Contact 3 (Week 6)' }
        ],
        'epi_schedule': [
          { 'dose': 'Birth', 'age_days': 0, 'vaccines': ['BCG', 'OPV0'], 'title': 'EPI Birth Doses' },
          { 'dose': '6 Weeks', 'age_days': 42, 'vaccines': ['Penta1', 'OPV1', 'PCV1', 'Rota1'], 'title': 'EPI 6-Week Doses' },
          { 'dose': '10 Weeks', 'age_days': 70, 'vaccines': ['Penta2', 'OPV2', 'PCV2', 'Rota2'], 'title': 'EPI 10-Week Doses' },
          { 'dose': '14 Weeks', 'age_days': 98, 'vaccines': ['Penta3', 'OPV3', 'PCV3', 'IPV'], 'title': 'EPI 14-Week Doses' },
          { 'dose': '9 Months', 'age_days': 270, 'vaccines': ['MR1', 'Yellow Fever', 'Vit A1'], 'title': 'EPI 9-Month Doses' },
          { 'dose': '18 Months', 'age_days': 540, 'vaccines': ['MR2', 'Vit A2'], 'title': 'EPI 18-Month Doses' }
        ]
      };
    }
  }

  static List<VisitModel> generateScheduledVisitsForMember(MemberModel member, HouseholdModel household) {
    final now = DateTime.now();
    final List<VisitModel> visits = [];

    switch (member.lifecycleStage) {
      case LifecycleStage.pregnant:
        visits.add(VisitModel(
          id: 'V-ANC-3-${member.id}',
          memberId: member.id,
          householdId: household.id,
          memberName: member.name,
          lifecycleStage: LifecycleStage.pregnant,
          visitType: 'ANC',
          title: 'ANC Contact 3 (Anaemia & Fetal Movement)',
          expectedDate: now.subtract(Duration(days: household.daysOverdue > 0 ? household.daysOverdue : 3)),
          status: household.daysOverdue > 0 ? VisitStatus.overdue : VisitStatus.due,
          daysOverdue: household.daysOverdue > 0 ? household.daysOverdue : 0,
          reason: 'Week 30 gestational contact overdue — Hb & BP screening required',
        ));
        visits.add(VisitModel(
          id: 'V-ANC-4-${member.id}',
          memberId: member.id,
          householdId: household.id,
          memberName: member.name,
          lifecycleStage: LifecycleStage.pregnant,
          visitType: 'ANC',
          title: 'ANC Contact 4 (Birth Preparedness)',
          expectedDate: now.add(const Duration(days: 14)),
          status: VisitStatus.upcoming,
          daysOverdue: 0,
          reason: 'Week 34 gestational contact — delivery plan & emergency transport',
        ));
        break;

      case LifecycleStage.newborn:
        visits.add(VisitModel(
          id: 'V-PNC-1-${member.id}',
          memberId: member.id,
          householdId: household.id,
          memberName: member.name,
          lifecycleStage: LifecycleStage.newborn,
          visitType: 'PNC',
          title: 'PNC Contact 1 (Within 48h Delivery Check)',
          expectedDate: now.subtract(const Duration(days: 2)),
          status: VisitStatus.overdue,
          daysOverdue: 2,
          reason: 'Newborn danger signs & maternal PPH screening overdue',
        ));
        visits.add(VisitModel(
          id: 'V-EPI-6W-${member.id}',
          memberId: member.id,
          householdId: household.id,
          memberName: member.name,
          lifecycleStage: LifecycleStage.newborn,
          visitType: 'EPI',
          title: 'EPI 6-Week Immunization (Penta1, OPV1, PCV1, Rota1)',
          expectedDate: now.add(const Duration(days: 10)),
          status: VisitStatus.upcoming,
          daysOverdue: 0,
          reason: 'First pentavalent & rotavirus dose window opens soon',
        ));
        break;

      case LifecycleStage.postpartum:
        visits.add(VisitModel(
          id: 'V-PNC-2-${member.id}',
          memberId: member.id,
          householdId: household.id,
          memberName: member.name,
          lifecycleStage: LifecycleStage.postpartum,
          visitType: 'PNC',
          title: 'PNC Contact 2 (Day 6 Postpartum Check)',
          expectedDate: now.subtract(const Duration(days: 1)),
          status: VisitStatus.due,
          daysOverdue: 1,
          reason: 'Lochia, maternal mood & breastfeeding attachment check',
        ));
        break;

      case LifecycleStage.childUnder5:
        final isMuacOverdue = (member.latestMuacCm ?? 12.0) < 11.5 || household.daysOverdue > 7;
        visits.add(VisitModel(
          id: 'V-GROWTH-${member.id}',
          memberId: member.id,
          householdId: household.id,
          memberName: member.name,
          lifecycleStage: LifecycleStage.childUnder5,
          visitType: 'Growth',
          title: 'Monthly MUAC & Growth Screening',
          expectedDate: isMuacOverdue ? now.subtract(Duration(days: household.daysOverdue)) : now,
          status: isMuacOverdue ? VisitStatus.overdue : VisitStatus.due,
          daysOverdue: isMuacOverdue ? household.daysOverdue : 0,
          reason: isMuacOverdue ? 'SAM/MAM MUAC velocity monitoring overdue' : 'Routine monthly growth monitoring due',
        ));
        if (member.ageMonths >= 9 && member.ageMonths < 12) {
          visits.add(VisitModel(
            id: 'V-EPI-9M-${member.id}',
            memberId: member.id,
            householdId: household.id,
            memberName: member.name,
            lifecycleStage: LifecycleStage.childUnder5,
            visitType: 'EPI',
            title: 'EPI 9-Month Doses (Measles-Rubella1, Yellow Fever, Vit A)',
            expectedDate: now.add(const Duration(days: 5)),
            status: VisitStatus.upcoming,
            daysOverdue: 0,
            reason: 'Measles-Rubella 1st dose & Yellow Fever immunization',
          ));
        }
        break;

      case LifecycleStage.womanReproductiveAge:
        visits.add(VisitModel(
          id: 'V-WRA-${member.id}',
          memberId: member.id,
          householdId: household.id,
          memberName: member.name,
          lifecycleStage: LifecycleStage.womanReproductiveAge,
          visitType: 'Anaemia',
          title: 'Quarterly Anaemia & Family Planning Check',
          expectedDate: now.add(const Duration(days: 30)),
          status: VisitStatus.upcoming,
          daysOverdue: 0,
          reason: 'Preconception health & palmar pallor screening',
        ));
        break;
    }

    return visits;
  }
}
