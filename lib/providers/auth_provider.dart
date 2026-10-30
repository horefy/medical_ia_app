import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider((ref) => AuthService());

final authStateProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});

class AuthNotifier extends StateNotifier<bool> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(false) {
    checkAuth();
  }

  Future<void> checkAuth() async {
    state = await _authService.isLoggedIn();
  }

  Future<bool> login(String username, String password) async {
    final success = await _authService.login(username, password);
    if (success) state = true;
    return success;
  }

  Future<void> logout() async {
    await _authService.logout();
    state = false;
  }
}
