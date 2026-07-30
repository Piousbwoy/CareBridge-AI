import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Primary Luxury Palette
  static const Color primaryNavy = Color(0xFF0F2027); // Deep Midnight Blue
  static const Color primaryNavyLight = Color(0xFF203A43);
  static const Color primaryNavyDark = Color(0xFF0B141B);
  
  static const Color accentTeal = Color(0xFF00A896); // Vibrant Emerald Teal
  static const Color accentTealGlow = Color(0xFF02C39A);
  static const Color accentGold = Color(0xFFD4AF37); // Royal Gold accent
  static const Color accentGoldLight = Color(0xFFFFF8E7);
  
  static const Color urgentRed = Color(0xFFE53E3E);
  static const Color urgentRedLight = Color(0xFFFFF5F5);
  static const Color watchAmber = Color(0xFFDD6B20);
  static const Color watchAmberLight = Color(0xFFFFFAF0);
  static const Color routineGreen = Color(0xFF2F855A);
  static const Color routineGreenLight = Color(0xFFF0FFF4);
  
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color cardBorderSubtle = Color(0xFFEDF2F7);
  
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMedium = Color(0xFF475569);
  static const Color textLight = Color(0xFF94A3B8);

  // Gradients
  static const LinearGradient luxuryHeaderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
  );

  static const LinearGradient heroCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A2540), Color(0xFF133E68), Color(0xFF00A896)],
  );

  static const LinearGradient tealButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00A896), Color(0xFF02C39A)],
  );

  static const LinearGradient goldAccentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD4AF37), Color(0xFFF4D03F)],
  );

  // Shadows
  static final List<BoxShadow> luxuryShadow = [
    BoxShadow(color: const Color(0xFF0A2540).withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 6)),
    BoxShadow(color: const Color(0xFF0A2540).withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 1)),
  ];

  static final List<BoxShadow> cardShadow = [
    BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 3)),
  ];

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
        displayLarge: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: textDark, letterSpacing: -0.5),
        displayMedium: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: textDark, letterSpacing: -0.3),
        displaySmall: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: textDark),
        headlineMedium: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: textDark),
        bodyLarge: GoogleFonts.inter(fontSize: 15, color: textDark, height: 1.5),
        bodyMedium: GoogleFonts.inter(fontSize: 13, color: textMedium, height: 1.4),
        labelLarge: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: textDark),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0,
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
          textStyle: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
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
