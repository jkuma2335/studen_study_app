import 'package:dio/dio.dart';
import 'package:mobile_app/core/api_client.dart';
import 'package:mobile_app/core/constants/api_constants.dart';
import 'package:mobile_app/features/notes/domain/note_model.dart';

class NoteRepository {
  final Dio _dio = ApiClient().dio;

  Future<List<Note>> getNotesBySubject(String subjectId) async {
    try {
      final response = await _dio.get(
        ApiConstants.notes,
        queryParameters: {'subjectId': subjectId},
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => Note.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch notes: ${e.message}');
    }
  }

  Future<List<Note>> getAllNotes() async {
    try {
      final response = await _dio.get(ApiConstants.notes);
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => Note.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch all notes: ${e.message}');
    }
  }

  Future<Note> createNote({
    required String subjectId,
    required String title,
    required String content,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.notes,
        data: {
          'subjectId': subjectId,
          'title': title,
          'content': content,
        },
      );
      return Note.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to create note: ${e.message}');
    }
  }

  Future<Note> updateNote({
    required String noteId,
    required String subjectId,
    required String title,
    required String content,
  }) async {
    try {
      final response = await _dio.patch(
        '${ApiConstants.notes}/$noteId',
        data: {
          'subjectId': subjectId,
          'title': title,
          'content': content,
        },
      );
      return Note.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to update note: ${e.message}');
    }
  }
}

