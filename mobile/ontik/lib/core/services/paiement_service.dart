import '../../models/paiement_request_model.dart';
import '../api/paiement_api.dart';

class PaiementService {
  final _api = PaiementApi();

  // Pour le paiement simple (ancienne méthode)
  Future<Map<String, dynamic>> processPayment(Map<String, dynamic> data) => _api.processPayment(data);

  // Pour le paiement avec réduction (nouvelle méthode)
  Future<Map<String, dynamic>> processPaymentWithReduction(PaiementRequestModel request) async {
    return await _api.processPaymentWithReduction(request);
  }

  // Pour lister tous les paiements (utilisé par admin)
  Future<List<dynamic>> getAllPayments() => _api.getPayments();

  // Pour lister les paiements d'un client
  Future<List<dynamic>> getPaymentsByClient(String codeClient) async {
    final response = await _api.getPaymentsByClient(codeClient);
    return response;
  }

  // Pour le remboursement
  Future<Map<String, dynamic>> rembourserReservation(int idReservation, String codeClient, bool isAnnulationEvenement) async {
    return await _api.rembourserReservation(idReservation, codeClient, isAnnulationEvenement);
  }

  // Pour vérifier une transaction mobile money
  Future<Map<String, dynamic>> verifierTransaction(String reference, String typePaiement) async {
    return await _api.verifierTransaction(reference, typePaiement);
  }

  // Pour obtenir le statut d'un paiement par réservation
  Future<Map<String, dynamic>> getPaiementStatusByReservation(int idReservation) async {
    return await _api.getPaiementStatusByReservation(idReservation);
  }
}