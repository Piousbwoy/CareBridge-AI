import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

// ─── SCREEN 7: CREATE ACCOUNT ──────────────────────────────────────────────────
class CreateAccountScreen extends StatefulWidget {
  final VoidCallback onAccountCreated;
  final VoidCallback onBackToSignIn;
  const CreateAccountScreen({super.key, required this.onAccountCreated, required this.onBackToSignIn});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _nameCtrl = TextEditingController(text: 'Ama Abena');
  final _phoneCtrl = TextEditingController(text: '+233 26 123 4567');
  final _idCtrl = TextEditingController(text: 'CHO-2145');
  final _zoneCtrl = TextEditingController(text: 'Bole CHPS Zone, Savannah Region');
  bool _agreed = false;
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
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(color: AppTheme.accentTeal, borderRadius: BorderRadius.circular(18)),
                    child: const Icon(Icons.person_add_rounded, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 12),
                  Text('CareBridge AI', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Create Your Account', style: GoogleFonts.inter(fontSize: 13, color: Colors.white60)),
                  Text('Field-time provisioning', style: GoogleFonts.inter(fontSize: 11, color: Colors.white38)),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildField('Full Name', _nameCtrl, Icons.person_outline),
                        const SizedBox(height: 14),
                        _buildField('Phone Number', _phoneCtrl, Icons.phone_outlined, type: TextInputType.phone),
                        const SizedBox(height: 14),
                        _buildField('Cadre / Role', _idCtrl, Icons.badge_outlined),
                        const SizedBox(height: 14),
                        _buildField('CHPS Zone, Savannah Region', _zoneCtrl, Icons.location_on_outlined),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => setState(() => _agreed = !_agreed),
                          child: Row(children: [
                            Container(
                              width: 22, height: 22,
                              decoration: BoxDecoration(
                                color: _agreed ? AppTheme.accentTeal : Colors.transparent,
                                border: Border.all(color: _agreed ? AppTheme.accentTeal : AppTheme.cardBorder, width: 2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: _agreed ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text('I agree to protect patient data under Ghana Data Protection Act (Act 843).',
                                  style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMedium)),
                            ),
                          ]),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity, height: 50,
                          child: ElevatedButton(
                            onPressed: (_agreed && !_loading) ? () async {
                              setState(() => _loading = true);
                              await Future.delayed(const Duration(milliseconds: 900));
                              if (mounted) widget.onAccountCreated();
                            } : null,
                            child: _loading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text('Create Account', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton(
                            onPressed: widget.onBackToSignIn,
                            child: Text('Already have account? Sign In', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.accentTeal)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.lock_outline, size: 12, color: Colors.white38),
                    const SizedBox(width: 6),
                    Text('Local Mode Ready · Works Offline', style: GoogleFonts.inter(fontSize: 11, color: Colors.white38)),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon, {TextInputType? type}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMedium)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: type,
          style: GoogleFonts.inter(fontSize: 13),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 17, color: AppTheme.textMedium),
            isDense: true,
          ),
        ),
      ],
    );
  }
}
