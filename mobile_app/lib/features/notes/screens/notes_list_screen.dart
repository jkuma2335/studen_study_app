import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_app/features/notes/presentation/providers/note_provider.dart';
import 'package:mobile_app/core/widgets/modern_card.dart';
import 'package:mobile_app/core/widgets/modern_button.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

/// Global Notes Screen - Shows all notes across all subjects
class NotesListScreen extends HookConsumerWidget {
  const NotesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesState = ref.watch(noteProvider);

    // Load all notes on init
    useEffect(() {
      Future.microtask(() {
        ref.read(noteProvider.notifier).loadAllNotes();
      });
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Notes',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: notesState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notesState.error != null
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
                        'Error loading notes',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notesState.error ?? 'Unknown error',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(noteProvider.notifier).loadAllNotes();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : notesState.notes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                  Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              LucideIcons.stickyNote,
                              size: 64,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 600.ms)
                              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 600.ms, curve: Curves.elasticOut),
                          const SizedBox(height: 24),
                          Text(
                            'No notes yet',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 500.ms, delay: 200.ms)
                              .slideY(begin: 0.1, end: 0, delay: 200.ms),
                          const SizedBox(height: 8),
                          Text(
                            'Create your first note from a subject',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 500.ms, delay: 300.ms),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: notesState.notes.length,
                      itemBuilder: (context, index) {
                        final note = notesState.notes[index];
                        return AnimatedModernCard(
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.only(bottom: 14),
                          borderRadius: 20,
                          delay: (index * 50).ms,
                          onTap: () {
                            context.push(
                              '/notes/editor',
                              extra: {
                                'note': note,
                                'subjectId': note.subjectId,
                              },
                            );
                          },
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
                                          Theme.of(context).colorScheme.primary,
                                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      LucideIcons.fileText,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      note.title,
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.onSurface,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ),
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
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _getContentPreview(note.content),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    LucideIcons.calendar,
                                    size: 14,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    DateFormat('MMM dd, yyyy').format(note.createdAt),
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Show dialog to select subject first, or navigate to subjects
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(LucideIcons.info, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    'Select a subject to create a note',
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
        icon: const Icon(LucideIcons.plus),
        label: Text(
          'New Note',
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

  String _getContentPreview(String content) {
    try {
      // Try to parse as JSON (rich text format)
      if (content.startsWith('[') || content.startsWith('{')) {
        final json = jsonDecode(content) as List;
        // Extract plain text from delta operations
        String plainText = '';
        for (var op in json) {
          if (op is Map && op.containsKey('insert')) {
            final insert = op['insert'];
            if (insert is String) {
              plainText += insert;
            }
          }
        }
        if (plainText.isEmpty) {
          return 'Empty note';
        }
        if (plainText.length <= 100) {
          return plainText;
        }
        return '${plainText.substring(0, 100)}...';
      }
      // Plain text
      if (content.length > 100) {
        return '${content.substring(0, 100)}...';
      }
      return content.isEmpty ? 'Empty note' : content;
    } catch (e) {
      // If parsing fails, return plain text preview
      if (content.length > 100) {
        return '${content.substring(0, 100)}...';
      }
      return content.isEmpty ? 'Empty note' : content;
    }
  }
}

