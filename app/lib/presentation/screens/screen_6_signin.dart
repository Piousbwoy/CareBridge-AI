import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../data/mock_repository.dart';

// ─── SCREEN 6: SIGN IN ────────────────────────────────────────────────────────
class SignInScreen extends StatefulWidget {
  final VoidCallback onSignInSuccess;
  final VoidCallback onCreateAccountRequested;
  final VoidCallback? onForgotPinRequested;

  const SignInScreen({
    super.key,
    required this.onSignInSuccess,
    required this.onCreateAccountRequested,
    this.onForgotPinRequested,
  });

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with SingleTickerProviderStateMixin {
  final _phoneCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  bool _loading = false;
  String? _errorMessage;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _phoneCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    final phone = _phoneCtrl.text.trim();
    final pin = _pinCtrl.text.trim();

    // Basic validation
    if (phone.isEmpty || pin.isEmpty) {
      setState(() => _errorMessage = 'Please enter your phone number and PIN.');
      return;
    }
    if (pin.length != 4 || int.tryParse(pin) == null) {
      setState(() => _errorMessage = 'PIN must be exactly 4 digits.');
      return;
    }

    setState(() { _loading = true; _errorMessage = null; });

    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    // Check credentials against stored account
    final repo = MockRepository();
    final result = repo.signIn(phone: phone, pin: pin);

    setState(() => _loading = false);

    if (result == SignInResult.success) {
      widget.onSignInSuccess();
    } else if (result == SignInResult.noAccount) {
      setState(() => _errorMessage = 'No account found for this phone number. Please create an account first.');
    } else {
      setState(() => _errorMessage = 'Incorrect PIN. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.navyTealGradient),
        child: Stack(
          children: [
            // Decorative orb top-right
            Positioned(
              top: -60, right: -60,
              child: Container(
                width: 220, height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accentTeal.withValues(alpha: 0.12),
                ),
              ),
            ),
            // Decorative orb bottom-left
            Positioned(
              bottom: -80, left: -60,
              child: Container(
                width: 260, height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryNavyLight.withValues(alpha: 0.3),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ── Animated Logo ──────────────────────────────────
                        ScaleTransition(
                          scale: _scaleAnim,
                          child: Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(
                              gradient: AppTheme.tealGradient,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: AppTheme.glowShadow(AppTheme.accentTeal),
                            ),
                            child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 40),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'CareBridge AI',
                          style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sign in to your account',
                          style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withValues(alpha: 0.65)),
                        ),
                        const SizedBox(height: 32),

                        // ── Glass Card Form ────────────────────────────────
                        SlideTransition(
                          position: _slideAnim,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.97),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 32, offset: const Offset(0, 12)),
                                BoxShadow(color: AppTheme.accentTeal.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 4)),
                              ],
                            ),
                            padding: const EdgeInsets.all(28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Sign In', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                                const SizedBox(height: 4),
                                Text('Enter your registered phone number and PIN', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMedium)),
                                const SizedBox(height: 24),

                                // Error message
                                if (_errorMessage != null) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: AppTheme.urgentRed.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppTheme.urgentRed.withValues(alpha: 0.3)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.error_outline_rounded, color: AppTheme.urgentRed, size: 16),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(_errorMessage!, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.urgentRed, fontWeight: FontWeight.w600)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                // Phone field
                                _FieldLabel('Phone Number'),
                                const SizedBox(height: 8),
                                _StyledField(
                                  controller: _phoneCtrl,
                                  keyboardType: TextInputType.phone,
                                  prefixIcon: Icons.phone_rounded,
                                  hintText: '+233 XX XXX XXXX',
                                ),
                                const SizedBox(height: 18),

                                // PIN field
                                _FieldLabel('4-Digit PIN'),
                                const SizedBox(height: 8),
                                _StyledField(
                                  controller: _pinCtrl,
                                  obscureText: true,
                                  maxLength: 4,
                                  keyboardType: TextInputType.number,
                                  prefixIcon: Icons.lock_rounded,
                                  hintText: '••••',
                                  letterSpacing: 8,
                                ),
                                 Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: widget.onForgotPinRequested,
                                      child: Text(
                                        'Forgot PIN?',
                                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accentTeal),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Sign In button
                                _GradientButton(
                                  label: 'Sign In',
                                  isLoading: _loading,
                                  onTap: _loading ? null : _handleSignIn,
                                ),
                                const SizedBox(height: 20),

                                // Divider
                                Row(children: [
                                  const Expanded(child: Divider()),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                    child: Text('or', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight)),
                                  ),
                                  const Expanded(child: Divider()),
                                ]),
                                const SizedBox(height: 20),

                                // Create account button
                                SizedBox(
                                  width: double.infinity, height: 50,
                                  child: OutlinedButton(
                                    onPressed: widget.onCreateAccountRequested,
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: AppTheme.primaryNavy.withValues(alpha: 0.4)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                    child: Text('Create New Account',
                                        style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Bottom badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: AppTheme.glassMorphism(opacity: 0.1, borderOpacity: 0.2, radius: 12),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.lock_outline, size: 12, color: Colors.white70),
                            const SizedBox(width: 6),
                            Text('Local Mode Ready · Works Offline', style: GoogleFonts.inter(fontSize: 11, color: Colors.white70)),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable field label ───────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textMedium, letterSpacing: 0.2),
  );
}

// ── Styled text field ─────────────────────────────────────────────────────────
class _StyledField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final int? maxLength;
  final IconData prefixIcon;
  final String hintText;
  final double letterSpacing;

  const _StyledField({
    required this.controller,
    required this.prefixIcon,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.maxLength,
    this.letterSpacing = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLength: maxLength,
      style: GoogleFonts.inter(fontSize: 14, letterSpacing: letterSpacing),
      decoration: InputDecoration(
        prefixIcon: Icon(prefixIcon, size: 18, color: AppTheme.textMedium),
        hintText: hintText,
        counterText: '',
        hintStyle: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight),
      ),
    );
  }
}

// ── Gradient CTA button ───────────────────────────────────────────────────────
class _GradientButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onTap;

  const _GradientButton({required this.label, required this.isLoading, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppTheme.fastAnim,
        width: double.infinity, height: 52,
        decoration: BoxDecoration(
          gradient: onTap == null
              ? const LinearGradient(colors: [Color(0xFFB0BEC5), Color(0xFF90A4AE)])
              : AppTheme.navyGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: onTap == null ? [] : [
            BoxShadow(color: AppTheme.primaryNavy.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : Text(label, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }
}
