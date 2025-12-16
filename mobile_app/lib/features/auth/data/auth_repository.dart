import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_app/core/api_client.dart';

class AuthRepository {
  final Dio _dio = ApiClient().dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'access_token';

  /// Login user
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final accessToken = response.data['accessToken'] as String;
      
      // Save token to secure storage
      await _storage.write(key: _tokenKey, value: accessToken);

      return {
        'success': true,
        'accessToken': accessToken,
        'user': response.data['user'],
      };
    } on DioException catch (e) {
      String errorMessage = 'Login failed';
      if (e.response != null) {
        errorMessage = e.response?.data['message'] ?? 
                      e.response?.statusMessage ?? 
                      'Login failed';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout. Please check your internet.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Server response timeout.';
      }
      
      return {
        'success': false,
        'error': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }

  /// Register new user
  Future<Map<String, dynamic>> register(
    String fullName,
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'fullName': fullName,
          'email': email,
          'password': password,
        },
      );

      final accessToken = response.data['accessToken'] as String;
      
      // Save token to secure storage
      await _storage.write(key: _tokenKey, value: accessToken);

      return {
        'success': true,
        'accessToken': accessToken,
        'user': response.data['user'],
      };
    } on DioException catch (e) {
      String errorMessage = 'Registration failed';
      if (e.response != null) {
        errorMessage = e.response?.data['message'] ?? 
                      e.response?.statusMessage ?? 
                      'Registration failed';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout. Please check your internet.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Server response timeout.';
      }
      
      return {
        'success': false,
        'error': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }

  /// Logout user
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Get stored token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Check if user is logged in (has valid token)
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return false;
    }
    
    // Check if token is expired using jwt_decoder
    try {
      // We'll validate this in the auth provider
      return true;
    } catch (e) {
      return false;
    }
  }
}

