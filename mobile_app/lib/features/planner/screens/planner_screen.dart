import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart' as calendar_view;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_app/features/planner/presentation/planner_provider.dart';
import 'package:mobile_app/features/planner/domain/study_session.dart';
import 'package:mobile_app/features/subjects/presentation/providers/subject_provider.dart';
import 'package:mobile_app/features/subjects/domain/subject.dart';
import 'package:mobile_app/core/widgets/modern_card.dart';
import 'package:mobile_app/core/widgets/modern_button.dart';

class PlannerScreen extends HookConsumerWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = useState<String>('Daily');
    final selectedDate = useState<DateTime>(DateTime.now());
    final plannerState = ref.watch(plannerProvider);
    final plannerNotifier = ref.read(plannerProvider.notifier);

    // Load week on initial build
    // Wrapped in Future to avoid modifying provider during build
    useEffect(() {
      Future(() {
        plannerNotifier.loadWeek(selectedDate.value);
      });
      return null;
    }, []);

    // Get the event controller from the provider
    final calendarControllerProvider = calendar_view.CalendarControllerProvider.of(context);
    final eventController = calendarControllerProvider.controller;

    // Convert sessions to calendar events and update controller
    useEffect(() {
      // Clear existing events
      eventController.removeWhere((_) => true);
      
      // Add new events
      for (final session in plannerState.sessions) {
        if (session.startTime != null) {
          eventController.add(
            calendar_view.CalendarEventData(
              date: session.startTime!,
              title: session.title ?? session.subject?.name ?? 'Study Session',
              description: '${session.durationMinutes} min',
              event: session,
              color: _parseColor(session.color),
            ),
          );
        }
      }
      
      return null;
    }, [plannerState.sessions]);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Planner',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: _ModernViewToggleButton(
                    label: 'Daily',
                    icon: LucideIcons.calendar,
                    isSelected: viewMode.value == 'Daily',
                    onTap: () => viewMode.value = 'Daily',
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 100.ms)
                      .slideX(begin: -0.1, end: 0, delay: 100.ms),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ModernViewToggleButton(
                    label: 'Weekly',
                    icon: LucideIcons.calendarDays,
                    isSelected: viewMode.value == 'Weekly',
                    onTap: () => viewMode.value = 'Weekly',
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 200.ms)
                      .slideX(begin: 0.1, end: 0, delay: 200.ms),
                ),
              ],
            ),
          ),
        ),
      ),
      body: plannerState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : plannerState.error != null
              ? Center(
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
                        'Error loading planner',
                        style: GoogleFonts.poppins(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        plannerState.error!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          plannerNotifier.loadWeek(selectedDate.value);
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : viewMode.value == 'Daily'
                  ? _DailyTimelineView(
                      selectedDate: selectedDate.value,
                      sessions: plannerState.sessions,
                      onDateTap: (date) {
                        selectedDate.value = date;
                        plannerNotifier.loadWeek(date);
                      },
                      onSessionTap: (session) => _showSessionDetails(context, session),
                    )
                  : calendar_view.WeekView(
                      controller: eventController,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      headerStyle: calendar_view.HeaderStyle(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        headerTextStyle: GoogleFonts.poppins(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        leftIconConfig: calendar_view.IconDataConfig(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        rightIconConfig: calendar_view.IconDataConfig(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      weekDayBuilder: (date) {
                        final isToday = date.day == DateTime.now().day &&
                            date.month == DateTime.now().month &&
                            date.year == DateTime.now().year;
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                ['M', 'T', 'W', 'T', 'F', 'S', 'S'][date.weekday - 1],
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isToday
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: isToday
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${date.day}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                                      color: isToday
                                          ? Colors.white
                                          : Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      weekNumberBuilder: (firstDayOfWeek) {
                        final weekNumber = _getWeekNumber(firstDayOfWeek);
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text(
                            '$weekNumber',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      },
                      hourIndicatorSettings: calendar_view.HourIndicatorSettings(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      liveTimeIndicatorSettings: calendar_view.LiveTimeIndicatorSettings(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      eventTileBuilder: (date, events, boundry, start, end) {
                        if (events.isEmpty) return const SizedBox.shrink();
                        final event = events.first;
                        final session = event.event as StudySession?;
                        if (session == null) return const SizedBox.shrink();

                        return _EventTile(
                          session: session,
                          onTap: () => _showSessionDetails(context, session),
                        );
                      },
                      onDateTap: (date) {
                        selectedDate.value = date;
                        plannerNotifier.loadWeek(date);
                      },
                      onEventTap: (events, date) {
                        if (events.isNotEmpty) {
                          final session = events.first.event as StudySession?;
                          if (session != null) {
                            _showSessionDetails(context, session);
                          }
                        }
                      },
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickAddSheet(context, selectedDate.value),
        icon: const Icon(LucideIcons.plus),
        label: Text(
          'Add Session',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 500.ms, delay: 300.ms)
          .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), delay: 300.ms),
    );
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  int _getWeekNumber(DateTime date) {
    // ISO week number calculation
    final dayOfYear = int.parse(DateFormat('D').format(date));
    final weekday = date.weekday;
    return ((dayOfYear - weekday + 10) / 7).floor();
  }

  void _showSessionDetails(BuildContext context, StudySession session) {
    // If session is PLANNED, show "Start this session?" sheet
    if (session.status == SessionStatus.planned) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _StartSessionSheet(session: session),
      );
    } else {
      // For other statuses, show regular details sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _SessionDetailsSheet(session: session),
      );
    }
  }

  void _showQuickAddSheet(BuildContext context, DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _QuickAddSheet(initialDate: date),
    );
  }
}

class _ModernViewToggleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModernViewToggleButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                      ],
                    )
                  : null,
              color: isSelected ? null : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                width: isSelected ? 0 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 15,
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final StudySession session;
  final VoidCallback onTap;

  const _EventTile({
    required this.session,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(session.color);
    final statusColor = _getStatusColor(session.status);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.25),
                color.withValues(alpha: 0.15),
              ],
            ),
            border: Border.all(
              color: color,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withValues(alpha: 0.7)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.6),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      session.title ?? session.subject?.name ?? 'Study Session',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: color,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Status indicator
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withValues(alpha: 0.6),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    LucideIcons.clock,
                    size: 10,
                    color: color.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${session.durationMinutes} min',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: 300.ms);
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  Color _getStatusColor(SessionStatus status) {
    switch (status) {
      case SessionStatus.completed:
        return Colors.green;
      case SessionStatus.inProgress:
        return Colors.orange;
      case SessionStatus.planned:
        return Colors.blue;
      case SessionStatus.skipped:
        return Colors.grey;
    }
  }
}

class _StartSessionSheet extends ConsumerWidget {
  final StudySession session;

  const _StartSessionSheet({required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _parseColor(session.color);
    final plannerNotifier = ref.read(plannerProvider.notifier);

    return AnimatedModernCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 28,
      margin: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  LucideIcons.play,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Start this session?',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 100.ms)
              .slideY(begin: -0.1, end: 0, delay: 100.ms),
          const SizedBox(height: 16),
          Text(
            session.title ?? session.subject?.name ?? 'Study Session',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (session.subject != null) ...[
            const SizedBox(height: 8),
            Text(
              'Subject: ${session.subject!.name}',
              style: GoogleFonts.poppins(),
            ),
          ],
          if (session.startTime != null) ...[
            const SizedBox(height: 8),
            Text(
              'Time: ${DateFormat('MMM dd, yyyy • hh:mm a').format(session.startTime!)}',
              style: GoogleFonts.poppins(),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Duration: ${session.durationMinutes} minutes',
            style: GoogleFonts.poppins(),
          ),
          const SizedBox(height: 24),
          ModernElevatedButton(
            onPressed: () async {
              // Mark session as IN_PROGRESS
              await plannerNotifier.updateSessionStatus(
                session.id,
                SessionStatus.inProgress,
              );
              
              if (context.mounted) {
                Navigator.pop(context);
                
                // Navigate to TimerScreen with planner session
                context.push('/timer', extra: session);
              }
            },
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.8)],
            ),
            borderRadius: 18,
            padding: const EdgeInsets.symmetric(vertical: 18),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.play,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  'Start Focusing',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .slideY(begin: 0.1, end: 0, delay: 200.ms),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              await plannerNotifier.updateSessionStatus(
                session.id,
                SessionStatus.skipped,
              );
              if (context.mounted) Navigator.pop(context);
            },
            icon: const Icon(LucideIcons.x),
            label: Text(
              'Skip',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 250.ms)
              .slideY(begin: 0.1, end: 0, delay: 250.ms),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }
}

class _SessionDetailsSheet extends ConsumerWidget {
  final StudySession session;

  const _SessionDetailsSheet({required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _parseColor(session.color);
    final plannerNotifier = ref.read(plannerProvider.notifier);

    return AnimatedModernCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 28,
      margin: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  LucideIcons.calendar,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  session.title ?? session.subject?.name ?? 'Study Session',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 100.ms)
              .slideY(begin: -0.1, end: 0, delay: 100.ms),
          const SizedBox(height: 16),
          if (session.subject != null)
            Text(
              'Subject: ${session.subject!.name}',
              style: GoogleFonts.poppins(),
            ),
          if (session.startTime != null) ...[
            const SizedBox(height: 8),
            Text(
              'Time: ${DateFormat('MMM dd, yyyy • hh:mm a').format(session.startTime!)}',
              style: GoogleFonts.poppins(),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Duration: ${session.durationMinutes} minutes',
            style: GoogleFonts.poppins(),
          ),
          const SizedBox(height: 8),
          Text(
            'Status: ${_getStatusText(session.status)}',
            style: GoogleFonts.poppins(),
          ),
          const SizedBox(height: 24),
          if (session.status == SessionStatus.inProgress)
            ModernElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.push('/timer', extra: session);
              },
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.8)],
              ),
              borderRadius: 18,
              padding: const EdgeInsets.symmetric(vertical: 18),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.play,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Continue Timer',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            )
              .animate()
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .slideY(begin: 0.1, end: 0, delay: 200.ms)
          else if (session.status == SessionStatus.planned)
            ModernElevatedButton(
              onPressed: () async {
                await plannerNotifier.updateSessionStatus(
                  session.id,
                  SessionStatus.inProgress,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  context.push('/timer', extra: session);
                }
              },
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.8)],
              ),
              borderRadius: 18,
              padding: const EdgeInsets.symmetric(vertical: 18),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.play,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Start Timer',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            )
              .animate()
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .slideY(begin: 0.1, end: 0, delay: 200.ms),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.2, end: 0);
  }

  String _getStatusText(SessionStatus status) {
    switch (status) {
      case SessionStatus.planned:
        return 'Planned';
      case SessionStatus.inProgress:
        return 'In Progress';
      case SessionStatus.completed:
        return 'Completed';
      case SessionStatus.skipped:
        return 'Skipped';
    }
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }
}

class _QuickAddSheet extends HookConsumerWidget {
  final DateTime initialDate;

  const _QuickAddSheet({required this.initialDate}) : super();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleController = useTextEditingController();
    final selectedSubject = useState<Subject?>(null);
    final startTime = useState<TimeOfDay>(
      TimeOfDay.fromDateTime(initialDate),
    );
    final endTime = useState<TimeOfDay>(
      TimeOfDay.fromDateTime(
        initialDate.add(const Duration(minutes: 25)),
      ),
    );
    final repeatMode = useState<String>('None');
    final selectedDays = useState<List<int>>([]);

    final subjectState = ref.watch(subjectProvider);
    final plannerNotifier = ref.read(plannerProvider.notifier);

    return AnimatedModernCard(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      borderRadius: 28,
      margin: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  LucideIcons.plus,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                'Quick Add Session',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 100.ms)
              .slideY(begin: -0.1, end: 0, delay: 100.ms),
          const SizedBox(height: 24),
          // Title field
          TextField(
            controller: titleController,
            style: GoogleFonts.poppins(),
            decoration: InputDecoration(
              labelText: 'What to study?',
              hintText: 'Enter session title',
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  LucideIcons.bookOpen,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 150.ms)
              .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 150.ms),
          const SizedBox(height: 16),
          // Subject dropdown
          DropdownButtonFormField<Subject?>(
            initialValue: selectedSubject.value,
            style: GoogleFonts.poppins(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              labelText: 'Subject',
              hintText: 'Select a subject',
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  LucideIcons.folder,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            ),
            items: subjectState.subjects.map((subject) {
              return DropdownMenuItem<Subject>(
                value: subject,
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _parseColor(subject.color),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _parseColor(subject.color).withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      subject.name,
                      style: GoogleFonts.poppins(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) => selectedSubject.value = value,
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 200.ms),
          const SizedBox(height: 20),
          // Time pickers - Modern Design
          Row(
            children: [
              Expanded(
                child: _ModernTimePicker(
                  label: 'Start Time',
                  time: startTime.value,
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: startTime.value,
                    );
                    if (picked != null) {
                      startTime.value = picked;
                    }
                  },
                  delay: 250.ms,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ModernTimePicker(
                  label: 'End Time',
                  time: endTime.value,
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: endTime.value,
                    );
                    if (picked != null) {
                      endTime.value = picked;
                    }
                  },
                  delay: 300.ms,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Repeat toggle - Modern Design
          Text(
            'Repeat?',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 350.ms),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ModernRepeatChip(
                  label: 'None',
                  icon: LucideIcons.x,
                  isSelected: repeatMode.value == 'None',
                  onSelected: () => repeatMode.value = 'None',
                  delay: 400.ms,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ModernRepeatChip(
                  label: 'Daily',
                  icon: LucideIcons.repeat,
                  isSelected: repeatMode.value == 'Daily',
                  onSelected: () => repeatMode.value = 'Daily',
                  delay: 450.ms,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ModernRepeatChip(
                  label: 'Weekly',
                  icon: LucideIcons.calendar,
                  isSelected: repeatMode.value == 'Weekly',
                  onSelected: () => repeatMode.value = 'Weekly',
                  delay: 500.ms,
                ),
              ),
            ],
          ),
          // Weekly days selector
          if (repeatMode.value == 'Weekly') ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (int i = 1; i <= 7; i++)
                  _ModernDayChip(
                    day: _getDayName(i),
                    isSelected: selectedDays.value.contains(i),
                    onSelected: (selected) {
                      final newDays = List<int>.from(selectedDays.value);
                      if (selected) {
                        newDays.add(i);
                      } else {
                        newDays.remove(i);
                      }
                      selectedDays.value = newDays;
                    },
                    delay: (500 + (i * 50)).ms,
                  ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          // Save button
          ModernElevatedButton(
            onPressed: () async {
              try {
                if (selectedSubject.value == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a subject'),
                    ),
                  );
                  return;
                }

                final startDateTime = DateTime(
                  initialDate.year,
                  initialDate.month,
                  initialDate.day,
                  startTime.value.hour,
                  startTime.value.minute,
                );
                final endDateTime = DateTime(
                  initialDate.year,
                  initialDate.month,
                  initialDate.day,
                  endTime.value.hour,
                  endTime.value.minute,
                );
                final durationMinutes =
                    endDateTime.difference(startDateTime).inMinutes;

                if (repeatMode.value == 'None') {
                  await plannerNotifier.createSession(
                    subjectId: selectedSubject.value!.id,
                    durationMinutes: durationMinutes,
                    startTime: startDateTime,
                    endTime: endDateTime,
                    title: titleController.text.isEmpty
                        ? null
                        : titleController.text,
                  );
                } else {
                  // Calculate until date (4 weeks from start)
                  final until = startDateTime.add(const Duration(days: 28));

                  await plannerNotifier.createRecurringSession(
                    subjectId: selectedSubject.value!.id,
                    durationMinutes: durationMinutes,
                    startTime: startDateTime,
                    frequency: (repeatMode.value == 'Daily') ? 'DAILY' : 'WEEKLY',
                    daysOfWeek: (repeatMode.value == 'Weekly')
                        ? selectedDays.value
                        : null,
                    until: until,
                    title: titleController.text.isEmpty
                        ? null
                        : titleController.text,
                  );
                }

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(LucideIcons.checkCircle, color: Colors.white),
                          const SizedBox(width: 12),
                          Text(
                            'Session created successfully',
                            style: GoogleFonts.poppins(),
                          ),
                        ],
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(LucideIcons.alertCircle, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Failed to create session: ${e.toString().replaceAll('Exception: ', '')}',
                              style: GoogleFonts.poppins(),
                            ),
                          ),
                        ],
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              }
            },
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: 18,
            padding: const EdgeInsets.symmetric(vertical: 18),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.check,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  'Save Session',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          )
                .animate()
                .fadeIn(duration: 400.ms, delay: 300.ms)
                .slideY(begin: 0.1, end: 0, delay: 300.ms),
          const SizedBox(height: 16),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.2, end: 0);
  }

  String _getDayName(int day) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[day - 1];
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }
}

/// Custom Daily Timeline View inspired by modern planner design
class _DailyTimelineView extends StatelessWidget {
  final DateTime selectedDate;
  final List<StudySession> sessions;
  final Function(DateTime) onDateTap;
  final Function(StudySession) onSessionTap;

  const _DailyTimelineView({
    required this.selectedDate,
    required this.sessions,
    required this.onDateTap,
    required this.onSessionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Get the week (Mon-Sun) for the selected date
    final weekStart = _getWeekStart(selectedDate);
    final weekDays = List.generate(7, (index) => weekStart.add(Duration(days: index)));

    // Filter sessions for the selected date
    final daySessions = sessions.where((session) {
      if (session.startTime == null) return false;
      final sessionDate = DateTime(
        session.startTime!.year,
        session.startTime!.month,
        session.startTime!.day,
      );
      final selectedDateOnly = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      );
      return sessionDate.isAtSameMomentAs(selectedDateOnly);
    }).toList()
      ..sort((a, b) {
        if (a.startTime == null || b.startTime == null) return 0;
        return a.startTime!.compareTo(b.startTime!);
      });

    // Generate time slots (6 AM to 11 PM)
    final timeSlots = List.generate(18, (index) => 6 + index);

    return Column(
      children: [
        // Weekly header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: isDark
                ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                : colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays.map((date) {
              final isSelected = _isSameDay(date, selectedDate);
              final dayName = DateFormat('EEE').format(date);
              final dayNumber = date.day;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onDateTap(date),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(
                              color: colorScheme.primary,
                              width: 2,
                            )
                          : null,
                    ),
                    child: Column(
                      children: [
                        Text(
                          dayName,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$dayNumber',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Timeline and events
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline column
              Container(
                width: 80,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: timeSlots.map((hour) {
                    return Expanded(
                      child: Stack(
                        children: [
                          // Vertical line
                          Positioned(
                            left: 30,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: 2,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    colorScheme.primary.withValues(alpha: 0.3),
                                    colorScheme.primary.withValues(alpha: 0.1),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Time marker
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Row(
                              children: [
                                Text(
                                  '${hour.toString().padLeft(2, '0')}:00',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: colorScheme.primary.withValues(alpha: 0.5),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Events column
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: daySessions.isEmpty
                        ? [
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(48.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      LucideIcons.calendarX,
                                      size: 64,
                                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No sessions scheduled',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ]
                        : daySessions.map((session) {
                            return _TimelineEventCard(
                              session: session,
                              onTap: () => onSessionTap(session),
                            )
                                .animate()
                                .fadeIn(duration: 300.ms)
                                .slideX(begin: 0.1, end: 0);
                          }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday; // 1 = Monday, 7 = Sunday
    final daysFromMonday = weekday - 1;
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: daysFromMonday));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

/// Timeline Event Card matching the design inspiration
class _TimelineEventCard extends StatelessWidget {
  final StudySession session;
  final VoidCallback onTap;

  const _TimelineEventCard({
    required this.session,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final color = _parseColor(session.color);
    final sessionTitle = session.title ?? session.subject?.name ?? 'Study Session';
    final sessionSubtitle = session.title != null
        ? session.subject?.name
        : null;

    // Calculate position based on start time
    final startTime = session.startTime;
    final endTime = startTime?.add(Duration(minutes: session.durationMinutes));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: isDark ? 0.3 : 0.9),
              color.withValues(alpha: isDark ? 0.2 : 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          sessionTitle,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          LucideIcons.moreVertical,
                          size: 20,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        onPressed: onTap,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  if (sessionSubtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      sessionSubtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                  if (startTime != null && endTime != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          DateFormat('h:mm a').format(startTime),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        Text(
                          ' - ${DateFormat('h:mm a').format(endTime)}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Decorative icon in top right
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getSubjectIcon(session.subject?.name ?? ''),
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ],
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

  IconData _getSubjectIcon(String subjectName) {
    final lower = subjectName.toLowerCase();
    if (lower.contains('physics') || lower.contains('science')) {
      return LucideIcons.atom;
    } else if (lower.contains('geography') || lower.contains('geo')) {
      return LucideIcons.globe;
    } else if (lower.contains('math')) {
      return LucideIcons.calculator;
    } else if (lower.contains('english') || lower.contains('language')) {
      return LucideIcons.bookOpen;
    } else if (lower.contains('history')) {
      return LucideIcons.scroll;
    } else {
      return LucideIcons.book;
    }
  }
}

/// Modern Time Picker Widget
class _ModernTimePicker extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;
  final Duration delay;

  const _ModernTimePicker({
    required this.label,
    required this.time,
    required this.onTap,
    this.delay = const Duration(milliseconds: 0),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    time.format(context),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      LucideIcons.clock,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: delay)
        .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: delay);
  }
}

/// Modern Repeat Chip Widget
class _ModernRepeatChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onSelected;
  final Duration delay;

  const _ModernRepeatChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onSelected,
    this.delay = const Duration(milliseconds: 0),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: isDark
                        ? [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withValues(alpha: 0.8),
                          ]
                        : [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withValues(alpha: 0.8),
                          ],
                  )
                : null,
            color: isSelected ? null : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: delay)
        .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: delay)
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: 400.ms,
          delay: delay,
        );
  }
}

/// Modern Day Chip Widget for Weekly Selection
class _ModernDayChip extends StatelessWidget {
  final String day;
  final bool isSelected;
  final ValueChanged<bool> onSelected;
  final Duration delay;

  const _ModernDayChip({
    required this.day,
    required this.isSelected,
    required this.onSelected,
    this.delay = const Duration(milliseconds: 0),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSelected(!isSelected),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                    ],
                  )
                : null,
            color: isSelected ? null : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            day,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: isSelected
                  ? Colors.white
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: delay)
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          duration: 300.ms,
          delay: delay,
        );
  }
}

