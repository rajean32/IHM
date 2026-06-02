import '../api/auth_api.dart';
import '../api/dio_config.dart';

class AuthService {
  final _authApi = AuthApi();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await _authApi.login(email, password);
    await setToken(data['token'] as String?);
    await setUserInfo(data);
    return data;
  }

  Future<void> register(Map<String, dynamic> userData) async {
    await _authApi.register(userData);
  }

  Future<void> firstLogin(String email, String password) async {
    await _authApi.firstLogin(email, password);
  }

  Future<void> logout() async {
    await clearSession();
  }
}
