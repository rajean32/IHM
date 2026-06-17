import '../api/user_api.dart';

class UserService {
  final _api = UserApi();

  Future<List<dynamic>> getUsers() => _api.getUsers();
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> data) => _api.createUser(data);
  Future<void> updateUser(String code, Map<String, dynamic> data) => _api.updateUser(code, data);
  Future<void> deleteUser(String code) => _api.deleteUser(code);
  Future<Map<String, dynamic>> getOrganizerProfile(String code) => _api.getOrganizerProfile(code);
  Future<void> updateOrganizerProfile(String code, Map<String, dynamic> data) => _api.updateOrganizerProfile(code, data);
  Future<Map<String, dynamic>> getUserProfile(String code) => _api.getUserProfile(code);
  Future<void> updateUserProfile(String code, Map<String, dynamic> data) => _api.updateUserProfile(code, data);
  Future<List<dynamic>> getUserPayments(String code) => _api.getUserPayments(code);
  Future<void> deleteSelfAccount(String code) => _api.selfDelete(code);
}
