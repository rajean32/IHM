import '../api/dio_config.dart';
import '../api/endpoints.dart';
import '../../models/reduction_model.dart';

class ReductionService {
  Future<List<Reduction>> getAllReductions() async {
    final response = await dio.get('${Endpoints.base}/reductions');
    final data = response.data['data'] as List? ?? [];
    return data.map((e) => Reduction.fromJson(e)).toList();
  }

  Future<Reduction> createReduction(Reduction reduction) async {
    final response = await dio.post(
      '${Endpoints.base}/reductions',
      data: reduction.toJson(),
    );
    return Reduction.fromJson(response.data['data']);
  }

  Future<Reduction> updateReduction(int id, Reduction reduction) async {
    final response = await dio.put(
      '${Endpoints.base}/reductions/$id',
      data: reduction.toJson(),
    );
    return Reduction.fromJson(response.data['data']);
  }

  Future<void> deleteReduction(int id) async {
    await dio.delete('${Endpoints.base}/reductions/$id');
  }

  Future<Map<String, dynamic>> verifierCodePromo(String code, int idEvenement) async {
    final response = await dio.post(
      '${Endpoints.base}/reductions/verifier?code=$code&idEvenement=$idEvenement',
    );
    return response.data['data'] as Map<String, dynamic>;
  }
}