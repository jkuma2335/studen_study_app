import 'package:mobile_app/core/api_client.dart';
import 'package:mobile_app/features/quiz/domain/quiz.dart';

class QuizRepository {
  final ApiClient _apiClient;

  QuizRepository(this._apiClient);

  Future<Quiz> generateQuiz({
    required String content,
    String? title,
    String? noteId,
    String? subjectId,
    int numQuestions = 5,
  }) async {
    final response = await _apiClient.post('/quiz/generate', data: {
      'content': content,
      if (title != null) 'title': title,
      if (noteId != null) 'noteId': noteId,
      if (subjectId != null) 'subjectId': subjectId,
      'numQuestions': numQuestions,
    });
    return Quiz.fromJson(response.data);
  }

  Future<Quiz> getQuiz(String id) async {
    final response = await _apiClient.get('/quiz/$id');
    return Quiz.fromJson(response.data);
  }

  Future<List<Quiz>> getHistory() async {
    final response = await _apiClient.get('/quiz/history');
    return (response.data as List).map((json) => Quiz.fromJson(json)).toList();
  }

  Future<Quiz> submitQuiz(String quizId, List<Map<String, dynamic>> answers) async {
    final response = await _apiClient.post('/quiz/$quizId/submit', data: {
      'answers': answers,
    });
    return Quiz.fromJson(response.data);
  }

  Future<void> deleteQuiz(String id) async {
    await _apiClient.delete('/quiz/$id');
  }
}
