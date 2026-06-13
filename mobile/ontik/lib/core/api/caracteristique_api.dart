import 'dio_config.dart';
import 'endpoints.dart';

class CaracteristiqueApi {
  Future<List<dynamic>> getByCategorie(String codeCategorie) async {
    final resp = await dio.get('${Endpoints.caracteristiques}/by-categorie/$codeCategorie');
    return (resp.data['data'] as List?) ?? [];
  }

  Future<Map<String, dynamic>> getById(int id) async {
    final resp = await dio.get('${Endpoints.caracteristiques}/$id');
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final resp = await dio.post(Endpoints.caracteristiques, data: data);
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> update(int id, Map<String, dynamic> data) async {
    final resp = await dio.put('${Endpoints.caracteristiques}/$id', data: data);
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<void> delete(int id) async {
    await dio.delete('${Endpoints.caracteristiques}/$id');
  }
}
