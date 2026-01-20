import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App Theme Configuration
/// "Medical Trust" Palette & Design System
class AppTheme {
  // --- Color Palette ---
  
  // Primary (Medical Blue) - Headers, Primary Buttons, Active States
  static const Color primaryColor = Color(0xFF1E40AF);
  
  // Secondary (Brand Blue) - Links, icons, subtle accents
  static const Color secondaryColor = Color(0xFF3B82F6);
  
  // Success (Health Green) - Success badges, "Notes Generated" status
  static const Color successColor = Color(0xFF059669);
  
  // Alert (Warning Orange) - Stop buttons, recording indicators
  static const Color warningColor = Color(0xFFF97316);
  
  // Error (Red) - Critical errors (Standard choice, distinct from warning)
  static const Color errorColor = Color(0xFFEF4444);
  
  // Background (Soft Gray) - Main app background (under cards)
  static const Color backgroundColor = Color(0xFFF8FAFC);
  
  // Surface (White) - Cards, input fields, modals
  static const Color surfaceColor = Color(0xFFFFFFFF);
  
  // Text (Primary) - Main headings and body text
  static const Color textPrimary = Color(0xFF1F2937);
  
  // Text (Secondary) - Subtitles, timestamps, captions
  static const Color textSecondary = Color(0xFF6B7280);

  // --- Shadows ---
  static List<BoxShadow> get shadowElevation1 => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowElevation2 => [
    BoxShadow(
      color: const Color(0xFF1E40AF).withOpacity(0.1),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  /// Light Theme
  static ThemeData get lightTheme {
    final base = ThemeData.light();
    
    return base.copyWith(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onBackground: textPrimary,
      ),

      // Typography
      textTheme: TextTheme(
        // Headings: Poppins (Geometric Sans-Serif)
        displayLarge: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 32,
          color: textPrimary,
        ),
        displayMedium: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 28,
          color: textPrimary,
        ),
        displaySmall: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 24,
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: textPrimary,
        ),
        
        // Body: Inter (Humanist Sans-Serif)
        bodyLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w400,
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: textPrimary, // Default body color
        ),
        bodySmall: GoogleFonts.inter(
          fontWeight: FontWeight.w400,
          fontSize: 12,
          color: textSecondary,
        ),
        labelLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w500, // Medium emphasis
          fontSize: 14,
          color: Colors.white,
        ),
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white, // Modern Clean Look
        foregroundColor: textPrimary,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),

      // Card Theme (Standard for all content cards: 12px)
      cardTheme: CardThemeData(
        elevation: 0, // Using manual shadows often looks better, or use low elevation
        color: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade100), // Subtle border
        ),
        margin: EdgeInsets.zero,
      ),

      // Button Theme (8px)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondaryColor,
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: Color(0xFFE5E7EB)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.inter(
             fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Input Fields (8px)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        hintStyle: GoogleFonts.inter(
          color: textSecondary,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.inter(
          color: textSecondary,
          fontSize: 14,
        ),
      ),

      // Floating Action Button (999px / Circle)
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: secondaryColor, // Or Alert depending on context
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(), // 999px effectively
      ),

      // Navigation Bar (Modern)
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Divider
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE5E7EB),
        thickness: 1,
      ),

      // Chips/Pills (999px)
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF3F4F6),
        labelStyle: GoogleFonts.inter(
           fontSize: 13,
           fontWeight: FontWeight.w500,
           color: textPrimary,
        ),
        shape: const StadiumBorder(), // 999px
        side: BorderSide.none,
      ),
    );
  }

  /// Dark Theme (Optional Placeholder - Design specs focused on Light)
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
       // Basic dark implementation matching light specs where possible
       primaryColor: primaryColor,
       scaffoldBackgroundColor: const Color(0xFF111827),
       colorScheme: const ColorScheme.dark(
         primary: primaryColor,
         secondary: secondaryColor,
         surface: Color(0xFF1F2937),
         background: Color(0xFF111827),
       ),
    );
  }
}
