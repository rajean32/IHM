import 'dio_config.dart';
import 'endpoints.dart';

class CategorieApi {
  Future<List<dynamic>> getCategories() async {
    final resp = await dio.get(Endpoints.categories);
    return (resp.data['data'] as List?) ?? [];
  }

  Future<Map<String, dynamic>> getCategory(String code) async {
    final resp = await dio.get('${Endpoints.categories}/$code');
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createCategory(Map<String, dynamic> data) async {
    final resp = await dio.post(Endpoints.categories, data: data);
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateCategory(String code, Map<String, dynamic> data) async {
    final resp = await dio.put('${Endpoints.categories}/$code', data: data);
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<void> deleteCategory(String code) async {
    await dio.delete('${Endpoints.categories}/$code');
  }

  Future<void> addSalleType(String code, String numeroSalle) async {
    await dio.post('${Endpoints.categories}/$code/salle-types/$numeroSalle');
  }

  Future<void> removeSalleType(String code, String numeroSalle) async {
    await dio.delete('${Endpoints.categories}/$code/salle-types/$numeroSalle');
  }

  Future<Map<String, dynamic>?> getCategorieSpecificConfig(String code) async {
    try {
      final resp = await dio.get('${Endpoints.categories}/$code/config');
      return resp.data['data'] as Map<String, dynamic>?;
    } catch (_) { return null; }
  }

  Future<void> updateCategorieSpecificConfig(String code, Map<String, dynamic> config) async {
    await dio.put('${Endpoints.categories}/$code/config', data: config);
  }
}
