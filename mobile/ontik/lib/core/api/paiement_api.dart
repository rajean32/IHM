import 'dio_config.dart';
import 'endpoints.dart';
import '../../models/paiement_request_model.dart';

class PaiementApi {
  Future<Map<String, dynamic>> processPayment(Map<String, dynamic> data) async {
    final resp = await dio.post(Endpoints.payments, data: data);
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> processPaymentWithReduction(PaiementRequestModel request) async {
    final resp = await dio.post(
      Endpoints.paymentProcessWithReduction,
      data: request.toJson(),
    );
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<List<dynamic>> getPayments() async {
    final resp = await dio.get(Endpoints.payments);
    return (resp.data['data'] as List?) ?? [];
  }

  Future<Map<String, dynamic>> rembourserReservation(
      int idReservation,
      String codeClient,
      bool isAnnulationEvenement,
      ) async {
    final resp = await dio.post(
      Endpoints.rembourserReservation(idReservation, codeClient, isAnnulationEvenement),
    );
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> verifierTransaction(String reference, String typePaiement) async {
    final resp = await dio.get(
      Endpoints.verifierTransaction(reference, typePaiement),
    );
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getPaiementStatusByReservation(int idReservation) async {
    final resp = await dio.get('${Endpoints.base}/paiements/reservation/$idReservation/status');
    return resp.data['data'] as Map<String, dynamic>;
  }

  // Ajouter cette méthode dans la classe PaiementApi

  Future<List<dynamic>> getPaymentsByClient(String codeClient) async {
    final resp = await dio.get('${Endpoints.base}/paiements?client=$codeClient');
    return (resp.data['data'] as List?) ?? [];
  }
}