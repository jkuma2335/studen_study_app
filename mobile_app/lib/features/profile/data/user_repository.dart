import 'package:dio/dio.dart';
import 'package:mobile_app/core/api_client.dart';

class UserRepository {
  final Dio _dio = ApiClient().dio;

  /// Get current user profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get('/users/me');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch profile');
    }
  }

  /// Get profile stats (total hours, completed tasks, streak)
  Future<Map<String, dynamic>> getProfileStats() async {
    try {
      final response = await _dio.get('/users/me/stats');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch stats');
    }
  }
}

