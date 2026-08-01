import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../data/mock_repository.dart';

/// Phase 1 — Screen 6: Forgot PIN Recovery Screen
class ForgotPinScreen extends StatefulWidget {
  final VoidCallback onBackToSignIn;
  final VoidCallback onPinResetSuccess;

  const ForgotPinScreen({
    super.key,
    required this.onBackToSignIn,
    required this.onPinResetSuccess,
  });

  @override
  State<ForgotPinScreen> createState() => _ForgotPinScreenState();
}

class _ForgotPinScreenState extends State<ForgotPinScreen> {
  final _phoneCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _newPinCtrl = TextEditingController();
  
  int _step = 1; // 1: Phone, 2: SMS Code, 3: New PIN
  bool _loading = false;
  String? _errorMessage;

  void _sendResetCode() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) {
      setState(() => _errorMessage = 'Please enter your registered phone number.');
      return;
    }
    setState(() { _loading = true; _errorMessage = null; });
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _loading = false;
      _step = 2;
    });
  }

  void _verifyCode() async {
    final code = _codeCtrl.text.trim();
    if (code.length < 4) {
      setState(() => _errorMessage = 'Please enter the 6-digit SMS code sent to your phone.');
      return;
    }
    setState(() { _loading = true; _errorMessage = null; });
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _loading = false;
      _step = 3;
    });
  }

  void _resetPin() async {
    final pin = _newPinCtrl.text.trim();
    if (pin.length != 4 || int.tryParse(pin) == null) {
      setState(() => _errorMessage = 'PIN must be exactly 4 numeric digits.');
      return;
    }
    setState(() { _loading = true; _errorMessage = null; });

    final repo = MockRepository();
    repo.setUserProfile(
      name: repo.chwName.isEmpty ? 'CHPS Officer' : repo.chwName,
      role: repo.userRole,
      region: repo.userRegion,
      district: repo.userDistrict,
      pin: pin,
      phone: _phoneCtrl.text.trim(),
    );

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PIN reset successfully! You can now sign in.')),
    );
    widget.onPinResetSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.navyTealGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      color: AppTheme.accentTeal.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.accentTeal, width: 2),
                    ),
                    child: const Icon(Icons.lock_reset_rounded, color: Colors.white, size: 34),
                  ),
                  const SizedBox(height: 16),
                  Text('CareBridge AI', style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Reset Your 4-Digit Security PIN', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.glassMorphism(opacity: 0.15, borderOpacity: 0.25, radius: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_errorMessage != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: AppTheme.urgentRed.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Expanded(child: Text(_errorMessage!, style: GoogleFonts.inter(fontSize: 12, color: Colors.white))),
                              ],
                            ),
                          ),

                        if (_step == 1) ...[
                          Text('STEP 1 OF 3: PHONE NUMBER', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentTeal)),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            style: GoogleFonts.inter(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Registered Phone Number',
                              prefixIcon: Icon(Icons.phone_android_rounded, color: AppTheme.accentTeal),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _sendResetCode,
                              child: _loading
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : Text('Send Reset SMS Code', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ] else if (_step == 2) ...[
                          Text('STEP 2 OF 3: ENTER SMS CODE', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentTeal)),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _codeCtrl,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.inter(color: Colors.white, letterSpacing: 4, fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(
                              labelText: '6-Digit SMS Verification Code',
                              prefixIcon: Icon(Icons.sms_rounded, color: AppTheme.accentTeal),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _verifyCode,
                              child: _loading
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : Text('Verify Code', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ] else ...[
                          Text('STEP 3 OF 3: CREATE NEW PIN', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentTeal)),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _newPinCtrl,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            maxLength: 4,
                            style: GoogleFonts.inter(color: Colors.white, letterSpacing: 6, fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(
                              labelText: 'New 4-Digit Security PIN',
                              prefixIcon: Icon(Icons.lock_outline_rounded, color: AppTheme.accentTeal),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _resetPin,
                              child: _loading
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : Text('Reset PIN & Sign In', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: widget.onBackToSignIn,
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70, size: 18),
                    label: Text('Back to Sign In', style: GoogleFonts.inter(color: Colors.white70)),
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
