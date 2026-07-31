import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../data/local/database.dart';
import '../../data/mock_repository.dart';
import '../../domain/models/clinical_models.dart';

// ─── SCREEN 7: CREATE ACCOUNT ──────────────────────────────────────────────────
class CreateAccountScreen extends StatefulWidget {
  final VoidCallback onAccountCreated;
  final VoidCallback onBackToSignIn;

  const CreateAccountScreen({
    super.key,
    required this.onAccountCreated,
    required this.onBackToSignIn,
  });

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  UserRole _selectedRole = UserRole.frontlineHealthWorker;
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();

  Map<String, List<String>> _regionData = {};
  String? _selectedRegion;
  String? _selectedDistrict;
  bool _agreed = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadAdministrativeData();
  }

  Future<void> _loadAdministrativeData() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/gh_northern_regions.json');
      final Map<String, dynamic> rawMap = jsonDecode(jsonString);
      final Map<String, List<String>> parsed = {};
      rawMap.forEach((key, value) {
        parsed[key] = List<String>.from(value['districts']);
      });
      if (mounted) {
        setState(() {
          _regionData = parsed;
          _selectedRegion = 'Savannah Region';
          _selectedDistrict = 'Bole';
        });
      }
    } catch (e) {
      // Fallback region dataset
      if (mounted) {
        setState(() {
          _regionData = {
            'Savannah Region': ['Bole', 'West Gonja Municipal', 'Central Gonja', 'Sawla-Tuna-Kalba'],
            'Northern Region': ['Tamale Metropolitan', 'Sagnarigu Municipal', 'Savelugu Municipal', 'Yendi Municipal'],
            'North East Region': ['East Mamprusi Municipal', 'West Mamprusi Municipal', 'Bunkpurugu Nakpanduri'],
            'Upper East Region': ['Bolgatanga Municipal', 'Bawku Municipal', 'Kassena Nankana Municipal'],
            'Upper West Region': ['Wa Municipal', 'Lawra Municipal', 'Jirapa Municipal'],
          };
          _selectedRegion = 'Savannah Region';
          _selectedDistrict = 'Bole';
        });
      }
    }
  }

  void _onRegionChanged(String? newRegion) {
    if (newRegion == null) return;
    setState(() {
      _selectedRegion = newRegion;
      final districts = _regionData[newRegion] ?? [];
      _selectedDistrict = districts.isNotEmpty ? districts.first : null;
    });
  }

  Future<void> _handleAccountCreation() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final pin = _pinCtrl.text.trim();

    if (name.isEmpty || phone.isEmpty || pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields (Name, Phone, and 4-Digit PIN).')),
      );
      return;
    }

    if (pin.length != 4 || int.tryParse(pin) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Security PIN must be exactly 4 numeric digits.')),
      );
      return;
    }

    setState(() => _loading = true);

    final repo = MockRepository();
    repo.setUserProfile(
      name: name,
      role: _selectedRole,
      region: _selectedRegion ?? 'Savannah Region',
      district: _selectedDistrict ?? 'Bole',
      pin: pin,
      phone: phone,
    );

    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _loading = false);
      widget.onAccountCreated();
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableDistricts = _regionData[_selectedRegion] ?? [];

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
                  Text('Northern Ghana Maternal & Child Health', style: GoogleFonts.inter(fontSize: 11, color: Colors.white38)),
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
                        // ── 1. ROLE SELECTOR FIRST ──────────────────────────────
                        Text('ACCOUNT ROLE (Select Access Level)',
                            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.cardBorder),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<UserRole>(
                              value: _selectedRole,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primaryNavy),
                              items: const [
                                DropdownMenuItem(
                                  value: UserRole.frontlineHealthWorker,
                                  child: Row(
                                    children: [
                                      Icon(Icons.local_hospital_outlined, size: 18, color: AppTheme.accentTeal),
                                      SizedBox(width: 8),
                                      Text('Frontline Health Worker (CHPS / CHO)'),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: UserRole.caregiver,
                                  child: Row(
                                    children: [
                                      Icon(Icons.family_restroom_outlined, size: 18, color: AppTheme.watchAmber),
                                      SizedBox(width: 8),
                                      Text('Caregiver (Mother / Family / TBA)'),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: UserRole.districtOfficer,
                                  child: Row(
                                    children: [
                                      Icon(Icons.admin_panel_settings_outlined, size: 18, color: AppTheme.urgentRed),
                                      SizedBox(width: 8),
                                      Text('District Officer / Supervisor (Web Only)'),
                                    ],
                                  ),
                                ),
                              ],
                              onChanged: (role) {
                                if (role != null) setState(() => _selectedRole = role);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── 2. CASCADING REGION & DISTRICT DROPDOWNS ────────────
                        Text('Region (Northern Ghana)',
                            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMedium)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.cardBorder),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedRegion,
                              isExpanded: true,
                              hint: const Text('Select Region'),
                              icon: const Icon(Icons.location_on_outlined, color: AppTheme.primaryNavy),
                              items: _regionData.keys.map((reg) => DropdownMenuItem(value: reg, child: Text(reg))).toList(),
                              onChanged: _onRegionChanged,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        Text('District / Municipal Assembly',
                            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMedium)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: availableDistricts.isEmpty ? Colors.grey.shade100 : AppTheme.backgroundLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.cardBorder),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedDistrict,
                              isExpanded: true,
                              hint: const Text('Select District'),
                              icon: const Icon(Icons.map_outlined, color: AppTheme.primaryNavy),
                              items: availableDistricts.map((dist) => DropdownMenuItem(value: dist, child: Text(dist))).toList(),
                              onChanged: availableDistricts.isEmpty ? null : (d) => setState(() => _selectedDistrict = d),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // ── 3. NAME & PHONE & PIN ──────────────────────────────
                        _buildField('Full Name', _nameCtrl, Icons.person_outline),
                        const SizedBox(height: 14),
                        _buildField('Phone Number', _phoneCtrl, Icons.phone_outlined, type: TextInputType.phone),
                        const SizedBox(height: 14),
                        _buildField('4-Digit Security PIN', _pinCtrl, Icons.lock_outline, type: TextInputType.number, obscure: true),
                        const SizedBox(height: 16),

                        // ── 4. AGREEMENT CHECKBOX ──────────────────────────────
                        GestureDetector(
                          onTap: () => setState(() => _agreed = !_agreed),
                          child: Row(
                            children: [
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
                                child: Text(
                                  'I agree to protect maternal & child health data under Ghana Data Protection Act (Act 843).',
                                  style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMedium),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Submit Button
                        SizedBox(
                          width: double.infinity, height: 50,
                          child: ElevatedButton(
                            onPressed: (_agreed && !_loading) ? _handleAccountCreation : null,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_outline, size: 12, color: Colors.white38),
                      const SizedBox(width: 6),
                      Text('Encrypted Storage · Northern Ghana Protocol', style: GoogleFonts.inter(fontSize: 11, color: Colors.white38)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon, {TextInputType? type, bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMedium)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: type,
          obscureText: obscure,
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
