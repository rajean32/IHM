import 'package:flutter/material.dart';
import '../../core/api/dio_config.dart';
import '../../core/api/endpoints.dart';
import '../../core/assets/app_colors.dart';
import '../../core/utils/error_helper.dart';
import '../../localization/app_localizations.dart';
import '../../models/user_model.dart';

class ActionHistoryPage extends StatefulWidget {
  const ActionHistoryPage({super.key});

  @override
  State<ActionHistoryPage> createState() => _ActionHistoryPageState();
}

class _ActionHistoryPageState extends State<ActionHistoryPage> {
  bool _loading = true;
  String? _error;
  List<AuditLogEntry> _logs = [];
  bool _undoing = false;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _loading = true);
    try {
      final resp = await dio.get(Endpoints.usersAuditLog);
      final data = (resp.data['data'] as List?) ?? [];
      if (!mounted) return;
      setState(() {
        _logs = data.map((e) => AuditLogEntry.fromJson(e as Map<String, dynamic>)).toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = apiErrorString(e); _loading = false; });
    }
  }

  Future<void> _undoAction(AuditLogEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('admin.actionHistory.undoTitle')),
        content: Text('${tr('admin.actionHistory.undoConfirm')} "${_actionLabel(entry.action)}" ${tr('admin.actionHistory.on')} ${entry.entityId ?? ''} ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr('admin.actionHistory.no'))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(tr('admin.actionHistory.yesUndo'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _undoing = true);
    try {
      await dio.post(Endpoints.auditLogUndo(entry.idAction!));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('admin.actionHistory.undone')), backgroundColor: AppColors.secondary),
      );
      _loadLogs();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(apiErrorString(e)), backgroundColor: AppColors.error),
      );
      setState(() => _undoing = false);
    }
  }

  String _actionLabel(String action) {
    switch (action) {
      case 'CREATE_USER': return tr('admin.actionHistory.createUser');
      case 'UPDATE_USER': return tr('admin.actionHistory.updateUser');
      case 'CHANGE_ROLE': return tr('admin.actionHistory.changeRole');
      case 'DEACTIVATE_USER': return tr('admin.actionHistory.deactivateUser');
      case 'ACTIVATE_USER': return tr('admin.actionHistory.activateUser');
      case 'RESET_PASSWORD': return tr('admin.actionHistory.resetPassword');
      case 'DELETE_USER': return tr('admin.actionHistory.deleteUser');
      case 'PAIEMENT_EFFECTUE': return tr('admin.actionHistory.paymentMade');
      case 'REMBOURSEMENT': return tr('admin.actionHistory.refund');
      default: return action;
    }
  }

  IconData _actionIcon(String action) {
    switch (action) {
      case 'CREATE_USER': return Icons.person_add;
      case 'UPDATE_USER': return Icons.edit;
      case 'CHANGE_ROLE': return Icons.swap_horiz;
      case 'DEACTIVATE_USER': return Icons.block;
      case 'ACTIVATE_USER': return Icons.check_circle;
      case 'RESET_PASSWORD': return Icons.lock_reset;
      case 'DELETE_USER': return Icons.person_remove;
      case 'PAIEMENT_EFFECTUE': return Icons.payment;
      case 'REMBOURSEMENT': return Icons.replay;
      default: return Icons.history;
    }
  }

  Color _actionColor(String action) {
    switch (action) {
      case 'CREATE_USER': return Colors.green;
      case 'UPDATE_USER': return Colors.blue;
      case 'CHANGE_ROLE': return Colors.orange;
      case 'DEACTIVATE_USER': return Colors.red;
      case 'ACTIVATE_USER': return Colors.green;
      case 'RESET_PASSWORD': return Colors.purple;
      case 'DELETE_USER': return Colors.red;
      case 'PAIEMENT_EFFECTUE': return Colors.teal;
      case 'REMBOURSEMENT': return Colors.amber;
      default: return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: AppColors.error)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadLogs, child: Text(tr('admin.actionHistory.retry'))),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Text(tr('admin.actionHistory.title'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('${_logs.length} ${tr('admin.actionHistory.actions')}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _logs.isEmpty
              ? Center(child: Text(tr('admin.actionHistory.empty')))
              : RefreshIndicator(
                  onRefresh: _loadLogs,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _logs.length,
                    itemBuilder: (ctx, i) {
                      final entry = _logs[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _actionColor(entry.action).withValues(alpha: 0.15),
                            child: Icon(_actionIcon(entry.action),
                                size: 20, color: _actionColor(entry.action)),
                          ),
                          title: Row(
                            children: [
                              Text(_actionLabel(entry.action),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                              if (entry.reverted)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child:                                   Text(tr('admin.actionHistory.reverted'),
                                      style: const TextStyle(fontSize: 10, color: Colors.orange)),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${entry.codeUtilisateur}  •  ${entry.details}',
                                  style: const TextStyle(fontSize: 12)),
                              if (entry.dateAction != null)
                                Text(entry.dateAction!,
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                            ],
                          ),
                          trailing: entry.reverted
                              ? null
                              : _undoing
                                  ? const SizedBox(
                                      width: 20, height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2))
                                  : TextButton.icon(
                                      onPressed: () => _undoAction(entry),
                                      icon: const Icon(Icons.undo, size: 16),
                                      label: Text(tr('admin.actionHistory.undo'), style: const TextStyle(fontSize: 12)),
                                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                                    ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
