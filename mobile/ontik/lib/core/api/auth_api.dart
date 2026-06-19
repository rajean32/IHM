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

  Future<Map<String, dynamic>> firstLogin(String code, String email, String password, {String? ville, String? villeCode}) async {
    final resp = await dio.post(Endpoints.firstLogin, data: {
      'codeUtilisateur': code,
      'newEmail': email,
      'newPassword': password,
      if (ville != null) 'ville': ville,
      if (villeCode != null) 'villeCode': villeCode,
    });
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    await dio.put(Endpoints.changePassword, data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  Future<void> updateVille(String codeUtilisateur, String ville, {String? villeCode}) async {
    await dio.put(Endpoints.updateVille, data: {
      'codeUtilisateur': codeUtilisateur,
      'ville': ville,
      if (villeCode != null) 'villeCode': villeCode,
    });
  }

  Future<void> logout() async {
    await clearSession();
  }
}
