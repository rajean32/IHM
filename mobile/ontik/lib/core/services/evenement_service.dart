import 'dart:io';
import '../api/evenement_api.dart';
import '../api/place_api.dart';

class EvenementService {
  final _api = EvenementApi();
  final _placeApi = PlaceApi();

  Future<List<dynamic>> getEvents({String? orgCode}) => _api.getEvents(orgCode: orgCode);
  Future<List<dynamic>> getRecentEvents() => _api.getRecentEvents();
  Future<Map<String, dynamic>> getEventDetail(int id) => _api.getEventDetail(id);
  Future<List<dynamic>> getAvailablePlaces(int eventId) => _api.getAvailablePlaces(eventId);
  Future<Map<String, dynamic>> createEvent(Map<String, dynamic> data) => _api.createEvent(data);
  Future<Map<String, dynamic>> updateEvent(int id, Map<String, dynamic> data) => _api.updateEvent(id, data);
  Future<void> deleteEvent(int id) => _api.deleteEvent(id);
  Future<Map<String, dynamic>> validateEvent(int id) => _api.validateEvent(id);
  Future<void> suspendEvent(int id) => _api.suspendEvent(id);
  Future<void> resumeEvent(int id) => _api.resumeEvent(id);
  Future<void> cancelEvent(int id, String motif) => _api.cancelEvent(id, motif);
  Future<void> uploadImage(int eventId, File file) => _api.uploadImage(eventId, file);
  Future<List<dynamic>> getStandingZones(int eventId) => _api.getStandingZones(eventId);
  Future<Map<String, dynamic>> createStandingZone(int eventId, Map<String, dynamic> data) => _api.createStandingZone(eventId, data);
  Future<void> deleteStandingZone(int eventId, int zoneId) => _api.deleteStandingZone(eventId, zoneId);

  Future<void> configureEventAfterCreation({
    required int eventId,
    required String typePlacement,
    required Map<String, double> typePrices,
    required Map<String, List<String>> rowAssignments,
    required Map<String, List<String>> placeAssignments,
    required List<Map<String, dynamic>> standingZones,
    File? image,
  }) async {
    if (typePlacement == 'NUMEROTE' || typePlacement == 'MIXTE') {
      for (final entry in typePrices.entries) {
        await _placeApi.setTypePricing(eventId, entry.key, entry.value);
      }
      for (final type in {...rowAssignments.keys, ...placeAssignments.keys}) {
        await _placeApi.assignTypes(eventId, {
          'typePlace': type,
          'placeIds': placeAssignments[type] ?? [],
          'rows': rowAssignments[type] ?? [],
        });
      }
    }
    if (typePlacement == 'MIXTE') {
      for (final zone in standingZones) {
        await _api.createStandingZone(eventId, zone);
      }
    }
    if (image != null) {
      await _api.uploadImage(eventId, image);
    }
  }
}
