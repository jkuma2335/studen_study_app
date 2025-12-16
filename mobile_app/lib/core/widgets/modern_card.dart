import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Modern Card with enhanced glassmorphism and animations
class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? borderColor;
  final double borderRadius;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final List<BoxShadow>? customShadows;
  final Gradient? gradient;
  final bool enableHover;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderColor,
    this.borderRadius = 20,
    this.onTap,
    this.backgroundColor,
    this.customShadows,
    this.gradient,
    this.enableHover = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: gradient,
        color: gradient == null
            ? (backgroundColor ??
                (isDark
                    ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8)
                    : theme.colorScheme.surface.withValues(alpha: 0.9)))
            : null,
        border: Border.all(
          color: borderColor ??
              (isDark
                  ? theme.colorScheme.outline.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.03)),
          width: isDark ? 1.5 : 1.5,
        ),
        boxShadow: customShadows ??
            [
              if (isDark)
                // Dark mode: Rich shadows with subtle primary color glow
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: -2,
                ),
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.5)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: isDark ? 30 : 24,
                offset: const Offset(0, 10),
                spreadRadius: isDark ? -4 : 0,
              ),
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: isDark ? 12 : 8,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          highlightColor: theme.colorScheme.primary.withValues(alpha: 0.05),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Animated Card that fades and slides in
class AnimatedModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? borderColor;
  final double borderRadius;
  final VoidCallback? onTap;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final Gradient? gradient;
  final Color? backgroundColor;
  final List<BoxShadow>? customShadows;

  const AnimatedModernCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderColor,
    this.borderRadius = 20,
    this.onTap,
    this.delay = const Duration(milliseconds: 0),
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
    this.gradient,
    this.backgroundColor,
    this.customShadows,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      borderColor: borderColor,
      borderRadius: borderRadius,
      onTap: onTap,
      gradient: gradient,
      backgroundColor: backgroundColor,
      customShadows: customShadows,
      child: child,
    )
        .animate()
        .fadeIn(duration: duration, delay: delay, curve: curve)
        .slideY(begin: 0.1, end: 0, duration: duration, delay: delay, curve: curve)
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: duration,
          delay: delay,
          curve: curve,
        );
  }
}

/// Gradient Card with modern styling
class GradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Gradient gradient;
  final double borderRadius;
  final VoidCallback? onTap;

  const GradientCard({
    super.key,
    required this.child,
    required this.gradient,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      onTap: onTap,
      gradient: gradient,
      borderColor: Colors.white.withValues(alpha: 0.2),
      customShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 20,
          offset: const Offset(0, 10),
          spreadRadius: 0,
        ),
      ],
      child: child,
    );
  }
}

