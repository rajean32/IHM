import 'dart:io';
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
  Future<void> uploadImage(int eventId, File file) => _api.uploadImage(eventId, file);
  Future<List<dynamic>> getStandingZones(int eventId) => _api.getStandingZones(eventId);
  Future<Map<String, dynamic>> createStandingZone(int eventId, Map<String, dynamic> data) => _api.createStandingZone(eventId, data);
  Future<void> deleteStandingZone(int eventId, int zoneId) => _api.deleteStandingZone(eventId, zoneId);
}
