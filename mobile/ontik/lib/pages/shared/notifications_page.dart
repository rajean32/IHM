import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/api/dio_config.dart';
import '../../core/assets/app_colors.dart';
import '../../core/services/app_config.dart';
import '../../core/services/notification_service.dart';
import '../../core/utils/error_helper.dart';
import '../../core/routes/client_routes.dart';
import '../../models/notification_model.dart';
import '../../widgets/error_state.dart';
import '../../widgets/admin/admin_toast.dart';
import '../../generated/app_localizations.dart';

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

  static const _types = [
    null,
    'PAYMENT_CONFIRMED',
    'PAYMENT_FAILED',
    'RESERVATION_CONFIRMED',
    'RESERVATION_CANCELLED',
    'EVENT_CANCELLED',
    'EVENT_APPROVED',
    'EVENT_UPDATED',
    'EVENT_SUSPENDED',
    'TICKET_VALIDATED',
    'TICKET_ALREADY_USED',
    'REFUND_PROCESSED',
  ];

  Map<String?, String> _typeLabels(BuildContext context) => {
    null: AppLocalizations.of(context)!.notificationsFilterAll,
    'PAYMENT_CONFIRMED': AppLocalizations.of(context)!.notificationsFilterPayments,
    'PAYMENT_FAILED': AppLocalizations.of(context)!.notificationsFilterFailed,
    'RESERVATION_CONFIRMED': AppLocalizations.of(context)!.notificationsFilterReservations,
    'RESERVATION_CANCELLED': AppLocalizations.of(context)!.notificationsFilterCancellations,
    'EVENT_CANCELLED': AppLocalizations.of(context)!.notificationsFilterCancelled,
    'EVENT_APPROVED': AppLocalizations.of(context)!.notificationsFilterApproved,
    'EVENT_UPDATED': AppLocalizations.of(context)!.notificationsFilterUpdated,
    'EVENT_SUSPENDED': AppLocalizations.of(context)!.notificationsFilterSuspended,
    'TICKET_VALIDATED': AppLocalizations.of(context)!.notificationsFilterScanned,
    'TICKET_ALREADY_USED': AppLocalizations.of(context)!.notificationsFilterReused,
    'REFUND_PROCESSED': AppLocalizations.of(context)!.notificationsFilterRefunded,
  };

  static final _typeConfig = <String, _TypeConfig>{
    'PAYMENT_CONFIRMED': _TypeConfig(Icons.payment, AppColors.secondary),
    'PAYMENT_FAILED': _TypeConfig(Icons.payment, AppColors.error),
    'RESERVATION_CONFIRMED': _TypeConfig(Icons.receipt_long, AppColors.primary),
    'RESERVATION_CANCELLED': _TypeConfig(Icons.event_busy, AppColors.accent),
    'EVENT_CANCELLED': _TypeConfig(Icons.cancel, AppColors.error),
    'EVENT_APPROVED': _TypeConfig(Icons.check_circle, AppColors.secondary),
    'EVENT_UPDATED': _TypeConfig(Icons.update, AppColors.primary),
    'EVENT_SUSPENDED': _TypeConfig(Icons.pause_circle, AppColors.accent),
    'TICKET_VALIDATED': _TypeConfig(Icons.qr_code_scanner, AppColors.statusPlanned),
    'TICKET_ALREADY_USED': _TypeConfig(Icons.warning, AppColors.error),
    'REFUND_PROCESSED': _TypeConfig(Icons.undo, AppColors.statusPlanned),
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
        _error = AppLocalizations.of(context)!.notificationsNotConnected;
        _loading = false;
      });
      return;
    }
    try {
      final svc = NotificationService();
      final list = await svc.getNotifications(uid,
          type: _filterType, isRead: _filterIsRead);
      if (!mounted) return;
      setState(() {
        _notifications = list;
        _loading = false;
      });
      await NotificationManager.refreshNow();
    } catch (e) {
      if (!mounted) return;
      String msg = apiErrorString(e);
      if (e is DioException && e.response != null) {
        msg += ' (${e.response?.statusCode})';
      }
      setState(() {
        _error = msg;
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
      if (!mounted) return;
      AdminToast.show(context, message: AppLocalizations.of(context)!.notificationsMarkAllRead, isSuccess: true);
    } catch (e) {
      if (!mounted) return;
      AdminToast.show(context, message: apiErrorString(e), isSuccess: false);
    }
  }

  Future<void> _markAsRead(InAppNotification n) async {
    if (n.isRead || n.id == null) return;
    try {
      await NotificationService().markAsRead(n.id!);
      await NotificationManager.refreshNow();
      if (!mounted) return;
      setState(() => n.isRead = true);
    } catch (e) {
      if (!mounted) return;
      AdminToast.show(context, message: apiErrorString(e), isSuccess: false);
    }
  }

  void _onNotificationTap(InAppNotification n) async {
    await _markAsRead(n);
    if (!mounted) return;
    if (n.idCible == null) return;
    final eventId = int.tryParse(n.idCible!);
    if (eventId == null) return;
    if (userRole == 'ORGANISATEUR' || userRole == 'ADMINISTRATEUR') {
      Navigator.pop(context);
      setActiveEvent(eventId, n.title);
    } else if (userRole == 'CLIENT') {
      Navigator.pushNamed(
        context,
        ClientRoutes.homeDetail,
        arguments: {'id': eventId},
      );
    }
  }

  Future<void> _delete(InAppNotification n) async {
    if (n.id == null) return;
    try {
      await NotificationService().deleteNotification(n.id!);
      await NotificationManager.refreshNow();
      if (!mounted) return;
      setState(() => _notifications.remove(n));
    } catch (e) {
      if (!mounted) return;
      AdminToast.show(context, message: apiErrorString(e), isSuccess: false);
    }
  }

  IconData _iconForType(String type) =>
      _typeConfig[type]?.icon ?? Icons.notifications;

  Color _colorForType(String type) =>
      _typeConfig[type]?.color ?? AppColors.textSecondary;

  String _timeAgo(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return "À l'instant";
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays}j';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: ModalRoute.of(context)?.canPop == true
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 22),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Text(AppLocalizations.of(context)!.notificationsTitle),
        actions: [
          if (unreadCount > 0)
            TextButton.icon(
              onPressed: _markAllRead,
              icon: const Icon(Icons.done_all, size: 18),
              label: Text(AppLocalizations.of(context)!.notificationsMarkAllReadShort),
            ),
        ],
      ),
      body: _buildBody(unreadCount),
    );
  }

  Widget _buildBody(int unreadCount) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return ErrorState(message: _error!, onRetry: _load);
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildFilterBar(unreadCount)),
          if (_notifications.isEmpty)
            SliverFillRemaining(child: _buildEmpty())
          else
            SliverList.separated(
              itemCount: _notifications.length,
              separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
              itemBuilder: (_, index) {
                final n = _notifications[index];
                return Dismissible(
                  key: ValueKey(n.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    color: Theme.of(context).colorScheme.error,
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
                        fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w600,
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
                            color: n.isRead
                                ? AppColors.textMuted
                                : AppColors.textSecondary,
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
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    tileColor: n.isRead
                        ? null
                        : AppColors.primary.withValues(alpha: 0.03),
                    onTap: () => _onNotificationTap(n),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(int unreadCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (unreadCount > 0) _buildUnreadBanner(unreadCount),
          _buildFilterChips(),
        ],
      ),
    );
  }

  Widget _buildUnreadBanner(int unreadCount) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.mark_email_unread, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$unreadCount notification${unreadCount > 1 ? 's' : ''}'
              ' non lue${unreadCount > 1 ? 's' : ''}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: _markAllRead,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(AppLocalizations.of(context)!.notificationsMarkAllReadShort, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildReadChip(AppLocalizations.of(context)!.notificationsAll, null),
          const SizedBox(width: 8),
          _buildReadChip(AppLocalizations.of(context)!.notificationsUnread, false),
          const SizedBox(width: 8),
          _buildReadChip(AppLocalizations.of(context)!.notificationsRead, true),
          const SizedBox(width: 12),
          SizedBox(
            height: 24,
            child: VerticalDivider(
              width: 1,
              thickness: 1,
              color: AppColors.textMuted.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(width: 12),
          ..._types.map((t) {
            final selected = _filterType == t;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(
                  _typeLabels(context)[t] ?? AppLocalizations.of(context)!.notificationsFilterAll,
                  style: TextStyle(
                    fontSize: 12,
                    color: selected ? Colors.white : AppColors.textSecondary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                selected: selected,
                onSelected: (_) {
                  setState(() => _filterType = t);
                  _load();
                },
                selectedColor: AppColors.primary,
                checkmarkColor: Colors.white,
                side: BorderSide.none,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            );
          }),
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
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      selected: selected,
      onSelected: (val) {
        setState(() {
          _filterIsRead = val ? value : null;
        });
        _load();
      },
      selectedColor: AppColors.primary,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildEmpty() {
    final hasActiveFilters = _filterType != null || _filterIsRead != null;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasActiveFilters ? Icons.filter_list_off : Icons.notifications_off,
              size: 48,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              hasActiveFilters ? AppLocalizations.of(context)!.notificationsNoResults : AppLocalizations.of(context)!.notificationsEmpty,
              style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              hasActiveFilters
                  ? AppLocalizations.of(context)!.notificationsEmptyFiltered
                  : AppLocalizations.of(context)!.notificationsEmptyGeneral,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            if (hasActiveFilters) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _filterType = null;
                    _filterIsRead = null;
                  });
                  _load();
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(AppLocalizations.of(context)!.notificationsResetFilters),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TypeConfig {
  final IconData icon;
  final Color color;
  const _TypeConfig(this.icon, this.color);
}
