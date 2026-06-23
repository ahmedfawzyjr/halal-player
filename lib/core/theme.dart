// Halal Player - Theme System
//
// Light and Dark theme definitions with toggle support

import 'package:flutter/material.dart';

/// App themes
class AppThemes {
  AppThemes._();

  // Colors
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF2A2A2A);
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Color(0xFFFFFFFF);

  /// Dark theme (default)
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          brightness: Brightness.dark,
          surface: darkSurface,
        ),
        scaffoldBackgroundColor: darkBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: darkSurface,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: darkSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.white12),
          ),
        ),
        navigationRailTheme: NavigationRailThemeData(
          backgroundColor: darkSurface,
          selectedIconTheme: const IconThemeData(color: primaryGreen),
          unselectedIconTheme: IconThemeData(color: Colors.grey[400]),
          indicatorColor: primaryGreen.withValues(alpha: 0.2),
        ),
        dividerTheme: const DividerThemeData(color: Colors.white12),
        sliderTheme: SliderThemeData(
          activeTrackColor: primaryGreen,
          thumbColor: primaryGreen,
          inactiveTrackColor: Colors.grey[700],
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? primaryGreen
                  : Colors.grey),
          trackColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? primaryGreen.withValues(alpha: 0.5)
                  : Colors.grey[700]),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: primaryGreen,
          contentTextStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          behavior: SnackBarBehavior.floating,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: darkSurface,
          selectedItemColor: primaryGreen,
          unselectedItemColor: Colors.grey,
          elevation: 8,
        ),
      );

  /// Light theme
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          brightness: Brightness.light,
          surface: lightSurface,
        ),
        scaffoldBackgroundColor: lightBackground,
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Color(0xFF1A1A1A)),
          displayMedium: TextStyle(color: Color(0xFF1A1A1A)),
          displaySmall: TextStyle(color: Color(0xFF1A1A1A)),
          headlineLarge: TextStyle(color: Color(0xFF1A1A1A)),
          headlineMedium: TextStyle(color: Color(0xFF1A1A1A)),
          headlineSmall: TextStyle(color: Color(0xFF1A1A1A)),
          titleLarge: TextStyle(color: Color(0xFF1A1A1A)),
          titleMedium: TextStyle(color: Color(0xFF1A1A1A)),
          titleSmall: TextStyle(color: Color(0xFF1A1A1A)),
          bodyLarge: TextStyle(color: Color(0xFF1A1A1A)),
          bodyMedium: TextStyle(color: Color(0xFF1A1A1A)),
          bodySmall: TextStyle(color: Color(0xFF424242)),
          labelLarge: TextStyle(color: Color(0xFF1A1A1A)),
          labelMedium: TextStyle(color: Color(0xFF1A1A1A)),
          labelSmall: TextStyle(color: Color(0xFF424242)),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: lightSurface,
          foregroundColor: Colors.grey[900],
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: lightSurface,
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        navigationRailTheme: NavigationRailThemeData(
          backgroundColor: lightSurface,
          selectedIconTheme: const IconThemeData(color: primaryGreen),
          unselectedIconTheme: IconThemeData(color: Colors.grey[600]),
          indicatorColor: primaryGreen.withValues(alpha: 0.2),
        ),
        dividerTheme: DividerThemeData(color: Colors.grey[300]),
        sliderTheme: SliderThemeData(
          activeTrackColor: primaryGreen,
          thumbColor: primaryGreen,
          inactiveTrackColor: Colors.grey[300],
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? primaryGreen
                  : Colors.grey),
          trackColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? primaryGreen.withValues(alpha: 0.5)
                  : Colors.grey[300]),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.grey[800],
            side: BorderSide(color: Colors.grey[400]!),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: primaryGreen,
          contentTextStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          behavior: SnackBarBehavior.floating,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: lightSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: lightSurface,
          selectedItemColor: primaryGreen,
          unselectedItemColor: Colors.grey[600],
          elevation: 8,
        ),
      );
}
