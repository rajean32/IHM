import '../api/lieu_api.dart';

class LieuService {
  final _api = LieuApi();

  Future<List<dynamic>> getLieux() => _api.getLieux();
  Future<Map<String, dynamic>> createLieu(Map<String, dynamic> data) => _api.createLieu(data);
  Future<void> deleteLieu(int id) => _api.deleteLieu(id);
  Future<List<dynamic>> getSalles() => _api.getSalles();
}
