import 'dio_config.dart';
import 'endpoints.dart';

class LieuApi {
  Future<List<dynamic>> getLieux() async {
    final resp = await dio.get(Endpoints.lieux);
    return (resp.data['data'] as List?) ?? [];
  }

  Future<Map<String, dynamic>> createLieu(Map<String, dynamic> data) async {
    final resp = await dio.post(Endpoints.lieux, data: data);
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<void> deleteLieu(String code) async {
    await dio.delete('${Endpoints.lieux}/$code');
  }

  Future<List<dynamic>> getSalles() async {
    final resp = await dio.get(Endpoints.salles);
    return (resp.data['data'] as List?) ?? [];
  }

  Future<List<dynamic>> getSallesByLieu(String codeLieu) async {
    final resp = await dio.get('${Endpoints.salles}/by-lieu/$codeLieu');
    return (resp.data['data'] as List?) ?? [];
  }

  Future<List<dynamic>> getSallesCompatible(String codeLieu, String codeCategorie) async {
    final resp = await dio.get('${Endpoints.salles}/compatible', queryParameters: {
      'codeLieu': codeLieu,
      'codeCategorie': codeCategorie,
    });
    return (resp.data['data'] as List?) ?? [];
  }

  Future<Map<String, dynamic>> createSalle(Map<String, dynamic> data) async {
    final resp = await dio.post(Endpoints.salles, data: data);
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateSalle(String numero, Map<String, dynamic> data) async {
    final resp = await dio.put('${Endpoints.salles}/$numero', data: data);
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<void> deleteSalle(String numero) async {
    await dio.delete('${Endpoints.salles}/$numero');
  }
}
