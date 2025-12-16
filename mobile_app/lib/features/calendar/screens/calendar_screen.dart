import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:mobile_app/features/assignments/domain/assignment.dart';
import 'package:mobile_app/features/assignments/presentation/providers/assignment_provider.dart';

class CalendarScreen extends HookConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentState = ref.watch(assignmentProvider);
    final selectedDay = useState<DateTime>(DateTime.now());
    final focusedDay = useState<DateTime>(DateTime.now());

    // Load all assignments on init
    useEffect(() {
      Future(() {
        ref.read(assignmentProvider.notifier).loadAllAssignments();
      });
      return null;
    }, []);

    // Group assignments by day
    List<Assignment> getEventsForDay(DateTime day) {
      if (assignmentState.assignments.isEmpty) {
        return [];
      }

      final normalizedDay = DateTime(day.year, day.month, day.day);
      return assignmentState.assignments.where((assignment) {
        final eventDate = DateTime(
          assignment.dueDate.year,
          assignment.dueDate.month,
          assignment.dueDate.day,
        );
        return eventDate.isAtSameMomentAs(normalizedDay);
      }).toList();
    }

    // Get assignments for selected day
    final selectedDayEvents = getEventsForDay(selectedDay.value);

    // Helper function to parse color
    Color parseColor(String? hexColor) {
      if (hexColor == null || hexColor.isEmpty) {
        return Colors.grey;
      }
      try {
        return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
      } catch (e) {
        return Colors.grey;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        elevation: 0,
      ),
      body: assignmentState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : assignmentState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: ${assignmentState.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(assignmentProvider.notifier).loadAllAssignments();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Calendar
                    TableCalendar<Assignment>(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: focusedDay.value,
                      calendarFormat: CalendarFormat.month,
                      selectedDayPredicate: (day) {
                        return isSameDay(selectedDay.value, day);
                      },
                      onDaySelected: (selected, focused) {
                        selectedDay.value = selected;
                        focusedDay.value = focused;
                      },
                      eventLoader: (day) {
                        return getEventsForDay(day);
                      },
                      calendarStyle: const CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Colors.deepPurple,
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                      onPageChanged: (focused) {
                        focusedDay.value = focused;
                      },
                    ),
                    const Divider(height: 1),
                    // Selected day assignments list
                    Expanded(
                      child: selectedDayEvents.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.event_busy,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No assignments on ${DateFormat('MMM dd, yyyy').format(selectedDay.value)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: selectedDayEvents.length,
                              itemBuilder: (context, index) {
                                final assignment = selectedDayEvents[index];
                                final subjectColor = assignment.subject?.color;
                                final color = parseColor(subjectColor);

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    leading: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    title: Text(
                                      assignment.title,
                                      style: TextStyle(
                                        decoration: assignment.status == 'COMPLETED'
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color: assignment.status == 'COMPLETED'
                                            ? Colors.grey
                                            : null,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (assignment.subject != null)
                                          Text(
                                            assignment.subject!.name,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getPriorityColor(assignment.priority)
                                                .withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            assignment.priority,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: _getPriorityColor(assignment.priority),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: assignment.status == 'COMPLETED'
                                        ? const Icon(Icons.check_circle, color: Colors.green)
                                        : const Icon(Icons.radio_button_unchecked),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

