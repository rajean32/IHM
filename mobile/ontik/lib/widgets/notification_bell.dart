import 'package:flutter/material.dart';
import '../core/services/notification_service.dart';
import '../core/routes/shared_routes.dart';
import '../localization/app_localizations.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  Key _animKey = UniqueKey();
  int _prevCount = 0;

  @override
  void initState() {
    super.initState();
    _prevCount = NotificationManager.unreadCount.value;
    NotificationManager.unreadCount.addListener(_onCountChanged);
  }

  @override
  void dispose() {
    NotificationManager.unreadCount.removeListener(_onCountChanged);
    super.dispose();
  }

  void _onCountChanged() {
    final current = NotificationManager.unreadCount.value;
    if (current > _prevCount) {
      setState(() => _animKey = UniqueKey());
    }
    _prevCount = current;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final count = NotificationManager.unreadCount.value;
    final icon = IconButton(
      icon: count > 0
          ? Badge(
              label: Text(
                count > 99 ? '99+' : count.toString(),
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
              child: const Icon(Icons.notifications_outlined),
            )
          : const Icon(Icons.notifications_outlined),
      tooltip: tr('widgets.notification_bell.tooltip'),
      onPressed: () => Navigator.pushNamed(context, SharedRoutes.notifications),
    );

    return TweenAnimationBuilder<double>(
      key: _animKey,
      tween: Tween(begin: 0.9, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: icon,
    );
  }
}
