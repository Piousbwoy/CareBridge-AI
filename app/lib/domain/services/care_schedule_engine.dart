import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/clinical_models.dart';

class CareScheduleEngine {
  static Map<String, dynamic>? _loadedConfig;

  /// Load care schedule JSON reference asset
  static Future<void> initialize() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/reference/care_schedule.json');
      _loadedConfig = jsonDecode(jsonStr);
    } catch (e) {
      // Fallback built-in configuration if asset loading fails
      _loadedConfig = null;
    }
  }

  /// Generate default protocol-driven schedule for a member
  static List<ScheduledVisitModel> generateScheduleForMember({
    required MemberModel member,
    required HouseholdModel household,
  }) {
    final now = DateTime.now();
    final List<ScheduledVisitModel> visits = [];

    switch (member.lifecycleStage) {
      case LifecycleStage.pregnant:
        // ANC Schedule (4-contact minimum / 8-contact WHO)
        final edd = member.eddDate ?? now.add(const Duration(days: 90)); // default ~30 wks
        final concepcionDate = edd.subtract(const Duration(days: 280));
        
        final ancContacts = [
          {'num': 1, 'name': 'ANC Contact 1 (Booking)', 'weeks': 10},
          {'num': 2, 'name': 'ANC Contact 2', 'weeks': 22},
          {'num': 3, 'name': 'ANC Contact 3', 'weeks': 28},
          {'num': 4, 'name': 'ANC Contact 4', 'weeks': 34},
          {'num': 5, 'name': 'ANC Contact 5 (Delivery Prep)', 'weeks': 38},
        ];

        for (final c in ancContacts) {
          final targetWeek = c['weeks'] as int;
          final dueDate = concepcionDate.add(Duration(days: targetWeek * 7));
          final status = _determineStatus(dueDate, now);
          final daysOverdue = now.difference(dueDate).inDays;
          
          String reason = 'GHS ANC Contact ${c['num']} — Gestational Wk $targetWeek check.';
          if (status == VisitStatus.overdue) {
            reason = 'ANC Contact ${c['num']} — $daysOverdue days overdue (Gestational Wk $targetWeek).';
          }

          visits.add(ScheduledVisitModel(
            id: 'SCH-${member.id}-ANC-${c['num']}',
            memberId: member.id,
            householdId: household.id,
            memberName: member.name,
            householdName: household.name,
            lifecycleStage: LifecycleStage.pregnant,
            title: c['name'] as String,
            contactName: 'ANC Contact ${c['num']}',
            dueDate: dueDate,
            status: status,
            reasonText: reason,
          ));
        }
        break;

      case LifecycleStage.postpartum:
      case LifecycleStage.newborn:
        // PNC Schedule (48h, Day 6, Wk 6)
        final delivDate = member.deliveryDate ?? member.birthDate ?? now.subtract(const Duration(days: 10));
        
        final pncTouchpoints = [
          {'num': 1, 'name': 'PNC Contact 1 (First 48h)', 'days': 1},
          {'num': 2, 'name': 'PNC Contact 2 (Day 6)', 'days': 6},
          {'num': 3, 'name': 'PNC Contact 3 (Week 6 & BCG/Penta 1)', 'days': 42},
        ];

        for (final p in pncTouchpoints) {
          final targetDays = p['days'] as int;
          final dueDate = delivDate.add(Duration(days: targetDays));
          final status = _determineStatus(dueDate, now);
          final daysOverdue = now.difference(dueDate).inDays;

          String reason = 'GHS Postnatal Care ${p['name']} check.';
          if (status == VisitStatus.overdue) {
            reason = '${p['name']} — $daysOverdue days overdue.';
          }

          visits.add(ScheduledVisitModel(
            id: 'SCH-${member.id}-PNC-${p['num']}',
            memberId: member.id,
            householdId: household.id,
            memberName: member.name,
            householdName: household.name,
            lifecycleStage: member.lifecycleStage,
            title: p['name'] as String,
            contactName: 'PNC Contact ${p['num']}',
            dueDate: dueDate,
            status: status,
            reasonText: reason,
          ));
        }
        break;

      case LifecycleStage.childUnder5:
        // Growth monitoring & EPI
        final birth = member.birthDate ?? now.subtract(Duration(days: member.ageMonths * 30));
        
        if (member.ageMonths <= 12) {
          // Monthly growth monitoring
          final nextMonthlyDue = now.subtract(Duration(days: (now.day > 15 ? 14 : 3)));
          final status = _determineStatus(nextMonthlyDue, now);
          final daysOverdue = now.difference(nextMonthlyDue).inDays;
          
          visits.add(ScheduledVisitModel(
            id: 'SCH-${member.id}-GROWTH-M',
            memberId: member.id,
            householdId: household.id,
            memberName: member.name,
            householdName: household.name,
            lifecycleStage: LifecycleStage.childUnder5,
            title: 'Monthly Growth Monitoring & MUAC Screen',
            contactName: 'Growth Check (Under 12m)',
            dueDate: nextMonthlyDue,
            status: status,
            reasonText: status == VisitStatus.overdue
                ? 'Monthly Growth & MUAC check — $daysOverdue days overdue.'
                : 'Routine monthly MUAC & weight screening.',
          ));
        } else {
          // Quarterly check
          final quarterlyDue = now.subtract(const Duration(days: 12));
          final status = _determineStatus(quarterlyDue, now);
          final daysOverdue = now.difference(quarterlyDue).inDays;

          visits.add(ScheduledVisitModel(
            id: 'SCH-${member.id}-GROWTH-Q',
            memberId: member.id,
            householdId: household.id,
            memberName: member.name,
            householdName: household.name,
            lifecycleStage: LifecycleStage.childUnder5,
            title: 'Quarterly Growth & Vitamin A Deworming',
            contactName: 'Growth Check (1-5 Years)',
            dueDate: quarterlyDue,
            status: status,
            reasonText: status == VisitStatus.overdue
                ? 'Quarterly MUAC & Deworming — $daysOverdue days overdue.'
                : 'Quarterly MUAC screening & Vitamin A touchpoint.',
          ));
        }
        break;

      case LifecycleStage.womanReproductiveAge:
      default:
        // Anaemia & Preconception check
        final due = now.subtract(const Duration(days: 21));
        visits.add(ScheduledVisitModel(
          id: 'SCH-${member.id}-PRECONCEPTION',
          memberId: member.id,
          householdId: household.id,
          memberName: member.name,
          householdName: household.name,
          lifecycleStage: LifecycleStage.womanReproductiveAge,
          title: 'Anaemia Screening & Preconception Follow-up',
          contactName: 'Maternal Wellness Contact',
          dueDate: due,
          status: VisitStatus.overdue,
          reasonText: 'Maternal Hb & Nutrition follow-up — 21 days overdue.',
        ));
        break;
    }

    return visits;
  }

  /// Create an ad-hoc / unscheduled visit entry for danger sign walk-in
  static ScheduledVisitModel createUnscheduledVisit({
    required MemberModel member,
    required HouseholdModel household,
    required String reportedDangerSign,
  }) {
    return ScheduledVisitModel(
      id: 'SCH-ADHOC-${DateTime.now().millisecondsSinceEpoch}',
      memberId: member.id,
      householdId: household.id,
      memberName: member.name,
      householdName: household.name,
      lifecycleStage: member.lifecycleStage,
      title: 'Ad-hoc Danger Sign Assessment',
      contactName: 'Unscheduled Visit',
      dueDate: DateTime.now(),
      status: VisitStatus.due,
      reasonText: 'Caregiver reported danger sign: $reportedDangerSign',
      isUnscheduled: true,
    );
  }

  static VisitStatus _determineStatus(DateTime dueDate, DateTime now) {
    final diffDays = now.difference(dueDate).inDays;
    if (diffDays > 3) return VisitStatus.overdue;
    if (diffDays >= -3 && diffDays <= 3) return VisitStatus.due;
    return VisitStatus.upcoming;
  }
}
