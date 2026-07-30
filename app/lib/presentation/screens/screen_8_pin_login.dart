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
      Future.delayed(const Duration(milliseconds: 300), () {
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
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF0A2540), Color(0xFF1A4A7A)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(color: AppTheme.accentTeal, borderRadius: BorderRadius.circular(18)),
                  child: const Icon(Icons.lock_rounded, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 20),
                Text('Enter 4-Digit PIN', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 6),
                Text('For quick & secure access', style: GoogleFonts.inter(fontSize: 13, color: Colors.white60)),
                const SizedBox(height: 36),
                // PIN Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 18, height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < _entered.length ? Colors.white : Colors.transparent,
                      border: Border.all(
                        color: _error ? AppTheme.urgentRed : Colors.white.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                  )),
                ),
                if (_error) ...[
                  const SizedBox(height: 10),
                  Text('Incorrect PIN. Try again.', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.urgentRed)),
                ],
                const SizedBox(height: 40),
                // Numpad
                ...List.generate(3, (row) => Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (col) {
                      final num = row * 3 + col + 1;
                      return _NumKey(label: '$num', onTap: () => _onKey('$num'));
                    }),
                  ),
                  const SizedBox(height: 12),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.shield_rounded, size: 13, color: Colors.white54),
                    const SizedBox(width: 6),
                    Text('Database Encrypted (SQLCipher)', style: GoogleFonts.inter(fontSize: 11, color: Colors.white54)),
                  ]),
                ),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: AppTheme.routineGreen, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text('Offline Active', style: GoogleFonts.inter(fontSize: 11, color: Colors.white54)),
                ]),
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
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: isDelete ? 0.05 : 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Center(
          child: Text(label,
              style: GoogleFonts.outfit(
                fontSize: isDelete ? 22 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              )),
        ),
      ),
    );
  }
}
