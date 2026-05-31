import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ontik/core/api_client.dart';
import 'package:ontik/core/api_endpoints.dart';
import 'package:ontik/models/api_wrapper.dart';
import 'package:ontik/models/ticket.dart';

class TicketRepository {
  final ApiClient _client;

  TicketRepository(this._client);

  Future<List<Ticket>> getAll() async {
    final response = await _client.get(ApiEndpoints.tickets.all);
    return ApiWrapper.fromJson(response).getDataList((e) => Ticket.fromJson(e));
  }

  Future<Ticket> getById(String code) async {
    final response = await _client.get(ApiEndpoints.tickets.byId(code));
    return ApiWrapper.fromJson(response).getData((d) => Ticket.fromJson(d));
  }

  Future<Ticket> create(Ticket ticket) async {
    final response = await _client.post(
      ApiEndpoints.tickets.all,
      data: ticket.toJson(),
    );
    return ApiWrapper.fromJson(response).getData((d) => Ticket.fromJson(d));
  }

  Future<TicketQRResponse> generateQRCode(String code) async {
    final response = await _client.get(ApiEndpoints.tickets.qrcode(code));
    return ApiWrapper.fromJson(response).getData((d) => TicketQRResponse.fromJson(d));
  }

  Future<TicketValidationResponse> validateTicket(String code) async {
    final response = await _client.post(
      ApiEndpoints.tickets.validate,
      queryParameters: {'codeTicket': code},
    );
    return ApiWrapper.fromJson(response).getData((d) => TicketValidationResponse.fromJson(d));
  }

  Future<List<Ticket>> getByClient(String clientCode) async {
    final response = await _client.get(ApiEndpoints.clients.tickets(clientCode));
    return ApiWrapper.fromJson(response).getDataList((e) => Ticket.fromJson(e));
  }

  Future<String> downloadPDF(String code) async {
    final response = await _client.dio.get(
      ApiEndpoints.tickets.pdf(code),
      options: Options(responseType: ResponseType.bytes),
    );
    final bytes = response.data as List<int>;
    final dir = Directory.systemTemp;
    final file = File('${dir.path}/ticket_$code.pdf');
    await file.writeAsBytes(bytes);
    return file.path;
  }
}
