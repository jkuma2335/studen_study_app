// Quiz domain models

class Quiz {
  final String id;
  final String title;
  final String userId;
  final String? noteId;
  final String? subjectId;
  final int totalQuestions;
  final int? score;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final List<QuizQuestion> questions;

  Quiz({
    required this.id,
    required this.title,
    required this.userId,
    this.noteId,
    this.subjectId,
    required this.totalQuestions,
    this.score,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
    this.questions = const [],
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Quiz',
      userId: json['userId'] ?? '',
      noteId: json['noteId'],
      subjectId: json['subjectId'],
      totalQuestions: json['totalQuestions'] ?? 0,
      score: json['score'],
      isCompleted: json['isCompleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      questions: (json['questions'] as List?)?.map((q) => QuizQuestion.fromJson(q)).toList() ?? [],
    );
  }

  int get scorePercent {
    if (totalQuestions == 0) return 0;
    return ((score ?? 0) / totalQuestions * 100).round();
  }
}

class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String? explanation;
  final String quizId;
  final int? userAnswer;
  final bool? isCorrect;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    this.explanation,
    required this.quizId,
    this.userAnswer,
    this.isCorrect,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      options: (json['options'] as List?)?.cast<String>() ?? [],
      correctOptionIndex: json['correctOptionIndex'] ?? 0,
      explanation: json['explanation'],
      quizId: json['quizId'] ?? '',
      userAnswer: json['userAnswer'],
      isCorrect: json['isCorrect'],
    );
  }
}
