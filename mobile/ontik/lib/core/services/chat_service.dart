import '../api/dio_config.dart';
import '../api/endpoints.dart';

class ChatService {

  Future<Map<String, dynamic>> createConversation(String p1, String p2) async {
    final resp = await dio.post(Endpoints.chatConversations, data: {
      'participant1': p1,
      'participant2': p2,
    });
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> sendMessage(int conversationId, String expediteur, String contenu) async {
    final resp = await dio.post(Endpoints.chatSendMessage, data: {
      'idConversation': conversationId,
      'expediteur': expediteur,
      'contenu': contenu,
    });
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<List<dynamic>> getConversations(String userId) async {
    final resp = await dio.get(Endpoints.chatConversationsByUser(userId));
    return (resp.data['data'] as List?) ?? [];
  }

  Future<List<dynamic>> getMessages(int conversationId, {int page = 0, int size = 50}) async {
    final resp = await dio.get(Endpoints.chatMessages(conversationId), queryParameters: {
      'page': page,
      'size': size,
    });
    return (resp.data['data'] as List?) ?? [];
  }

  Future<void> markAsRead(int conversationId, String userId) async {
    await dio.patch(Endpoints.chatMarkRead(conversationId), data: {'userId': userId});
  }

  Future<int> getUnreadCount(String userId) async {
    final resp = await dio.get(Endpoints.chatUnread(userId));
    return (resp.data['data'] as num?)?.toInt() ?? 0;
  }
}
