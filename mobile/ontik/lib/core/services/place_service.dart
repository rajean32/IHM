import '../api/place_api.dart';

class PlaceService {
  final _api = PlaceApi();

  Future<List<dynamic>> getPlacesBySalle(String salle) => _api.getPlacesBySalle(salle);
  Future<void> setTypePricing(int eventId, String typePlace, double prix) => _api.setTypePricing(eventId, typePlace, prix);
  Future<void> assignTypes(int eventId, Map<String, dynamic> data) => _api.assignTypes(eventId, data);
  Future<Map<String, dynamic>> createPlace(Map<String, dynamic> data) => _api.createPlace(data);
  Future<void> deletePlace(String numeroPlace) => _api.deletePlace(numeroPlace);

  Future<List<dynamic>> getOrganizerEventSalles(int eventId) => _api.getOrganizerEventSalles(eventId);
  Future<List<dynamic>> getPlacesConfig(int eventId, String salle) => _api.getPlacesConfig(eventId, salle);
  Future<void> applyRowPricing(int eventId, String rang, String typePlace, double? prix) => _api.applyRowPricing(eventId, rang, typePlace, prix);
  Future<void> applyOrganizerTypePricing(int eventId, String typePlace, double? prix) => _api.applyOrganizerTypePricing(eventId, typePlace, prix);
  Future<void> assignOrganizerTypes(int eventId, Map<String, dynamic> data) => _api.assignOrganizerTypes(eventId, data);
  Future<void> updatePlaceConfig(int eventId, String numeroPlace, {String? typePlace, double? prix}) => _api.updatePlaceConfig(eventId, numeroPlace, typePlace: typePlace, prix: prix);
}
