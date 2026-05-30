import 'package:ontik/core/api_client.dart';
import 'package:ontik/core/api_endpoints.dart';
import 'package:ontik/models/api_wrapper.dart';
import 'package:ontik/models/evenement.dart';
import 'package:ontik/models/venue.dart';

class EventRepository {
  final ApiClient _client;

  EventRepository(this._client);

  Future<List<Evenement>> getAll() async {
    final response = await _client.get(ApiEndpoints.events.all);
    return ApiWrapper.fromJson(response).getDataList((e) => Evenement.fromJson(e));
  }

  Future<List<Evenement>> getUpcoming() async {
    final response = await _client.get(ApiEndpoints.events.upcoming);
    return ApiWrapper.fromJson(response).getDataList((e) => Evenement.fromJson(e));
  }

  Future<List<Evenement>> getPopular() async {
    final response = await _client.get(ApiEndpoints.events.popular);
    return ApiWrapper.fromJson(response).getDataList((e) => Evenement.fromJson(e));
  }

  Future<EventDetail> getDetail(int id) async {
    final response = await _client.get(ApiEndpoints.events.detail(id));
    return ApiWrapper.fromJson(response).getData((d) => EventDetail.fromJson(d));
  }

  Future<List<SeatingPlace>> getAvailableSeats(int id) async {
    final response = await _client.get(ApiEndpoints.events.availableSeats(id));
    return ApiWrapper.fromJson(response).getDataList((e) => SeatingPlace.fromJson(e));
  }

  Future<List<Evenement>> search({
    String? q,
    String? categorie,
    String? ville,
    int? idLieu,
    String? dateFrom,
    String? dateTo,
    String? statut,
    double? prixMin,
    double? prixMax,
  }) async {
    final params = <String, dynamic>{};
    if (q != null) params['q'] = q;
    if (categorie != null) params['categorie'] = categorie;
    if (ville != null) params['ville'] = ville;
    if (idLieu != null) params['idLieu'] = idLieu;
    if (dateFrom != null) params['dateFrom'] = dateFrom;
    if (dateTo != null) params['dateTo'] = dateTo;
    if (statut != null) params['statut'] = statut;
    if (prixMin != null) params['prixMin'] = prixMin;
    if (prixMax != null) params['prixMax'] = prixMax;

    final response = await _client.get(ApiEndpoints.events.search, queryParameters: params);
    return ApiWrapper.fromJson(response).getDataList((e) => Evenement.fromJson(e));
  }

  Future<List<Evenement>> getByOrganisateur(String code) async {
    final response = await _client.get(ApiEndpoints.events.byOrganisateur(code));
    return ApiWrapper.fromJson(response).getDataList((e) => Evenement.fromJson(e));
  }

  Future<Evenement> create(Evenement event) async {
    final response = await _client.post(ApiEndpoints.events.all, data: event.toJson());
    return ApiWrapper.fromJson(response).getData((d) => Evenement.fromJson(d));
  }

  Future<Evenement> update(int id, Evenement event) async {
    final response = await _client.put(ApiEndpoints.events.byId(id), data: event.toJson());
    return ApiWrapper.fromJson(response).getData((d) => Evenement.fromJson(d));
  }

  Future<void> delete(int id) async {
    await _client.delete(ApiEndpoints.events.byId(id));
  }
}
