import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme.dart';
import 'data/mock_repository.dart';
import 'domain/models/clinical_models.dart';
import 'domain/rules/imci_rules_engine.dart';
import 'domain/rules/muac_trend_classifier.dart';
import 'core/services/sync_queue_service.dart';
import 'core/services/override_audit_log.dart';

import 'presentation/screens/screen_1_splash.dart';
import 'presentation/screens/screen_2_onboarding_welcome.dart';
import 'presentation/screens/screen_6_signin.dart';
import 'presentation/screens/screen_7_create_account.dart';
import 'presentation/screens/screen_8_pin_login.dart';
import 'presentation/screens/screen_10_prioritized_visits.dart';
import 'presentation/screens/screen_11_household_triage_detail.dart';
import 'presentation/screens/screen_12_child_assessment.dart';
import 'presentation/screens/screen_13_young_infant_assessment.dart';
import 'presentation/screens/screen_14_maternal_assessment.dart';
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
        color: const Color(0xFF09141E),
        child: Center(
          child: Container(
            width: 375,
            height: 812,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Colors.grey.shade900, width: 12),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 30, spreadRadius: 8),
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
        return PinLoginScreen(onPinSuccess: () => setState(() => _currentStep = 'MAIN_APP'));
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
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, -4)),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedTabIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.accentTeal,
          unselectedItemColor: AppTheme.textMedium,
          selectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500),
          onTap: (index) {
            setState(() {
              _selectedTabIndex = index;
              if (index == 2 && _assessmentStep == 0) _assessmentStep = 1;
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
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Luxurious CHO Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.heroCardGradient,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(color: AppTheme.primaryNavy.withValues(alpha: 0.3), blurRadius: 18, offset: const Offset(0, 8)),
                  ],
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
                            Text(repo.chwName, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                          ),
                          child: Row(
                            children: [
                              Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppTheme.accentTealGlow, shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Text('CHO Active', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: AppTheme.accentTealGlow, size: 16),
                        const SizedBox(width: 4),
                        Text(repo.chwZone, style: GoogleFonts.inter(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Urgent Alert Banner if urgent households exist
              if (urgentCount > 0)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.urgentRedLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.urgentRed.withValues(alpha: 0.3)),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color: AppTheme.urgentRed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('URGENT TRIAGE ATTENTION', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.urgentRed, letterSpacing: 0.5)),
                            const SizedBox(height: 2),
                            Text('$urgentCount household(s) flagged for SAM / maternal risk.', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 18),

              // Summary Metric Cards
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.urgentRed.withValues(alpha: 0.3)),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('URGENT', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.urgentRed)),
                          const SizedBox(height: 4),
                          Text('$urgentCount', style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.urgentRed)),
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
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.watchAmber.withValues(alpha: 0.3)),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('WATCH', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.watchAmber)),
                          const SizedBox(height: 4),
                          Text('$watchCount', style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.watchAmber)),
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
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.accentTeal.withValues(alpha: 0.3)),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('QUEUE', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentTeal)),
                          const SizedBox(height: 4),
                          Text('${_syncQueue.pendingCount}', style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.accentTeal)),
                          Text('Offline 2G', style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textMedium)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // Quick Action Navigation Buttons
              Text('CLINICAL QUICK ACTIONS', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy, letterSpacing: 0.5)),
              const SizedBox(height: 12),

              _HomeActionTile(
                icon: Icons.format_list_numbered_rounded,
                title: 'Prioritized Visits List',
                subtitle: 'Ordered by 0-100 priority score & overdue penalty',
                color: AppTheme.primaryNavy,
                onTap: () => setState(() => _selectedTabIndex = 1),
              ),
              _HomeActionTile(
                icon: Icons.add_task_rounded,
                title: 'Start New Clinical Assessment',
                subtitle: '26-parameter WHO IMCI / GHS triage at point of care',
                color: AppTheme.accentTeal,
                onTap: () => setState(() {
                  _selectedTabIndex = 2;
                  _assessmentStep = 1;
                }),
              ),
              _HomeActionTile(
                icon: Icons.local_hospital_outlined,
                title: 'Urgent Referrals & 2G SMS',
                subtitle: 'Bit-packed compressed payloads for remote hospital',
                color: AppTheme.urgentRed,
                onTap: () => setState(() => _selectedTabIndex = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisitsTabFlow() {
    if (_assessmentStep == 0) {
      return PrioritizedVisitsScreen(
        onSelectHousehold: (household) => setState(() {
          _selectedHousehold = household;
          _assessmentStep = 1; // Show detail screen
        }),
      );
    }

    // Step 1: Household detail
    return HouseholdTriageDetailScreen(
      household: _selectedHousehold!,
      onBack: () => setState(() => _assessmentStep = 0),
      onStartAssessment: () => setState(() => _assessmentStep = 2), // Child assessment
    );
  }

  Widget _buildAssessmentTabFlow() {
    switch (_assessmentStep) {
      case 0:
      case 1:
      case 2:
        return ChildAssessmentScreen(
          householdName: _selectedHousehold?.name ?? 'Akua Serwaa',
          initialMuac: _muac,
          initialBilateralOedema: _oedema,
          onComplete: (muac, oedema, dangerSigns) {
            setState(() {
              _muac = muac;
              _oedema = oedema;
              _childDanger = dangerSigns;
              _assessmentStep = 2; // Move to Young Infant
            });
          },
          onNextTab: () => setState(() => _assessmentStep = 2),
        );
      case 2:
        return YoungInfantAssessmentScreen(
          initialRr: _rr,
          initialTemp: _temp,
          onComplete: (rr, temp, dangerSigns) {
            setState(() {
              _rr = rr;
              _temp = temp;
              _infantDanger = dangerSigns;
              _assessmentStep = 3; // Move to Maternal
            });
          },
          onNextTab: () => setState(() => _assessmentStep = 3),
        );
      case 3:
        return MaternalAssessmentScreen(
          initialHb: _hb,
          initialPallorProxy: _pallorProxy,
          onComplete: (hb, pallorProxy, maternalDanger) {
            setState(() {
              _hb = hb;
              _pallorProxy = pallorProxy;
              _maternalDanger = maternalDanger;
            });
            _runAIEngine(); // Evaluate offline AI engine & navigate to results (Step 4)
          },
          onCompleteAssessment: (hb, pallorProxy, maternalDanger) {
            setState(() {
              _hb = hb;
              _pallorProxy = pallorProxy;
              _maternalDanger = maternalDanger;
            });
            _runAIEngine();
          },
          onNextTab: () => _runAIEngine(),
        );
      case 4:
        return AICareRecommendationsScreen(
          onFinishToHome: () => setState(() {
            _selectedTabIndex = 0;
            _assessmentStep = 0;
          }),
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

  Widget _buildReferralScreen() {
    return ReferralActionScreen(
      householdId: _selectedHousehold?.id ?? 'H-10041',
      patientName: _selectedHousehold?.name ?? 'Akua Serwaa',
      riskTier: _activeRuleResult?.overallTier.name ?? 'URGENT',
      reasons: _activeRuleResult?.reasons ?? ['MUAC 10.5cm — SAM (Severe Acute Malnutrition)', 'Fast Breathing (62/min)'],
      muacCm: _muac,
      breathingRate: _rr,
      hbLevel: _hb ?? 8.4,
      onViewNutrition: () => setState(() {
        _selectedTabIndex = 2;
        _assessmentStep = 6;
      }),
    );
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: AppTheme.cardShadow,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMedium, height: 1.3)),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textMedium, size: 22),
        onTap: onTap,
      ),
    );
  }
}
