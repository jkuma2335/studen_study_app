import 'package:dio/dio.dart';
import 'package:mobile_app/core/api_client.dart';
import 'package:mobile_app/core/constants/api_constants.dart';
import 'package:mobile_app/features/planner/domain/study_session.dart';

class PlannerRepository {
  final Dio _dio = apiClient.dio;

  /// Get sessions for a date range
  /// GET /study-sessions/planner?startDate=...&endDate=...
  Future<List<StudySession>> getSessions(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.studySessions}/planner',
        queryParameters: {
          'startDate': start.toIso8601String(),
          'endDate': end.toIso8601String(),
        },
      );

      if (response.data is List) {
        return (response.data as List<dynamic>)
            .map((json) => StudySession.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw Exception('Failed to fetch sessions: ${e.message}');
    }
  }

  /// Create a study session
  /// POST /study-sessions
  /// Returns a single session or list of sessions (if recurring)
  Future<dynamic> createSession(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        ApiConstants.studySessions,
        data: data,
      );

      // If recurrenceRule is provided, backend returns an array
      if (response.data is List) {
        return (response.data as List<dynamic>)
            .map((json) => StudySession.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      // Otherwise, returns a single session
      return StudySession.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to create session: ${e.message}');
    }
  }

  /// Update session status
  /// PATCH /study-sessions/:id/status
  Future<StudySession> updateStatus(String id, String status) async {
    try {
      final response = await _dio.patch(
        '${ApiConstants.studySessions}/$id/status',
        data: { 'status': status },
      );

      return StudySession.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to update session status: ${e.message}');
    }
  }
}

