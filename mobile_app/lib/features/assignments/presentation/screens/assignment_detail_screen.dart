import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/features/assignments/domain/assignment.dart';
import 'package:mobile_app/features/assignments/presentation/providers/assignment_provider.dart';
import 'package:mobile_app/features/subjects/presentation/providers/subject_provider.dart';
import 'package:mobile_app/features/subjects/domain/subject.dart';
import 'package:mobile_app/core/widgets/modern_glass_card.dart';

/// Screen C: Assignment Detail Screen
class AssignmentDetailScreen extends HookConsumerWidget {
  final Assignment assignment;

  const AssignmentDetailScreen({
    super.key,
    required this.assignment,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStatus = useState<String>(assignment.status);
    final assignmentNotifier = ref.read(assignmentProvider.notifier);
    final subjectState = ref.watch(subjectProvider);

    Subject? subject;
    try {
      subject = subjectState.subjects.firstWhere(
        (s) => s.id == assignment.subjectId,
      );
    } catch (e) {
      subject = null;
    }

    Color _parseColor(String? hexColor) {
      if (hexColor == null || hexColor.isEmpty) return Colors.grey;
      try {
        return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
      } catch (e) {
        return Colors.grey;
      }
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

    Future<void> _updateStatus(String newStatus) async {
      try {
        await assignmentNotifier.updateAssignment(
          id: assignment.id,
          subjectId: assignment.subjectId,
          status: newStatus,
        );
        currentStatus.value = newStatus;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Status updated')),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Assignment Details',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.edit),
            onPressed: () {
              context.push('/assignments/edit', extra: assignment);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card with Subject Color
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _parseColor(subject?.color ?? '#3B82F6'),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assignment.title,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          assignment.priority,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (subject != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            subject.name,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Due: ${DateFormat('MMM dd, yyyy • hh:mm a').format(assignment.dueDate)}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Selector
                  Text(
                    'Status',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatusButton(
                          context,
                          'NOT_STARTED',
                          'Not Started',
                          currentStatus.value == 'NOT_STARTED',
                          Colors.grey,
                          () => _updateStatus('NOT_STARTED'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatusButton(
                          context,
                          'IN_PROGRESS',
                          'In Progress',
                          currentStatus.value == 'IN_PROGRESS',
                          Colors.orange,
                          () => _updateStatus('IN_PROGRESS'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatusButton(
                          context,
                          'COMPLETED',
                          'Completed',
                          currentStatus.value == 'COMPLETED',
                          Colors.green,
                          () => _updateStatus('COMPLETED'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Description
                  Text(
                    'Description',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ModernGlassCard(
                    padding: const EdgeInsets.all(16),
                    child: assignment.description != null &&
                            assignment.description!.isNotEmpty
                        ? Text(
                            assignment.description!,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          )
                        : Text(
                            'No description provided',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                  ),
                  const SizedBox(height: 32),

                  // Attachments
                  Text(
                    'Attachments',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (assignment.attachmentUrls.isEmpty)
                    ModernGlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(
                            LucideIcons.paperclip,
                            size: 32,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No attachments',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () {
                              // TODO: Implement file picker
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('File picker coming soon'),
                                ),
                              );
                            },
                            icon: const Icon(LucideIcons.plus),
                            label: Text(
                              'Add Attachment',
                              style: GoogleFonts.poppins(),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...assignment.attachmentUrls.map((url) {
                      return ModernGlassCard(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(LucideIcons.file),
                          title: Text(
                            url,
                            style: GoogleFonts.poppins(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(LucideIcons.externalLink),
                          onTap: () {
                            // TODO: Open attachment
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Opening: $url')),
                            );
                          },
                        ),
                      );
                    }),
                  const SizedBox(height: 32),

                  // Reminders
                  Text(
                    'Reminders',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ModernGlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildReminderItem(
                          context,
                          '24 hours before',
                          assignment.dueDate.subtract(const Duration(hours: 24)),
                        ),
                        const SizedBox(height: 12),
                        _buildReminderItem(
                          context,
                          '3 hours before',
                          assignment.dueDate.subtract(const Duration(hours: 3)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(
    BuildContext context,
    String status,
    String label,
    bool isSelected,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.2)
              : Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: isSelected ? color : Theme.of(context).colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              isSelected ? LucideIcons.checkCircle : LucideIcons.circle,
              color: isSelected ? color : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? color
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderItem(
    BuildContext context,
    String label,
    DateTime reminderTime,
  ) {
    final now = DateTime.now();
    final isPast = reminderTime.isBefore(now);

    return Row(
      children: [
        Icon(
          isPast ? LucideIcons.checkCircle : LucideIcons.clock,
          size: 20,
          color: isPast
              ? Colors.green
              : Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMM dd, yyyy • hh:mm a').format(reminderTime),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (isPast)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Sent',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
          ),
      ],
    );
  }
}

