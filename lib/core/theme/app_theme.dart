import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFEF1826), // Red (from logo)
      primary: const Color(0xFFE81F28), // The nFactorial Red
      secondary: const Color(0xFF1E293B), // Dark slate
      surface: Colors.white,
      background: Colors.white,
      onBackground: const Color(0xFF0F172A), // Dark slate
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.white,
      fontFamily: GoogleFonts.outfit().fontFamily,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Color(0xFF0F172A),
      ),
    );
  }

  // Use the same bright, white theme for dark mode to force the "pure white background" requirement.
  // Alternatively, create a light-only app or provide a white dark mode.
  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFE81F28), // The nFactorial Red
      brightness: Brightness.light, // Force light mode to satisfy "pure white background everywhere"
      primary: const Color(0xFFE81F28),
      secondary: const Color(0xFF1E293B), 
      surface: Colors.white, 
      background: Colors.white, 
      onBackground: const Color(0xFF0F172A),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.white,
      fontFamily: GoogleFonts.outfit().fontFamily,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Color(0xFF0F172A),
      ),
    );
  }
}
