import 'package:flutter/material.dart';

/// Modern color palette for Light and Dark modes
/// Light Mode: Apple-style clean aesthetics
/// Dark Mode: Neon aesthetics with deep backgrounds
class AppPalette {
  // ========== LIGHT MODE COLORS ==========
  
  // Primary Colors (Deep Violet/Indigo)
  static const Color lightPrimary = Color(0xFF6366F1); // Indigo-500
  static const Color lightPrimaryDark = Color(0xFF4F46E5); // Indigo-600
  static const Color lightPrimaryLight = Color(0xFF818CF8); // Indigo-400
  
  // Secondary Colors (Neon Blue)
  static const Color lightSecondary = Color(0xFF06B6D4); // Cyan-500
  static const Color lightSecondaryDark = Color(0xFF0891B2); // Cyan-600
  static const Color lightSecondaryLight = Color(0xFF22D3EE); // Cyan-400
  
  // Accent Colors (Bright Coral/Orange for urgency)
  static const Color lightAccent = Color(0xFFFF6B6B); // Coral Red
  static const Color lightAccentDark = Color(0xFFEE5A6F);
  static const Color lightAccentLight = Color(0xFFFF8E8E);
  
  // Surface Colors (Very light grey)
  static const Color lightSurface = Color(0xFFFAFAFA);
  static const Color lightSurfaceVariant = Color(0xFFF5F5F5);
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF1F2937); // Dark grey
  static const Color lightOnSurfaceVariant = Color(0xFF6B7280); // Medium grey
  
  // Error & Success
  static const Color lightError = Color(0xFFEF4444);
  static const Color lightSuccess = Color(0xFF10B981);
  static const Color lightWarning = Color(0xFFF59E0B);
  
  // ========== DARK MODE COLORS ==========
  // Beautiful dark mode with rich, modern colors and excellent contrast
  
  // Primary Colors (Vibrant Indigo with glow effect)
  static const Color darkPrimary = Color(0xFF8B5CF6); // Vibrant Purple-Indigo
  static const Color darkPrimaryDark = Color(0xFF7C3AED); // Deeper purple
  static const Color darkPrimaryLight = Color(0xFFA78BFA); // Lighter purple-indigo
  
  // Secondary Colors (Bright Cyan with neon effect)
  static const Color darkSecondary = Color(0xFF06B6D4); // Bright Cyan
  static const Color darkSecondaryDark = Color(0xFF0891B2); // Deeper cyan
  static const Color darkSecondaryLight = Color(0xFF22D3EE); // Lighter cyan
  
  // Accent Colors (Vibrant Coral/Pink)
  static const Color darkAccent = Color(0xFFEC4899); // Vibrant Pink
  static const Color darkAccentDark = Color(0xFFDB2777);
  static const Color darkAccentLight = Color(0xFFF472B6);
  
  // Surface Colors (Rich dark backgrounds with subtle blue tint)
  static const Color darkSurface = Color(0xFF1A1F2E); // Rich dark blue-grey
  static const Color darkSurfaceVariant = Color(0xFF252B3D); // Slightly lighter for cards
  static const Color darkBackground = Color(0xFF0F1419); // Deepest background
  static const Color darkCard = Color(0xFF252B3D); // Card background with subtle elevation
  
  // Text Colors (High contrast for readability)
  static const Color darkOnPrimary = Color(0xFFFFFFFF); // White on primary
  static const Color darkOnSecondary = Color(0xFFFFFFFF); // White on secondary
  static const Color darkOnSurface = Color(0xFFE2E8F0); // Light grey-blue for text
  static const Color darkOnSurfaceVariant = Color(0xFF94A3B8); // Medium grey-blue for secondary text
  
  // Error & Success (Vibrant with good contrast)
  static const Color darkError = Color(0xFFF87171); // Soft red
  static const Color darkSuccess = Color(0xFF34D399); // Bright green
  static const Color darkWarning = Color(0xFFFBBF24); // Amber
  
  // ========== GRADIENT COLORS ==========
  
  // Light Mode Gradients
  static const LinearGradient lightPrimaryGradient = LinearGradient(
    colors: [lightPrimary, lightPrimaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient lightSecondaryGradient = LinearGradient(
    colors: [lightSecondary, lightSecondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Dark Mode Gradients (Vibrant neon effect)
  static const LinearGradient darkPrimaryGradient = LinearGradient(
    colors: [darkPrimary, darkPrimaryDark, Color(0xFF6D28D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkSecondaryGradient = LinearGradient(
    colors: [darkSecondary, darkSecondaryDark, Color(0xFF0E7490)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkAccentGradient = LinearGradient(
    colors: [darkAccent, darkAccentDark, Color(0xFFBE185D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // ========== SHADOW COLORS ==========
  
  static const Color lightShadow = Color(0x1A000000);
  static const Color darkShadow = Color(0x40000000);
  
  // ========== BORDER COLORS ==========
  
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color darkBorder = Color(0xFF3A4556); // Lighter border for better visibility in dark mode
}

