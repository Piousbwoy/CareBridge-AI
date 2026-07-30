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
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF0A2540), Color(0xFF0D3563)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(color: AppTheme.accentTeal, borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 16),
                  Text('CareBridge AI', style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Welcome back!', style: GoogleFonts.inter(fontSize: 14, color: Colors.white60)),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sign In', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                        const SizedBox(height: 20),
                        Text('Phone Number', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textMedium)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.phone_rounded, size: 18),
                            hintText: '+233 XX XXX XXXX',
                          ),
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        Text('PIN (4 digit)', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textMedium)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _pinCtrl,
                          obscureText: true,
                          maxLength: 4,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_rounded, size: 18),
                            counterText: '',
                            hintText: '••••',
                          ),
                          style: GoogleFonts.inter(fontSize: 18, letterSpacing: 8),
                        ),
                        const SizedBox(height: 8),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          const SizedBox(),
                          TextButton(
                            onPressed: () {},
                            child: Text('Forgot PIN?', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.accentTeal)),
                          ),
                        ]),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity, height: 50,
                          child: ElevatedButton(
                            onPressed: _loading ? null : () async {
                              setState(() => _loading = true);
                              await Future.delayed(const Duration(milliseconds: 800));
                              if (mounted) widget.onSignInSuccess();
                            },
                            child: _loading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text('Sign In', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('or', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight)),
                          ),
                          const Expanded(child: Divider()),
                        ]),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity, height: 48,
                          child: OutlinedButton(
                            onPressed: widget.onCreateAccountRequested,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppTheme.primaryNavy),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text('Create New Account', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.lock_outline, size: 12, color: Colors.white60),
                      const SizedBox(width: 6),
                      Text('Local Mode Ready · Works Offline', style: GoogleFonts.inter(fontSize: 11, color: Colors.white60)),
                    ]),
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
