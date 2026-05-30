import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/admin_repositories.dart';
import '../repositories/dashboard_repository.dart';
import 'auth_controller.dart';

final categorieRepositoryProvider = Provider<CategorieRepository>((ref) {
  return CategorieRepository(ref.watch(apiClientProvider));
});

final lieuRepositoryProvider = Provider<LieuRepository>((ref) {
  return LieuRepository(ref.watch(apiClientProvider));
});

final salleRepositoryProvider = Provider<SalleRepository>((ref) {
  return SalleRepository(ref.watch(apiClientProvider));
});

final placeRepositoryProvider = Provider<PlaceRepository>((ref) {
  return PlaceRepository(ref.watch(apiClientProvider));
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.watch(apiClientProvider));
});
