import 'package:ontik/core/api_client.dart';
import 'package:ontik/core/api_endpoints.dart';
import 'package:ontik/models/api_wrapper.dart';
import 'package:ontik/models/categorie.dart';
import 'package:ontik/models/venue.dart';

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
    final response = await _client.post(
      ApiEndpoints.categories.all,
      data: cat.toJson(),
    );
    return ApiWrapper.fromJson(response).getData((d) => Categorie.fromJson(d));
  }
}

class LieuRepository {
  final ApiClient _client;
  LieuRepository(this._client);

  Future<List<Lieu>> getAll() async {
    final response = await _client.get(ApiEndpoints.lieux.all);
    return ApiWrapper.fromJson(response).getDataList((e) => Lieu.fromJson(e));
  }

  Future<Lieu> create(Lieu lieu) async {
    final response = await _client.post(ApiEndpoints.lieux.all, data: lieu.toJson());
    return ApiWrapper.fromJson(response).getData((d) => Lieu.fromJson(d));
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
}
