// famatisation des erreurs
import 'package:dio/dio.dart';

String apiErrorString(dynamic e) {
  if (e is DioException) {
    final data = e.response?.data;
    if (data is Map) {
      final errorMsg = data['error'] as String?;
      if (errorMsg != null && errorMsg.isNotEmpty) return errorMsg;
      final message = data['message'] as String?;
      if (message != null && message.isNotEmpty) return message;
    }
    return e.message ?? 'Erreur inconnue';
  }
  return e.toString();
}
