import 'dart:io';
import 'package:dio/dio.dart';
import 'dio_config.dart';
import 'endpoints.dart';

class EvenementApi {
  Future<List<dynamic>> getEvents({String? orgCode}) async {
    final url = orgCode != null ? '${Endpoints.events}?organisateur=$orgCode' : Endpoints.events;
    final resp = await dio.get(url);
    return (resp.data['data'] as List?) ?? [];
  }

  Future<Map<String, dynamic>> getEventDetail(int id) async {
    final resp = await dio.get(Endpoints.eventById(id));
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<List<dynamic>> getAvailablePlaces(int eventId) async {
    final resp = await dio.get(Endpoints.eventAvailablePlaces(eventId));
    return (resp.data['data'] as List?) ?? [];
  }

  Future<Map<String, dynamic>> createEvent(Map<String, dynamic> data) async {
    final resp = await dio.post(Endpoints.events, data: data);
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateEvent(int id, Map<String, dynamic> data) async {
    final resp = await dio.put(Endpoints.eventById(id), data: data);
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<void> deleteEvent(int id) async {
    await dio.delete(Endpoints.eventById(id));
  }

  Future<Map<String, dynamic>> validateEvent(int id) async {
    final resp = await dio.put(Endpoints.eventValidate(id));
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<void> suspendEvent(int id) async {
    await dio.put('${Endpoints.events}/$id/suspend');
  }

  Future<void> resumeEvent(int id) async {
    await dio.put('${Endpoints.events}/$id/resume');
  }

  Future<void> cancelEvent(int id, String motif) async {
    await dio.put('${Endpoints.events}/$id/cancel', data: {'motifAnnulation': motif});
  }

  Future<List<dynamic>> getStandingZones(int eventId) async {
    final resp = await dio.get(Endpoints.eventStandingZones(eventId));
    return (resp.data['data'] as List?) ?? [];
  }

  Future<Map<String, dynamic>> createStandingZone(int eventId, Map<String, dynamic> data) async {
    final resp = await dio.post(Endpoints.eventStandingZones(eventId), data: data);
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<void> deleteStandingZone(int eventId, int zoneId) async {
    await dio.delete('${Endpoints.eventStandingZones(eventId)}/$zoneId');
  }

  Future<void> uploadImage(int eventId, File file) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
    });
    await dio.post(Endpoints.eventImage(eventId), data: formData);
  }

  // AJOUTER cette méthode dans EvenementApi

// NOUVELLE MÉTHODE : Événements cinéma
  Future<List<dynamic>> getCinemaEvents() async {
    final resp = await dio.get(Endpoints.cinemaEvents);
    return (resp.data['data'] as List?) ?? [];
  }
}
