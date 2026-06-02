import '../api/paiement_api.dart';

class PaiementService {
  final _api = PaiementApi();

  Future<Map<String, dynamic>> processPayment(Map<String, dynamic> data) => _api.processPayment(data);
  Future<List<dynamic>> getPayments() => _api.getPayments();
}
