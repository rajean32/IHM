import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_client.dart';
import '../core/api_endpoints.dart';
import '../models/api_wrapper.dart';
import '../models/user.dart';

class AuthRepository {
  final ApiClient _client;

  AuthRepository(this._client);

  Future<void> saveSession(LoginResponse user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', user.token);
    await prefs.setString('role', user.role);
    await prefs.setString('userCode', user.codeUtilisateur);
    await prefs.setString('userEmail', user.email);
    await prefs.setString('needsFirstLogin', user.isFirstLogin.toString());
  }

  Future<LoginResponse> login(String email, String password) async {
    final response = await _client.post(
      ApiEndpoints.auth.login,
      data: {
        'email': email,
        'motDePasse': password,
      },
    );
    final wrapper = ApiWrapper.fromJson(response);
    final loginResp = wrapper.getData((d) => LoginResponse.fromJson(d));

    await saveSession(loginResp);

    return loginResp;
  }

  Future<LoginResponse> firstLoginUpdate({
    required String codeUtilisateur,
    required String newPassword,
    required String newEmail,
  }) async {
    final response = await _client.post(
      ApiEndpoints.auth.firstLoginUpdate,
      data: {
        'codeUtilisateur': codeUtilisateur,
        'newPassword': newPassword,
        'newEmail': newEmail,
      },
    );
    final wrapper = ApiWrapper.fromJson(response);
    final loginResp = wrapper.getData((d) => LoginResponse.fromJson(d));
    return loginResp;
  }

  Future<LoginResponse> register({
    required String codeUtilisateur,
    required String nom,
    required String prenoms,
    required String sexe,
    required String dateDeNaissance,
    required String email,
    required String tel,
    required String motDePasse,
    String type = 'client',
  }) async {
    final response = await _client.post(
      ApiEndpoints.auth.register,
      data: {
        'codeUtilisateur': codeUtilisateur,
        'nom': nom,
        'prenoms': prenoms,
        'sexe': sexe,
        'dateDeNaissance': dateDeNaissance,
        'email': email,
        'tel': tel,
        'motDePasse': motDePasse,
        'type': type,
      },
    );
    final wrapper = ApiWrapper.fromJson(response);
    return wrapper.getData((d) => LoginResponse.fromJson(d));
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<Map<String, String?>> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'token': prefs.getString('token'),
      'role': prefs.getString('role'),
      'userCode': prefs.getString('userCode'),
      'userEmail': prefs.getString('userEmail'),
      'needsFirstLogin': prefs.getString('needsFirstLogin'),
    };
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }
}
