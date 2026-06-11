import '../api/categorie_api.dart';

class CategorieService {
  final _api = CategorieApi();

  Future<List<dynamic>> getCategories() => _api.getCategories();
  Future<Map<String, dynamic>> getCategory(String code) => _api.getCategory(code);
  Future<Map<String, dynamic>> createCategory(Map<String, dynamic> data) => _api.createCategory(data);
  Future<Map<String, dynamic>> updateCategory(String code, Map<String, dynamic> data) => _api.updateCategory(code, data);
  Future<void> deleteCategory(String code) => _api.deleteCategory(code);
  Future<void> addSalleType(String code, String numeroSalle) => _api.addSalleType(code, numeroSalle);
  Future<void> removeSalleType(String code, String numeroSalle) => _api.removeSalleType(code, numeroSalle);
  Future<Map<String, dynamic>?> getCategorieSpecificConfig(String code) => _api.getCategorieSpecificConfig(code);
  Future<void> updateCategorieSpecificConfig(String code, Map<String, dynamic> config) => _api.updateCategorieSpecificConfig(code, config);
}
