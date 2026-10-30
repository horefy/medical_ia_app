import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_client.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<bool> login(String username, String password) async {
    try {
      final response = await _apiClient.dio.post('/auth/login/', data: {
        'username': username,
        'password': password,
      });
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', response.data['access']);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    try {
      await _apiClient.dio.post('/auth/register/', data: {
        'username': username,
        'email': email,
        'password': password,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('access_token');
  }
}
