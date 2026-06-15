import 'package:flutter/material.dart';
import '../../core/api/dio_config.dart';
import '../../core/assets/app_colors.dart';
import '../../core/services/notification_service.dart';
import '../../core/utils/error_helper.dart';
import '../../models/notification_model.dart';
import '../../widgets/error_state.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _loading = true;
  String? _error;
  List<InAppNotification> _notifications = [];
  String? _filterType;
  bool? _filterIsRead;
  bool _showFilters = false;

  static const _types = [
    null,
    'PAYMENT_CONFIRMED',
    'PAYMENT_FAILED',
    'RESERVATION_CONFIRMED',
    'RESERVATION_CANCELLED',
    'EVENT_CANCELLED',
    'EVENT_APPROVED',
    'EVENT_SUSPENDED',
    'TICKET_VALIDATED',
    'TICKET_ALREADY_USED',
    'REFUND_PROCESSED',
  ];

  static const _typeLabels = {
    null: 'Tous',
    'PAYMENT_CONFIRMED': 'Paiement',
    'PAYMENT_FAILED': 'Échec',
    'RESERVATION_CONFIRMED': 'Réservation',
    'RESERVATION_CANCELLED': 'Annulation',
    'EVENT_CANCELLED': 'Événement',
    'EVENT_APPROVED': 'Approuvé',
    'EVENT_SUSPENDED': 'Suspendu',
    'TICKET_VALIDATED': 'Scanné',
    'TICKET_ALREADY_USED': 'Réutilisé',
    'REFUND_PROCESSED': 'Remboursé',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = userCode;
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    if (uid == null) {
      setState(() {
        _error = "Utilisateur non connecté";
        _loading = false;
      });
      return;
    }
    try {
      final svc = NotificationService();
      final list = await svc.getNotifications(uid,
          type: _filterType,
          isRead: _filterIsRead);
      if (!mounted) return;
      setState(() {
        _notifications = list;
        _loading = false;
      });
      await NotificationManager.refreshNow();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = apiErrorString(e);
        _loading = false;
      });
    }
  }

  Future<void> _markAllRead() async {
    final uid = userCode;
    if (uid == null) return;
    try {
      await NotificationService().markAllAsRead(uid);
      await NotificationManager.refreshNow();
      if (!mounted) return;
      setState(() {
        for (final n in _notifications) {
          n.isRead = true;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tout marquer comme lu'), backgroundColor: AppColors.secondary),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(apiErrorString(e)), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _markAsRead(InAppNotification n) async {
    if (n.isRead || n.id == null) return;
    try {
      await NotificationService().markAsRead(n.id!);
      await NotificationManager.refreshNow();
      if (!mounted) return;
      setState(() => n.isRead = true);
    } catch (_) {}
  }

  Future<void> _delete(InAppNotification n) async {
    if (n.id == null) return;
    try {
      await NotificationService().deleteNotification(n.id!);
      await NotificationManager.refreshNow();
      if (!mounted) return;
      setState(() => _notifications.remove(n));
    } catch (_) {}
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'PAYMENT_CONFIRMED':
        return Icons.payment;
      case 'PAYMENT_FAILED':
        return Icons.payment;
      case 'RESERVATION_CONFIRMED':
        return Icons.receipt_long;
      case 'RESERVATION_CANCELLED':
        return Icons.event_busy;
      case 'EVENT_CANCELLED':
        return Icons.cancel;
      case 'EVENT_APPROVED':
        return Icons.check_circle;
      case 'EVENT_SUSPENDED':
        return Icons.pause_circle;
      case 'TICKET_VALIDATED':
        return Icons.qr_code_scanner;
      case 'TICKET_ALREADY_USED':
        return Icons.warning;
      case 'REFUND_PROCESSED':
        return Icons.undo;
      default:
        return Icons.notifications;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'PAYMENT_CONFIRMED':
        return AppColors.secondary;
      case 'PAYMENT_FAILED':
        return AppColors.error;
      case 'RESERVATION_CONFIRMED':
        return AppColors.primary;
      case 'RESERVATION_CANCELLED':
        return AppColors.accent;
      case 'EVENT_CANCELLED':
        return AppColors.error;
      case 'EVENT_APPROVED':
        return AppColors.secondary;
      case 'EVENT_SUSPENDED':
        return AppColors.accent;
      case 'TICKET_VALIDATED':
        return AppColors.statusPlanned;
      case 'TICKET_ALREADY_USED':
        return AppColors.error;
      case 'REFUND_PROCESSED':
        return AppColors.statusPlanned;
      default:
        return AppColors.textSecondary;
    }
  }

  String _timeAgo(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays}j';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_notifications.any((n) => !n.isRead))
            TextButton.icon(
              onPressed: _markAllRead,
              icon: const Icon(Icons.done_all, size: 18, color: Colors.white),
              label: const Text('Tout lire', style: TextStyle(color: Colors.white, fontSize: 13)),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorState(message: _error!, onRetry: _load)
              : _notifications.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: _buildFilterBar(),
                          ),
                          SliverList.separated(
                            itemCount: _notifications.length,
                            separatorBuilder: (_, _) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                          final n = _notifications[index];
                          return Dismissible(
                            key: ValueKey(n.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 24),
                              color: AppColors.error,
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) => _delete(n),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _colorForType(n.type).withValues(alpha: 0.15),
                                child: Icon(
                                  _iconForType(n.type),
                                  color: _colorForType(n.type),
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                n.title,
                                style: TextStyle(
                                  fontWeight: n.isRead ? FontWeight.normal : FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    n.message,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: n.isRead ? AppColors.textMuted : AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _timeAgo(n.createdAt),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              tileColor: n.isRead ? null : AppColors.primary.withValues(alpha: 0.03),
                              onTap: () {
                                _markAsRead(n);
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_off, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          const Text(
            'Aucune notification',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Vous serez notifié ici des mises à jour importantes.',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildReadChip('Toutes', null),
              const SizedBox(width: 6),
              _buildReadChip('Non lues', false),
              const SizedBox(width: 6),
              _buildReadChip('Lues', true),
              const Spacer(),
              TextButton.icon(
                onPressed: () => setState(() => _showFilters = !_showFilters),
                icon: Icon(
                  _showFilters ? Icons.filter_list_off : Icons.filter_list,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                label: Text(
                  _showFilters ? 'Masquer' : 'Filtrer',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          if (_showFilters) ...[
            const SizedBox(height: 6),
            SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _types.length,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  final t = _types[index];
                  final selected = _filterType == t;
                  return FilterChip(
                    label: Text(
                      _typeLabels[t] ?? 'Tous',
                      style: TextStyle(
                        fontSize: 11,
                        color: selected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                    selected: selected,
                    onSelected: (val) {
                      setState(() => _filterType = t);
                      _load();
                    },
                    selectedColor: AppColors.primary,
                    checkmarkColor: Colors.white,
                    side: BorderSide.none,
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReadChip(String label, bool? value) {
    final selected = _filterIsRead == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: selected ? Colors.white : AppColors.textSecondary,
        ),
      ),
      selected: selected,
      onSelected: (val) {
        setState(() => _filterIsRead = value);
        _load();
      },
      selectedColor: AppColors.primary,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
