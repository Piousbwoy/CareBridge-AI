import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'core/theme.dart';
import 'data/mock_repository.dart';
import 'data/sync_queue_service.dart';
import 'domain/ai/muac_trend_classifier.dart';
import 'domain/models/clinical_models.dart';
import 'domain/rules/imci_rules_engine.dart';
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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
          onSkip: () => setState(() => _currentStep = 'PIN_LOGIN'),
        );
      case 'ONBOARDING_3':
        return OnboardingPillarsScreen(
          onNext: () => setState(() => _currentStep = 'ONBOARDING_4'),
          onSkip: () => setState(() => _currentStep = 'PIN_LOGIN'),
        );
      case 'ONBOARDING_4':
        return OnboardingWorkflowPreviewScreen(
          onGetStarted: () => setState(() => _currentStep = 'SIGNIN'),
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
        return PinLoginScreen(onPinSuccess: () => setState(() => _currentStep = 'MAIN_APP'));
      case 'MAIN_APP':
      default:
        return MainNavigationShell(onLogout: () => setState(() => _currentStep = 'PIN_LOGIN'));
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
  int _assessmentStep = 0;

  // Collected clinical parameters
  double _muac = 10.5;
  bool _oedema = true;
  Map<String, bool> _childDanger = {};
  int _rr = 62;
  double _temp = 37.8;
  Map<String, bool> _infantDanger = {};
  double? _hb = 8.4;
  bool _pallorProxy = false;
  Map<String, bool> _maternalDanger = {};

  ClinicalRuleResult? _activeRuleResult;
  TrendResult? _activeTrendResult;

  // Services
  final _syncQueue = SyncQueueService();
  final _overrideLog = OverrideAuditLog();

  @override
  void initState() {
    super.initState();
    _selectedHousehold = MockRepository().households.first;
    // Point 9: Simulate connectivity listener — in production, ConnectivityPlus stream
    // fires _syncQueue.attemptAutoSync() on ConnectivityResult.mobile / .wifi events
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
      isYoungInfant: true,
      breathingRate: _rr,
      bodyTemp: _temp,
      severeChestIndrawing: _infantDanger['severeChestIndrawing'] ?? false,
      noSpontaneousMovement: _infantDanger['noSpontaneousMovement'] ?? false,
      notFeedingWell: _infantDanger['notFeedingWell'] ?? false,
      infantConvulsionsHistory: _infantDanger['infantConvulsionsHistory'] ?? false,
      jaundiceEarlyOrYellowPalms: _infantDanger['jaundiceEarlyOrYellowPalms'] ?? false,
      maternalHb: _hb,
      conjunctivaPalmarPallorProxy: _pallorProxy,
      vaginalBleeding: _maternalDanger['vaginalBleeding'] ?? false,
      maternalConvulsions: _maternalDanger['maternalConvulsions'] ?? false,
      severeHeadacheBlurredVision: _maternalDanger['severeHeadacheBlurredVision'] ?? false,
      reducedAbsentFetalMovement: _maternalDanger['reducedAbsentFetalMovement'] ?? false,
      weeksOverdue: ((_selectedHousehold?.daysOverdue ?? 0) / 7).ceil(),
    );

    // Layer 1: Deterministic rules engine — fully offline, instantaneous
    final ruleRes = IMCIRulesEngine.evaluate(input);

    // Layer 2: TFLite trend classifier — runs in background isolate, never blocks UI
    final history = MockRepository().getHistoricalMUAC('M-3');
    final trendRes = await MUACTrendClassifier.analyzeTrend(history);

    // Point 9: Queue assessment locally for later sync — no network required
    _syncQueue.enqueueAssessment(
      householdId: _selectedHousehold?.id ?? 'H-UNKNOWN',
      patientName: _selectedHousehold?.name ?? 'Unknown',
      chpsZone: MockRepository().chwZone,
      riskTier: ruleRes.overallTier.name,
      reasons: ruleRes.reasons,
      muacCm: _muac,
      breathingRate: _rr,
      hbLevel: _hb,
      isUrgentReferral: ruleRes.overallTier == RiskTier.URGENT,
    );

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
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
            if (index == 1 && _assessmentStep == 0) _assessmentStep = 1;
          });
        },
        items: const [
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
      case 0: return _buildVisitsTabFlow();
      case 1: return _buildAssessmentTabFlow();
      case 2: return _buildReferralScreen();
      case 3:
      default: return SyncStatusScreen(onLogout: widget.onLogout);
    }
  }

  Widget _buildVisitsTabFlow() {
    if (_assessmentStep == 0) {
      return PrioritizedVisitsScreen(
        onSelectHousehold: (household) => setState(() {
          _selectedHousehold = household;
          _assessmentStep = 99; // go to household details sub-view
        }),
      );
    }
    return HouseholdDetailsScreen(
      household: _selectedHousehold!,
      onStartAssessment: () => setState(() {
        _selectedTabIndex = 1;
        _assessmentStep = 1;
      }),
      onBack: () => setState(() => _assessmentStep = 0),
    );
  }

  Widget _buildReferralScreen() {
    return ReferralActionScreen(
      householdId: _selectedHousehold?.id ?? 'H-10041',
      patientName: _selectedHousehold?.name ?? 'Akua Serwaa',
      riskTier: _activeRuleResult?.overallTier.name ?? 'URGENT',
      // Point 8: reasons auto-injected from rules engine result
      reasons: _activeRuleResult?.reasons ?? ['MUAC 10.5cm — Severe Acute Malnutrition (SAM)', 'Fast breathing (62/min > 60/min) in young infant'],
      muacCm: _muac,
      breathingRate: _rr,
      hbLevel: _hb ?? 12.0,
      onViewNutrition: () => setState(() { _selectedTabIndex = 1; _assessmentStep = 6; }),
    );
  }

  Widget _buildAssessmentTabFlow() {
    switch (_assessmentStep) {
      case 1:
        return ChildAssessmentScreen(
          onNext: (muac, oedema, dangerSigns) => setState(() {
            _muac = muac; _oedema = oedema; _childDanger = dangerSigns; _assessmentStep = 2;
          }),
        );
      case 2:
        return YoungInfantAssessmentScreen(
          onNext: (rr, temp, infantSigns) => setState(() {
            _rr = rr; _temp = temp; _infantDanger = infantSigns; _assessmentStep = 3;
          }),
        );
      case 3:
        return MaternalAssessmentScreen(
          onCompleteAssessment: (hb, pallor, maternalSigns) {
            _hb = hb; _pallorProxy = pallor; _maternalDanger = maternalSigns;
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
          // Point 5: Override is always logged with full audit trail before proceeding
          onOverride: () {
            _overrideLog.record(
              ruleId: result.ghsProtocolCodes.isNotEmpty ? result.ghsProtocolCodes.first : 'MANUAL_OVERRIDE',
              overriddenBy: MockRepository().chwName,
              originalTier: result.overallTier.name,
              newTier: 'WATCH', // CHW-selected downgrade tier
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
          patientName: _selectedHousehold?.name ?? 'Akua Serwaa',
          riskTier: _activeRuleResult?.overallTier.name ?? 'URGENT',
          reasons: _activeRuleResult?.reasons ?? ['MUAC 10.5cm — SAM'],
          muacCm: _muac,
          breathingRate: _rr,
          hbLevel: _hb ?? 12.0,
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
