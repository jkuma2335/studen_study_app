import 'package:dio/dio.dart';
import 'package:mobile_app/core/api_client.dart';
import 'package:mobile_app/core/constants/api_constants.dart';
import 'package:mobile_app/features/subjects/domain/subject.dart';
import 'package:mobile_app/features/subjects/domain/schedule_model.dart';

class SubjectRepository {
  final Dio _dio = ApiClient().dio;

  Future<List<Subject>> getSubjects() async {
    try {
      final response = await _dio.get(ApiConstants.subjects);
      
      // Ensure response.data is a List
      if (response.data is! List) {
        throw FormatException('Expected List, got ${response.data.runtimeType}');
      }
      
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) {
            // Convert to Map<String, dynamic> if needed
            Map<String, dynamic> jsonMap;
            if (json is Map<String, dynamic>) {
              jsonMap = json;
            } else if (json is Map) {
              jsonMap = Map<String, dynamic>.from(json);
            } else {
              throw FormatException('Invalid JSON format for Subject: $json');
            }
            return Subject.fromJson(jsonMap);
          })
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch subjects: ${e.message}');
    } catch (e) {
      throw Exception('Failed to parse subjects: $e');
    }
  }

  Future<Subject> createSubject({
    required String name,
    String? color,
    String? teacherName,
    String? teacherEmail,
    String? teacherPhone,
    double? studyGoalHours,
    String? category,
    String? difficulty,
    List<ScheduleItem>? schedules,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name,
        if (color != null) 'color': color,
        if (teacherName != null) 'teacherName': teacherName,
        if (teacherEmail != null) 'teacherEmail': teacherEmail,
        if (teacherPhone != null) 'teacherPhone': teacherPhone,
        if (studyGoalHours != null) 'studyGoalHours': studyGoalHours,
        if (category != null) 'category': category,
        if (difficulty != null) 'difficulty': difficulty,
        if (schedules != null && schedules.isNotEmpty)
          'schedules': schedules.map((schedule) => schedule.toCreateDto()).toList(),
      };

      final response = await _dio.post(
        ApiConstants.subjects,
        data: data,
      );
      
      // Convert response.data to Map<String, dynamic>
      Map<String, dynamic> jsonMap;
      if (response.data is Map<String, dynamic>) {
        jsonMap = response.data as Map<String, dynamic>;
      } else if (response.data is Map) {
        jsonMap = Map<String, dynamic>.from(response.data as Map);
      } else {
        throw FormatException(
          'Invalid response format. Expected Map, got: ${response.data.runtimeType}',
        );
      }
      
      return Subject.fromJson(jsonMap);
    } on DioException catch (e) {
      throw Exception('Failed to create subject: ${e.message}');
    }
  }

  Future<Subject> updateSubject({
    required String id,
    String? name,
    String? color,
    String? teacherName,
    String? teacherEmail,
    String? teacherPhone,
    double? studyGoalHours,
    String? category,
    String? difficulty,
    List<ScheduleItem>? schedules,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (color != null) data['color'] = color;
      if (teacherName != null) data['teacherName'] = teacherName;
      if (teacherEmail != null) data['teacherEmail'] = teacherEmail;
      if (teacherPhone != null) data['teacherPhone'] = teacherPhone;
      if (studyGoalHours != null) data['studyGoalHours'] = studyGoalHours;
      if (category != null) data['category'] = category;
      if (difficulty != null) data['difficulty'] = difficulty;
      if (schedules != null) {
        data['schedules'] = schedules.map((schedule) => schedule.toCreateDto()).toList();
      }

      final response = await _dio.patch(
        '${ApiConstants.subjects}/$id',
        data: data,
      );
      
      // Convert response.data to Map<String, dynamic>
      Map<String, dynamic> jsonMap;
      if (response.data is Map<String, dynamic>) {
        jsonMap = response.data as Map<String, dynamic>;
      } else if (response.data is Map) {
        jsonMap = Map<String, dynamic>.from(response.data as Map);
      } else {
        throw FormatException(
          'Invalid response format. Expected Map, got: ${response.data.runtimeType}',
        );
      }
      
      return Subject.fromJson(jsonMap);
    } on DioException catch (e) {
      throw Exception('Failed to update subject: ${e.message}');
    }
  }

  Future<void> deleteSubject(String id) async {
    try {
      await _dio.delete('${ApiConstants.subjects}/$id');
    } on DioException catch (e) {
      throw Exception('Failed to delete subject: ${e.message}');
    }
  }
}

