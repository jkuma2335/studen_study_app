import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_palette.dart';

/// Modern theme configuration with Light and Dark modes
/// Uses Inter font family for clean, modern aesthetics
class AppTheme {
  // Main font family
  static final TextTheme _textTheme = GoogleFonts.interTextTheme();
  
  // ========== LIGHT THEME ==========
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: AppPalette.lightPrimary,
        onPrimary: AppPalette.lightOnPrimary,
        primaryContainer: AppPalette.lightPrimaryLight,
        onPrimaryContainer: AppPalette.lightOnPrimary,
        
        secondary: AppPalette.lightSecondary,
        onSecondary: AppPalette.lightOnSecondary,
        secondaryContainer: AppPalette.lightSecondaryLight,
        onSecondaryContainer: AppPalette.lightOnSecondary,
        
        tertiary: AppPalette.lightAccent,
        onTertiary: AppPalette.lightOnPrimary,
        
        error: AppPalette.lightError,
        onError: AppPalette.lightOnPrimary,
        
        surface: AppPalette.lightSurface,
        onSurface: AppPalette.lightOnSurface,
        surfaceContainerHighest: AppPalette.lightSurfaceVariant,
        onSurfaceVariant: AppPalette.lightOnSurfaceVariant,
        
        outline: AppPalette.lightBorder,
        shadow: AppPalette.lightShadow,
      ),
      
      // Typography
      textTheme: _textTheme.copyWith(
        displayLarge: _textTheme.displayLarge?.copyWith(
          color: AppPalette.lightOnSurface,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: _textTheme.displayMedium?.copyWith(
          color: AppPalette.lightOnSurface,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: _textTheme.displaySmall?.copyWith(
          color: AppPalette.lightOnSurface,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: _textTheme.headlineLarge?.copyWith(
          color: AppPalette.lightOnSurface,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: _textTheme.headlineMedium?.copyWith(
          color: AppPalette.lightOnSurface,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: _textTheme.headlineSmall?.copyWith(
          color: AppPalette.lightOnSurface,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: _textTheme.titleLarge?.copyWith(
          color: AppPalette.lightOnSurface,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: _textTheme.titleMedium?.copyWith(
          color: AppPalette.lightOnSurface,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: _textTheme.titleSmall?.copyWith(
          color: AppPalette.lightOnSurface,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: _textTheme.bodyLarge?.copyWith(
          color: AppPalette.lightOnSurface,
        ),
        bodyMedium: _textTheme.bodyMedium?.copyWith(
          color: AppPalette.lightOnSurface,
        ),
        bodySmall: _textTheme.bodySmall?.copyWith(
          color: AppPalette.lightOnSurfaceVariant,
        ),
        labelLarge: _textTheme.labelLarge?.copyWith(
          color: AppPalette.lightOnSurface,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: _textTheme.labelMedium?.copyWith(
          color: AppPalette.lightOnSurfaceVariant,
        ),
        labelSmall: _textTheme.labelSmall?.copyWith(
          color: AppPalette.lightOnSurfaceVariant,
        ),
      ),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppPalette.lightSurface,
        foregroundColor: AppPalette.lightOnSurface,
        titleTextStyle: _textTheme.titleLarge?.copyWith(
          color: AppPalette.lightOnSurface,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(
          color: AppPalette.lightOnSurface,
        ),
      ),
      
      // Card Theme (Rounded corners, slight elevation, glass effect)
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: AppPalette.lightCard,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // Input Decoration Theme (Rounded corners, no borders, soft fill)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.lightSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppPalette.lightPrimary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppPalette.lightError,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppPalette.lightError,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(
          color: AppPalette.lightOnSurfaceVariant,
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: AppPalette.lightPrimary,
          foregroundColor: AppPalette.lightOnPrimary,
          textStyle: _textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: AppPalette.lightPrimary,
        foregroundColor: AppPalette.lightOnPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppPalette.lightSurface,
        selectedItemColor: AppPalette.lightPrimary,
        unselectedItemColor: AppPalette.lightOnSurfaceVariant,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: _textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppPalette.lightSurfaceVariant,
        selectedColor: AppPalette.lightPrimary,
        labelStyle: _textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppPalette.lightBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }
  
  // ========== DARK THEME ==========
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color Scheme
      colorScheme: ColorScheme.dark(
        primary: AppPalette.darkPrimary,
        onPrimary: AppPalette.darkOnPrimary,
        primaryContainer: AppPalette.darkPrimaryLight,
        onPrimaryContainer: AppPalette.darkOnPrimary,
        
        secondary: AppPalette.darkSecondary,
        onSecondary: AppPalette.darkOnSecondary,
        secondaryContainer: AppPalette.darkSecondaryLight,
        onSecondaryContainer: AppPalette.darkOnSecondary,
        
        tertiary: AppPalette.darkAccent,
        onTertiary: AppPalette.darkOnPrimary,
        
        error: AppPalette.darkError,
        onError: AppPalette.darkOnPrimary,
        
        surface: AppPalette.darkSurface,
        onSurface: AppPalette.darkOnSurface,
        surfaceContainerHighest: AppPalette.darkSurfaceVariant,
        onSurfaceVariant: AppPalette.darkOnSurfaceVariant,
        
        outline: AppPalette.darkBorder,
        shadow: AppPalette.darkShadow,
      ),
      
      // Typography
      textTheme: _textTheme.copyWith(
        displayLarge: _textTheme.displayLarge?.copyWith(
          color: AppPalette.darkOnSurface,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: _textTheme.displayMedium?.copyWith(
          color: AppPalette.darkOnSurface,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: _textTheme.displaySmall?.copyWith(
          color: AppPalette.darkOnSurface,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: _textTheme.headlineLarge?.copyWith(
          color: AppPalette.darkOnSurface,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: _textTheme.headlineMedium?.copyWith(
          color: AppPalette.darkOnSurface,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: _textTheme.headlineSmall?.copyWith(
          color: AppPalette.darkOnSurface,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: _textTheme.titleLarge?.copyWith(
          color: AppPalette.darkOnSurface,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: _textTheme.titleMedium?.copyWith(
          color: AppPalette.darkOnSurface,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: _textTheme.titleSmall?.copyWith(
          color: AppPalette.darkOnSurface,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: _textTheme.bodyLarge?.copyWith(
          color: AppPalette.darkOnSurface,
        ),
        bodyMedium: _textTheme.bodyMedium?.copyWith(
          color: AppPalette.darkOnSurface,
        ),
        bodySmall: _textTheme.bodySmall?.copyWith(
          color: AppPalette.darkOnSurfaceVariant,
        ),
        labelLarge: _textTheme.labelLarge?.copyWith(
          color: AppPalette.darkOnSurface,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: _textTheme.labelMedium?.copyWith(
          color: AppPalette.darkOnSurfaceVariant,
        ),
        labelSmall: _textTheme.labelSmall?.copyWith(
          color: AppPalette.darkOnSurfaceVariant,
        ),
      ),
      
      // App Bar Theme (Subtle elevation with rich background)
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppPalette.darkSurface,
        foregroundColor: AppPalette.darkOnSurface,
        surfaceTintColor: Colors.transparent,
        shadowColor: AppPalette.darkPrimary.withOpacity(0.1),
        titleTextStyle: _textTheme.titleLarge?.copyWith(
          color: AppPalette.darkOnSurface,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(
          color: AppPalette.darkOnSurface,
          size: 24,
        ),
      ),
      
      // Card Theme (Rounded corners, elevated with subtle glow)
      cardTheme: CardThemeData(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: AppPalette.darkCard,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shadowColor: AppPalette.darkPrimary.withOpacity(0.2),
      ),
      
      // Input Decoration Theme (Rounded corners, subtle borders, rich fill)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.darkSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppPalette.darkBorder.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppPalette.darkBorder.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppPalette.darkPrimary,
            width: 2.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppPalette.darkError,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppPalette.darkError,
            width: 2.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: TextStyle(
          color: AppPalette.darkOnSurfaceVariant.withOpacity(0.7),
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: AppPalette.darkPrimary,
          foregroundColor: AppPalette.darkOnPrimary,
          textStyle: _textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 6,
        backgroundColor: AppPalette.darkPrimary,
        foregroundColor: AppPalette.darkOnPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Bottom Navigation Bar Theme (Rich background with vibrant selection)
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppPalette.darkSurface,
        selectedItemColor: AppPalette.darkPrimary,
        unselectedItemColor: AppPalette.darkOnSurfaceVariant.withOpacity(0.6),
        elevation: 12,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: _textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
        unselectedLabelStyle: _textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // Chip Theme (Vibrant selection with better contrast)
      chipTheme: ChipThemeData(
        backgroundColor: AppPalette.darkSurfaceVariant,
        selectedColor: AppPalette.darkPrimary,
        disabledColor: AppPalette.darkSurfaceVariant.withOpacity(0.5),
        labelStyle: _textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(
          color: AppPalette.darkBorder.withOpacity(0.3),
          width: 1,
        ),
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppPalette.darkBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }
}

