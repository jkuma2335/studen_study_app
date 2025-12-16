import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/api_client.dart';
import 'package:mobile_app/features/quiz/data/quiz_repository.dart';
import 'package:mobile_app/features/quiz/domain/quiz.dart';

class QuizState {
  final bool isLoading;
  final bool isGenerating;
  final String? error;
  final Quiz? currentQuiz;
  final List<Quiz> history;
  final Map<String, int> selectedAnswers; // questionId -> selectedIndex

  QuizState({
    this.isLoading = false,
    this.isGenerating = false,
    this.error,
    this.currentQuiz,
    this.history = const [],
    this.selectedAnswers = const {},
  });

  QuizState copyWith({
    bool? isLoading,
    bool? isGenerating,
    String? error,
    Quiz? currentQuiz,
    List<Quiz>? history,
    Map<String, int>? selectedAnswers,
  }) {
    return QuizState(
      isLoading: isLoading ?? this.isLoading,
      isGenerating: isGenerating ?? this.isGenerating,
      error: error,
      currentQuiz: currentQuiz ?? this.currentQuiz,
      history: history ?? this.history,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
    );
  }
}

class QuizNotifier extends StateNotifier<QuizState> {
  final QuizRepository _repository;

  QuizNotifier(this._repository) : super(QuizState());

  Future<Quiz?> generateQuiz({
    required String content,
    String? title,
    String? noteId,
    String? subjectId,
    int numQuestions = 5,
  }) async {
    state = state.copyWith(isGenerating: true, error: null, selectedAnswers: {});
    try {
      final quiz = await _repository.generateQuiz(
        content: content,
        title: title,
        noteId: noteId,
        subjectId: subjectId,
        numQuestions: numQuestions,
      );
      state = state.copyWith(isGenerating: false, currentQuiz: quiz);
      return quiz;
    } catch (e) {
      state = state.copyWith(isGenerating: false, error: e.toString());
      return null;
    }
  }

  Future<void> loadQuiz(String id) async {
    state = state.copyWith(isLoading: true, error: null, selectedAnswers: {});
    try {
      final quiz = await _repository.getQuiz(id);
      state = state.copyWith(isLoading: false, currentQuiz: quiz);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final history = await _repository.getHistory();
      state = state.copyWith(isLoading: false, history: history);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectAnswer(String questionId, int answerIndex) {
    final newAnswers = Map<String, int>.from(state.selectedAnswers);
    newAnswers[questionId] = answerIndex;
    state = state.copyWith(selectedAnswers: newAnswers);
  }

  Future<Quiz?> submitQuiz() async {
    if (state.currentQuiz == null) return null;
    
    state = state.copyWith(isLoading: true, error: null);
    try {
      final answers = state.selectedAnswers.entries.map((e) => {
        'questionId': e.key,
        'answerIndex': e.value,
      }).toList();

      final result = await _repository.submitQuiz(state.currentQuiz!.id, answers);
      state = state.copyWith(isLoading: false, currentQuiz: result);
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  void clearQuiz() {
    state = QuizState(history: state.history);
  }
}

final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return QuizRepository(ApiClient());
});

final quizProvider = StateNotifierProvider<QuizNotifier, QuizState>((ref) {
  return QuizNotifier(ref.read(quizRepositoryProvider));
});
