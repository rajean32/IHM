import 'dio_config.dart';
import 'endpoints.dart';

class PaiementApi {
  Future<Map<String, dynamic>> processPayment(Map<String, dynamic> data) async {
    final resp = await dio.post(Endpoints.payments, data: data);
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<List<dynamic>> getPayments() async {
    final resp = await dio.get(Endpoints.payments);
    return (resp.data['data'] as List?) ?? [];
  }
}
