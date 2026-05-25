import 'package:ontik/core/api_client.dart';
import 'package:ontik/core/api_endpoints.dart';
import 'package:ontik/models/api_wrapper.dart';
import 'package:ontik/models/reservation.dart';

class PaiementRepository {
  final ApiClient _client;

  PaiementRepository(this._client);

  Future<List<Paiement>> getAll() async {
    final response = await _client.get(ApiEndpoints.paiements.all);
    return ApiWrapper.fromJson(response).getDataList((e) => Paiement.fromJson(e));
  }

  Future<Paiement> getById(int id) async {
    final response = await _client.get(ApiEndpoints.paiements.byId(id));
    return ApiWrapper.fromJson(response).getData((d) => Paiement.fromJson(d));
  }

  Future<Paiement> create(Paiement paiement) async {
    final response = await _client.post(
      ApiEndpoints.paiements.all,
      data: paiement.toJson(),
    );
    return ApiWrapper.fromJson(response).getData((d) => Paiement.fromJson(d));
  }

  Future<PaiementStatus> getPaymentStatus(int reservationId) async {
    final response = await _client.get(
      ApiEndpoints.paiements.status(reservationId),
    );
    return ApiWrapper.fromJson(response).getData((d) => PaiementStatus.fromJson(d));
  }

  Future<List<Paiement>> getByClient(String code) async {
    final response = await _client.get(ApiEndpoints.clients.payments(code));
    return ApiWrapper.fromJson(response).getDataList((e) => Paiement.fromJson(e));
  }
}
