import 'package:ontik/core/api_client.dart';
import 'package:ontik/core/api_endpoints.dart';
import 'package:ontik/models/api_wrapper.dart';
import 'package:ontik/models/dashboard.dart';

class DashboardRepository {
  final ApiClient _client;

  DashboardRepository(this._client);

  Future<AdminDashboardStats> getAdminStats() async {
    final response = await _client.get(ApiEndpoints.admin.dashboard);
    return ApiWrapper.fromJson(response).getData((d) => AdminDashboardStats.fromJson(d));
  }

  Future<OrganizerDashboardStats> getOrganizerStats(String code) async {
    final response = await _client.get(ApiEndpoints.organisateurs.dashboard(code));
    return ApiWrapper.fromJson(response).getData((d) => OrganizerDashboardStats.fromJson(d));
  }
}
