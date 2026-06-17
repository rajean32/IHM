import 'package:flutter/material.dart';
import 'package:ontik/core/api/dio_config.dart';
import 'package:ontik/core/api/endpoints.dart';
import 'package:ontik/core/assets/app_colors.dart';
import 'package:ontik/core/utils/error_helper.dart';
import 'package:ontik/models/user_model.dart';
import 'package:ontik/widgets/admin/admin_error_state.dart';
import 'package:ontik/widgets/admin/admin_empty_state.dart';
import 'package:ontik/widgets/admin/admin_toast.dart';

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
        title: const Text('Annuler l\'action'),
        content: Text('Voulez-vous annuler l\'action "${_actionLabel(entry.action)}" sur ${entry.entityId ?? ''} ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Non')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Oui, annuler', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _undoing = true);
    try {
      await dio.post(Endpoints.auditLogUndo(entry.idAction!));
      if (!mounted) return;
      AdminToast.show(context, message: 'Action annulée', isSuccess: true);
      _loadLogs();
    } catch (e) {
      if (!mounted) return;
      AdminToast.show(context, message: apiErrorString(e), isSuccess: false);
      setState(() => _undoing = false);
    }
  }

  String _actionLabel(String action) {
    switch (action) {
      case 'CREATE_USER': return 'Création d\'utilisateur';
      case 'UPDATE_USER': return 'Modification d\'utilisateur';
      case 'CHANGE_ROLE': return 'Changement de rôle';
      case 'DEACTIVATE_USER': return 'Désactivation d\'utilisateur';
      case 'ACTIVATE_USER': return 'Activation d\'utilisateur';
      case 'RESET_PASSWORD': return 'Réinitialisation mot de passe';
      case 'DELETE_USER': return 'Suppression d\'utilisateur';
      case 'PAIEMENT_EFFECTUE': return 'Paiement effectué';
      case 'REMBOURSEMENT': return 'Remboursement';
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
      case 'UPDATE_USER': return AppColors.primary;
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
      return AdminErrorState(message: _error!, onRetry: _loadLogs);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              const Text('Historique des actions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('${_logs.length} action(s)',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _logs.isEmpty
              ? const AdminEmptyState(message: 'Aucune action enregistrée', icon: Icons.history)
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
                                  child: const Text('Annulée',
                                      style: TextStyle(fontSize: 10, color: Colors.orange)),
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
                                      label: const Text('Annuler', style: TextStyle(fontSize: 12)),
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
