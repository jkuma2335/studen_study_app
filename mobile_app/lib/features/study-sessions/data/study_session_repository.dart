import 'package:dio/dio.dart';
import 'package:mobile_app/core/api_client.dart';
import 'package:mobile_app/core/constants/api_constants.dart';

class StudySessionRepository {
  final Dio _dio = apiClient.dio;

  Future<void> logSession({
    required String subjectId,
    required int durationMinutes,
    DateTime? startTime,
  }) async {
    try {
      await _dio.post(
        ApiConstants.studySessions,
        data: {
          'subjectId': subjectId,
          'durationMinutes': durationMinutes,
          'status': 'COMPLETED',
          if (startTime != null) 'startTime': startTime.toIso8601String(),
        },
      );
    } on DioException catch (e) {
      throw Exception('Failed to log study session: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> getStatsBySubject(String subjectId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.studySessions}/stats/$subjectId',
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Failed to fetch stats: ${e.message}');
    }
  }
}

