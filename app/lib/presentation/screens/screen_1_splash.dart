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
  late AnimationController _pulseCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _pulseAnim;

  final List<String> _bootMessages = [
    'Loading clinical rules engine...',
    'Initializing IMCI protocol...',
    'Mounting offline SQLite database...',
    'Pre-loading Dagbani audio prompts...',
    'Configuring 2G SMS compressor...',
    'Verifying encrypted storage...',
    'CareBridge AI is ready.',
  ];
  String _currentMsg = 'Loading...';

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);

    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _pulseAnim = Tween<double>(begin: 0.96, end: 1.04).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _fadeCtrl.forward();
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
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const brandBlue = Color(0xFF1E68F6);
    const darkNavy = Color(0xFF0B1E36);
    const waveBlue = Color(0xFF0052CC);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FD),
      body: Stack(
        children: [
          // Light gradient background with soft tech circles
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFEBF3FC), Color(0xFFFFFFFF), Color(0xFFF0F6FE)],
                ),
              ),
            ),
          ),

          // Tech background grid/dot pattern overlay fallback
          Positioned(
            top: -40, left: -40,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: brandBlue.withValues(alpha: 0.05),
              ),
            ),
          ),

          // Main Screen Layout
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const SizedBox(height: 20),

                // ── Top Logo & Header ────────────────────────────────────────
                FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    children: [
                      // 3D-Style Heart Logo Icon
                      ScaleTransition(
                        scale: _pulseAnim,
                        child: Container(
                          width: 82, height: 82,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF2B79FF), Color(0xFF0047BB)],
                            ),
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(color: brandBlue.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 8)),
                            ],
                          ),
                          child: Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(Icons.favorite, color: Colors.white, size: 52),
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Icon(Icons.add_rounded, color: brandBlue, size: 24),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title: CareBridge AI
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'CareBridge ',
                              style: GoogleFonts.outfit(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: darkNavy,
                                letterSpacing: -0.5,
                              ),
                            ),
                            TextSpan(
                              text: 'AI',
                              style: GoogleFonts.outfit(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: brandBlue,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Subtitle
                      Text(
                        'Predict Risk  •  Save Lives  •  Reach Everyone',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF475569),
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Protocol Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2EDFE),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: brandBlue.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(color: brandBlue, shape: BoxShape.circle),
                              child: const Icon(Icons.add, size: 12, color: Colors.white),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'GHS CHPS PROTOCOL',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: brandBlue,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Middle Section: Hero Image + Glass Feature Badges ─────────
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Hero Image (CHW Nurse)
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/splash_hero.png',
                          fit: BoxFit.contain,
                          alignment: Alignment.bottomCenter,
                          errorBuilder: (_, __, ___) => const SizedBox(),
                        ),
                      ),

                      // Left Glassmorphic Feature Cards Overlay
                      Positioned(
                        left: 16,
                        top: 20,
                        child: FadeTransition(
                          opacity: _fadeAnim,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FeatureGlassBadge(
                                icon: Icons.psychology_rounded,
                                line1: 'AI-Powered',
                                line2: 'Risk Prediction',
                                brandBlue: brandBlue,
                              ),
                              const SizedBox(height: 10),
                              _FeatureGlassBadge(
                                icon: Icons.shield_rounded,
                                line1: 'Secure &',
                                line2: 'Private',
                                brandBlue: brandBlue,
                              ),
                              const SizedBox(height: 10),
                              _FeatureGlassBadge(
                                icon: Icons.cloud_off_rounded,
                                line1: 'Works',
                                line2: 'Offline',
                                brandBlue: brandBlue,
                              ),
                              const SizedBox(height: 10),
                              _FeatureGlassBadge(
                                icon: Icons.people_alt_rounded,
                                line1: 'Built for',
                                line2: 'Frontline Heroes',
                                brandBlue: brandBlue,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Bottom Curved Wave & Loading Progress ─────────────────────
                ClipPath(
                  clipper: _TopCurveClipper(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [waveBlue, Color(0xFF003896)],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Ghana Health Service Logo / Subtitle
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                              ),
                              child: const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ghana Health Service',
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Savannah Region',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Sleek Progress Bar
                        SizedBox(
                          width: 220,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: _progress,
                              minHeight: 4,
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        Text(
                          _currentMsg,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Left Glassmorphic Feature Badge ───────────────────────────────────────────
class _FeatureGlassBadge extends StatelessWidget {
  final IconData icon;
  final String line1;
  final String line2;
  final Color brandBlue;

  const _FeatureGlassBadge({
    required this.icon,
    required this.line1,
    required this.line2,
    required this.brandBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 155,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: brandBlue,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: brandBlue.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  line1,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  line2,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Top Curved Clipper for Bottom Wave ─────────────────────────────────────────
class _TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 24);
    path.quadraticBezierTo(size.width * 0.5, -10, size.width, 24);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
