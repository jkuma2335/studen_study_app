import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_app/core/auth_state.dart';
import 'package:mobile_app/core/theme/theme_provider.dart';
import 'package:mobile_app/features/profile/user_provider.dart';
import 'package:mobile_app/core/widgets/modern_card.dart';
import 'package:mobile_app/core/widgets/modern_button.dart';

/// Profile Screen - Modern, clean design like Instagram/Duolingo
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userWithStatsAsync = ref.watch(userWithStatsProvider);
    final themeMode = ref.watch(themeModeProvider);
    
    // Determine if dark mode is currently active
    final isDark = themeMode == ThemeMode.dark || 
                   (themeMode == ThemeMode.system && 
                    MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: userWithStatsAsync.when(
        data: (data) {
          final user = data.user;
          final stats = data.stats;
          
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // ========== HEADER SECTION - Modern Redesign ==========
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Circular Avatar with Gradient Border and Edit Badge
                      Stack(
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.secondary,
                                  Theme.of(context).colorScheme.tertiary ?? Theme.of(context).colorScheme.primary,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                                  blurRadius: 24,
                                  spreadRadius: 4,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(4),
                            child: CircleAvatar(
                              radius: 66,
                              backgroundColor: Theme.of(context).colorScheme.surface,
                              child: user.avatarUrl != null
                                  ? ClipOval(
                                      child: Image.network(
                                        user.avatarUrl!,
                                        fit: BoxFit.cover,
                                        width: 132,
                                        height: 132,
                                      ),
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Theme.of(context).colorScheme.primary,
                                            Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        LucideIcons.user,
                                        size: 70,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 100.ms)
                              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 600.ms, delay: 100.ms),
                          // Edit Pencil Icon Badge - Modern Design
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.surface,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                LucideIcons.pencil,
                                size: 20,
                                color: Colors.white,
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 500.ms, delay: 300.ms)
                                .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), duration: 500.ms, delay: 300.ms, curve: Curves.elasticOut),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Name (Bold, Large) - Animated
                      Text(
                        user.name,
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 500.ms, delay: 200.ms)
                          .slideY(begin: -0.1, end: 0, delay: 200.ms),
                      const SizedBox(height: 8),
                      // Dynamic Title with Badge Design
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.award,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getUserTitle(stats.totalStudyHours),
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 500.ms, delay: 300.ms)
                          .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), delay: 300.ms),
                    ],
                  ),
                ),

                // ========== STATS ROW - Modern Redesign ==========
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: AnimatedModernCard(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    borderRadius: 24,
                    delay: 400.ms,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Streak 🔥 - Enhanced
                        _buildModernStatColumn(
                          context,
                          icon: LucideIcons.flame,
                          label: 'Streak',
                          value: '${stats.streakDays}',
                          color: Colors.orange,
                          delay: 500.ms,
                        ),
                        // Divider
                        Container(
                          width: 1.5,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        // Hours ⏳ - Enhanced
                        _buildModernStatColumn(
                          context,
                          icon: LucideIcons.clock,
                          label: 'Hours',
                          value: '${stats.totalStudyHours.toInt()}',
                          color: Theme.of(context).colorScheme.primary,
                          delay: 600.ms,
                        ),
                        // Divider
                        Container(
                          width: 1.5,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        // Tasks ✅ - Enhanced
                        _buildModernStatColumn(
                          context,
                          icon: LucideIcons.checkCircle2,
                          label: 'Tasks',
                          value: '${stats.tasksCompleted}',
                          color: Colors.green,
                          delay: 700.ms,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ========== MENU LIST (Settings) - Modern Redesign ==========
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      _buildModernMenuItem(
                        context,
                        icon: LucideIcons.user,
                        title: 'Account Settings',
                        iconColor: Theme.of(context).colorScheme.primary,
                        delay: 800.ms,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(LucideIcons.info, color: Colors.white),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Account Settings - Coming soon!',
                                    style: GoogleFonts.poppins(),
                                  ),
                                ],
                              ),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildModernMenuItem(
                        context,
                        icon: LucideIcons.palette,
                        title: 'Appearance',
                        subtitle: isDark ? 'Dark Mode' : 'Light Mode',
                        iconColor: Colors.purple,
                        delay: 850.ms,
                        trailing: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [Colors.purple, Colors.deepPurple]
                                  : [Colors.orange, Colors.deepOrange],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Switch(
                            value: isDark,
                            onChanged: (value) {
                              ref.read(themeModeProvider.notifier).toggleTheme();
                            },
                            activeColor: Colors.white,
                            inactiveThumbColor: Colors.white,
                          ),
                        ),
                        onTap: () {
                          ref.read(themeModeProvider.notifier).toggleTheme();
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildModernMenuItem(
                        context,
                        icon: LucideIcons.bell,
                        title: 'Notifications',
                        iconColor: Colors.blue,
                        delay: 900.ms,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(LucideIcons.info, color: Colors.white),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Notifications - Coming soon!',
                                    style: GoogleFonts.poppins(),
                                  ),
                                ],
                              ),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildModernMenuItem(
                        context,
                        icon: LucideIcons.helpCircle,
                        title: 'Help & Support',
                        iconColor: Colors.teal,
                        delay: 950.ms,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(LucideIcons.info, color: Colors.white),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Help & Support - Coming soon!',
                                    style: GoogleFonts.poppins(),
                                  ),
                                ],
                              ),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // ========== LOG OUT BUTTON - Modern Redesign ==========
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ModernElevatedButton(
                    onPressed: () {
                      _showLogoutDialog(context, ref);
                    },
                    backgroundColor: Colors.red.withValues(alpha: 0.15),
                    borderRadius: 20,
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            LucideIcons.logOut,
                            size: 20,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Log Out',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 1000.ms)
                      .slideY(begin: 0.1, end: 0, delay: 1000.ms),
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.alertCircle,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load profile',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(userWithStatsProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build a modern stat column with gradient icon and animations
  Widget _buildModernStatColumn(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Duration delay,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color,
                color.withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 24,
            color: Colors.white,
          ),
        )
            .animate()
            .fadeIn(duration: 500.ms, delay: delay)
            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 500.ms, delay: delay, curve: Curves.elasticOut),
        const SizedBox(height: 12),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: delay + 100.ms)
            .slideY(begin: 0.1, end: 0, delay: delay + 100.ms),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: delay + 200.ms),
      ],
    );
  }

  /// Build a modern menu item with gradient icon and animations
  Widget _buildModernMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required Color iconColor,
    Widget? trailing,
    required Duration delay,
    required VoidCallback onTap,
  }) {
    return AnimatedModernCard(
      padding: EdgeInsets.zero,
      borderRadius: 18,
      delay: delay,
      onTap: onTap,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                iconColor,
                iconColor.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: iconColor.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 20,
            color: Colors.white,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
            letterSpacing: -0.2,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              )
            : null,
        trailing: trailing ??
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }

  /// Show logout confirmation dialog
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Log Out',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Logout user (clears token and sets state to false)
              ref.read(authProvider.notifier).logout();
              // Navigate to login screen
              context.go('/login');
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(
              'Log Out',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get user title based on total study hours (gamification)
  String _getUserTitle(double totalHours) {
    if (totalHours >= 200) {
      return 'Master';
    } else if (totalHours >= 100) {
      return 'Researcher';
    } else if (totalHours >= 50) {
      return 'Scholar';
    } else if (totalHours >= 25) {
      return 'Student';
    } else if (totalHours >= 10) {
      return 'Learner';
    } else {
      return 'Beginner';
    }
  }
}

