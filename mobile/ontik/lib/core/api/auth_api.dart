import 'dio_config.dart';
import 'endpoints.dart';

class AuthApi {
  Future<Map<String, dynamic>> login(String email, String password) async {
    final resp = await dio.post(Endpoints.login, data: {
      'email': email,
      'motDePasse': password,
    });
    final data = resp.data['data'] as Map<String, dynamic>;
    await setToken(data['token'] as String?);
    await setUserInfo(data);
    return data;
  }

  Future<void> register(Map<String, dynamic> userData) async {
    await dio.post(Endpoints.register, data: userData);
  }

  Future<void> firstLogin(String email, String password) async {
    await dio.put(Endpoints.firstLogin, data: {
      'email': email,
      'motDePasse': password,
    });
  }

  Future<void> logout() async {
    await clearSession();
  }
}
