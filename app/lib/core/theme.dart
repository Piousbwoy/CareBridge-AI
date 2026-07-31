import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Brand Primary Palette ──────────────────────────────────────────────────
  static const Color primaryNavy = Color(0xFF0A2540);
  static const Color primaryNavyDark = Color(0xFF061829);
  static const Color primaryNavyLight = Color(0xFF0D3563);
  static const Color accentTeal = Color(0xFF00A896);
  static const Color accentTealLight = Color(0xFF00C9B5);
  static const Color accentTealDark = Color(0xFF008F7F);

  // ─── Tier Colors ────────────────────────────────────────────────────────────
  static const Color urgentRed = Color(0xFFE53E3E);
  static const Color urgentRedLight = Color(0xFFFFF5F5);
  static const Color urgentRedGlow = Color(0x40E53E3E);
  static const Color watchAmber = Color(0xFFDD6B20);
  static const Color watchAmberLight = Color(0xFFFFFAF0);
  static const Color watchAmberGlow = Color(0x40DD6B20);
  static const Color routineGreen = Color(0xFF38A169);
  static const Color routineGreenLight = Color(0xFFF0FFF4);
  static const Color routineGreenGlow = Color(0x4038A169);

  // ─── Neutral Surface ────────────────────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF0F4F8);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color textDark = Color(0xFF1A202C);
  static const Color textMedium = Color(0xFF718096);
  static const Color textLight = Color(0xFFA0AEC0);

  // ─── Animation Durations ────────────────────────────────────────────────────
  static const Duration fastAnim = Duration(milliseconds: 180);
  static const Duration normalAnim = Duration(milliseconds: 300);
  static const Duration slowAnim = Duration(milliseconds: 550);

  // ─── Gradients ──────────────────────────────────────────────────────────────
  static const LinearGradient navyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryNavy, Color(0xFF0D3563), Color(0xFF114478)],
  );

  static const LinearGradient navyTealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryNavy, Color(0xFF0D3563), Color(0xFF0A5C6E)],
  );

  static const LinearGradient tealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentTeal, accentTealLight],
  );

  static LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryNavy, primaryNavyLight, accentTealDark.withValues(alpha: 0.85)],
    stops: const [0.0, 0.55, 1.0],
  );

  // ─── Glass Morphism ─────────────────────────────────────────────────────────
  static BoxDecoration glassMorphism({
    double opacity = 0.12,
    double borderOpacity = 0.2,
    double radius = 20,
    Color color = Colors.white,
  }) {
    return BoxDecoration(
      color: color.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: color.withValues(alpha: borderOpacity), width: 1),
    );
  }

  // ─── Card Shadow ────────────────────────────────────────────────────────────
  static List<BoxShadow> cardShadow({Color? color, double opacity = 0.06}) => [
    BoxShadow(
      color: (color ?? Colors.black).withValues(alpha: opacity),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: (color ?? Colors.black).withValues(alpha: opacity * 0.5),
      blurRadius: 6,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> glowShadow(Color color) => [
    BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 20, spreadRadius: 2),
    BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 40, spreadRadius: 4),
  ];

  // ─── Theme Data ─────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryNavy,
        primary: primaryNavy,
        secondary: accentTeal,
        surface: surfaceWhite,
        error: urgentRed,
      ),
      scaffoldBackgroundColor: backgroundLight,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: textDark),
        displayMedium: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: textDark),
        displaySmall: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: textDark),
        headlineMedium: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: textDark),
        bodyLarge: GoogleFonts.inter(fontSize: 15, color: textDark),
        bodyMedium: GoogleFonts.inter(fontSize: 13, color: textMedium),
        labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: textDark),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: cardBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryNavy,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF7F9FC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accentTeal, width: 2),
        ),
        labelStyle: GoogleFonts.inter(fontSize: 14, color: textMedium),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
