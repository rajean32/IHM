import 'dart:io';
import 'package:dio/dio.dart';
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

  Future<void> selfDelete(String code) async {
    await dio.delete('${Endpoints.utilisateurs}/$code');
  }

  Future<Map<String, dynamic>> getOrganizerProfile(String code) async {
    final resp = await dio.get(Endpoints.organizerProfile(code));
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<void> updateOrganizerProfile(String code, Map<String, dynamic> data) async {
    await dio.put(Endpoints.organizerProfile(code), data: data);
  }

  Future<Map<String, dynamic>> getUserProfile(String code) async {
    final resp = await dio.get('${Endpoints.utilisateurs}/$code');
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<void> updateUserProfile(String code, Map<String, dynamic> data) async {
    await dio.put('${Endpoints.utilisateurs}/$code', data: data);
  }

  Future<List<dynamic>> getUserPayments(String code) async {
    final resp = await dio.get('${Endpoints.paiements}/client/$code');
    final data = resp.data['data'];
    if (data is List) return data;
    return [];
  }

  Future<void> uploadPhoto(String code, File file) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: 'profile.jpg'),
    });
    await dio.post('${Endpoints.utilisateurs}/$code/photo', data: formData);
  }
}
