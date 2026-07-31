import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../data/mock_repository.dart';

// ─── SCREEN 8: PIN LOGIN ───────────────────────────────────────────────────────
class PinLoginScreen extends StatefulWidget {
  final VoidCallback onPinSuccess;
  const PinLoginScreen({super.key, required this.onPinSuccess});

  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen>
    with SingleTickerProviderStateMixin {
  String _entered = '';
  bool _error = false;
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _onKey(String digit) {
    if (_entered.length >= 4) return;
    setState(() {
      _entered += digit;
      _error = false;
    });
    if (_entered.length == 4) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        final storedPin = MockRepository().pinCode;
        if (_entered == storedPin) {
          widget.onPinSuccess();
        } else {
          setState(() => _error = true);
          _shakeCtrl.forward(from: 0);
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) setState(() { _entered = ''; _error = false; });
          });
        }
      });
    }
  }

  void _onDelete() {
    if (_entered.isNotEmpty) {
      setState(() => _entered = _entered.substring(0, _entered.length - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.navyTealGradient),
        child: Stack(
          children: [
            // Decorative large blurred circle top
            Positioned(
              top: -100, left: -80,
              child: Container(
                width: 300, height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accentTeal.withValues(alpha: 0.09),
                ),
              ),
            ),
            Positioned(
              bottom: -80, right: -60,
              child: Container(
                width: 250, height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryNavyLight.withValues(alpha: 0.25),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 44),

                    // ── Lock icon with glow ──────────────────────────────
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        gradient: AppTheme.tealGradient,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: AppTheme.glowShadow(AppTheme.accentTeal),
                      ),
                      child: const Icon(Icons.lock_rounded, color: Colors.white, size: 34),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Enter Your PIN',
                      style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Quick & secure access to CareBridge AI',
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withValues(alpha: 0.6)),
                    ),
                    const SizedBox(height: 44),

                    // ── PIN Dots ─────────────────────────────────────────
                    AnimatedBuilder(
                      animation: _shakeAnim,
                      builder: (context, child) {
                        final dx = _error
                            ? 10 * (0.5 - (_shakeAnim.value - 0.5).abs()) * 2
                            : 0.0;
                        return Transform.translate(
                          offset: Offset(dx, 0),
                          child: child,
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (i) {
                          final filled = i < _entered.length;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutBack,
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            width: filled ? 22 : 18,
                            height: filled ? 22 : 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: filled
                                  ? (_error ? AppTheme.urgentRed : AppTheme.accentTeal)
                                  : Colors.transparent,
                              border: Border.all(
                                color: filled
                                    ? (_error ? AppTheme.urgentRed : AppTheme.accentTeal)
                                    : Colors.white.withValues(alpha: 0.4),
                                width: 2,
                              ),
                              boxShadow: filled
                                  ? AppTheme.glowShadow(_error ? AppTheme.urgentRed : AppTheme.accentTeal)
                                  : [],
                            ),
                          );
                        }),
                      ),
                    ),

                    if (_error) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.urgentRed.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.urgentRed.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          'Incorrect PIN — please try again',
                          style: GoogleFonts.inter(fontSize: 12, color: AppTheme.urgentRed, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],

                    const SizedBox(height: 48),

                    // ── Number Pad ───────────────────────────────────────
                    ...List.generate(3, (row) => Column(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (col) {
                          final num = row * 3 + col + 1;
                          return _NumKey(label: '$num', onTap: () => _onKey('$num'));
                        }),
                      ),
                      const SizedBox(height: 14),
                    ])),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Biometric placeholder
                        _NumKey(
                          label: '',
                          icon: Icons.fingerprint_rounded,
                          onTap: () {},
                          iconColor: AppTheme.accentTeal,
                        ),
                        _NumKey(label: '0', onTap: () => _onKey('0')),
                        _NumKey(label: '⌫', onTap: _onDelete, isDelete: true),
                      ],
                    ),

                    const Spacer(),

                    // ── Footer badges ────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _FooterBadge(icon: Icons.shield_rounded, label: 'Encrypted (SQLCipher)'),
                        const SizedBox(width: 10),
                        _FooterBadge(
                          icon: Icons.circle,
                          iconColor: AppTheme.routineGreen,
                          label: 'Offline Active',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Number key widget ─────────────────────────────────────────────────────────
class _NumKey extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDelete;
  final IconData? icon;
  final Color? iconColor;

  const _NumKey({
    required this.label,
    required this.onTap,
    this.isDelete = false,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty && icon == null) return const SizedBox(width: 78, height: 64);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 78, height: 64,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: isDelete
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, color: iconColor ?? Colors.white70, size: 28)
              : Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: isDelete ? 22 : 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}

// ── Footer badge ──────────────────────────────────────────────────────────────
class _FooterBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;

  const _FooterBadge({required this.icon, required this.label, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: AppTheme.glassMorphism(opacity: 0.08, borderOpacity: 0.15, radius: 10),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: iconColor ?? Colors.white54),
        const SizedBox(width: 5),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.white54)),
      ]),
    );
  }
}
