import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

// ─── SCREEN 8: PIN LOGIN ───────────────────────────────────────────────────────
class PinLoginScreen extends StatefulWidget {
  final VoidCallback onPinSuccess;
  const PinLoginScreen({super.key, required this.onPinSuccess});

  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  String _entered = '';
  bool _error = false;

  void _onKey(String digit) {
    if (_entered.length >= 4) return;
    setState(() { _entered += digit; _error = false; });
    if (_entered.length == 4) {
      Future.delayed(const Duration(milliseconds: 280), () {
        if (mounted) widget.onPinSuccess(); // Accept any 4-digit PIN for demo
      });
    }
  }

  void _onDelete() {
    if (_entered.isNotEmpty) setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.luxuryHeaderGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 36),

                // Icon container
                Container(
                  width: 70, height: 70,
                  decoration: BoxDecoration(
                    color: AppTheme.accentTeal,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(color: AppTheme.accentTeal.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 6)),
                    ],
                    border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.5),
                  ),
                  child: const Icon(Icons.lock_rounded, color: Colors.white, size: 34),
                ),

                const SizedBox(height: 18),
                Text('Enter 4-Digit Security PIN', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.3)),
                const SizedBox(height: 6),
                Text('CHO Officer Authentication · Bole CHPS Zone', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),

                const SizedBox(height: 36),

                // PIN Glowing Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) {
                    final isFilled = i < _entered.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: isFilled ? 20 : 18,
                      height: isFilled ? 20 : 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isFilled ? AppTheme.accentTealGlow : Colors.transparent,
                        boxShadow: isFilled
                            ? [BoxShadow(color: AppTheme.accentTealGlow.withValues(alpha: 0.6), blurRadius: 12, spreadRadius: 2)]
                            : [],
                        border: Border.all(
                          color: _error
                              ? AppTheme.urgentRed
                              : (isFilled ? AppTheme.accentTealGlow : Colors.white.withValues(alpha: 0.45)),
                          width: 2,
                        ),
                      ),
                    );
                  }),
                ),

                if (_error) ...[
                  const SizedBox(height: 12),
                  Text('Incorrect PIN. Please try again.', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.urgentRed, fontWeight: FontWeight.w600)),
                ],

                const SizedBox(height: 36),

                // Luxurious Numpad
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
                    _NumKey(label: '', onTap: () {}),
                    _NumKey(label: '0', onTap: () => _onKey('0')),
                    _NumKey(label: '⌫', onTap: _onDelete, isDelete: true),
                  ],
                ),

                const Spacer(),

                // Bottom Footer Indicators
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shield_rounded, size: 13, color: AppTheme.accentTealGlow),
                      const SizedBox(width: 6),
                      Text('SQLCipher Passphrase Encrypted', style: GoogleFonts.inter(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppTheme.accentTealGlow, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text('Local Offline Engine Active', style: GoogleFonts.inter(fontSize: 11, color: Colors.white54)),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NumKey extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDelete;
  const _NumKey({required this.label, required this.onTap, this.isDelete = false});

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox(width: 84, height: 60);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 84, height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: isDelete ? 0.06 : 0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: isDelete ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
