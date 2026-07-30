import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

// ─── SCREEN 6: SIGN IN ────────────────────────────────────────────────────────
class SignInScreen extends StatefulWidget {
  final VoidCallback onSignInSuccess;
  final VoidCallback onCreateAccountRequested;
  const SignInScreen({super.key, required this.onSignInSuccess, required this.onCreateAccountRequested});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _phoneCtrl = TextEditingController(text: '+233 24 123 4567');
  final _pinCtrl = TextEditingController(text: '••••');
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.luxuryHeaderGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo container
                  Container(
                    width: 76, height: 76,
                    decoration: BoxDecoration(
                      color: AppTheme.accentTeal,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(color: AppTheme.accentTeal.withValues(alpha: 0.45), blurRadius: 24, offset: const Offset(0, 8)),
                      ],
                      border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.5),
                    ),
                    child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 40),
                  ),

                  const SizedBox(height: 18),
                  Text('CareBridge AI', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  Text('Ghana Health Service · CHPS Triage', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70, letterSpacing: 0.3)),

                  const SizedBox(height: 28),

                  // Glassmorphic Sign In Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 24, offset: const Offset(0, 10)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Officer Sign In', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.accentTeal.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text('GHS Bole Zone', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentTeal)),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        Text('Phone Number', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.phone_rounded, size: 18, color: AppTheme.accentTeal),
                            hintText: '+233 XX XXX XXXX',
                          ),
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                        ),

                        const SizedBox(height: 16),

                        Text('4-Digit Security PIN', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _pinCtrl,
                          obscureText: true,
                          maxLength: 4,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_rounded, size: 18, color: AppTheme.accentTeal),
                            counterText: '',
                            hintText: '••••',
                          ),
                          style: GoogleFonts.inter(fontSize: 18, letterSpacing: 8, fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 6),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text('Forgot PIN?', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accentTeal)),
                          ),
                        ),

                        const SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _loading ? null : () async {
                              setState(() => _loading = true);
                              await Future.delayed(const Duration(milliseconds: 700));
                              if (mounted) widget.onSignInSuccess();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryNavy,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: _loading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Authenticate Officer', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        Row(
                          children: [
                            const Expanded(child: Divider(color: AppTheme.cardBorderSubtle)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text('or', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight)),
                            ),
                            const Expanded(child: Divider(color: AppTheme.cardBorderSubtle)),
                          ],
                        ),

                        const SizedBox(height: 18),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: widget.onCreateAccountRequested,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppTheme.cardBorder),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text('Register New CHO Credentials', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shield_rounded, size: 13, color: AppTheme.accentTealGlow),
                        const SizedBox(width: 6),
                        Text('SQLCipher Encrypted · Local Mode Ready', style: GoogleFonts.inter(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
