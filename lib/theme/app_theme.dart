import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized design system for Trippies.
/// Official palette: White, Pink #F2B5D3, Baby Blue #A5B4FC, Dark Blue #45464E
class AppTheme {
  AppTheme._();

  // ── Core Palette ──────────────────────────────────────────────────────────
  static const Color white = Colors.white;
  static const Color pink = Color(0xFFF2B5D3);
  static const Color babyBlue = Color(0xFFA5B4FC);
  static const Color darkBlue = Color(0xFF45464E);

  // ── Extended Palette (derived from core) ──────────────────────────────────
  static const Color background = Color(0xFFF9F9F7);
  static const Color lavender = Color(0xFFB8A9D0);
  static const Color softPink = Color(0xFFF3B6D1);
  static const Color cardBg = Color(0xFFF0EEFB);
  static const Color navyLegacy = Color(0xFF1A1A2E); // only for deep contrast
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color surface = Color(0xFFF5F5F0);

  // ── Radius ────────────────────────────────────────────────────────────────
  static const double radiusSm = 12.0;
  static const double radiusMd = 20.0;
  static const double radiusLg = 24.0;
  static const double radiusXl = 30.0;

  // ── Shadows ───────────────────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get buttonShadow => [
        BoxShadow(
          color: darkBlue.withValues(alpha: 0.15),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ];

  // ── Text Styles ───────────────────────────────────────────────────────────
  static TextStyle get headingLg => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: darkBlue,
      );

  static TextStyle get headingMd => GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: darkBlue,
      );

  static TextStyle get headingSm => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: darkBlue,
      );

  static TextStyle get titleMd => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: darkBlue,
      );

  static TextStyle get bodyLg => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: darkBlue,
        height: 1.5,
      );

  static TextStyle get bodyMd => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: darkBlue,
        height: 1.5,
      );

  static TextStyle get bodySm => GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      );

  static TextStyle get labelSm => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textSecondary,
        letterSpacing: 1.0,
      );

  static TextStyle get caption => GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: textTertiary,
      );

  static TextStyle get buttonText => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: white,
      );

  static TextStyle get appBarTitle => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: navyLegacy,
      );

  // ── Input Decoration ──────────────────────────────────────────────────────
  static InputDecoration inputDecoration({
    required String hint,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        color: const Color(0xFFBDBDBD),
        fontSize: 14,
      ),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: textSecondary, size: 20)
          : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: babyBlue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  // ── Button Styles ─────────────────────────────────────────────────────────
  static ButtonStyle get primaryButton => ElevatedButton.styleFrom(
        backgroundColor: pink,
        foregroundColor: darkBlue,
        elevation: 4,
        shadowColor: pink.withValues(alpha: 0.35),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      );

  static ButtonStyle get secondaryButton => OutlinedButton.styleFrom(
        foregroundColor: darkBlue,
        side: const BorderSide(color: divider, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      );

  static ButtonStyle get accentButton => ElevatedButton.styleFrom(
        backgroundColor: babyBlue,
        foregroundColor: darkBlue,
        elevation: 4,
        shadowColor: babyBlue.withValues(alpha: 0.35),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      );

  // ── Full Theme Data ───────────────────────────────────────────────────────
  static ThemeData get themeData => ThemeData(
        scaffoldBackgroundColor: background,
        primaryColor: pink,
        colorScheme: ColorScheme.light(
          primary: pink,
          secondary: babyBlue,
          surface: white,
          onPrimary: darkBlue,
          onSecondary: darkBlue,
          onSurface: darkBlue,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: appBarTitle,
          iconTheme: const IconThemeData(color: babyBlue),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButton),
        outlinedButtonTheme: OutlinedButtonThemeData(style: secondaryButton),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: babyBlue, width: 1.5),
          ),
        ),
        cardTheme: CardThemeData(
          color: white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: white,
          selectedItemColor: pink,
          unselectedItemColor: const Color(0xFF76767F),
          showUnselectedLabels: true,
          elevation: 10,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
        ),
        textTheme: TextTheme(
          headlineLarge: headingLg,
          headlineMedium: headingMd,
          headlineSmall: headingSm,
          titleMedium: titleMd,
          bodyLarge: bodyLg,
          bodyMedium: bodyMd,
          bodySmall: bodySm,
          labelSmall: labelSm,
        ),
      );

  // ── Helper: Network Image with Error Handling ─────────────────────────────
  static Widget networkImage({
    required String url,
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    BorderRadius? borderRadius,
  }) {
    final isNetwork = url.startsWith('http');

    Widget image;
    if (isNetwork) {
      image = Image.network(
        url,
        fit: fit,
        width: width,
        height: height,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: surface,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: babyBlue,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: surface,
            child: const Center(
              child: Icon(Icons.image_not_supported_outlined,
                  color: textTertiary, size: 32),
            ),
          );
        },
      );
    } else if (url.isNotEmpty) {
      image = Image.asset(
        url,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: surface,
            child: const Center(
              child: Icon(Icons.image_not_supported_outlined,
                  color: textTertiary, size: 32),
            ),
          );
        },
      );
    } else {
      image = Container(
        width: width,
        height: height,
        color: surface,
        child: const Center(
          child: Icon(Icons.image_outlined, color: textTertiary, size: 32),
        ),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius, child: image);
    }
    return image;
  }

  // ── Helper: Network Image Provider ─────────────────────────────────────────
  static ImageProvider networkImageProvider(String url) {
    if (url.startsWith('http')) {
      return NetworkImage(url);
    } else if (url.isNotEmpty) {
      return AssetImage(url);
    }
    return const AssetImage('assets/images/placeholder.png');
  }
}
