import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mobile_app/core/widgets/modern_card.dart';
import 'package:mobile_app/core/widgets/modern_button.dart';
import 'package:mobile_app/features/subjects/domain/subject.dart';
import 'package:mobile_app/features/assignments/presentation/providers/assignment_provider.dart';
import 'package:mobile_app/features/notes/presentation/providers/note_provider.dart';

class SubjectDetailScreen extends HookConsumerWidget {
  final Subject subject;

  const SubjectDetailScreen({super.key, required this.subject});

  Color _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return Colors.blue;
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'Mathematics': return LucideIcons.calculator;
      case 'Science': return LucideIcons.flaskConical;
      case 'Language': return LucideIcons.languages;
      case 'Arts': return LucideIcons.palette;
      case 'History': return LucideIcons.hourglass;
      case 'Computer Science': return LucideIcons.code;
      default: return LucideIcons.bookOpen;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectColor = _parseColor(subject.color);
    final tabController = useTabController(initialLength: 2);
    
    // Load data on first build only
    useEffect(() {
      Future.microtask(() {
        ref.read(assignmentProvider.notifier).loadAssignments(subject.id);
        ref.read(noteProvider.notifier).loadNotes(subject.id);
      });
      return null;
    }, [subject.id]);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(_getCategoryIcon(subject.category), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                subject.name,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: subjectColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.pencil),
            onPressed: () => context.push('/home/subjects/edit', extra: subject),
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Info Card
          Container(
            padding: const EdgeInsets.all(16),
            color: subjectColor.withValues(alpha: 0.1),
            child: Row(
              children: [
                Expanded(
                  child: _QuickStatCard(
                    icon: LucideIcons.clock,
                    label: 'Goal',
                    value: '${subject.studyGoalHours.toStringAsFixed(1)}h',
                    color: subjectColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickStatCard(
                    icon: LucideIcons.flame,
                    label: 'Streak',
                    value: '${subject.streak} days',
                    color: subjectColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickStatCard(
                    icon: LucideIcons.graduationCap,
                    label: 'Level',
                    value: subject.difficulty ?? 'Medium',
                    color: subjectColor,
                  ),
                ),
              ],
            ),
          ),
          
          // Study Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/timer', extra: subject),
                icon: const Icon(LucideIcons.play),
                label: Text(
                  'Start Studying',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: subjectColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: tabController,
              tabs: const [
                Tab(text: 'Assignments'),
                Tab(text: 'Notes'),
              ],
              labelColor: subjectColor,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
              indicatorColor: subjectColor,
              indicatorWeight: 3,
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                _AssignmentsTab(subject: subject, subjectColor: subjectColor),
                _NotesTab(subject: subject, subjectColor: subjectColor),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: ListenableBuilder(
        listenable: tabController,
        builder: (context, child) {
          final isNotesTab = tabController.index == 1;
          return FloatingActionButton.extended(
            onPressed: () {
              if (isNotesTab) {
                context.push('/home/notes/editor', extra: {
                  'subjectId': subject.id,
                  'note': null,
                });
              } else {
                context.push('/home/assignments/add', extra: {'subjectId': subject.id});
              }
            },
            backgroundColor: subjectColor,
            icon: Icon(
              isNotesTab ? LucideIcons.stickyNote : LucideIcons.clipboardList,
              color: Colors.white,
            ),
            label: Text(
              isNotesTab ? 'Add Note' : 'Add Assignment',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _QuickStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignmentsTab extends ConsumerWidget {
  final Subject subject;
  final Color subjectColor;

  const _AssignmentsTab({required this.subject, required this.subjectColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(assignmentProvider);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.alertCircle, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading assignments'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => ref.read(assignmentProvider.notifier).loadAssignments(subject.id),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: subjectColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.clipboardList, size: 40, color: subjectColor),
            ),
            const SizedBox(height: 16),
            Text(
              'No assignments yet',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap + to add one',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.assignments.length,
      itemBuilder: (context, index) {
        final assignment = state.assignments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: _getPriorityColor(assignment.priority),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            title: Text(
              assignment.title,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              assignment.dueDate != null
                  ? 'Due: ${assignment.dueDate!.day}/${assignment.dueDate!.month}/${assignment.dueDate!.year}'
                  : 'No due date',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            trailing: _buildStatusBadge(assignment.status),
            onTap: () => context.push('/home/assignments/${assignment.id}', extra: assignment),
          ),
        );
      },
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'HIGH': return Colors.red;
      case 'MEDIUM': return Colors.orange;
      case 'LOW': return Colors.green;
      default: return Colors.grey;
    }
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        color = Colors.green;
        label = 'Done';
        break;
      case 'IN_PROGRESS':
        color = Colors.orange;
        label = 'In Progress';
        break;
      default:
        color = Colors.grey;
        label = 'To Do';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _NotesTab extends ConsumerWidget {
  final Subject subject;
  final Color subjectColor;

  const _NotesTab({required this.subject, required this.subjectColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(noteProvider);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.alertCircle, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading notes'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => ref.read(noteProvider.notifier).loadNotes(subject.id),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: subjectColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.stickyNote, size: 40, color: subjectColor),
            ),
            const SizedBox(height: 16),
            Text(
              'No notes yet',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap + to create one',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.notes.length,
      itemBuilder: (context, index) {
        final note = state.notes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(LucideIcons.fileText, color: subjectColor),
            title: Text(
              note.title,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'Updated: ${note.updatedAt.day}/${note.updatedAt.month}/${note.updatedAt.year}',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            onTap: () => context.push('/home/notes/editor', extra: {
              'subjectId': subject.id,
              'note': note,
            }),
          ),
        );
      },
    );
  }
}
