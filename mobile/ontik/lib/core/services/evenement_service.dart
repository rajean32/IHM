import '../api/evenement_api.dart';

class EvenementService {
  final _api = EvenementApi();

  Future<List<dynamic>> getEvents({String? orgCode}) => _api.getEvents(orgCode: orgCode);
  Future<Map<String, dynamic>> getEventDetail(int id) => _api.getEventDetail(id);
  Future<List<dynamic>> getAvailablePlaces(int eventId) => _api.getAvailablePlaces(eventId);
  Future<Map<String, dynamic>> createEvent(Map<String, dynamic> data) => _api.createEvent(data);
  Future<Map<String, dynamic>> updateEvent(int id, Map<String, dynamic> data) => _api.updateEvent(id, data);
  Future<void> deleteEvent(int id) => _api.deleteEvent(id);
  Future<Map<String, dynamic>> validateEvent(int id) => _api.validateEvent(id);
}
