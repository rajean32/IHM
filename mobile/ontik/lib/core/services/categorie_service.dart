import '../api/categorie_api.dart';

class CategorieService {
  final _api = CategorieApi();

  Future<List<dynamic>> getCategories() => _api.getCategories();
  Future<Map<String, dynamic>> createCategory(Map<String, dynamic> data) => _api.createCategory(data);
  Future<void> deleteCategory(String code) => _api.deleteCategory(code);
  // modification
  // Future<void> editCategory(String code) => _api.editCategory(code);
}
