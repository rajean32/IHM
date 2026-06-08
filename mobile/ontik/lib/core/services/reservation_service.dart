import '../api/reservation_api.dart';

class ReservationService {
  final _api = ReservationApi();

  Future<List<dynamic>> getAvailablePlaces(int eventId) => _api.getAvailablePlaces(eventId);
  Future<Map<String, dynamic>> createReservation(Map<String, dynamic> data) => _api.createReservation(data);
  Future<List<dynamic>> getMyReservations(String userCode) => _api.getMyReservations(userCode);
  Future<List<dynamic>> getReservations() => _api.getReservations();
  Future<List<dynamic>> getEventReservations(int eventId) => _api.getEventReservations(eventId);
  Future<Map<String, dynamic>> getReservationDetail(int id) => _api.getReservationDetail(id);
  Future<Map<String, dynamic>> cancelReservation(int id) => _api.cancelReservation(id);
}
