import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_app/core/widgets/modern_card.dart';
import 'package:mobile_app/features/subjects/presentation/providers/subject_provider.dart';


class SubjectsScreen extends HookConsumerWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectState = ref.watch(subjectProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Subjects',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: subjectState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : subjectState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: ${subjectState.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(subjectProvider.notifier).loadSubjects();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : subjectState.subjects.isEmpty
                  ? const Center(
                      child: Text(
                        'No subjects yet.\nTap the + button to add one!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: subjectState.subjects.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final subject = subjectState.subjects[index];
                        final subjectColor = _parseColor(subject.color);
                        
                        return AnimatedModernCard(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(20),
                          borderRadius: 22,
                          delay: (index * 80).ms,
                          onTap: () {
                            context.push(
                              '/subjects/details',
                              extra: subject,
                            );
                          },
                          child: Row(
                            children: [
                              // Modern Icon Container
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      subjectColor,
                                      subjectColor.withValues(alpha: 0.8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: subjectColor.withValues(alpha: 0.4),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _getCategoryIcon(subject.category),
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Title & Teacher Name
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                subject.name,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                                  letterSpacing: -0.3,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              if (subject.teacherName != null) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  subject.teacherName!,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Context Menu (3 dots)
                                        PopupMenuButton<String>(
                                          icon: Icon(
                                            LucideIcons.moreVertical,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                          onSelected: (value) {
                                            if (value == 'edit') {
                                              // Navigate to edit screen
                                              context.push(
                                                '/subjects/edit',
                                                extra: subject,
                                              );
                                            } else if (value == 'delete') {
                                              _showDeleteDialog(
                                                context,
                                                ref,
                                                subject.id,
                                                subject.name,
                                              );
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    LucideIcons.edit,
                                                    size: 18,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    'Edit',
                                                    style: GoogleFonts.poppins(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    LucideIcons.trash2,
                                                    size: 18,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .error,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    'Delete',
                                                    style: GoogleFonts.poppins(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .error,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    if (subject.studyGoalHours > 0) ...[
                                      const SizedBox(height: 12),
                                      // Goal Badge - Modern Design
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              subjectColor.withValues(alpha: 0.15),
                                              subjectColor.withValues(alpha: 0.08),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: subjectColor.withValues(alpha: 0.4),
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: subjectColor.withValues(alpha: 0.1),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              LucideIcons.target,
                                              size: 16,
                                              color: subjectColor,
                                            ),
                                            const SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                'Goal: ${subject.studyGoalHours.toStringAsFixed(1)} hrs/week',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: subjectColor,
                                                  letterSpacing: -0.2,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/subjects/add');
        },
        icon: const Icon(LucideIcons.plus),
        label: Text(
          'Add Subject',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    String subjectId,
    String subjectName,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text('Are you sure you want to delete "$subjectName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(subjectProvider.notifier).deleteSubject(subjectId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
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

  IconData _getCategoryIcon(String? category) {
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
      default:
        return LucideIcons.bookOpen;
    }
  }
}

