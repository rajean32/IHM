import '../api/dio_config.dart';
import '../api/endpoints.dart';

class AbonnementService {

  Future<void> subscribe(String codeClient, String codeOrganisateur) async {
    await dio.post(Endpoints.abonnements, data: {
      'codeClient': codeClient,
      'codeOrganisateur': codeOrganisateur,
    });
  }

  Future<void> unsubscribe(String codeClient, String codeOrganisateur) async {
    await dio.delete('${Endpoints.abonnements}/$codeClient/$codeOrganisateur');
  }

  Future<List<dynamic>> getAbonnements(String codeClient) async {
    final resp = await dio.get('${Endpoints.abonnements}/$codeClient');
    return (resp.data['data'] as List?) ?? [];
  }

  Future<List<dynamic>> getFeed(String codeClient) async {
    final resp = await dio.get(Endpoints.abonnementFeed(codeClient));
    return (resp.data['data'] as List?) ?? [];
  }
}
