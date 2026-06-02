import 'dio_config.dart';
import 'endpoints.dart';

class ReservationApi {
  Future<List<dynamic>> getAvailablePlaces(int eventId) async {
    final resp = await dio.get(Endpoints.eventAvailablePlaces(eventId));
    return (resp.data['data'] as List?) ?? [];
  }

  Future<Map<String, dynamic>> createReservation(Map<String, dynamic> data) async {
    final resp = await dio.post(Endpoints.reservations, data: data);
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<List<dynamic>> getMyReservations(String userCode) async {
    final resp = await dio.get('${Endpoints.reservations}?client=$userCode');
    return (resp.data['data'] as List?) ?? [];
  }

  Future<List<dynamic>> getReservations() async {
    final resp = await dio.get(Endpoints.reservations);
    return (resp.data['data'] as List?) ?? [];
  }
}
