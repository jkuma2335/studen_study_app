import 'package:mobile_app/core/api_client.dart';
import 'package:mobile_app/features/analytics/domain/analytics_models.dart';

class AnalyticsRepository {
  final ApiClient _apiClient;

  AnalyticsRepository(this._apiClient);

  Future<StudySummary> getSummary() async {
    final response = await _apiClient.get('/analytics/summary');
    return StudySummary.fromJson(response.data);
  }

  Future<List<DailyStudyData>> getDailyStats({int days = 7}) async {
    final response = await _apiClient.get('/analytics/daily', queryParameters: {
      'days': days.toString(),
    });
    return (response.data as List)
        .map((json) => DailyStudyData.fromJson(json))
        .toList();
  }

  Future<List<SubjectStudyData>> getBySubject() async {
    final response = await _apiClient.get('/analytics/by-subject');
    return (response.data as List)
        .map((json) => SubjectStudyData.fromJson(json))
        .toList();
  }

  Future<StreakData> getStreaks() async {
    final response = await _apiClient.get('/analytics/streaks');
    return StreakData.fromJson(response.data);
  }

  Future<AnalyticsData> getAllAnalytics() async {
    final results = await Future.wait([
      getSummary(),
      getDailyStats(days: 7),
      getBySubject(),
      getStreaks(),
    ]);

    return AnalyticsData(
      summary: results[0] as StudySummary,
      dailyData: results[1] as List<DailyStudyData>,
      subjectData: results[2] as List<SubjectStudyData>,
      streaks: results[3] as StreakData,
    );
  }
}
