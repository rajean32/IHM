import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../api/dio_config.dart';
import '../api/endpoints.dart';
import '../../models/notification_model.dart';

class NotificationManager {
  static final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);
  static StompClient? _stompClient;
  static bool _initialized = false;
  static Timer? _pollTimer;

  static void connect(String userId, String? token) {
    if (_initialized || userId.isEmpty) return;
    _initialized = true;

    _refreshCount(userId);

    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshCount(userId);
    });

    try {
      _stompClient = StompClient(
        config: StompConfig(
          url: '${Endpoints.wsUrl}?token=${token ?? ''}',
          onConnect: (StompFrame frame) {
            _stompClient?.subscribe(
              destination: '/user/$userId/queue/notifications',
              callback: (StompFrame frame) {
                if (frame.body != null) {
                  try {
                    final parsed = jsonDecode(frame.body!) as Map<String, dynamic>;
                    final notif = InAppNotification.fromJson(parsed);
                    if (!notif.isRead) {
                      unreadCount.value = unreadCount.value + 1;
                    }
                  } catch (_) {}
                }
              },
            );
          },
          onStompError: (StompFrame frame) {},
          onWebSocketError: (dynamic error) {},
          onWebSocketDone: () {},
        ),
      );
      _stompClient?.activate();
    } catch (_) {}
  }

  static void disconnect() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _stompClient?.deactivate();
    _stompClient = null;
    _initialized = false;
    unreadCount.value = 0;
  }

  static Future<void> _refreshCount(String userId) async {
    try {
      final response = await dio.get(
        '${Endpoints.notifications}/unread-count?userId=$userId',
      );
      final count = (response.data['data'] as num?)?.toInt() ?? 0;
      unreadCount.value = count;
    } catch (_) {}
  }

  static Future<void> refreshNow() async {
    if (userCode != null) {
      await _refreshCount(userCode!);
    }
  }
}

class NotificationService {
  Future<List<InAppNotification>> getNotifications(String userId, {String? type, bool? isRead, DateTime? dateFrom, DateTime? dateTo}) async {
    final params = <String, String>{'userId': userId};
    if (type != null) params['type'] = type;
    if (isRead != null) params['isRead'] = isRead.toString();
    if (dateFrom != null) params['dateFrom'] = dateFrom.toIso8601String();
    if (dateTo != null) params['dateTo'] = dateTo.toIso8601String();
    final query = params.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');
    final response = await dio.get('${Endpoints.notifications}?$query');
    final data = response.data['data'] as List? ?? [];
    return data.map((e) => InAppNotification.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<int> getUnreadCount(String userId) async {
    final response = await dio.get('${Endpoints.notifications}/unread-count?userId=$userId');
    return (response.data['data'] as num?)?.toInt() ?? 0;
  }

  Future<void> markAsRead(int id) async {
    await dio.patch('${Endpoints.notifications}/$id/read');
  }

  Future<void> markAllAsRead(String userId) async {
    await dio.patch('${Endpoints.notifications}/read-all', data: {'userId': userId});
  }

  Future<void> deleteNotification(int id) async {
    await dio.delete('${Endpoints.notifications}/$id');
  }

  Future<void> deleteAll(String userId) async {
    await dio.delete('${Endpoints.notifications}?userId=$userId');
  }
}
