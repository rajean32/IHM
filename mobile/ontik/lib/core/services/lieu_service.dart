import '../api/lieu_api.dart';

class LieuService {
  final _api = LieuApi();

  Future<List<dynamic>> getLieux() => _api.getLieux();
  Future<Map<String, dynamic>> createLieu(Map<String, dynamic> data) => _api.createLieu(data);
  Future<void> deleteLieu(String code) => _api.deleteLieu(code);
  Future<List<dynamic>> getSalles() => _api.getSalles();
  Future<Map<String, dynamic>> createSalle(Map<String, dynamic> data) => _api.createSalle(data);
}
