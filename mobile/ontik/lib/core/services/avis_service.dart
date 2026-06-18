import '../api/dio_config.dart';
import '../api/endpoints.dart';

class AvisService {
  Future<List<dynamic>> getByEvenement(int idEvenement) async {
    final resp = await dio.get(Endpoints.avisByEvent(idEvenement));
    return (resp.data['data'] as List?) ?? [];
  }

  Future<Map<String, dynamic>> getMoyenne(int idEvenement) async {
    final resp = await dio.get(Endpoints.avisMoyenne(idEvenement));
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> create(int idEvenement, String codeClient, int note, String? commentaire) async {
    final resp = await dio.post(Endpoints.avis, data: {
      'idEvenement': idEvenement,
      'codeClient': codeClient,
      'note': note,
      'commentaire': commentaire ?? '',
    });
    return resp.data['data'] as Map<String, dynamic>;
  }
}
