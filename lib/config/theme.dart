import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors - Palet warna yang lebih modern
  static const Color primaryColor = Color(0xFF4361EE); // Biru utama yang lebih cerah
  static const Color primaryColorLight = Color(0xFF4CC9F0);
  static const Color primaryColorDark = Color(0xFF3A0CA3);
  static const Color accentColor = Color(0xFF7209B7); // Aksen ungu
  static const Color textColor = Color(0xFF2B2D42);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFE63946);
  static const Color successColor = Color(0xFF06D6A0);
  static const Color warningColor = Color(0xFFFFD166);
  static const Color infoColor = Color(0xFF4CC9F0);
  static const Color secondaryTextColor = Color(0xFF6C757D);

  // Text Styles
  static TextStyle get headingLarge => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textColor,
      );

  static TextStyle get headingMedium => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textColor,
      );

  static TextStyle get headingSmall => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: textColor,
      );

  static TextStyle get subtitleLarge => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textColor,
      );

  static TextStyle get subtitleMedium => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      );

  static TextStyle get bodyLarge => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textColor,
      );

  static TextStyle get bodyMedium => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textColor,
      );

  static TextStyle get bodySmall => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: textColor,
      );

  static TextStyle get buttonText => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      );

  // ThemeData
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        error: errorColor,
        background: backgroundColor,
        surface: cardColor,
      ),
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: buttonText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          elevation: 3,
          shadowColor: primaryColor.withOpacity(0.3),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 2),
          textStyle: buttonText.copyWith(color: primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: buttonText.copyWith(color: primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        hintStyle: bodyMedium.copyWith(color: Colors.grey),
        labelStyle: bodyMedium.copyWith(color: textColor),
        prefixIconColor: primaryColor,
        suffixIconColor: primaryColor,
      ),
      textTheme: TextTheme(
        displayLarge: headingLarge,
        displayMedium: headingMedium,
        displaySmall: headingSmall,
        headlineMedium: subtitleLarge,
        headlineSmall: subtitleMedium,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
      ),
      dividerTheme: DividerThemeData(
        space: 24,
        thickness: 1,
        color: Colors.grey.withOpacity(0.2),
      ),
      iconTheme: const IconThemeData(
        color: primaryColor,
        size: 24,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey.withOpacity(0.6),
        selectedLabelStyle: bodySmall.copyWith(fontWeight: FontWeight.bold),
        unselectedLabelStyle: bodySmall,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 8,
      ),
    );
  }
}