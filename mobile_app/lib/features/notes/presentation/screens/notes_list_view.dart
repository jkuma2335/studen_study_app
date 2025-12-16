import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/features/notes/domain/note_model.dart';
import 'package:mobile_app/features/notes/presentation/providers/note_provider.dart';
import 'package:mobile_app/features/notes/screens/note_editor_screen.dart';

class NotesListView extends ConsumerWidget {
  final String subjectId;

  const NotesListView({
    super.key,
    required this.subjectId,
  });

  String _getContentPreview(String content) {
    try {
      // Try to parse as JSON (rich text format)
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
    } catch (e) {
      // Fallback to plain text if not JSON
      if (content.length <= 100) {
        return content;
      }
      return '${content.substring(0, 100)}...';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteState = ref.watch(noteProvider);

    if (noteState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (noteState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: ${noteState.error}',
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(noteProvider.notifier).loadNotes(subjectId);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (noteState.notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No notes yet.\nTap the + button to add one!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: noteState.notes.length,
      itemBuilder: (context, index) {
        final note = noteState.notes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(
              note.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  _getContentPreview(note.content),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('MMM dd, yyyy').format(note.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push(
                '/notes/editor',
                extra: {'note': note, 'subjectId': subjectId},
              );
            },
          ),
        );
      },
    );
  }
}

