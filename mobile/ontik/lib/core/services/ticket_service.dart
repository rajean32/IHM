import '../api/ticket_api.dart';

class TicketService {
  final _api = TicketApi();

  Future<Map<String, dynamic>> getTicket(String code) => _api.getTicket(code);
  Future<Map<String, dynamic>> validateTicket(String code) => _api.validateTicket(code);
  Future<List<dynamic>> getTickets() => _api.getTickets();
  Future<List<dynamic>> getEventTickets(int eventId) => _api.getEventTickets(eventId);
}
