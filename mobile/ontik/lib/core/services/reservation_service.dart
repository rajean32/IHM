import '../api/reservation_api.dart';

class ReservationService {
  final _api = ReservationApi();

  Future<List<dynamic>> getAvailablePlaces(int eventId) => _api.getAvailablePlaces(eventId);
  Future<Map<String, dynamic>> createReservation(Map<String, dynamic> data) => _api.createReservation(data);
  Future<List<dynamic>> getMyReservations(String userCode) => _api.getMyReservations(userCode);
  Future<List<dynamic>> getReservations() => _api.getReservations();
}
