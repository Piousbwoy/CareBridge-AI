import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

// ─── SCREEN 1: SPLASH ─────────────────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const SplashScreen({super.key, required this.onFinish});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  double _progress = 0.0;
  late AnimationController _pulse;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
    _scaleAnim = Tween<double>(begin: 0.95, end: 1.05).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
    _startInit();
  }

  void _startInit() async {
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 220));
      if (mounted) setState(() => _progress = i / 10.0);
    }
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) widget.onFinish();
  }

  @override
  void dispose() { _pulse.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A2540), Color(0xFF0D3563), Color(0xFF1A4A7A)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 2),
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.accentTeal,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [BoxShadow(color: AppTheme.accentTeal.withValues(alpha: 0.45), blurRadius: 28, offset: const Offset(0, 10))],
                    ),
                    child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 52),
                  ),
                ),
                const SizedBox(height: 28),
                Text('CareBridge AI', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Text('Predict Risk. Save Lives.', style: GoogleFonts.inter(fontSize: 15, color: Colors.white70)),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI-powered maternal & child health support for every community.',
                          style: GoogleFonts.inter(fontSize: 13, color: Colors.white70, height: 1.5)),
                      const SizedBox(height: 16),
                      Row(children: [
                        const Icon(Icons.wifi_off_rounded, size: 14, color: Colors.white54),
                        const SizedBox(width: 6),
                        Text('Works 100% offline', style: GoogleFonts.inter(fontSize: 12, color: Colors.white54)),
                      ]),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Initializing secure system...', style: GoogleFonts.inter(fontSize: 12, color: Colors.white54)),
                        Text('${(_progress * 100).round()}%', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accentTeal)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentTeal),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
