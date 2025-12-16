import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_app/features/assignments/domain/assignment.dart';
import 'package:mobile_app/features/assignments/presentation/providers/assignment_provider.dart';
import 'package:mobile_app/features/subjects/presentation/providers/subject_provider.dart';
import 'package:mobile_app/features/subjects/domain/subject.dart';
import 'package:mobile_app/core/widgets/modern_card.dart';
import 'package:mobile_app/core/widgets/modern_button.dart';

/// Screen A & D: Global Tasks Screen with Filter Modal
class AssignmentsListScreen extends HookConsumerWidget {
  const AssignmentsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final searchQuery = useState<String>('');
    final selectedPriorities = useState<Set<String>>({});
    final selectedStatuses = useState<Set<String>>({});
    final dateRange = useState<DateTimeRange?>(null);

    final assignmentState = ref.watch(assignmentProvider);
    final subjectState = ref.watch(subjectProvider);

    // Load all assignments and subjects on mount
    // Wrapped in Future to avoid modifying provider during build
    useEffect(() {
      Future(() {
        ref.read(assignmentProvider.notifier).loadAllAssignments();
        ref.read(subjectProvider.notifier).loadSubjects();
      });
      return null;
    }, []);

    // Filter assignments
    final filteredAssignments = useMemoized(() {
      var assignments = assignmentState.assignments;

      // Search filter
      if (searchQuery.value.isNotEmpty) {
        assignments = assignments.where((a) {
          return a.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
              (a.description?.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false);
        }).toList();
      }



      // Priority filter
      if (selectedPriorities.value.isNotEmpty) {
        assignments = assignments
            .where((a) => selectedPriorities.value
                .any((p) => p.toLowerCase() == a.priority.toLowerCase()))
            .toList();
      }

      // Status filter
      if (selectedStatuses.value.isNotEmpty) {
        assignments = assignments
            .where((a) => selectedStatuses.value
                .any((s) => s.toLowerCase() == a.status.toLowerCase()))
            .toList();
      }

      // Date range filter
      if (dateRange.value != null) {
        assignments = assignments.where((a) {
          return a.dueDate.isAfter(dateRange.value!.start.subtract(const Duration(days: 1))) &&
              a.dueDate.isBefore(dateRange.value!.end.add(const Duration(days: 1)));
        }).toList();
      }

      return assignments;
    }, [
      assignmentState.assignments,
      searchQuery.value,
      selectedPriorities.value,
      selectedStatuses.value,
      dateRange.value,
    ]);

    // Group assignments
    final grouped = useMemoized(() {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));

      final overdue = <Assignment>[];
      final dueToday = <Assignment>[];
      final dueTomorrow = <Assignment>[];
      final upcoming = <Assignment>[];
      final completed = <Assignment>[];

      for (final assignment in filteredAssignments) {
        if (assignment.status == 'COMPLETED') {
          completed.add(assignment);
        } else if (assignment.isOverdue) {
          overdue.add(assignment);
        } else {
          final dueDate = DateTime(
            assignment.dueDate.year,
            assignment.dueDate.month,
            assignment.dueDate.day,
          );
          if (dueDate == today) {
            dueToday.add(assignment);
          } else if (dueDate == tomorrow) {
            dueTomorrow.add(assignment);
          } else if (dueDate.isAfter(tomorrow)) {
            upcoming.add(assignment);
          } else {
            overdue.add(assignment);
          }
        }
      }

      return {
        'overdue': overdue,
        'dueToday': dueToday,
        'dueTomorrow': dueTomorrow,
        'upcoming': upcoming,
        'completed': completed,
      };
    }, [filteredAssignments]);

    Color _parseColor(String? hexColor) {
      if (hexColor == null || hexColor.isEmpty) return Colors.grey;
      try {
        return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
      } catch (e) {
        return Colors.grey;
      }
    }

    Color _getStatusColor(String status) {
      switch (status) {
        case 'COMPLETED':
          return Colors.green;
        case 'IN_PROGRESS':
          return Colors.orange;
        case 'NOT_STARTED':
          return Colors.grey;
        default:
          return Colors.grey;
      }
    }

    String _getStatusLabel(String status) {
      switch (status) {
        case 'COMPLETED':
          return 'Done';
        case 'IN_PROGRESS':
          return 'In Progress';
        case 'NOT_STARTED':
          return 'Not Started';
        default:
          return status;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Assignments',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.filter),
            onPressed: () => _showFilterModal(
              context,
              selectedPriorities,
              selectedStatuses,
              dateRange,
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.plus),
            onPressed: () {
              context.push('/assignments/add');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Modern Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: AnimatedModernCard(
              padding: EdgeInsets.zero,
              borderRadius: 20,
              delay: 100.ms,
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search assignments...',
                  hintStyle: GoogleFonts.poppins(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      LucideIcons.search,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  suffixIcon: searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              LucideIcons.x,
                              size: 16,
                            ),
                          ),
                          onPressed: () {
                            searchController.clear();
                            searchQuery.value = '';
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                onChanged: (value) {
                  searchQuery.value = value;
                },
              ),
            ),
          ),

          // List
          Expanded(
            child: assignmentState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : assignmentState.error != null
                    ? Center(
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
                              'Failed to load assignments',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              assignmentState.error!,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                ref.read(assignmentProvider.notifier).loadAllAssignments();
                              },
                              icon: const Icon(LucideIcons.refreshCw),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : filteredAssignments.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  LucideIcons.clipboardList,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No assignments found',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                        onRefresh: () async {
                          await ref.read(assignmentProvider.notifier).loadAllAssignments();
                        },
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            // Overdue Section
                            if (grouped['overdue']!.isNotEmpty) ...[
                              _buildSectionHeader(
                                context,
                                'Overdue',
                                grouped['overdue']!.length,
                                Colors.red,
                                hasGlow: true,
                              ),
                              const SizedBox(height: 8),
                              ...grouped['overdue']!.asMap().entries.map((entry) => _buildAssignmentCard(
                                    context,
                                    entry.value,
                                    subjectState.subjects,
                                    ref,
                                    _parseColor,
                                    _getStatusColor,
                                    _getStatusLabel,
                                    index: entry.key,
                                  )),
                              const SizedBox(height: 24),
                            ],

                            // Due Today
                            if (grouped['dueToday']!.isNotEmpty) ...[
                              _buildSectionHeader(
                                context,
                                'Due Today',
                                grouped['dueToday']!.length,
                                Colors.orange,
                              ),
                              const SizedBox(height: 8),
                              ...grouped['dueToday']!.asMap().entries.map((entry) => _buildAssignmentCard(
                                    context,
                                    entry.value,
                                    subjectState.subjects,
                                    ref,
                                    _parseColor,
                                    _getStatusColor,
                                    _getStatusLabel,
                                    index: entry.key,
                                  )),
                              const SizedBox(height: 24),
                            ],

                            // Due Tomorrow
                            if (grouped['dueTomorrow']!.isNotEmpty) ...[
                              _buildSectionHeader(
                                context,
                                'Due Tomorrow',
                                grouped['dueTomorrow']!.length,
                                Colors.blue,
                              ),
                              const SizedBox(height: 8),
                              ...grouped['dueTomorrow']!.asMap().entries.map((entry) => _buildAssignmentCard(
                                    context,
                                    entry.value,
                                    subjectState.subjects,
                                    ref,
                                    _parseColor,
                                    _getStatusColor,
                                    _getStatusLabel,
                                    index: entry.key,
                                  )),
                              const SizedBox(height: 24),
                            ],

                            // Upcoming
                            if (grouped['upcoming']!.isNotEmpty) ...[
                              _buildSectionHeader(
                                context,
                                'Upcoming',
                                grouped['upcoming']!.length,
                                Colors.grey,
                              ),
                              const SizedBox(height: 8),
                              ...grouped['upcoming']!.asMap().entries.map((entry) => _buildAssignmentCard(
                                    context,
                                    entry.value,
                                    subjectState.subjects,
                                    ref,
                                    _parseColor,
                                    _getStatusColor,
                                    _getStatusLabel,
                                    index: entry.key,
                                  )),
                              const SizedBox(height: 24),
                            ],

                            // Completed
                            if (grouped['completed']!.isNotEmpty) ...[
                              _buildSectionHeader(
                                context,
                                'Completed',
                                grouped['completed']!.length,
                                Colors.green,
                              ),
                              const SizedBox(height: 8),
                              ...grouped['completed']!.asMap().entries.map((entry) => _buildAssignmentCard(
                                    context,
                                    entry.value,
                                    subjectState.subjects,
                                    ref,
                                    _parseColor,
                                    _getStatusColor,
                                    _getStatusLabel,
                                    index: entry.key,
                                  )),
                            ],
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    int count,
    Color color, {
    bool hasGlow = false,
  }) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 24,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color,
                color.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(3),
            boxShadow: hasGlow
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.6),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
        ),
        const SizedBox(width: 14),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.25),
                color.withValues(alpha: 0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            '$count',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideX(begin: -0.1, end: 0);
  }

  Widget _buildAssignmentCard(
    BuildContext context,
    Assignment assignment,
    List<Subject> subjects,
    WidgetRef ref,
    Color Function(String?) parseColor,
    Color Function(String) getStatusColor,
    String Function(String) getStatusLabel, {
    int index = 0,
  }) {
    Subject? subject;
    try {
      subject = subjects.firstWhere(
        (s) => s.id == assignment.subjectId,
      );
    } catch (e) {
      subject = null;
    }
    final subjectColor = parseColor(subject?.color ?? '#3B82F6');
    final statusColor = getStatusColor(assignment.status);

    return AnimatedModernCard(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.only(bottom: 14),
      borderRadius: 20,
      delay: (index * 50).ms,
      onTap: () {
        context.push('/assignments/details', extra: assignment);
      },
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left border with gradient subject color
            Container(
              width: 5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    subjectColor,
                    subjectColor.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: subjectColor.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(2, 0),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            assignment.title,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        // Modern Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                statusColor.withValues(alpha: 0.25),
                                statusColor.withValues(alpha: 0.15),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: statusColor.withValues(alpha: 0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
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
                              const SizedBox(width: 6),
                              Text(
                                getStatusLabel(assignment.status),
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (subject != null) ...[
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: subjectColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              subject.name,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          DateFormat('MMM dd, yyyy').format(assignment.dueDate),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterModal(
    BuildContext context,
    ValueNotifier<Set<String>> selectedPriorities,
    ValueNotifier<Set<String>> selectedStatuses,
    ValueNotifier<DateTimeRange?> dateRange,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FilterModal(
        selectedPriorities: selectedPriorities,
        selectedStatuses: selectedStatuses,
        dateRange: dateRange,
      ),
    );
  }
}

class _FilterModal extends HookConsumerWidget {
  final ValueNotifier<Set<String>> selectedPriorities;
  final ValueNotifier<Set<String>> selectedStatuses;
  final ValueNotifier<DateTimeRange?> dateRange;

  const _FilterModal({
    required this.selectedPriorities,
    required this.selectedStatuses,
    required this.dateRange,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter Assignments',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 24),

                // Priority Filter
                Text(
                  'Priority',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: ['High', 'Medium', 'Low'].map((priority) {
                    final isSelected = selectedPriorities.value.contains(priority);
                    return FilterChip(
                      label: Text(
                        priority,
                        style: TextStyle(
                          color: isSelected 
                              ? theme.colorScheme.onPrimaryContainer 
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      selected: isSelected,
                      showCheckmark: false,
                      selectedColor: theme.colorScheme.primaryContainer,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      onSelected: (selected) {
                        final newSet = Set<String>.from(selectedPriorities.value);
                        if (selected) {
                          newSet.add(priority);
                        } else {
                          newSet.remove(priority);
                        }
                        selectedPriorities.value = newSet;
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Status Filter
                Text(
                  'Status',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: ['NOT_STARTED', 'IN_PROGRESS', 'COMPLETED'].map((status) {
                    final isSelected = selectedStatuses.value.contains(status);
                    String label;
                    switch (status) {
                      case 'NOT_STARTED':
                        label = 'Not Started';
                        break;
                      case 'IN_PROGRESS':
                        label = 'In Progress';
                        break;
                      case 'COMPLETED':
                        label = 'Completed';
                        break;
                      default:
                        label = status;
                    }
                    return FilterChip(
                      label: Text(
                        label,
                        style: TextStyle(
                          color: isSelected 
                              ? theme.colorScheme.onPrimaryContainer 
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      selected: isSelected,
                      showCheckmark: false,
                      selectedColor: theme.colorScheme.primaryContainer,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      onSelected: (selected) {
                        final newSet = Set<String>.from(selectedStatuses.value);
                        if (selected) {
                          newSet.add(status);
                        } else {
                          newSet.remove(status);
                        }
                        selectedStatuses.value = newSet;
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Date Range
                Text(
                  'Date Range',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: Text(
                    dateRange.value == null
                        ? 'Select date range'
                        : '${DateFormat('MMM dd').format(dateRange.value!.start)} - ${DateFormat('MMM dd').format(dateRange.value!.end)}',
                    style: GoogleFonts.poppins(),
                  ),
                  trailing: const Icon(LucideIcons.calendar),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  onTap: () async {
                    final range = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (range != null) {
                      dateRange.value = range;
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          selectedPriorities.value = {};
                          selectedStatuses.value = {};
                          dateRange.value = null;
                        },
                        child: Text(
                          'Clear All',
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Apply',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
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
    );
  }
}

