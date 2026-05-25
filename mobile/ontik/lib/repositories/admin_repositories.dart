import 'package:ontik/core/api_client.dart';
import 'package:ontik/core/api_endpoints.dart';
import 'package:ontik/models/api_wrapper.dart';
import 'package:ontik/models/categorie.dart';

class CategorieRepository {
  final ApiClient _client;
  CategorieRepository(this._client);

  Future<List<Categorie>> getAll() async {
    final response = await _client.get(ApiEndpoints.categories.all);
    return ApiWrapper.fromJson(
      response,
    ).getDataList((e) => Categorie.fromJson(e));
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

  Future<List<dynamic>> getAll() async {
    final response = await _client.get(ApiEndpoints.lieux.all);
    return ApiWrapper.fromJson(response).data as List;
  }

  Future<dynamic> create(Map<String, dynamic> data) async {
    final response = await _client.post(ApiEndpoints.lieux.all, data: data);
    return ApiWrapper.fromJson(response).data;
  }
}

class SalleRepository {
  final ApiClient _client;
  SalleRepository(this._client);

  Future<List<dynamic>> getAll() async {
    final response = await _client.get(ApiEndpoints.salles.all);
    return ApiWrapper.fromJson(response).data as List;
  }

  Future<dynamic> create(Map<String, dynamic> data) async {
    final response = await _client.post(ApiEndpoints.salles.all, data: data);
    return ApiWrapper.fromJson(response).data;
  }
}

class PlaceRepository {
  final ApiClient _client;
  PlaceRepository(this._client);

  Future<List<dynamic>> getAll() async {
    final response = await _client.get(ApiEndpoints.places.all);
    return ApiWrapper.fromJson(response).data as List;
  }

  Future<dynamic> create(Map<String, dynamic> data) async {
    final response = await _client.post(ApiEndpoints.places.all, data: data);
    return ApiWrapper.fromJson(response).data;
  }
}
