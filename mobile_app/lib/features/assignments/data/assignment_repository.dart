import 'package:dio/dio.dart';
import 'package:mobile_app/core/api_client.dart';
import 'package:mobile_app/core/constants/api_constants.dart';
import 'package:mobile_app/features/assignments/domain/assignment.dart';

class AssignmentRepository {
  final Dio _dio = apiClient.dio;

  Future<List<Assignment>> getAssignments(String subjectId) async {
    try {
      final response = await _dio.get(
        ApiConstants.assignments,
        queryParameters: {'subjectId': subjectId},
      );
      
      if (response.data is! List) {
        throw FormatException('Expected List, got ${response.data.runtimeType}');
      }
      
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) {
            Map<String, dynamic> jsonMap;
            if (json is Map<String, dynamic>) {
              jsonMap = json;
            } else if (json is Map) {
              jsonMap = Map<String, dynamic>.from(json);
            } else {
              throw FormatException('Invalid JSON format for Assignment: $json');
            }
            return Assignment.fromJson(jsonMap);
          })
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch assignments: ${e.message}');
    } catch (e) {
      throw Exception('Failed to parse assignments: $e');
    }
  }

  Future<List<Assignment>> getAllAssignments() async {
    try {
      print('📡 [AssignmentRepository] Calling GET ${ApiConstants.assignments}');
      final response = await _dio.get(ApiConstants.assignments);
      print('📡 [AssignmentRepository] Response received: ${response.statusCode}');
      
      if (response.data is! List) {
        throw FormatException('Expected List, got ${response.data.runtimeType}');
      }
      
      final List<dynamic> data = response.data as List<dynamic>;
      print('📡 [AssignmentRepository] Parsing ${data.length} items');
      return data
          .map((json) {
            Map<String, dynamic> jsonMap;
            if (json is Map<String, dynamic>) {
              jsonMap = json;
            } else if (json is Map) {
              jsonMap = Map<String, dynamic>.from(json);
            } else {
              throw FormatException('Invalid JSON format for Assignment: $json');
            }
            return Assignment.fromJson(jsonMap);
          })
          .toList();
    } on DioException catch (e) {
      print('❌ [AssignmentRepository] DioException: ${e.message}');
      throw Exception('Failed to fetch all assignments: ${e.message}');
    } catch (e) {
      print('❌ [AssignmentRepository] Error: $e');
      throw Exception('Failed to parse assignments: $e');
    }
  }

  Future<Assignment> createAssignment(
    String subjectId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.assignments,
        data: {
          ...data,
          'subjectId': subjectId,
        },
      );
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
      return Assignment.fromJson(jsonMap);
    } on DioException catch (e) {
      throw Exception('Failed to create assignment: ${e.message}');
    } catch (e) {
      throw Exception('Failed to parse assignment: $e');
    }
  }

  Future<Assignment> updateAssignment(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.patch(
        '${ApiConstants.assignments}/$id',
        data: data,
      );

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
      return Assignment.fromJson(jsonMap);
    } on DioException catch (e) {
      throw Exception('Failed to update assignment: ${e.message}');
    } catch (e) {
      throw Exception('Failed to parse assignment: $e');
    }
  }

  Future<Assignment> toggleComplete(String id, String currentStatus) async {
    try {
      // Convert current status to new status
      String newStatus;
      if (currentStatus == 'COMPLETED') {
        newStatus = 'NOT_STARTED';
      } else if (currentStatus == 'IN_PROGRESS') {
        newStatus = 'COMPLETED';
      } else {
        // NOT_STARTED -> IN_PROGRESS
        newStatus = 'IN_PROGRESS';
      }

      final response = await _dio.patch(
        '${ApiConstants.assignments}/$id',
        data: {
          'status': newStatus,
        },
      );

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
      return Assignment.fromJson(jsonMap);
    } on DioException catch (e) {
      throw Exception('Failed to toggle assignment: ${e.message}');
    }
  }
}

