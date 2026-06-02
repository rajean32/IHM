import 'dio_config.dart';
import 'endpoints.dart';

class UserApi {
  Future<List<dynamic>> getUsers() async {
    final resp = await dio.get(Endpoints.users);
    return (resp.data['data'] as List?) ?? [];
  }

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> data) async {
    final resp = await dio.post(Endpoints.users, data: data);
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<void> updateUser(String code, Map<String, dynamic> data) async {
    await dio.put('${Endpoints.users}/$code', data: data);
  }

  Future<void> deleteUser(String code) async {
    await dio.delete('${Endpoints.users}/$code');
  }

  Future<Map<String, dynamic>> getOrganizerProfile(String code) async {
    final resp = await dio.get(Endpoints.organizerProfile(code));
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<void> updateOrganizerProfile(String code, Map<String, dynamic> data) async {
    await dio.put(Endpoints.organizerProfile(code), data: data);
  }
}
