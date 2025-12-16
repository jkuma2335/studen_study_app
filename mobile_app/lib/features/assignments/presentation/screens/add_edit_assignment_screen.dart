import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/features/assignments/domain/assignment.dart';
import 'package:mobile_app/features/assignments/presentation/providers/assignment_provider.dart';
import 'package:mobile_app/features/subjects/presentation/providers/subject_provider.dart';
import 'package:mobile_app/core/widgets/modern_card.dart';
import 'package:mobile_app/core/widgets/modern_button.dart';

/// Screen B: Add/Edit Assignment Screen
class AddEditAssignmentScreen extends HookConsumerWidget {
  final Assignment? assignment; // null = create mode, non-null = edit mode

  const AddEditAssignmentScreen({
    super.key,
    this.assignment,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleController = useTextEditingController(
      text: assignment?.title ?? '',
    );
    final descriptionController = useTextEditingController(
      text: assignment?.description ?? '',
    );
    final selectedSubjectId = useState<String?>(
      assignment?.subjectId,
    );
    final selectedDate = useState<DateTime>(
      assignment?.dueDate ?? DateTime.now().add(const Duration(days: 7)),
    );
    final selectedTime = useState<TimeOfDay>(
      assignment?.dueDate != null
          ? TimeOfDay.fromDateTime(assignment!.dueDate)
          : const TimeOfDay(hour: 23, minute: 59),
    );
    final isAllDay = useState<bool>(assignment?.dueDate == null ? true : false);
    final selectedPriority = useState<String>(
      assignment?.priority ?? 'Medium',
    );
    final selectedStatus = useState<String>(
      assignment?.status ?? 'NOT_STARTED',
    );
    final remind24h = useState<bool>(true);
    final remind3h = useState<bool>(true);

    final subjectState = ref.watch(subjectProvider);
    final assignmentNotifier = ref.read(assignmentProvider.notifier);

    Color _parseColor(String? hexColor) {
      if (hexColor == null || hexColor.isEmpty) return Colors.grey;
      try {
        return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
      } catch (e) {
        return Colors.grey;
      }
    }

    Future<void> _saveAssignment() async {
      // Validate and sanitize title
      final trimmedTitle = titleController.text.trim();
      if (trimmedTitle.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Title is required')),
        );
        return;
      }
      
      // Prevent nonsense titles - ensure minimum length and basic validation
      if (trimmedTitle.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Title must be at least 2 characters')),
        );
        return;
      }
      
      // Use default title if it's just whitespace or too short
      final finalTitle = trimmedTitle.length >= 2 ? trimmedTitle : 'New Task';

      if (selectedSubjectId.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a subject')),
        );
        return;
      }

      final dueDateTime = isAllDay.value
          ? DateTime(
              selectedDate.value.year,
              selectedDate.value.month,
              selectedDate.value.day,
              23,
              59,
            )
          : DateTime(
              selectedDate.value.year,
              selectedDate.value.month,
              selectedDate.value.day,
              selectedTime.value.hour,
              selectedTime.value.minute,
            );

      try {
        if (assignment == null) {
          // Create mode
          await assignmentNotifier.addAssignment(
            subjectId: selectedSubjectId.value!,
            title: finalTitle,
            description: descriptionController.text.trim().isEmpty
                ? null
                : descriptionController.text.trim(),
            dueDate: dueDateTime,
            priority: selectedPriority.value,
            status: selectedStatus.value,
          );
        } else {
          // Edit mode
          await assignmentNotifier.updateAssignment(
            id: assignment!.id,
            subjectId: selectedSubjectId.value!,
            title: finalTitle,
            description: descriptionController.text.trim().isEmpty
                ? null
                : descriptionController.text.trim(),
            dueDate: dueDateTime,
            priority: selectedPriority.value,
            status: selectedStatus.value,
          );
        }

        if (context.mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                assignment == null
                    ? 'Assignment created successfully!'
                    : 'Assignment updated successfully!',
              ),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            LucideIcons.arrowLeft,
            color: colorScheme.onSurface,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          assignment == null ? 'Add Assignment' : 'Edit Assignment',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.surface,
                    colorScheme.surface.withValues(alpha: 0.8),
                  ],
                )
              : null,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: Basic Info
              AnimatedModernCard(
                delay: const Duration(milliseconds: 0),
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primary,
                                colorScheme.primary.withValues(alpha: 0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            LucideIcons.fileText,
                            color: colorScheme.onPrimary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Basic Information',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: titleController,
                      style: GoogleFonts.poppins(),
                      decoration: InputDecoration(
                        labelText: 'Title *',
                        hintText: 'Enter assignment title',
                        prefixIcon: Icon(
                          LucideIcons.edit3,
                          color: colorScheme.primary,
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: colorScheme.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: colorScheme.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      maxLines: 5,
                      style: GoogleFonts.poppins(),
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter assignment description',
                        prefixIcon: Icon(
                          LucideIcons.alignLeft,
                          color: colorScheme.primary,
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: colorScheme.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: colorScheme.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Section 2: Subject Picker
              AnimatedModernCard(
                delay: const Duration(milliseconds: 100),
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.secondary,
                                colorScheme.secondary.withValues(alpha: 0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            LucideIcons.bookOpen,
                            color: colorScheme.onSecondary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Subject',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: selectedSubjectId.value,
                      style: GoogleFonts.poppins(
                        color: colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Select Subject *',
                        prefixIcon: Icon(
                          LucideIcons.chevronDown,
                          color: colorScheme.primary,
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: colorScheme.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: colorScheme.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      items: subjectState.subjects.map((subject) {
                        return DropdownMenuItem<String>(
                          value: subject.id,
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
                                      color: _parseColor(subject.color).withValues(alpha: 0.5),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                subject.name,
                                style: GoogleFonts.poppins(
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        selectedSubjectId.value = value;
                      },
                    ),
                  ],
                ),
              ),

              // Section 3: Date & Time
              AnimatedModernCard(
                delay: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.tertiary,
                                colorScheme.tertiary.withValues(alpha: 0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            LucideIcons.calendar,
                            color: colorScheme.onTertiary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Due Date & Time',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ModernCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      margin: const EdgeInsets.only(bottom: 12),
                      borderRadius: 16,
                      backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                LucideIcons.clock,
                                color: colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'All Day',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: isAllDay.value,
                            onChanged: (value) {
                              isAllDay.value = value;
                            },
                            activeColor: colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                    ModernCard(
                      padding: EdgeInsets.zero,
                      borderRadius: 16,
                      backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate.value,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          selectedDate.value = picked;
                        }
                      },
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            LucideIcons.calendar,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          'Date',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          DateFormat('MMM dd, yyyy').format(selectedDate.value),
                          style: GoogleFonts.poppins(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        trailing: Icon(
                          LucideIcons.chevronRight,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (!isAllDay.value) ...[
                      const SizedBox(height: 12),
                      ModernCard(
                        padding: EdgeInsets.zero,
                        borderRadius: 16,
                        backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: selectedTime.value,
                          );
                          if (picked != null) {
                            selectedTime.value = picked;
                          }
                        },
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              LucideIcons.clock,
                              color: colorScheme.primary,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            'Time',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            selectedTime.value.format(context),
                            style: GoogleFonts.poppins(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          trailing: Icon(
                            LucideIcons.chevronRight,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Section 4: Priority
              AnimatedModernCard(
                delay: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.error,
                                colorScheme.error.withValues(alpha: 0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            LucideIcons.flag,
                            color: colorScheme.onError,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Priority',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SegmentedButton<String>(
                      segments: [
                        ButtonSegment(
                          value: 'Low',
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.arrowDown,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              const Text('Low'),
                            ],
                          ),
                        ),
                        ButtonSegment(
                          value: 'Medium',
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.minus,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              const Text('Medium'),
                            ],
                          ),
                        ),
                        ButtonSegment(
                          value: 'High',
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.arrowUp,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              const Text('High'),
                            ],
                          ),
                        ),
                      ],
                      selected: {selectedPriority.value},
                      onSelectionChanged: (Set<String> newSelection) {
                        selectedPriority.value = newSelection.first;
                      },
                      style: SegmentedButton.styleFrom(
                        selectedBackgroundColor: colorScheme.primary,
                        selectedForegroundColor: colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              // Section 5: Status
              AnimatedModernCard(
                delay: const Duration(milliseconds: 400),
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primaryContainer,
                                colorScheme.primaryContainer.withValues(alpha: 0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            LucideIcons.circleDot,
                            color: colorScheme.onPrimaryContainer,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Status',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        'NOT_STARTED',
                        'IN_PROGRESS',
                        'COMPLETED',
                      ].map((status) {
                        final isSelected = selectedStatus.value == status;
                        String label;
                        IconData icon;
                        Color statusColor;
                        switch (status) {
                          case 'NOT_STARTED':
                            label = 'Not Started';
                            icon = LucideIcons.circle;
                            statusColor = colorScheme.outline;
                            break;
                          case 'IN_PROGRESS':
                            label = 'In Progress';
                            icon = LucideIcons.clock;
                            statusColor = isDark
                                ? const Color(0xFFFBBF24)
                                : const Color(0xFFF59E0B);
                            break;
                          case 'COMPLETED':
                            label = 'Completed';
                            icon = LucideIcons.checkCircle;
                            statusColor = isDark
                                ? const Color(0xFF34D399)
                                : const Color(0xFF10B981);
                            break;
                          default:
                            label = status;
                            icon = LucideIcons.circle;
                            statusColor = colorScheme.outline;
                        }
                        return ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                icon,
                                size: 16,
                                color: isSelected
                                    ? colorScheme.onPrimary
                                    : statusColor,
                              ),
                              const SizedBox(width: 6),
                              Text(label),
                            ],
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              selectedStatus.value = status;
                            }
                          },
                          selectedColor: statusColor,
                          labelStyle: GoogleFonts.poppins(
                            color: isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected
                                  ? statusColor
                                  : colorScheme.outline.withValues(alpha: 0.3),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // Section 6: Reminders
              AnimatedModernCard(
                delay: const Duration(milliseconds: 500),
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.secondaryContainer,
                                colorScheme.secondaryContainer.withValues(alpha: 0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            LucideIcons.bell,
                            color: colorScheme.onSecondaryContainer,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Reminders',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ModernCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      margin: const EdgeInsets.only(bottom: 12),
                      borderRadius: 16,
                      backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                LucideIcons.clock,
                                color: colorScheme.secondary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Remind me 24 hours before',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: remind24h.value,
                            onChanged: (value) {
                              remind24h.value = value;
                            },
                            activeColor: colorScheme.secondary,
                          ),
                        ],
                      ),
                    ),
                    ModernCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      borderRadius: 16,
                      backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                LucideIcons.clock,
                                color: colorScheme.secondary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Remind me 3 hours before',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: remind3h.value,
                            onChanged: (value) {
                              remind3h.value = value;
                            },
                            activeColor: colorScheme.secondary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Save Button
              AnimatedModernCard(
                delay: const Duration(milliseconds: 600),
                padding: EdgeInsets.zero,
                margin: const EdgeInsets.only(bottom: 32),
                child: ModernElevatedButton(
                  width: double.infinity,
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  onPressed: _saveAssignment,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        assignment == null
                            ? LucideIcons.plus
                            : LucideIcons.check,
                        color: colorScheme.onPrimary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        assignment == null
                            ? 'Create Assignment'
                            : 'Update Assignment',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

