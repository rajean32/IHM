import 'dio_config.dart';
import 'endpoints.dart';

class CategorieApi {
  Future<List<dynamic>> getCategories() async {
    final resp = await dio.get(Endpoints.categories);
    return (resp.data['data'] as List?) ?? [];
  }

  Future<Map<String, dynamic>> createCategory(Map<String, dynamic> data) async {
    final resp = await dio.post(Endpoints.categories, data: data);
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<void> deleteCategory(String code) async {
    await dio.delete('${Endpoints.categories}/$code');
  }
}
