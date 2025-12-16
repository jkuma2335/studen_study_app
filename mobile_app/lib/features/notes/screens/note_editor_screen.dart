import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../domain/note_model.dart';
import '../presentation/providers/note_provider.dart';
import 'package:mobile_app/core/widgets/modern_button.dart';
import 'package:mobile_app/features/quiz/presentation/providers/quiz_provider.dart';

class NoteEditorScreen extends StatefulHookConsumerWidget {
  final String subjectId;
  final Note? existingNote;

  const NoteEditorScreen({
    super.key,
    required this.subjectId,
    this.existingNote,
  });

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late QuillController _quillController;

  late TextEditingController _titleController;
  bool _isGeneratingQuiz = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingNote?.title ?? '');
    
    // Initialize QuillController with document
    if (widget.existingNote != null && widget.existingNote!.content.isNotEmpty) {
      try {
        // Parse the JSON string content into a Document
        final json = jsonDecode(widget.existingNote!.content) as List;
        final delta = Delta.fromJson(json);
        final document = Document.fromDelta(delta);
        _quillController = QuillController(
          document: document,
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        // If parsing fails, create empty document
        _quillController = QuillController.basic();
      }
    } else {
      _quillController = QuillController.basic();
    }
  }

  @override
  void dispose() {
    _quillController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'Note Title...',
              hintStyle: GoogleFonts.poppins(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                fontSize: 18,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            style: GoogleFonts.poppins(
              color: theme.colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
        ),
        actions: [
          // Generate Quiz Button
          // Generate Quiz Button
          IconButton(
            onPressed: _isGeneratingQuiz 
                ? null 
                : () async {
                    final plainText = _quillController.document.toPlainText().trim();
                    if (plainText.isEmpty || plainText.length < 50) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(LucideIcons.alertCircle, color: Colors.white),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Add more content (at least 50 characters) to generate a quiz',
                                  style: GoogleFonts.poppins(),
                                ),
                              ),
                            ],
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    setState(() => _isGeneratingQuiz = true);

                    try {
                      final quiz = await ref.read(quizProvider.notifier).generateQuiz(
                        content: plainText,
                        title: _titleController.text.isNotEmpty 
                            ? 'Quiz: ${_titleController.text}' 
                            : 'AI Generated Quiz',
                        noteId: widget.existingNote?.id,
                        subjectId: widget.subjectId,
                      );

                      if (quiz != null && context.mounted) {
                        context.push('/home/quiz/${quiz.id}');
                      }
                    } finally {
                      if (mounted) {
                        setState(() => _isGeneratingQuiz = false);
                      }
                    }
                  },
            icon: _isGeneratingQuiz
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onSurface,
                    ),
                  )
                : Icon(
                    LucideIcons.sparkles,
                    size: 24,
                    color: theme.colorScheme.onSurface,
                  ),
            tooltip: 'Generate Quiz with AI',
          ),
          // Save Button - Modern Design
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ModernElevatedButton(
              onPressed: () {
                if (_titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(LucideIcons.alertCircle, color: Colors.white),
                          const SizedBox(width: 12),
                          Text(
                            'Please add a title',
                            style: GoogleFonts.poppins(),
                          ),
                        ],
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                final contentJson = jsonEncode(_quillController.document.toDelta().toJson());

                if (widget.existingNote != null) {
                  // Update
                  ref.read(noteProvider.notifier).updateNote(
                    noteId: widget.existingNote!.id,
                    subjectId: widget.subjectId,
                    title: _titleController.text.trim(),
                    content: contentJson,
                  );
                } else {
                  // Create
                  ref.read(noteProvider.notifier).createNote(
                    subjectId: widget.subjectId,
                    title: _titleController.text.trim(),
                    content: contentJson,
                  );
                }
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(LucideIcons.checkCircle, color: Colors.white),
                        const SizedBox(width: 12),
                        Text(
                          widget.existingNote != null ? 'Note updated!' : 'Note saved!',
                          style: GoogleFonts.poppins(),
                        ),
                      ],
                    ),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
                
                context.pop();
              },
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.check,
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Save',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Modern Toolbar Container
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Quill Simple Toolbar with custom styling
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: QuillSimpleToolbar(
                    controller: _quillController,
                  ),
                ),
                // Divider with gradient
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        theme.colorScheme.outline.withValues(alpha: 0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: -0.1, end: 0),
          // Quill Editor with modern styling
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: QuillEditor.basic(
                controller: _quillController,
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 200.ms)
                .scale(begin: const Offset(0.98, 0.98), end: const Offset(1, 1), delay: 200.ms),
          ),
        ],
      ),
    );
  }
}