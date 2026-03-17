import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Professional Eco-System Palette ---
  static const Color primaryEmerald = Color(0xFF2ECC71); // Eco Green
  static const Color primaryGreen = Color(0xFF27AE60);
  static const Color secondaryGreen = Color(0xFF1E8449);
  static const Color secondarySlate = Color(0xFF2C3E50);
  static const Color accentIndigo = Color(0xFF5D6D7E);
  static const Color accentGreen = Color(0xFF2ECC71);

  // Waste Categories
  static const Color dryWaste = Color(0xFF3498DB);
  static const Color wetWaste = Color(0xFFE67E22); 
  static const Color ewaste = Color(0xFF9B59B6);

  // Backgrounds & Surfaces
  static const Color bgSurface = Color(0xFFF7F9F9);
  static const Color bgCanvas = Color(0xFFFFFFFF);
  static const Color bgDark = Color(0xFF1B2631);
  
  // Neutral Swatches (Slate/Earth)
  static const Color grey50 = Color(0xFFF8F9F9);
  static const Color grey100 = Color(0xFFEFF1F1);
  static const Color grey200 = Color(0xFFD5DBDB);
  static const Color grey300 = Color(0xFFABB2B9);
  static const Color grey400 = Color(0xFF808B96);
  static const Color grey500 = Color(0xFF566573);
  static const Color grey600 = Color(0xFF2E4053);
  static const Color grey700 = Color(0xFF283747);
  static const Color grey800 = Color(0xFF212F3C);
  static const Color grey900 = Color(0xFF1B2631);
  
  // Status & Actions
  static const Color success = Color(0xFF28B463);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);
  
  // Modern Linear Gradients
  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = emeraldGradient;

  static const LinearGradient slateGradient = LinearGradient(
    colors: [Color(0xFF2C3E50), Color(0xFF1B2631)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Soft Premium Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.02),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get intenseShadow => [
    BoxShadow(
      color: primaryEmerald.withValues(alpha: 0.2),
      blurRadius: 40,
      offset: const Offset(0, 20),
    ),
  ];

  static List<BoxShadow> get smoothShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 15,
      offset: const Offset(0, 5),
    ),
  ];

  // Professional Typography (Inter / Plus Jakarta Sans)
  static TextTheme get textTheme => TextTheme(
    displayLarge: GoogleFonts.inter(
      fontSize: 34,
      fontWeight: FontWeight.w800,
      color: grey900,
      letterSpacing: -1.2,
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      color: grey900,
      letterSpacing: -0.8,
    ),
    displaySmall: GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: grey900,
      letterSpacing: -0.5,
    ),
    headlineLarge: GoogleFonts.plusJakartaSans(
      fontSize: 22,
      fontWeight: FontWeight.w800,
      color: grey900,
      letterSpacing: -0.5,
    ),
    headlineMedium: GoogleFonts.plusJakartaSans(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: grey900,
    ),
    titleLarge: GoogleFonts.plusJakartaSans(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: grey900,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: grey800,
      height: 1.6,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: grey600,
      height: 1.5,
    ),
    labelLarge: GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w800,
      color: grey700,
      letterSpacing: 0.5,
    ),
  );

  // Theme Configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bgSurface,
      textTheme: textTheme,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryEmerald,
        primary: primaryEmerald,
        secondary: grey800,
        surface: bgCanvas,
        error: error,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: grey900,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: grey900,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: grey100, width: 1.5),
        ),
        color: bgCanvas,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryEmerald,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 0.5),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: grey800,
          side: const BorderSide(color: grey200, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgCanvas,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: grey100, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: grey100, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: primaryEmerald, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        hintStyle: GoogleFonts.inter(color: grey400, fontSize: 14, fontWeight: FontWeight.w500),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: bgCanvas,
        elevation: 0,
        indicatorColor: primaryEmerald.withValues(alpha: 0.1),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: primaryEmerald);
          }
          return GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: grey400);
        }),
      ),
    );
  }

  static ThemeData get darkTheme => lightTheme.copyWith(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDark,
  );

  // Reusable Component Helpers
  static Widget statusTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.1), width: 1),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // Radius
  static const double radiusS = 8.0;
  static const double radiusM = 16.0;
  static const double radiusL = 24.0;
  static const double radiusXL = 32.0;
}
