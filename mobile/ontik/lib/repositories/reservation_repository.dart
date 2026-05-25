import 'package:ontik/core/api_client.dart';
import 'package:ontik/core/api_endpoints.dart';
import 'package:ontik/models/api_wrapper.dart';
import 'package:ontik/models/reservation.dart';

class ReservationRepository {
  final ApiClient _client;

  ReservationRepository(this._client);

  Future<List<Reservation>> getAll() async {
    final response = await _client.get(ApiEndpoints.reservations.all);
    return ApiWrapper.fromJson(response).getDataList((e) => Reservation.fromJson(e));
  }

  Future<List<Reservation>> getByClient(String code) async {
    final response = await _client.get(ApiEndpoints.clients.reservations(code));
    return ApiWrapper.fromJson(response).getDataList((e) => Reservation.fromJson(e));
  }

  Future<Reservation> getById(int id) async {
    final response = await _client.get(ApiEndpoints.reservations.byId(id));
    return ApiWrapper.fromJson(response).getData((d) => Reservation.fromJson(d));
  }

  Future<Reservation> create(Reservation reservation) async {
    final response = await _client.post(
      ApiEndpoints.reservations.all,
      data: reservation.toJson(),
    );
    return ApiWrapper.fromJson(response).getData((d) => Reservation.fromJson(d));
  }

  Future<Reservation> update(int id, Reservation reservation) async {
    final response = await _client.put(
      ApiEndpoints.reservations.update(id),
      data: reservation.toJson(),
    );
    return ApiWrapper.fromJson(response).getData((d) => Reservation.fromJson(d));
  }

  Future<void> cancel(int id) async {
    await _client.post(ApiEndpoints.reservations.cancel(id));
  }

  Future<void> delete(int id) async {
    await _client.delete(ApiEndpoints.reservations.byId(id));
  }

  Future<List<dynamic>> getTickets(int id) async {
    final response = await _client.get(ApiEndpoints.reservations.tickets(id));
    return ApiWrapper.fromJson(response).data as List;
  }
}
