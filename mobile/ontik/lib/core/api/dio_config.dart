import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

String? _token;
String? userCode;
String? userRole;
String? userNom;
String? userVille;

final Dio dio = Dio(BaseOptions(
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 10),
  headers: {'Content-Type': 'application/json'},
));

Future<void> init() async {
  final prefs = await SharedPreferences.getInstance();
  _token = prefs.getString('token');
  userCode = prefs.getString('userCode');
  userRole = prefs.getString('userRole');
  userNom = prefs.getString('userNom');
  userVille = prefs.getString('userVille');
  if (_token != null) {
    dio.options.headers['Authorization'] = 'Bearer $_token';
  }
  dio.interceptors.add(_authInterceptor());
}

Interceptor _authInterceptor() {
  return InterceptorsWrapper(
    onError: (error, handler) async {
      if (error.response?.statusCode == 401) {
        await clearSession();
      }
      handler.next(error);
    },
  );
}

Future<void> setToken(String? token) async {
  _token = token;
  final prefs = await SharedPreferences.getInstance();
  if (token != null) {
    await prefs.setString('token', token);
    dio.options.headers['Authorization'] = 'Bearer $token';
  } else {
    await prefs.remove('token');
    dio.options.headers.remove('Authorization');
  }
}

Future<String?> getToken() async {
  if (_token != null) return _token;
  final prefs = await SharedPreferences.getInstance();
  _token = prefs.getString('token');
  return _token;
}

Future<bool> isAuthenticated() async {
  final t = await getToken();
  return t != null && t.isNotEmpty;
}

Future<void> setUserInfo(Map<String, dynamic> data) async {
  userCode = data['codeUtilisateur'] as String?;
  userRole = data['role'] as String?;
  userNom = data['nom'] as String?;
  userVille = data['ville'] as String?;
  final prefs = await SharedPreferences.getInstance();
  if (userCode != null) await prefs.setString('userCode', userCode!);
  if (userRole != null) await prefs.setString('userRole', userRole!);
  if (userNom != null) await prefs.setString('userNom', userNom!);
  if (userVille != null) await prefs.setString('userVille', userVille!);
}

bool get isLoggedInSync => _token != null && _token!.isNotEmpty;

bool get hasRoleSync => userRole != null && userRole!.isNotEmpty;

Future<void> clearSession() async {
  await setToken(null);
  userCode = null;
  userRole = null;
  userNom = null;
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('userCode');
  await prefs.remove('userRole');
  await prefs.remove('userNom');
}
