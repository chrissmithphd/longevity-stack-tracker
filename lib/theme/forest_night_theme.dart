import 'package:flutter/material.dart';

/// Forest Night - A calm, biologically grounded dark mode theme
class ForestNightTheme {
  // Private constructor to prevent instantiation
  ForestNightTheme._();

  // ========================================
  // COLOR PALETTE
  // ========================================

  // Backgrounds
  static const Color primaryBackground = Color(0xFF1A2419);
  static const Color secondaryBackground = Color(0xFF242F23);
  static const Color tertiaryBackground = Color(0xFF2E3A2D);

  // Text
  static const Color primaryText = Color(0xFFE8EDE7);
  static const Color secondaryText = Color(0xFF9FAB9D);
  static const Color tertiaryText = Color(0xFF6B7569);

  // Accent Colors
  static const Color completed = Color(0xFF5A8A5F); // Soft moss green
  static const Color skipped = Color(0xFF8F8775);   // Warm stone
  static const Color pending = Color(0xFF4A6B6F);   // Muted teal
  static const Color active = Color(0xFF7A9C6A);    // Living green

  // Supporting
  static const Color successBackground = Color(0xFF2D4032);
  static const Color warningBackground = Color(0xFF3D3A2F);
  static const Color errorSurface = Color(0xFF4A3533);

  // ========================================
  // SPACING SYSTEM
  // ========================================

  static const double space1 = 4.0;
  static const double space2 = 8.0;
  static const double space3 = 12.0;
  static const double space4 = 16.0;
  static const double space6 = 24.0;
  static const double space8 = 32.0;
  static const double space12 = 48.0;

  // ========================================
  // BORDER RADIUS
  // ========================================

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusFull = 999.0;

  // ========================================
  // THEME DATA
  // ========================================

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // ========================================
      // COLOR SCHEME
      // ========================================
      colorScheme: ColorScheme.dark(
        primary: active,
        onPrimary: primaryText,
        secondary: completed,
        onSecondary: primaryText,
        tertiary: pending,
        onTertiary: primaryText,
        surface: secondaryBackground,
        onSurface: primaryText,
        surfaceContainerHighest: tertiaryBackground,
        error: Color(0xFFCF6679),
        onError: primaryText,
        outline: tertiaryBackground,
        shadow: Colors.black.withOpacity(0.1),
      ),

      scaffoldBackgroundColor: primaryBackground,

      // ========================================
      // APP BAR
      // ========================================
      appBarTheme: AppBarTheme(
        backgroundColor: secondaryBackground,
        foregroundColor: primaryText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: primaryText,
          letterSpacing: 0.3,
        ),
        shadowColor: Colors.black.withOpacity(0.05),
      ),

      // ========================================
      // CARD
      // ========================================
      cardTheme: CardThemeData(
        color: secondaryBackground,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          side: BorderSide(
            color: tertiaryBackground,
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),

      // ========================================
      // ELEVATED BUTTON
      // ========================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: completed.withOpacity(0.15),
          foregroundColor: completed,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: space4, vertical: space3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall),
          ),
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ========================================
      // TEXT BUTTON
      // ========================================
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondaryText,
          padding: EdgeInsets.symmetric(horizontal: space4, vertical: space3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall),
          ),
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ========================================
      // OUTLINED BUTTON
      // ========================================
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryText,
          side: BorderSide(color: tertiaryBackground, width: 1),
          padding: EdgeInsets.symmetric(horizontal: space4, vertical: space3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall),
          ),
        ),
      ),

      // ========================================
      // ICON THEME
      // ========================================
      iconTheme: IconThemeData(
        color: secondaryText,
        size: 20,
      ),

      // ========================================
      // TYPOGRAPHY
      // ========================================
      textTheme: TextTheme(
        // Headings
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: primaryText,
          letterSpacing: 0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: primaryText,
          letterSpacing: 0.5,
        ),
        displaySmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: primaryText,
          letterSpacing: 0.3,
        ),

        // Titles
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: primaryText,
          letterSpacing: 0.3,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: primaryText,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: primaryText,
        ),

        // Body
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: primaryText,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: primaryText,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: secondaryText,
          height: 1.4,
        ),

        // Labels
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: primaryText,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: secondaryText,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: tertiaryText,
        ),
      ),

      // ========================================
      // DIVIDER
      // ========================================
      dividerTheme: DividerThemeData(
        color: tertiaryBackground,
        thickness: 1,
        space: space4,
      ),

      // ========================================
      // BOTTOM NAVIGATION BAR
      // ========================================
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: secondaryBackground,
        selectedItemColor: active,
        unselectedItemColor: secondaryText,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // ========================================
      // SNACKBAR
      // ========================================
      snackBarTheme: SnackBarThemeData(
        backgroundColor: tertiaryBackground,
        contentTextStyle: TextStyle(
          color: primaryText,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ========================================
  // SHADOWS
  // ========================================

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get cardShadowHover => [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get headerShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static BoxShadow completedGlow = BoxShadow(
    color: completed.withOpacity(0.08),
    blurRadius: 8,
    offset: Offset(0, 2),
  );

  static BoxShadow activeGlow = BoxShadow(
    color: active.withOpacity(0.1),
    blurRadius: 12,
    offset: Offset(0, 2),
  );
}
