import '../api/lieu_api.dart';

class LieuService {
  final _api = LieuApi();

  Future<List<dynamic>> getLieux() => _api.getLieux();
  Future<Map<String, dynamic>> createLieu(Map<String, dynamic> data) => _api.createLieu(data);
  Future<void> deleteLieu(String code) => _api.deleteLieu(code);
  Future<List<dynamic>> getSalles() => _api.getSalles();
  Future<List<dynamic>> getSallesByLieu(String codeLieu) => _api.getSallesByLieu(codeLieu);
  Future<List<dynamic>> getSallesCompatible(String codeLieu, String codeCategorie) => _api.getSallesCompatible(codeLieu, codeCategorie);
  Future<Map<String, dynamic>> createSalle(Map<String, dynamic> data) => _api.createSalle(data);
  Future<Map<String, dynamic>> updateSalle(String numero, Map<String, dynamic> data) => _api.updateSalle(numero, data);
  Future<void> deleteSalle(String numero) => _api.deleteSalle(numero);
}
