import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_app/core/theme/app_palette.dart';
import 'package:mobile_app/core/widgets/modern_button.dart';
import 'package:mobile_app/core/widgets/modern_card.dart';

/// Splash/Onboarding Screen - First screen users see
/// Shows SmartStudy logo, app name, tagline, and sign in/sign up buttons
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppPalette.darkBackground,
                    AppPalette.darkSurface,
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppPalette.lightBackground,
                    AppPalette.lightSurface,
                  ],
                ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                // SmartStudy Logo with modern card container
                Center(
                  child: AnimatedModernCard(
                    padding: const EdgeInsets.all(24),
                    borderRadius: 32,
                    backgroundColor: isDark
                        ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6)
                        : Colors.white.withValues(alpha: 0.9),
                    customShadows: [
                      BoxShadow(
                        color: (isDark ? AppPalette.darkPrimary : AppPalette.lightPrimary)
                            .withValues(alpha: 0.2),
                        blurRadius: 30,
                        spreadRadius: -5,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    child: const SmartStudyLogo(),
                    delay: 200.ms,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 200.ms)
                    .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 600.ms, delay: 200.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 32),
                // App Name
                Text(
                  'SmartStudy',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppPalette.darkOnSurface
                        : AppPalette.lightOnSurface,
                    letterSpacing: -1,
                    height: 1.2,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 400.ms)
                    .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 400.ms, curve: Curves.easeOutCubic),
                const SizedBox(height: 12),
                // Tagline
                Text(
                  'Organize. Focus. Ace.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppPalette.darkOnSurfaceVariant
                        : AppPalette.lightOnSurfaceVariant,
                    letterSpacing: 1,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 600.ms)
                    .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 600.ms, curve: Curves.easeOutCubic),
                const Spacer(flex: 3),
                // Sign In Button
                ModernElevatedButton(
                  gradient: isDark
                      ? AppPalette.darkPrimaryGradient
                      : AppPalette.lightPrimaryGradient,
                  onPressed: () => context.push('/login'),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  borderRadius: 18,
                  child: Text(
                    'Sign In',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 800.ms)
                    .slideY(begin: 0.3, end: 0, duration: 600.ms, delay: 800.ms, curve: Curves.easeOutBack)
                    .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: 600.ms, delay: 800.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 16),
                // Sign Up Button (Outlined with modern styling)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark
                          ? AppPalette.darkPrimary
                          : AppPalette.lightPrimary,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? AppPalette.darkPrimary : AppPalette.lightPrimary)
                            .withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => context.push('/signup'),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            'Sign Up',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppPalette.darkPrimary
                                  : AppPalette.lightPrimary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 1000.ms)
                    .slideY(begin: 0.3, end: 0, duration: 600.ms, delay: 1000.ms, curve: Curves.easeOutBack)
                    .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: 600.ms, delay: 1000.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// SmartStudy Logo Widget
/// Uses the actual logo image asset
class SmartStudyLogo extends StatelessWidget {
  const SmartStudyLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Image.asset(
        'assets/images/smartstudy_logo.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback if image is not found
          return const Icon(
            Icons.school,
            size: 100,
            color: Colors.grey,
          );
        },
      ),
    );
  }
}

