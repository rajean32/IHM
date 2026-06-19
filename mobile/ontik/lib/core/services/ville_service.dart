import '../api/dio_config.dart';
import '../api/endpoints.dart';
import '../../models/ville_model.dart';

class VilleService {
  Future<List<Ville>> getVilles({String? search}) async {
    final params = <String, dynamic>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    final resp = await dio.get(Endpoints.villes, queryParameters: params);
    final data = resp.data['data'] as List? ?? [];
    return data.map((e) => Ville.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Ville> getVille(String code) async {
    final resp = await dio.get('${Endpoints.villes}/$code');
    return Ville.fromJson(resp.data['data'] as Map<String, dynamic>);
  }

  Future<Ville> createVille(Ville ville) async {
    final resp = await dio.post(Endpoints.villes, data: ville.toJson());
    return Ville.fromJson(resp.data['data'] as Map<String, dynamic>);
  }

  Future<Ville> updateVille(String code, Ville ville) async {
    final resp = await dio.put('${Endpoints.villes}/$code', data: ville.toJson());
    return Ville.fromJson(resp.data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteVille(String code) async {
    await dio.delete('${Endpoints.villes}/$code');
  }
}
