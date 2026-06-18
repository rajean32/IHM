import '../api/dio_config.dart';
import '../api/endpoints.dart';

class AnnonceService {
  Future<List<dynamic>> getByEvenement(int idEvenement) async {
    final resp = await dio.get(Endpoints.annoncesByEvent(idEvenement));
    return (resp.data['data'] as List?) ?? [];
  }
}
