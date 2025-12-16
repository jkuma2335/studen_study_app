import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_app/core/widgets/modern_glass_card.dart';
import 'package:mobile_app/core/widgets/modern_card.dart';
import 'package:mobile_app/core/widgets/modern_button.dart';
import 'package:mobile_app/core/theme/app_palette.dart';
import 'package:mobile_app/core/providers/bottom_nav_provider.dart';
import 'package:mobile_app/features/dashboard/presentation/dashboard_provider.dart';
import 'package:mobile_app/features/subjects/presentation/providers/subject_provider.dart';
import 'package:mobile_app/features/assignments/presentation/providers/assignment_provider.dart';
import 'package:mobile_app/features/assignments/domain/assignment.dart';
import 'package:mobile_app/features/subjects/domain/subject.dart';
import 'package:mobile_app/features/planner/domain/study_session.dart';
import 'package:mobile_app/features/planner/presentation/planner_provider.dart';

class DashboardScreen extends HookConsumerWidget {
  const DashboardScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning, Scholar';
    } else if (hour < 17) {
      return 'Good Afternoon, Scholar';
    } else {
      return 'Good Evening, Scholar';
    }
  }

  Color _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return Colors.grey;
    }
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return AppPalette.lightAccent;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String? category) {
    if (category == null) return LucideIcons.bookOpen;
    switch (category) {
      case 'Mathematics':
        return LucideIcons.calculator;
      case 'Science':
        return LucideIcons.flaskConical;
      case 'Language':
        return LucideIcons.languages;
      case 'Arts':
        return LucideIcons.palette;
      case 'History':
        return LucideIcons.hourglass;
      case 'Computer Science':
        return LucideIcons.code;
      case 'Other':
        return LucideIcons.bookOpen;
      default:
        return LucideIcons.bookOpen;
    }
  }

  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
    // Navigate to Add Assignment Screen instead of showing dialog
    context.push('/assignments/add');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final subjectState = ref.watch(subjectProvider);
    final plannerState = ref.watch(plannerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progressAnimation = useAnimationController(
      duration: const Duration(milliseconds: 1200),
    );

    // Calculate daily goal progress (3 hours = 180 minutes)
    const dailyGoalMinutes = 180;
    final studyMinutesToday = dashboardAsync.maybeWhen(
      data: (stats) => stats.studyMinutesToday,
      orElse: () => 0,
    );
    final progress = (studyMinutesToday / dailyGoalMinutes).clamp(0.0, 1.0);

    // Get recent subject (mock: first subject or null)
    final recentSubject = subjectState.subjects.isNotEmpty
        ? subjectState.subjects.first
        : null;

    // Get today's planned sessions
    final todaySessions = plannerState.sessions.where((session) {
      if (session.startTime == null) return false;
      final sessionDate = DateTime(
        session.startTime!.year,
        session.startTime!.month,
        session.startTime!.day,
      );
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      return sessionDate.isAtSameMomentAs(todayDate) &&
          session.status == SessionStatus.planned;
    }).toList();

    final plannedHoursToday = todaySessions.fold<double>(
      0.0,
      (sum, session) => sum + (session.durationMinutes / 60.0),
    );

    // Animate progress ring on load
    useEffect(() {
      progressAnimation.forward();
      return null;
    }, []);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/assignments/add'),
        icon: const Icon(LucideIcons.plus),
        label: Text(
          'Add Task',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: dashboardAsync.when(
        data: (stats) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardProvider);
            ref.read(subjectProvider.notifier).loadSubjects();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ========== SECTION A: Header (Greeting & Progress) ==========
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _getGreeting(),
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 100.ms)
                          .slideY(begin: -0.1, end: 0),
                    ),
                    Row(
                      children: [
                        // Analytics Button
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          ),
                          child: IconButton(
                            onPressed: () => context.push('/home/analytics'),
                            icon: Icon(
                              LucideIcons.barChart3,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 150.ms)
                            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
                        const SizedBox(width: 8),
                        // Flashcards Button
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          ),
                          child: IconButton(
                            onPressed: () => context.push('/home/flashcards'),
                            icon: Icon(
                              LucideIcons.layers,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 175.ms)
                            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
                        const SizedBox(width: 8),
                        // Circular Profile Avatar (Placeholder)
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.primary,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            LucideIcons.user,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 24,
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 200.ms)
                            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Hero Card with Circular Progress Indicator - Modern Redesign
                GradientCard(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            AppPalette.darkPrimary,
                            AppPalette.darkPrimaryDark,
                            AppPalette.darkSecondary,
                          ]
                        : [
                            AppPalette.lightPrimary,
                            AppPalette.lightPrimaryDark,
                            AppPalette.lightSecondary,
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  padding: const EdgeInsets.all(28),
                  borderRadius: 24,
                  child: Row(
                    children: [
                      // Circular Percent Indicator with animation
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: progress),
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeOutCubic,
                        builder: (context, animatedProgress, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularPercentIndicator(
                                radius: 70.0,
                                lineWidth: 12.0,
                                percent: animatedProgress,
                                center: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$studyMinutesToday',
                                      style: GoogleFonts.poppins(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        height: 1.2,
                                      ),
                                    ),
                                    Text(
                                      'mins',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.white.withValues(alpha: 0.8),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                footer: Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    'Daily Goal: 3 hrs',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                progressColor: Colors.white,
                                backgroundColor: Colors.white.withValues(alpha: 0.25),
                                circularStrokeCap: CircularStrokeCap.round,
                                animation: false,
                              ),
                              // Glow effect
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withValues(alpha: 0.3 * animatedProgress),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(width: 28),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  LucideIcons.target,
                                  size: 18,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Today\'s Progress',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: GoogleFonts.poppins(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Complete',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    LucideIcons.clock,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      '${dailyGoalMinutes - studyMinutesToday} mins left',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 300.ms)
                    .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic)
                    .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: 600.ms, delay: 300.ms),
                const SizedBox(height: 32),

                // Directive Prompt (if planned sessions exist) - Modern Redesign
                if (plannedHoursToday > 0)
                  AnimatedModernCard(
                    padding: const EdgeInsets.all(20),
                    delay: 400.ms,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            LucideIcons.target,
                            color: Colors.white,
                            size: 24,
                          ),
                        )
                            .animate(onPlay: (controller) => controller.repeat())
                            .shimmer(
                              duration: 2000.ms,
                              color: Colors.white.withValues(alpha: 0.3),
                            )
                            .scale(
                              begin: const Offset(1, 1),
                              end: const Offset(1.05, 1.05),
                              duration: 1500.ms,
                              curve: Curves.easeInOut,
                            )
                            .then()
                            .scale(
                              begin: const Offset(1.05, 1.05),
                              end: const Offset(1, 1),
                              duration: 1500.ms,
                              curve: Curves.easeInOut,
                            ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'You planned ${plannedHoursToday.toStringAsFixed(1)} hours today',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).colorScheme.onSurface,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Let\'s begin your first session',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () {
                              context.push('/timer');
                            },
                            icon: const Icon(
                              LucideIcons.play,
                              color: Colors.white,
                            ),
                          ),
                        )
                            .animate(onPlay: (controller) => controller.repeat())
                            .slideX(
                              duration: 1000.ms,
                              begin: 0,
                              end: 4,
                              curve: Curves.easeInOut,
                            )
                            .then()
                            .slideX(
                              duration: 1000.ms,
                              begin: 4,
                              end: 0,
                              curve: Curves.easeInOut,
                            ),
                      ],
                    ),
                  ),
                // Primary action prompt if no planned sessions but has subjects - Modern Redesign
                if (plannedHoursToday == 0 && recentSubject != null)
                  AnimatedModernCard(
                    padding: const EdgeInsets.all(20),
                    delay: 400.ms,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.secondary,
                                Theme.of(context).colorScheme.secondary.withValues(alpha: 0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            LucideIcons.play,
                            color: Colors.white,
                            size: 24,
                          ),
                        )
                            .animate(onPlay: (controller) => controller.repeat())
                            .scale(
                              begin: const Offset(1, 1),
                              end: const Offset(1.1, 1.1),
                              duration: 1000.ms,
                              curve: Curves.easeInOut,
                            )
                            .then()
                            .scale(
                              begin: const Offset(1.1, 1.1),
                              end: const Offset(1, 1),
                              duration: 1000.ms,
                              curve: Curves.easeInOut,
                            ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Start today\'s first session',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).colorScheme.onSurface,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Continue with ${recentSubject.name}',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ModernElevatedButton(
                          onPressed: () {
                            context.push('/timer', extra: recentSubject);
                          },
                          padding: const EdgeInsets.all(12),
                          borderRadius: 14,
                          child: Icon(
                            LucideIcons.play,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (plannedHoursToday > 0 || (plannedHoursToday == 0 && recentSubject != null))
                  const SizedBox(height: 24),

                // ========== SECTION B: Quick Actions ==========
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quick Actions',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 500.ms)
                        .slideX(begin: -0.1, end: 0),
                  ],
                ),
                const SizedBox(height: 20),
                // Horizontal row of icon buttons - Modern Redesign
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _ModernQuickActionButton(
                        icon: LucideIcons.plus,
                        label: 'Add Task',
                        onTap: () => context.push('/assignments/add'),
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                          ],
                        ),
                        delay: 600.ms,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ModernQuickActionButton(
                        icon: LucideIcons.play,
                        label: 'Start Timer',
                        onTap: () {
                          if (recentSubject != null) {
                            context.push('/timer', extra: recentSubject);
                          } else {
                            context.push('/timer');
                          }
                        },
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.secondary,
                            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8),
                          ],
                        ),
                        delay: 650.ms,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ModernQuickActionButton(
                        icon: LucideIcons.calendar,
                        label: 'Calendar',
                        onTap: () => context.push('/calendar'),
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.tertiary ?? Theme.of(context).colorScheme.primary,
                            (Theme.of(context).colorScheme.tertiary ?? Theme.of(context).colorScheme.primary).withValues(alpha: 0.8),
                          ],
                        ),
                        delay: 700.ms,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // ========== SECTION C: "Up Next" (Horizontal Scroll) ==========
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Urgent Tasks',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (stats.recentAssignments.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          // Navigate to tasks tab (index 2)
                          ref.read(bottomNavIndexProvider.notifier).state = 2;
                        },
                        child: Text(
                          'See All',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (stats.recentAssignments.isEmpty)
                  ModernGlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            LucideIcons.checkCircle2,
                            size: 48,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No urgent tasks!',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: stats.recentAssignments.length,
                      itemBuilder: (context, index) {
                        final assignment = stats.recentAssignments[index];
                        final priorityColor = _getPriorityColor(assignment.priority);
                        final subjectColor = _parseColor(assignment.subject?.color);

                        return Container(
                          width: 280,
                          margin: const EdgeInsets.only(right: 12),
                          child: ModernGlassCard(
                            padding: EdgeInsets.zero,
                            onTap: () {
                              // Navigate to assignment detail
                              context.push(
                                '/assignments/details',
                                extra: assignment,
                              );
                            },
                            child: Row(
                              children: [
                                // Colored strip based on priority
                                Container(
                                  width: 4,
                                  decoration: BoxDecoration(
                                    color: priorityColor,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      bottomLeft: Radius.circular(16),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          assignment.title,
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        if (assignment.subject != null)
                                          Row(
                                            children: [
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: subjectColor,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                assignment.subject!.name,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormat('MMM dd, yyyy')
                                              .format(assignment.dueDate),
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: (600 + index * 100).ms)
                            .slideX(begin: 0.1, end: 0, curve: Curves.easeOut);
                      },
                    ),
                  ),
                const SizedBox(height: 32),

                // ========== SECTION C: "Continue Learning" - Modern Redesign ==========
                if (recentSubject != null)
                  AnimatedModernCard(
                    padding: const EdgeInsets.all(24),
                    delay: 800.ms,
                    onTap: () {
                      context.push(
                        '/subjects/details',
                        extra: recentSubject,
                      );
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _parseColor(recentSubject.color),
                                _parseColor(recentSubject.color).withValues(alpha: 0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: _parseColor(recentSubject.color).withValues(alpha: 0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(
                            _getCategoryIcon(recentSubject.category),
                            color: Colors.white,
                            size: 32,
                          ),
                        )
                            .animate(onPlay: (controller) => controller.repeat())
                            .shimmer(
                              duration: 2000.ms,
                              color: Colors.white.withValues(alpha: 0.4),
                            )
                            .scale(
                              begin: const Offset(1, 1),
                              end: const Offset(1.05, 1.05),
                              duration: 1500.ms,
                              curve: Curves.easeInOut,
                            )
                            .then()
                            .scale(
                              begin: const Offset(1.05, 1.05),
                              end: const Offset(1, 1),
                              duration: 1500.ms,
                              curve: Curves.easeInOut,
                            ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Resume ${recentSubject.name}',
                                style: GoogleFonts.poppins(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Continue where you left off',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ModernElevatedButton(
                          onPressed: () {
                            context.push(
                              '/timer',
                              extra: recentSubject,
                            );
                          },
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          borderRadius: 16,
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.play,
                                size: 18,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Start',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                if (recentSubject != null) const SizedBox(height: 32),

                // ========== SECTION D: Courses (Horizontal Scrollable Cards) ==========
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Courses',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 800.ms)
                        .slideX(begin: -0.1, end: 0),
                    const SizedBox(height: 4),
                    Text(
                      'Your running subjects',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 850.ms)
                        .slideX(begin: -0.1, end: 0),
                  ],
                ),
                const SizedBox(height: 20),
                if (subjectState.subjects.isEmpty)
                  ModernGlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            LucideIcons.library,
                            size: 48,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No subjects yet',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: subjectState.subjects.length,
                      itemBuilder: (context, index) {
                        final subject = subjectState.subjects[index];
                        final subjectColor = _parseColor(subject.color);

                        return Container(
                          width: 160,
                          margin: EdgeInsets.only(
                            right: index == subjectState.subjects.length - 1 ? 0 : 16,
                          ),
                          child: AnimatedModernCard(
                            padding: const EdgeInsets.all(20),
                            borderRadius: 24,
                            delay: (900 + index * 80).ms,
                            onTap: () {
                              context.push(
                                '/subjects/details',
                                extra: subject,
                              );
                            },
                            gradient: LinearGradient(
                              colors: [
                                subjectColor,
                                subjectColor.withValues(alpha: 0.85),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Icon at top center
                                Icon(
                                  _getCategoryIcon(subject.category),
                                  color: Colors.white,
                                  size: 64,
                                ),
                                const SizedBox(height: 20),
                                // Subject name centered below icon
                                Text(
                                  subject.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.alertCircle,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading dashboard',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(dashboardProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Animated Glass Card wrapper
class _AnimatedGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Duration delay;

  const _AnimatedGlassCard({
    required this.child,
    this.padding,
    this.onTap,
    Duration? delay,
  }) : delay = delay ?? const Duration(milliseconds: 0);

  @override
  Widget build(BuildContext context) {
    return ModernGlassCard(
      padding: padding,
      onTap: onTap,
      child: child,
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: delay)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
  }
}

// Button with glow effect on press
class _GlowButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;

  const _GlowButton({
    required this.onPressed,
    required this.child,
    this.style,
  });

  @override
  State<_GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<_GlowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.3 * _glowAnimation.value),
                  blurRadius: 8 * _glowAnimation.value,
                  spreadRadius: 2 * _glowAnimation.value,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: null, // Handled by GestureDetector
              style: (widget.style ?? ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              )).copyWith(
                backgroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

// Modern Quick Action Button with gradient
class _ModernQuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Gradient gradient;
  final Duration delay;

  const _ModernQuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.gradient,
    Duration? delay,
  }) : delay = delay ?? const Duration(milliseconds: 0);

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      onTap: onTap,
      borderRadius: 18,
      gradient: gradient,
      borderColor: Colors.white.withValues(alpha: 0.2),
      customShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 16,
          offset: const Offset(0, 6),
          spreadRadius: 0,
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: delay)
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          duration: 500.ms,
          delay: delay,
          curve: Curves.easeOutBack,
        );
  }
}

class _AddTaskDialog extends StatefulWidget {
  final List<Subject> subjects;
  final Function(String, String, DateTime, String) onSave;

  const _AddTaskDialog({
    required this.subjects,
    required this.onSave,
  });

  @override
  State<_AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<_AddTaskDialog> {
  late final TextEditingController _titleController;
  Subject? _selectedSubject;
  String _selectedPriority = 'Medium';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Color _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return Colors.grey;
    }
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
            'Add New Task',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
            ),
          ),
      content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subject Dropdown
                Text(
                  'Subject *',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<Subject?>(
                  initialValue: _selectedSubject,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  items: widget.subjects.map((subject) {
                    return DropdownMenuItem<Subject>(
                      value: subject,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _parseColor(subject.color),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            subject.name,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSubject = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Task Title
                Text(
                  'Task Title *',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Enter task title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                // Priority Dropdown
                Text(
                  'Priority',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedPriority,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  items: ['High', 'Medium', 'Low']
                      .map((priority) => DropdownMenuItem(
                            value: priority,
                            child: Text(
                              priority,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedPriority = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Due Date Picker
                Text(
                  'Due Date',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    DateFormat('MMM dd, yyyy').format(_selectedDate),
                    style: GoogleFonts.poppins(),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                ),
              ],
            ),
      ),
      actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Task title is required'),
                    ),
                  );
                  return;
                }

                if (_selectedSubject == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a subject'),
                    ),
                  );
                  return;
                }

                widget.onSave(
                  _selectedSubject!.id,
                  _titleController.text.trim(),
                  _selectedDate,
                  _selectedPriority,
                );
              },
              child: Text(
                'Save',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
      ],
    );
  }
}
