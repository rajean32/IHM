import 'package:shared_preferences/shared_preferences.dart';
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

  Future<Map<String, dynamic>> firstLogin(String code, String email, String password, {String? ville, String? villeCode}) async {
    final data = await _authApi.firstLogin(code, email, password, ville: ville, villeCode: villeCode);
    await setToken(data['token'] as String?);
    await setUserInfo(data);
    return data;
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    await _authApi.changePassword(currentPassword, newPassword);
  }

  Future<void> updateVille(String ville, {String? villeCode}) async {
    final code = userCode;
    if (code == null) return;
    await _authApi.updateVille(code, ville, villeCode: villeCode);
    userVille = ville;
    userVilleCode = villeCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userVille', ville);
    if (villeCode != null) await prefs.setString('userVilleCode', villeCode);
  }

  Future<void> logout() async {
    await clearSession();
  }
}
