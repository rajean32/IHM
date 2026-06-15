import 'package:flutter/material.dart';
import '../core/services/notification_service.dart';
import '../core/routes/shared_routes.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  @override
  void initState() {
    super.initState();
    NotificationManager.unreadCount.addListener(_onCountChanged);
  }

  @override
  void dispose() {
    NotificationManager.unreadCount.removeListener(_onCountChanged);
    super.dispose();
  }

  void _onCountChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final count = NotificationManager.unreadCount.value;
    return IconButton(
      icon: count > 0
          ? Badge(
              label: Text(
                count > 99 ? '99+' : count.toString(),
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
              child: const Icon(Icons.notifications_outlined),
            )
          : const Icon(Icons.notifications_outlined),
      tooltip: 'Notifications',
      onPressed: () {
        Navigator.pushNamed(context, SharedRoutes.notifications);
      },
    );
  }
}
