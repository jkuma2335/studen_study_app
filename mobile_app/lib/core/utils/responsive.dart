import 'package:flutter/material.dart';

/// Responsive utility class for handling different screen sizes
class Responsive {
  static double width(BuildContext context) => MediaQuery.of(context).size.width;
  static double height(BuildContext context) => MediaQuery.of(context).size.height;
  
  /// Screen size breakpoints
  static bool isMobile(BuildContext context) => width(context) < 600;
  static bool isTablet(BuildContext context) => width(context) >= 600 && width(context) < 1024;
  static bool isDesktop(BuildContext context) => width(context) >= 1024;
  
  /// Small phone detection (less than 360dp width)
  static bool isSmallPhone(BuildContext context) => width(context) < 360;
  
  /// Get responsive value based on screen size
  static T value<T>(BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }
  
  /// Get responsive font size
  static double fontSize(BuildContext context, double baseFontSize) {
    final screenWidth = width(context);
    if (screenWidth < 320) return baseFontSize * 0.8;
    if (screenWidth < 360) return baseFontSize * 0.9;
    if (screenWidth < 400) return baseFontSize * 0.95;
    return baseFontSize;
  }
  
  /// Get responsive padding
  static double padding(BuildContext context, {double base = 20}) {
    final screenWidth = width(context);
    if (screenWidth < 320) return base * 0.6;
    if (screenWidth < 360) return base * 0.7;
    if (screenWidth < 400) return base * 0.85;
    return base;
  }
  
  /// Get responsive horizontal padding
  static EdgeInsets horizontalPadding(BuildContext context, {double base = 20}) {
    return EdgeInsets.symmetric(horizontal: padding(context, base: base));
  }
  
  /// Get responsive spacing
  static double spacing(BuildContext context, {double base = 16}) {
    return padding(context, base: base);
  }
  
  /// Get safe area with additional padding
  static EdgeInsets safeArea(BuildContext context, {double additional = 0}) {
    final mediaQuery = MediaQuery.of(context);
    return EdgeInsets.only(
      top: mediaQuery.padding.top + additional,
      bottom: mediaQuery.padding.bottom + additional,
      left: mediaQuery.padding.left + additional,
      right: mediaQuery.padding.right + additional,
    );
  }
}

/// Extension for responsive sizing on numbers
extension ResponsiveExtension on num {
  /// Scale value based on screen width (base: 375 - iPhone X)
  double sw(BuildContext context) {
    return this * MediaQuery.of(context).size.width / 375;
  }
  
  /// Scale value based on screen height (base: 812 - iPhone X)
  double sh(BuildContext context) {
    return this * MediaQuery.of(context).size.height / 812;
  }
}
