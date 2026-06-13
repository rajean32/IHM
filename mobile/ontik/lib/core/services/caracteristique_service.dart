import '../api/caracteristique_api.dart';

class CaracteristiqueService {
  final _api = CaracteristiqueApi();

  Future<List<dynamic>> getByCategorie(String codeCategorie) => _api.getByCategorie(codeCategorie);
  Future<Map<String, dynamic>> getById(int id) => _api.getById(id);
  Future<Map<String, dynamic>> create(Map<String, dynamic> data) => _api.create(data);
  Future<Map<String, dynamic>> update(int id, Map<String, dynamic> data) => _api.update(id, data);
  Future<void> delete(int id) => _api.delete(id);
}
