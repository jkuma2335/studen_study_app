import 'package:dio/dio.dart';
import 'package:mobile_app/core/api_client.dart';
import 'package:mobile_app/core/constants/api_constants.dart';
import 'package:mobile_app/features/dashboard/domain/dashboard_stats.dart';

class DashboardRepository {
  final Dio _dio = apiClient.dio;

  Future<DashboardStats> getDashboardStats() async {
    try {
      final response = await _dio.get('/dashboard');
      return DashboardStats.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to fetch dashboard stats: ${e.message}');
    }
  }
}

