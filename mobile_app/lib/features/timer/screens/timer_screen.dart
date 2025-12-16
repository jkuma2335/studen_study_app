import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:mobile_app/features/subjects/domain/subject.dart';
import 'package:mobile_app/features/subjects/presentation/providers/subject_provider.dart';
import 'package:mobile_app/features/timer/presentation/providers/timer_provider.dart';
import 'package:mobile_app/features/planner/presentation/planner_provider.dart';
import 'package:mobile_app/features/planner/domain/study_session.dart' as planner;
import 'package:mobile_app/core/widgets/modern_card.dart';
import 'package:mobile_app/core/widgets/modern_button.dart';

class TimerScreen extends HookConsumerWidget {
  final Subject? subject;
  final planner.StudySession? plannerSession; // Planner session being tracked
  const TimerScreen({super.key, this.subject, this.plannerSession});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Load subjects when screen opens
    useEffect(() {
      // Wrap provider modifications in Future to avoid modifying during build
      Future.microtask(() {
        final subjectNotifier = ref.read(subjectProvider.notifier);
        subjectNotifier.loadSubjects();
        
        // If planner session is provided, initialize timer with it
        if (plannerSession != null) {
          final session = plannerSession!;
          final timerNotifier = ref.read(timerProvider.notifier);
          timerNotifier.initializeFromPlanner(
            subjectId: session.subjectId,
            plannerSessionId: session.id,
            durationMinutes: session.durationMinutes,
            autoStart: true, // Auto-start when coming from planner
          );
          
          // Mark session as IN_PROGRESS
          final plannerNotifier = ref.read(plannerProvider.notifier);
          plannerNotifier.updateSessionStatus(
            session.id,
            planner.SessionStatus.inProgress,
          );
        } else if (subject != null) {
          // Legacy: Set subject if provided
          final timerNotifier = ref.read(timerProvider.notifier);
          timerNotifier.setSubject(subject!.id);
        }
      });
      return null;
    }, []);

    return _TimerScreenContent(
      subject: subject,
      plannerSession: plannerSession,
    );
  }
}

class _TimerScreenContent extends HookConsumerWidget {
  final Subject? subject;
  final planner.StudySession? plannerSession;
  
  const _TimerScreenContent({
    this.subject,
    this.plannerSession,
  });

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final subjectState = ref.watch(subjectProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedSubject = subjectState.subjects.firstWhere(
      (s) => s.id == timerState.selectedSubjectId,
      orElse: () => subjectState.subjects.isNotEmpty
          ? subjectState.subjects.first
          : Subject(
              id: '',
              name: 'No Subject',
              color: '#6366F1',
              studyGoalHours: 0,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
    );
    final subjectColor = _parseColor(selectedSubject.color);
    final textColor = _getLegibleTextColor(subjectColor, context);
    
    // Calculate progress (0.0 to 1.0)
    const initialSeconds = 1500; // 25 minutes
    final progress = 1.0 - (timerState.timeLeft / initialSeconds);
    
    // Animation controller for pulsing effect when running
    final pulseAnimation = useAnimationController(
      duration: const Duration(seconds: 2),
    );
    
    useEffect(() {
      if (timerState.isRunning) {
        pulseAnimation.repeat(reverse: true);
      } else {
        pulseAnimation.stop();
        pulseAnimation.reset();
      }
      return null;
    }, [timerState.isRunning]);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Study Timer',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                  ]
                : [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                
                // Modern Circular Timer with Progress
                AnimatedBuilder(
                  animation: pulseAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: timerState.isRunning
                            ? [
                                BoxShadow(
                                  color: subjectColor.withValues(
                                    alpha: 0.15 + (0.1 * pulseAnimation.value),
                                  ),
                                  blurRadius: 20 + (10 * pulseAnimation.value),
                                  spreadRadius: 2.0,
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: CircularPercentIndicator(
                        radius: 140,
                        lineWidth: 16,
                        percent: progress.clamp(0.0, 1.0),
                        center: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _formatTime(timerState.timeLeft),
                              style: GoogleFonts.poppins(
                                fontSize: 56,
                                fontWeight: FontWeight.bold,
                                color: timerState.isRunning
                                    ? textColor
                                    : Theme.of(context).colorScheme.onSurface,
                                height: 1.1,
                                letterSpacing: -2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: timerState.isRunning
                                    ? subjectColor.withValues(alpha: 0.15)
                                    : Colors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: timerState.isRunning
                                          ? subjectColor
                                          : Colors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                      .animate(onPlay: (controller) {
                                        if (timerState.isRunning) {
                                          controller.repeat();
                                        }
                                      })
                                      .scale(
                                        begin: const Offset(1, 1),
                                        end: const Offset(1.3, 1.3),
                                        duration: 1000.ms,
                                        curve: Curves.easeInOut,
                                      )
                                      .then()
                                      .scale(
                                        begin: const Offset(1.3, 1.3),
                                        end: const Offset(1, 1),
                                        duration: 1000.ms,
                                        curve: Curves.easeInOut,
                                      ),
                                  const SizedBox(width: 6),
                                  Text(
                                    timerState.isRunning ? 'Focusing' : 'Ready',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: timerState.isRunning
                                          ? textColor
                                          : Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        progressColor: timerState.isRunning
                            ? subjectColor
                            : Theme.of(context).colorScheme.primary,
                        backgroundColor: timerState.isRunning
                            ? subjectColor.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.1),
                        circularStrokeCap: CircularStrokeCap.round,
                        animation: false,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .scale(
                          begin: const Offset(0.9, 0.9),
                          end: const Offset(1, 1),
                          duration: 600.ms,
                          curve: Curves.easeOutBack,
                        );
                  },
                ),
                const SizedBox(height: 48),

                // Subject Selector - Modern Design
                if (!timerState.isRunning)
                  AnimatedModernCard(
                    padding: EdgeInsets.zero,
                    borderRadius: 20,
                    delay: 200.ms,
                    child: DropdownButtonFormField<String>(
                      value: timerState.selectedSubjectId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Select Subject',
                        labelStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(20),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(12),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            LucideIcons.bookOpen,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      items: subjectState.subjects
                          .map((subject) => DropdownMenuItem(
                                value: subject.id,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            _parseColor(subject.color),
                                            _parseColor(subject.color).withValues(alpha: 0.8),
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: _parseColor(subject.color).withValues(alpha: 0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 200),
                                      child: Text(
                                        subject.name,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        ref.read(timerProvider.notifier).setSubject(value);
                      },
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  )
                else
                  AnimatedModernCard(
                    padding: const EdgeInsets.all(20),
                    borderRadius: 20,
                    delay: 200.ms,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                subjectColor,
                                subjectColor.withValues(alpha: 0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: subjectColor.withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            LucideIcons.bookOpen,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Studying',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                selectedSubject.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                  letterSpacing: -0.3,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const SizedBox(height: 6),
                              // Expanded details (Goal & Streak)
                              Wrap(
                                spacing: 10,
                                runSpacing: 4,
                                children: [
                                  if (selectedSubject.studyGoalHours > 0)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(LucideIcons.target, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Goal: ${selectedSubject.studyGoalHours.toStringAsFixed(1)} h',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(LucideIcons.flame, size: 14, color: Colors.orange),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Streak: ${selectedSubject.streak}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (selectedSubject.difficulty != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _parseColor(selectedSubject.color).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: _parseColor(selectedSubject.color).withValues(alpha: 0.3),
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Text(
                                        selectedSubject.difficulty!,
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 48),

                // Control Buttons - Modern Design
                if (!timerState.isRunning)
                  ModernElevatedButton(
                    onPressed: timerState.selectedSubjectId == null
                        ? null
                        : () {
                            HapticFeedback.mediumImpact();
                            ref.read(timerProvider.notifier).startTimer();
                          },
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    borderRadius: 20,
                    gradient: timerState.selectedSubjectId != null
                        ? LinearGradient(
                            colors: [
                              subjectColor,
                              subjectColor.withValues(alpha: 0.8),
                            ],
                          )
                        : null,
                    backgroundColor: timerState.selectedSubjectId == null
                        ? Colors.grey
                        : null,
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.play,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Start Focus',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 400.ms)
                      .slideY(begin: 0.1, end: 0, delay: 400.ms)
                else
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: ModernElevatedButton(
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            ref.read(timerProvider.notifier).stopTimer();
                          },
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 18,
                          ),
                          borderRadius: 20,
                          gradient: LinearGradient(
                            colors: [
                              subjectColor,
                              subjectColor.withValues(alpha: 0.85),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.pause,
                                color: Colors.white,
                                size: 22,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Pause',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: OutlinedButton(
                          onPressed: () async {
                            HapticFeedback.mediumImpact();
                            final timerNotifier = ref.read(timerProvider.notifier);
                            final elapsedTime = timerNotifier.elapsedTimeSeconds;

                            // Confirmation Dialog logic
                             showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(
                                    'Finish Session?',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: Text(
                                    elapsedTime < 60 
                                      ? 'This session is less than 1 minute and won\'t be saved.'
                                      : 'Are you sure you want to finish this study session?',
                                    style: GoogleFonts.poppins(),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        'Resume',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        // Save Logic
                                        if (elapsedTime >= 60) {
                                           try {
                                            final timerState = ref.read(timerProvider);
                                            if (timerState.plannerSessionId != null) {
                                              final plannerNotifier = ref.read(plannerProvider.notifier);
                                              await plannerNotifier.updateSessionStatus(
                                                timerState.plannerSessionId!,
                                                planner.SessionStatus.completed,
                                              );
                                            } else {
                                              await timerNotifier.saveSession();
                                            }
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Session Saved!', style: GoogleFonts.poppins()),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            // Handle error
                                          }
                                        } else {
                                           timerNotifier.resetTimer();
                                        }
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: Text(
                                        'Finish',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.checkCircle,
                                color: Theme.of(context).colorScheme.onSurface,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Finish',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 400.ms)
                      .slideY(begin: 0.1, end: 0, delay: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  Color _getLegibleTextColor(Color color, BuildContext context) {
    // If we are in dark mode, light colors usually look fine.
    // If we are in light mode, light colors (like yellow) are unreadable.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (isDark) {
       // On dark background, ensure color isn't too dark
       if (color.computeLuminance() < 0.2) {
         return Colors.white; 
       }
       return color;
    } else {
      // On light background, if color is light, darken it
      if (color.computeLuminance() > 0.5) {
        return HSLColor.fromColor(color).withLightness(0.35).toColor();
      }
      return color;
    }
  }
}

