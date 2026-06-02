import '../api/dashboard_api.dart';

class DashboardService {
  final _api = DashboardApi();

  Future<Map<String, dynamic>> getDashboard({String? orgCode}) => _api.getDashboard(orgCode: orgCode);
}
