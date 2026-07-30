import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const SplashScreen({super.key, required this.onFinish});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  double _progress = 0.0;
  late AnimationController _fadeCtrl;
  late AnimationController _slideCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _pulseAnim;

  final List<String> _bootMessages = [
    'Loading clinical rules engine...',
    'Initializing IMCI protocol (26 params)...',
    'Mounting offline SQLite database...',
    'Pre-loading Dagbani audio prompts...',
    'Configuring 2G SMS compressor...',
    'Verifying encrypted local storage...',
    'CareBridge AI is ready.',
  ];
  String _currentMsg = 'Initializing secure system...';

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _slideCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);

    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _pulseAnim = Tween<double>(begin: 0.96, end: 1.04)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _fadeCtrl.forward();
    _slideCtrl.forward();
    _startInit();
  }

  void _startInit() async {
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 250));
      if (mounted) {
        setState(() {
          _progress = i / 10.0;
          if (i <= _bootMessages.length) {
            _currentMsg = _bootMessages[i - 1];
          }
        });
      }
    }
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) widget.onFinish();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A2540),
      body: Stack(
        children: [
          // Full-bleed hero image with gradient fallback
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash_hero.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0A2540), Color(0xFF0D3563), Color(0xFF1A5A6A)],
                  ),
                ),
              ),
            ),
          ),

          // Dark gradient overlay — bottom-heavy for text readability
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.25),
                    Colors.black.withValues(alpha: 0.78),
                    Colors.black.withValues(alpha: 0.92),
                  ],
                  stops: const [0.0, 0.35, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // Subtle top teal overlay shimmer
          Positioned(
            top: 0, left: 0, right: 0, height: 180,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryNavy.withValues(alpha: 0.65),
                    AppTheme.accentTeal.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 18),

                  // GHS protocol badge top
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.accentTeal.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.health_and_safety_rounded, size: 14, color: Colors.white),
                              const SizedBox(width: 5),
                              Text('GHS CHPS Protocol', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                          ),
                          child: Text('Offline Ready', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Logo + Brand
                  SlideTransition(
                    position: _slideAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Column(
                        children: [
                          // Animated logo
                          ScaleTransition(
                            scale: _pulseAnim,
                            child: Container(
                              width: 88, height: 88,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(26),
                                boxShadow: [
                                  BoxShadow(color: AppTheme.accentTeal.withValues(alpha: 0.5), blurRadius: 30, spreadRadius: 4),
                                ],
                              ),
                              child: const Icon(Icons.favorite_rounded, color: AppTheme.accentTeal, size: 48),
                            ),
                          ),

                          const SizedBox(height: 20),

                          Text('CareBridge AI', style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5)),
                          const SizedBox(height: 6),
                          Text('Predict Risk · Save Lives · Reach Everyone', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70, letterSpacing: 0.3)),

                          const SizedBox(height: 28),

                          // Stat pills
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _StatPill('26', 'Parameters'),
                              const SizedBox(width: 8),
                              _StatPill('2G', 'SMS Ready'),
                              const SizedBox(width: 8),
                              _StatPill('100%', 'Offline'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Loading section
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(_currentMsg, style: GoogleFonts.inter(fontSize: 11, color: Colors.white60), overflow: TextOverflow.ellipsis),
                            ),
                            const SizedBox(width: 8),
                            Text('${(_progress * 100).round()}%', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.accentTeal)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: _progress,
                            minHeight: 5,
                            backgroundColor: Colors.white.withValues(alpha: 0.12),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentTeal),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Text('Ghana Health Service · Savannah Region', style: GoogleFonts.inter(fontSize: 11, color: Colors.white38)),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String value;
  final String label;
  const _StatPill(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(value, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.accentTeal)),
          Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.white60)),
        ],
      ),
    );
  }
}
