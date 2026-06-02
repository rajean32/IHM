import 'dio_config.dart';
import 'endpoints.dart';

class PlaceApi {
  Future<List<dynamic>> getPlacesBySalle(String salle) async {
    final resp = await dio.get(Endpoints.placeBySalle(salle));
    return (resp.data['data'] as List?) ?? [];
  }

  Future<void> setTypePricing(int eventId, String typePlace, double prix) async {
    await dio.put(Endpoints.typePricing(eventId), data: {
      'typePlace': typePlace,
      'prix': prix,
    });
  }

  Future<void> assignTypes(int eventId, Map<String, dynamic> data) async {
    await dio.put(Endpoints.assignType(eventId), data: data);
  }

  Future<Map<String, dynamic>> createPlace(Map<String, dynamic> data) async {
    final resp = await dio.post(Endpoints.places, data: data);
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<void> deletePlace(String numeroPlace) async {
    await dio.delete('${Endpoints.places}/$numeroPlace');
  }

  Future<List<dynamic>> getOrganizerEventSalles(int eventId) async {
    final resp = await dio.get(Endpoints.organizerEventSalles(eventId));
    return (resp.data['data'] as List?) ?? [];
  }

  Future<List<dynamic>> getPlacesConfig(int eventId, String salle) async {
    final resp = await dio.get(Endpoints.organizerEventPlacesConfig(eventId, salle));
    return (resp.data['data'] as List?) ?? [];
  }

  Future<void> applyRowPricing(int eventId, String rang, String typePlace, double? prix) async {
    await dio.put(Endpoints.organizerEventRowPricing(eventId), data: {
      'rang': rang, 'typePlace': typePlace, 'prix': prix,
    });
  }

  Future<void> applyOrganizerTypePricing(int eventId, String typePlace, double? prix) async {
    await dio.put(Endpoints.organizerEventTypePricing(eventId), data: {
      'typePlace': typePlace, 'prix': prix,
    });
  }

  Future<void> assignOrganizerTypes(int eventId, Map<String, dynamic> data) async {
    await dio.put(Endpoints.organizerEventAssignType(eventId), data: data);
  }

  Future<void> updatePlaceConfig(int eventId, String numeroPlace, {String? typePlace, double? prix}) async {
    final qp = <String, dynamic>{};
    if (typePlace != null && typePlace.isNotEmpty) qp['typePlace'] = typePlace;
    if (prix != null) qp['prix'] = prix;
    await dio.put(
      Endpoints.organizerEventPlaceConfig(eventId, numeroPlace),
      queryParameters: qp.isNotEmpty ? qp : null,
    );
  }
}
