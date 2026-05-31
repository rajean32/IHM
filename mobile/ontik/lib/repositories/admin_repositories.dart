import 'package:ontik/core/api_client.dart';
import 'package:ontik/core/api_endpoints.dart';
import 'package:ontik/models/api_wrapper.dart';
import 'package:ontik/models/categorie.dart';
import 'package:ontik/models/venue.dart';
import 'package:ontik/models/ticket.dart';
import 'package:ontik/models/reservation.dart';
import 'package:ontik/models/user_detail.dart';

class CategorieRepository {
  final ApiClient _client;
  CategorieRepository(this._client);

  Future<List<Categorie>> getAll() async {
    final response = await _client.get(ApiEndpoints.categories.all);
    return ApiWrapper.fromJson(response).getDataList((e) => Categorie.fromJson(e));
  }

  Future<Categorie> getById(String code) async {
    final response = await _client.get(ApiEndpoints.categories.byId(code));
    return ApiWrapper.fromJson(response).getData((d) => Categorie.fromJson(d));
  }

  Future<Categorie> create(Categorie cat) async {
    final response = await _client.post(ApiEndpoints.categories.all, data: cat.toJson());
    return ApiWrapper.fromJson(response).getData((d) => Categorie.fromJson(d));
  }

  Future<void> delete(String code) async {
    await _client.delete(ApiEndpoints.categories.byId(code));
  }
}

class LieuRepository {
  final ApiClient _client;
  LieuRepository(this._client);

  Future<List<Lieu>> getAll() async {
    final response = await _client.get(ApiEndpoints.lieux.all);
    return ApiWrapper.fromJson(response).getDataList((e) => Lieu.fromJson(e));
  }

  Future<Lieu> getById(int id) async {
    final response = await _client.get(ApiEndpoints.lieux.byId(id));
    return ApiWrapper.fromJson(response).getData((d) => Lieu.fromJson(d));
  }

  Future<Lieu> create(Lieu lieu) async {
    final response = await _client.post(ApiEndpoints.lieux.all, data: lieu.toJson());
    return ApiWrapper.fromJson(response).getData((d) => Lieu.fromJson(d));
  }

  Future<void> delete(int id) async {
    await _client.delete(ApiEndpoints.lieux.byId(id));
  }
}

class SalleRepository {
  final ApiClient _client;
  SalleRepository(this._client);

  Future<List<Salle>> getAll() async {
    final response = await _client.get(ApiEndpoints.salles.all);
    return ApiWrapper.fromJson(response).getDataList((e) => Salle.fromJson(e));
  }

  Future<Salle> create(Salle salle) async {
    final response = await _client.post(ApiEndpoints.salles.all, data: salle.toJson());
    return ApiWrapper.fromJson(response).getData((d) => Salle.fromJson(d));
  }

  Future<void> delete(String numero) async {
    await _client.delete(ApiEndpoints.salles.byId(numero));
  }
}

class PlaceRepository {
  final ApiClient _client;
  PlaceRepository(this._client);

  Future<List<Place>> getAll() async {
    final response = await _client.get(ApiEndpoints.places.all);
    return ApiWrapper.fromJson(response).getDataList((e) => Place.fromJson(e));
  }

  Future<Place> create(Place place) async {
    final response = await _client.post(ApiEndpoints.places.all, data: place.toJson());
    return ApiWrapper.fromJson(response).getData((d) => Place.fromJson(d));
  }

  Future<void> delete(String numero) async {
    await _client.delete(ApiEndpoints.places.byId(numero));
  }
}

class AdminUserRepository {
  final ApiClient _client;
  AdminUserRepository(this._client);

  Future<List<UserDetail>> getAll() async {
    final response = await _client.get(ApiEndpoints.admin.users);
    return ApiWrapper.fromJson(response).getDataList((e) => UserDetail.fromJson(e));
  }

  Future<void> toggleActive(String code) async {
    await _client.put(ApiEndpoints.admin.toggleActive(code));
  }

  Future<void> changeRole(String code, String role) async {
    await _client.put(ApiEndpoints.admin.userRole(code), data: {'role': role});
  }

  Future<void> resetPassword({required String codeUtilisateur, String? newPassword}) async {
    await _client.post(ApiEndpoints.admin.resetPassword, data: {
      'codeUtilisateur': codeUtilisateur,
      if (newPassword != null) 'newPassword': newPassword,
    });
  }

  Future<void> delete(String code) async {
    await _client.delete(ApiEndpoints.admin.userById(code));
  }

  Future<List<AuditLogEntry>> getAuditLog() async {
    final response = await _client.get(ApiEndpoints.admin.auditLog);
    return ApiWrapper.fromJson(response).getDataList((e) => AuditLogEntry.fromJson(e));
  }
}

class TicketRepository {
  final ApiClient _client;
  TicketRepository(this._client);

  Future<List<Ticket>> getAll() async {
    final response = await _client.get(ApiEndpoints.tickets.all);
    return ApiWrapper.fromJson(response).getDataList((e) => Ticket.fromJson(e));
  }
}

class ReservationRepository {
  final ApiClient _client;
  ReservationRepository(this._client);

  Future<List<Reservation>> getAll() async {
    final response = await _client.get(ApiEndpoints.reservations.all);
    return ApiWrapper.fromJson(response).getDataList((e) => Reservation.fromJson(e));
  }

  Future<void> cancel(int id) async {
    await _client.put(ApiEndpoints.reservations.cancel(id));
  }
}

class PaiementRepository {
  final ApiClient _client;
  PaiementRepository(this._client);

  Future<List<Paiement>> getAll() async {
    final response = await _client.get(ApiEndpoints.paiements.all);
    return ApiWrapper.fromJson(response).getDataList((e) => Paiement.fromJson(e));
  }
}
