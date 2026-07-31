import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme.dart';
import 'data/mock_repository.dart';
import 'data/sync_queue_service.dart';
import 'domain/ai/muac_trend_classifier.dart';
import 'domain/models/clinical_models.dart';
import 'domain/rules/imci_rules_engine.dart';
import 'domain/services/care_schedule_engine.dart';
import 'presentation/screens/screen_1_splash.dart';
import 'presentation/screens/screen_2_onboarding_welcome.dart';
import 'presentation/screens/screen_3_onboarding_why.dart';
import 'presentation/screens/screen_4_onboarding_pillars.dart';
import 'presentation/screens/screen_5_onboarding_workflow_preview.dart';
import 'presentation/screens/screen_6_signin.dart';
import 'presentation/screens/screen_7_create_account.dart';
import 'presentation/screens/screen_8_pin_login.dart';
import 'presentation/screens/screen_10_prioritized_visits.dart';
import 'presentation/screens/screen_11_household_details.dart';
import 'presentation/screens/screen_12_child_assessment.dart';
import 'presentation/screens/screen_13_young_infant_assessment.dart';
import 'presentation/screens/screen_14_maternal_assessment.dart';
import 'presentation/screens/screen_15_ai_risk_result.dart';
import 'presentation/screens/screen_16_referral_action.dart';
import 'presentation/screens/screen_17_local_nutrition.dart';
import 'presentation/screens/screen_18_ai_care_recommendations.dart';
import 'presentation/screens/screen_19_sync_status.dart';
import 'presentation/screens/screen_web_only_notice.dart';
import 'presentation/screens/screen_assess_category_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CareScheduleEngine.initialize();
  runApp(const CareBridgeApp());
}

class CareBridgeApp extends StatefulWidget {
  const CareBridgeApp({super.key});

  @override
  State<CareBridgeApp> createState() => _CareBridgeAppState();
}

class _CareBridgeAppState extends State<CareBridgeApp> {
  String _currentStep = 'SPLASH';

  @override
  Widget build(BuildContext context) {
    Widget app = MaterialApp(
      title: 'CareBridge AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _buildCurrentFlowScreen(),
    );

    // If running on the web (e.g. Chrome), constrain the width and wrap it in a mock phone frame
    if (kIsWeb) {
      return Container(
        color: Colors.black87,
        child: Center(
          child: Container(
            width: 375,
            height: 812,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Colors.grey.shade900, width: 12),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 5),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: app,
            ),
          ),
        ),
      );
    }

    return app;
  }

  Widget _buildCurrentFlowScreen() {
    switch (_currentStep) {
      case 'SPLASH':
        return SplashScreen(onFinish: () => setState(() => _currentStep = 'ONBOARDING_1'));
      case 'ONBOARDING_1':
        return OnboardingWelcomeScreen(
          onNext: () => setState(() => _currentStep = 'ONBOARDING_2'),
          onSkip: () => setState(() => _currentStep = 'PIN_LOGIN'),
        );
      case 'ONBOARDING_2':
        return OnboardingWhyScreen(
          onNext: () => setState(() => _currentStep = 'ONBOARDING_3'),
          onBack: () => setState(() => _currentStep = 'ONBOARDING_1'),
          onSkip: () => setState(() => _currentStep = 'PIN_LOGIN'),
        );
      case 'ONBOARDING_3':
        return OnboardingPillarsScreen(
          onNext: () => setState(() => _currentStep = 'ONBOARDING_4'),
          onBack: () => setState(() => _currentStep = 'ONBOARDING_2'),
          onSkip: () => setState(() => _currentStep = 'PIN_LOGIN'),
        );
      case 'ONBOARDING_4':
        return OnboardingWorkflowPreviewScreen(
          onGetStarted: () => setState(() => _currentStep = 'SIGNIN'),
          onBack: () => setState(() => _currentStep = 'ONBOARDING_3'),
        );
      case 'SIGNIN':
        return SignInScreen(
          onSignInSuccess: () => setState(() => _currentStep = 'PIN_LOGIN'),
          onCreateAccountRequested: () => setState(() => _currentStep = 'CREATE_ACCOUNT'),
        );
      case 'CREATE_ACCOUNT':
        return CreateAccountScreen(
          onAccountCreated: () => setState(() => _currentStep = 'PIN_LOGIN'),
          onBackToSignIn: () => setState(() => _currentStep = 'SIGNIN'),
        );
      case 'PIN_LOGIN':
        return PinLoginScreen(onPinSuccess: () {
          final repo = MockRepository();
          // District Officers must use the web dashboard — redirect them
          if (repo.userRole == UserRole.districtOfficer) {
            setState(() => _currentStep = 'WEB_ONLY_NOTICE');
          } else {
            setState(() => _currentStep = 'MAIN_APP');
          }
        });
      case 'WEB_ONLY_NOTICE':
        return WebOnlyNoticeScreen(
          onBack: () => setState(() => _currentStep = 'SIGNIN'),
        );
      case 'MAIN_APP':
      default:
        return MainNavigationShell(onLogout: () => setState(() => _currentStep = 'SIGNIN'));
    }
  }
}

class MainNavigationShell extends StatefulWidget {
  final VoidCallback onLogout;
  const MainNavigationShell({super.key, required this.onLogout});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _selectedTabIndex = 0;

  // Assessment state
  HouseholdModel? _selectedHousehold;
  MemberModel? _selectedMember;
  ScheduledVisitModel? _activeVisitContext;
  int _assessmentStep = 0;

  // Collected clinical parameters
  double _muac = 10.5;
  bool _oedema = false;
  Map<String, bool> _childDanger = {};
  int _rr = 40;
  double _temp = 36.8;
  Map<String, bool> _infantDanger = {};
  PregnancyStatus _pregnancyStatus = PregnancyStatus.currentlyPregnant;
  double? _hb = 11.5;
  bool _pallorProxy = false;
  Map<String, bool> _maternalDanger = {};

  ClinicalRuleResult? _activeRuleResult;
  TrendResult? _activeTrendResult;

  // Tracks which category was picked so routing is correct after each form
  PersonCategory _assessmentCategory = PersonCategory.childUnder5;

  // Services
  final _syncQueue = SyncQueueService();
  final _overrideLog = OverrideAuditLog();

  @override
  void initState() {
    super.initState();
    if (MockRepository().households.isNotEmpty) {
      _selectedHousehold = MockRepository().households.first;
    }
  }

  /// Runs both AI layers fully offline — no network call anywhere in this chain
  void _runAIEngine() async {
    final input = AssessmentInput(
      muacCm: _muac,
      bilateralOedema: _oedema,
      convulsions: _childDanger['convulsions'] ?? false,
      unableToDrinkBreastfeed: _childDanger['unableToDrinkBreastfeed'] ?? false,
      vomitsEverything: _childDanger['vomitsEverything'] ?? false,
      lethargicOrUnconscious: _childDanger['lethargicOrUnconscious'] ?? false,
      severePalmarPallor: _childDanger['severePalmarPallor'] ?? false,
      stiffNeck: _childDanger['stiffNeck'] ?? false,
      isYoungInfant: (_selectedMember?.ageMonths ?? 99) < 2,
      breathingRate: _rr,
      bodyTemp: _temp,
      severeChestIndrawing: _infantDanger['severeChestIndrawing'] ?? false,
      noSpontaneousMovement: _infantDanger['noSpontaneousMovement'] ?? false,
      notFeedingWell: _infantDanger['notFeedingWell'] ?? false,
      infantConvulsionsHistory: _infantDanger['infantConvulsionsHistory'] ?? false,
      jaundiceEarlyOrYellowPalms: _infantDanger['jaundiceEarlyOrYellowPalms'] ?? false,
      pregnancyStatus: _pregnancyStatus,
      maternalHb: _hb,
      conjunctivaPalmarPallorProxy: _pallorProxy,
      vaginalBleeding: _maternalDanger['vaginalBleeding'] ?? false,
      maternalConvulsions: _maternalDanger['maternalConvulsions'] ?? false,
      severeHeadacheBlurredVision: _maternalDanger['severeHeadacheBlurredVision'] ?? false,
      reducedAbsentFetalMovement: _maternalDanger['reducedAbsentFetalMovement'] ?? false,
      postpartumHeavyBleeding: _maternalDanger['postpartumHeavyBleeding'] ?? false,
      weeksOverdue: ((_selectedHousehold?.daysOverdue ?? 0) / 7).ceil(),
    );

    // Layer 1: Deterministic rules engine — fully offline, instantaneous
    final ruleRes = IMCIRulesEngine.evaluate(input);

    // Layer 2: TFLite trend classifier — runs in background isolate, never blocks UI
    final memberId = _selectedMember?.id ?? _selectedHousehold?.id ?? 'M-UNKNOWN';
    final history = MockRepository().getHistoricalMUAC(memberId);
    final trendRes = await MUACTrendClassifier.analyzeTrend(history);

    _syncQueue.enqueueAssessment(
      householdId: _selectedHousehold?.id ?? 'H-UNKNOWN',
      patientName: _selectedMember?.name ?? _selectedHousehold?.name ?? 'Unknown',
      chpsZone: MockRepository().chwZone,
      riskTier: ruleRes.overallTier.name,
      reasons: ruleRes.reasons,
      muacCm: _muac,
      breathingRate: _rr,
      hbLevel: _hb,
      isUrgentReferral: ruleRes.overallTier == RiskTier.URGENT,
    );

    // Update live repository, complete scheduled visit, and persist assessment record
    if (_selectedHousehold != null) {
      MockRepository().recordAssessment(
        householdId: _selectedHousehold!.id,
        memberId: _selectedMember?.id,
        tier: ruleRes.overallTier,
        muac: _muac,
        reasons: ruleRes.reasons,
        activeVisitId: _activeVisitContext?.id,
      );
    }

    setState(() {
      _activeRuleResult = ruleRes;
      _activeTrendResult = trendRes;
      _assessmentStep = 4; // AI Risk Result screen
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBodyForCurrentTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryNavy,
        unselectedItemColor: AppTheme.textMedium,
        selectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 10),
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
            // Reset Visits sub-view when leaving/returning to Visits tab
            if (index == 1) _showingHouseholdDetails = false;
            // Always show category picker when Assess tab is tapped fresh
            if (index == 2) {
              _assessmentStep = 0;
              _activeVisitContext = null;
            }
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.format_list_numbered_rounded), label: 'Visits'),
          BottomNavigationBarItem(icon: Icon(Icons.add_task_rounded), label: 'Assess'),
          BottomNavigationBarItem(icon: Icon(Icons.local_hospital_outlined), label: 'Referrals'),
          BottomNavigationBarItem(icon: Icon(Icons.sync_rounded), label: 'Sync'),
        ],
      ),
    );
  }

  Widget _buildBodyForCurrentTab() {
    switch (_selectedTabIndex) {
      case 0: return _buildHomeScreen();
      case 1: return _buildVisitsTabFlow();
      case 2: return _buildAssessmentTabFlow();
      case 3: return _buildReferralScreen();
      case 4:
      default: return SyncStatusScreen(onLogout: widget.onLogout);
    }
  }

  Widget _buildHomeScreen() {
    final repo = MockRepository();
    final urgentCount = repo.households.where((h) => h.currentRiskTier == RiskTier.URGENT).length;
    final watchCount = repo.households.where((h) => h.currentRiskTier == RiskTier.WATCH).length;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CHO Header Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavy,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: AppTheme.primaryNavy.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Good Morning,', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
                            Text(repo.chwName, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppTheme.accentTeal, borderRadius: BorderRadius.circular(8)),
                          child: Text('CHO Active', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: AppTheme.accentTeal, size: 16),
                        const SizedBox(width: 4),
                        Text(repo.chwZone, style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Urgent Alert Banner if urgent households exist
              if (urgentCount > 0)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.urgentRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.urgentRed.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppTheme.urgentRed, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('URGENT TRIAGE ATTENTION REQUIRED', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.urgentRed, letterSpacing: 1.0)),
                            Text('$urgentCount household(s) flagged for immediate SAM/maternal intervention.', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Summary Metric Cards
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.urgentRed.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('URGENT', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.urgentRed)),
                          const SizedBox(height: 4),
                          Text('$urgentCount', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.urgentRed)),
                          Text('Critical Risk', style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textMedium)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.watchAmber.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('WATCH', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.watchAmber)),
                          const SizedBox(height: 4),
                          Text('$watchCount', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.watchAmber)),
                          Text('Follow-up', style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textMedium)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.accentTeal.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('QUEUE', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentTeal)),
                          const SizedBox(height: 4),
                          Text('${_syncQueue.pendingCount}', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.accentTeal)),
                          Text('Offline 2G', style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textMedium)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Quick Action Navigation Buttons
              Text('QUICK ACTIONS', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
              const SizedBox(height: 10),

              _HomeActionTile(
                icon: Icons.format_list_numbered_rounded,
                title: 'Prioritized Visits List',
                subtitle: 'View households ordered by 0-100 priority score & overdue decay',
                color: AppTheme.primaryNavy,
                onTap: () => setState(() => _selectedTabIndex = 1),
              ),
              _HomeActionTile(
                icon: Icons.add_task_rounded,
                title: 'Start New Clinical Assessment',
                subtitle: 'Run 26-parameter WHO IMCI / GHS triage at point of care',
                color: AppTheme.accentTeal,
                onTap: () => setState(() {
                  _selectedTabIndex = 2;
                  _assessmentStep = 1;
                }),
              ),
              _HomeActionTile(
                icon: Icons.local_hospital_outlined,
                title: 'Urgent Referrals & 2G SMS',
                subtitle: 'Generate sub-60 char bit-packed payloads for remote facilities',
                color: AppTheme.urgentRed,
                onTap: () => setState(() => _selectedTabIndex = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── VISITS tab internal view state (separate from assessment step) ─────────────
  bool _showingHouseholdDetails = false;

  Widget _buildVisitsTabFlow() {
    if (!_showingHouseholdDetails) {
      return PrioritizedVisitsScreen(
        onSelectHousehold: (household) => setState(() {
          _selectedHousehold = household;
          _showingHouseholdDetails = true;
        }),
        onSelectScheduledVisit: (visit) => setState(() {
          // Pre-load the visit context then jump to Assess tab
          _activeVisitContext = visit;
          _selectedHousehold = MockRepository().households.firstWhere(
            (h) => h.id == visit.householdId,
            orElse: () => MockRepository().households.first,
          );
          _selectedMember = MockRepository().members.firstWhere(
            (m) => m.id == visit.memberId,
            orElse: () => MockRepository().members.first,
          );
          _assessmentCategory = _stageToCategory(visit.lifecycleStage);
          _assessmentStep = _stageToStartStep(visit.lifecycleStage);
          _selectedTabIndex = 2;
        }),
      );
    }
    return HouseholdDetailsScreen(
      household: _selectedHousehold!,
      onStartMemberAssessment: (member) => setState(() {
        _selectedMember = member;
        _activeVisitContext = null;
        _assessmentCategory = member.category;
        _assessmentStep = _categoryToStartStep(member.category);
        _selectedTabIndex = 2;
        _showingHouseholdDetails = false;
      }),
      onAddNewPerson: (category) => setState(() {
        _activeVisitContext = null;
        _assessmentCategory = category;
        _assessmentStep = _categoryToStartStep(category);
        _selectedTabIndex = 2;
        _showingHouseholdDetails = false;
      }),
      onBack: () => setState(() => _showingHouseholdDetails = false),
    );
  }

  PersonCategory _stageToCategory(LifecycleStage stage) {
    switch (stage) {
      case LifecycleStage.childUnder5: return PersonCategory.childUnder5;
      case LifecycleStage.newborn: return PersonCategory.newbornYoungInfant;
      case LifecycleStage.postpartum:
      case LifecycleStage.pregnant:
      case LifecycleStage.womanReproductiveAge: return PersonCategory.mother;
    }
  }

  int _stageToStartStep(LifecycleStage stage) {
    switch (stage) {
      case LifecycleStage.childUnder5: return 1;
      case LifecycleStage.newborn: return 2;
      case LifecycleStage.postpartum: return 3;
      case LifecycleStage.pregnant: return 3;
      case LifecycleStage.womanReproductiveAge: return 3;
    }
  }

  int _categoryToStartStep(PersonCategory category) {
    switch (category) {
      case PersonCategory.childUnder5: return 1;
      case PersonCategory.newbornYoungInfant: return 2;
      case PersonCategory.mother: return 3;
      default: return 1;
    }
  }

  Widget _buildReferralScreen() {
    return ReferralActionScreen(
      householdId: _selectedHousehold?.id ?? 'H-10041',
      memberId: _selectedMember?.id,
      patientName: _selectedMember?.name ?? _selectedHousehold?.name ?? 'Akua Serwaa',
      riskTier: _activeRuleResult?.overallTier.name ?? 'URGENT',
      reasons: _activeRuleResult?.reasons ?? ['MUAC 10.5cm — Severe Acute Malnutrition (SAM)', 'Fast breathing (62/min > 60/min) in young infant'],
      muacCm: _muac,
      breathingRate: _rr,
      hbLevel: _hb ?? 11.5,
      bilateralOedema: _oedema,
      onViewNutrition: () => setState(() { _selectedTabIndex = 2; _assessmentStep = 6; }),
    );
  }

  Widget _buildAssessmentTabFlow() {
    switch (_assessmentStep) {
      case 0:
        // Category picker — shown when Assess tab is tapped fresh
        return AssessCategoryPickerScreen(
          onCategorySelected: (category) => setState(() {
            _selectedMember = null;
            _activeVisitContext = null;
            _assessmentCategory = category;
            _assessmentStep = _categoryToStartStep(category);
          }),
        );
      case 1:
        return ChildAssessmentScreen(
          visitContext: _activeVisitContext,
          onNext: (muac, oedema, dangerSigns) {
            setState(() { _muac = muac; _oedema = oedema; _childDanger = dangerSigns; });
            _runAIEngine(); // async — updates _assessmentStep to 4 on completion
          },
        );
      case 2:
        return YoungInfantAssessmentScreen(
          visitContext: _activeVisitContext,
          onNext: (rr, temp, infantSigns) {
            setState(() { _rr = rr; _temp = temp; _infantDanger = infantSigns; });
            if (_assessmentCategory == PersonCategory.newbornYoungInfant) {
              _runAIEngine(); // async — skips maternal, routes to AI result
            } else {
              setState(() => _assessmentStep = 3);
            }
          },
        );
      case 3:
        return MaternalAssessmentScreen(
          visitContext: _activeVisitContext,
          onCompleteAssessment: (hb, pallor, maternalSigns, status) {
            _hb = hb;
            _pallorProxy = pallor;
            _maternalDanger = maternalSigns;
            _pregnancyStatus = status;
            _runAIEngine(); // Fully offline — triggers both AI layers
          },
        );
      case 4:
        final result = _activeRuleResult ?? ClinicalRuleResult(
          overallTier: RiskTier.URGENT,
          triggeredRules: [],
          reasons: ['MUAC 10.5cm — Severe Acute Malnutrition (SAM)', 'Fast breathing (62/min) in young infant'],
          timestamp: '2026-07-30 10:30',
        );
        final trend = _activeTrendResult ?? TrendResult(
          direction: TrendDirection.WORSENING,
          probability: 0.88,
          summary: 'High risk trend: MUAC dropped by 7.0% over recent visits.',
        );
        return AIRiskResultScreen(
          ruleResult: result,
          trendResult: trend,
          onRefer: () => setState(() => _assessmentStep = 5),
          onOverride: () {
            _overrideLog.record(
              ruleId: result.ghsProtocolCodes.isNotEmpty ? result.ghsProtocolCodes.first : 'MANUAL_OVERRIDE',
              overriddenBy: MockRepository().chwName,
              originalTier: result.overallTier.name,
              newTier: 'WATCH',
              note: 'CHW clinical judgment override — field conditions noted',
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Override recorded in audit trail. Proceeding to referral.')),
            );
            setState(() => _assessmentStep = 5);
          },
        );
      case 5:
        return ReferralActionScreen(
          householdId: _selectedHousehold?.id ?? 'H-10041',
          memberId: _selectedMember?.id,
          patientName: _selectedMember?.name ?? _selectedHousehold?.name ?? 'Akua Serwaa',
          riskTier: _activeRuleResult?.overallTier.name ?? 'URGENT',
          reasons: _activeRuleResult?.reasons ?? ['MUAC 10.5cm — SAM'],
          muacCm: _muac,
          breathingRate: _rr,
          hbLevel: _hb ?? 11.5,
          bilateralOedema: _oedema,
          onViewNutrition: () => setState(() => _assessmentStep = 6),
        );
      case 6:
        return LocalNutritionScreen(onNextCarePlan: () => setState(() => _assessmentStep = 7));
      case 7:
      default:
        return AICareRecommendationsScreen(
          onFinishToHome: () => setState(() { _selectedTabIndex = 0; _assessmentStep = 0; }),
        );
    }
  }
}

class _HomeActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _HomeActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMedium)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textMedium),
        onTap: onTap,
      ),
    );
  }
}
