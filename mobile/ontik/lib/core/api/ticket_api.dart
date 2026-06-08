import 'dio_config.dart';
import 'endpoints.dart';

class TicketApi {
  Future<Map<String, dynamic>> getTicket(String code) async {
    final resp = await dio.get('${Endpoints.tickets}/$code/qrcode');
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> validateTicket(String code) async {
    final resp = await dio.post('${Endpoints.tickets}/validate?codeTicket=$code');
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<List<dynamic>> getTickets() async {
    final resp = await dio.get(Endpoints.tickets);
    return (resp.data['data'] as List?) ?? [];
  }

  Future<List<dynamic>> getEventTickets(int eventId) async {
    final resp = await dio.get(Endpoints.organizerEventTickets(eventId));
    return (resp.data['data'] as List?) ?? [];
  }
}
