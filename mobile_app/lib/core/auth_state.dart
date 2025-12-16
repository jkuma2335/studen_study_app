import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mobile_app/features/auth/data/auth_repository.dart';

/// StateProvider to track authentication status
/// Default: false (not logged in)
final isLoggedInProvider = StateProvider<bool>((ref) => false);

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Auth Notifier to manage authentication state
class AuthNotifier extends StateNotifier<bool> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(false) {
    checkLoginStatus();
  }

  /// Check if user is logged in on app start
  Future<void> checkLoginStatus() async {
    final token = await _repository.getToken();
    if (token != null && token.isNotEmpty) {
      // Check if token is expired
      try {
        if (!JwtDecoder.isExpired(token)) {
          state = true;
          return;
        }
      } catch (e) {
        // Token is invalid, clear it
        await _repository.logout();
      }
    }
    state = false;
  }

  /// Login user
  Future<Map<String, dynamic>> login(String email, String password) async {
    final result = await _repository.login(email, password);
    if (result['success'] == true) {
      state = true;
    }
    return result;
  }

  /// Register user
  Future<Map<String, dynamic>> register(
    String fullName,
    String email,
    String password,
  ) async {
    final result = await _repository.register(fullName, email, password);
    if (result['success'] == true) {
      state = true;
    }
    return result;
  }

  /// Logout user
  Future<void> logout() async {
    await _repository.logout();
    state = false;
  }
}

/// Provider for AuthNotifier
final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
