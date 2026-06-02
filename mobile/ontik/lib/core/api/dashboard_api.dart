import 'dio_config.dart';
import 'endpoints.dart';

class DashboardApi {
  Future<Map<String, dynamic>> getDashboard({String? orgCode}) async {
    final url = orgCode != null ? Endpoints.organizerDashboard(orgCode) : Endpoints.dashboard;
    final resp = await dio.get(url);
    return resp.data['data'] as Map<String, dynamic>;
  }
}
