import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/notes/data/note_repository.dart';
import 'package:mobile_app/features/notes/domain/note_model.dart';

class NoteState {
  final List<Note> notes;
  final bool isLoading;
  final String? error;

  NoteState({
    this.notes = const [],
    this.isLoading = false,
    this.error,
  });

  NoteState copyWith({
    List<Note>? notes,
    bool? isLoading,
    String? error,
  }) {
    return NoteState(
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class NoteNotifier extends StateNotifier<NoteState> {
  final NoteRepository _repository;

  NoteNotifier(this._repository) : super(NoteState());

  Future<void> loadNotes(String subjectId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final notes = await _repository.getNotesBySubject(subjectId);
      state = state.copyWith(notes: notes, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadAllNotes() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final notes = await _repository.getAllNotes();
      state = state.copyWith(notes: notes, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createNote({
    required String subjectId,
    required String title,
    required String content,
  }) async {
    try {
      await _repository.createNote(
        subjectId: subjectId,
        title: title,
        content: content,
      );
      await loadNotes(subjectId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateNote({
    required String noteId,
    required String subjectId,
    required String title,
    required String content,
  }) async {
    try {
      await _repository.updateNote(
        noteId: noteId,
        subjectId: subjectId,
        title: title,
        content: content,
      );
      await loadNotes(subjectId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepository();
});

final noteProvider = StateNotifierProvider<NoteNotifier, NoteState>((ref) {
  final repository = ref.watch(noteRepositoryProvider);
  return NoteNotifier(repository);
});

