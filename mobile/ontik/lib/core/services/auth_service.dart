import '../api/auth_api.dart';
import '../api/dio_config.dart';

class AuthService {
  final _authApi = AuthApi();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await _authApi.login(email, password);
    return data;
  }

  Future<void> register(Map<String, dynamic> userData) async {
    await _authApi.register(userData);
  }

  Future<Map<String, dynamic>> firstLogin(String code, String email, String password) async {
    final data = await _authApi.firstLogin(code, email, password);
    await setToken(data['token'] as String?);
    await setUserInfo(data);
    return data;
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    await _authApi.changePassword(currentPassword, newPassword);
  }

  Future<void> logout() async {
    await clearSession();
  }
}
