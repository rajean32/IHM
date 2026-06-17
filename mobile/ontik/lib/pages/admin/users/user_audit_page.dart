import 'package:flutter/material.dart';
import 'package:ontik/core/api/endpoints.dart';
import 'package:ontik/core/api/dio_config.dart';
import 'package:ontik/models/user_model.dart';
import 'package:ontik/core/assets/app_colors.dart';
import 'package:ontik/core/utils/error_helper.dart';
import 'package:ontik/widgets/admin/admin_error_state.dart';
import 'package:ontik/widgets/admin/admin_empty_state.dart';
import 'package:ontik/widgets/admin/admin_toast.dart';

class UserAuditPage extends StatefulWidget {
  final VoidCallback onBack;
  const UserAuditPage({super.key, required this.onBack});

  @override
  State<UserAuditPage> createState() => _UserAuditPageState();
}

class _UserAuditPageState extends State<UserAuditPage> {
  bool _loading = true;
  String? _error;
  List<AuditLogEntry> _logs = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final resp = await dio.get(Endpoints.usersAuditLog);
      final data = (resp.data['data'] as List?) ?? [];
      if (!mounted) return;
      setState(() { _logs = data.map((e) => AuditLogEntry.fromJson(e as Map<String, dynamic>)).toList(); _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = apiErrorString(e); _loading = false; });
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
      case 'CREATE_USER': return AppColors.secondary;
      case 'UPDATE_USER': return AppColors.primary;
      case 'CHANGE_ROLE': return AppColors.accent;
      case 'DEACTIVATE_USER': return AppColors.error;
      case 'ACTIVATE_USER': return AppColors.secondary;
      case 'RESET_PASSWORD': return const Color(0xFF9C27B0);
      case 'DELETE_USER': return AppColors.error;
      case 'PAIEMENT_EFFECTUE': return const Color(0xFF00897B);
      case 'REMBOURSEMENT': return const Color(0xFFFFA000);
      default: return AppColors.textSecondary;
    }
  }

  Future<void> _undoAction(AuditLogEntry entry) async {
    final confirm1 = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Annuler l\'action'),
      content: Text('Voulez-vous vraiment annuler cette action : "${_actionLabel(entry.action)}" ?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Non')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Oui, annuler', style: TextStyle(color: AppColors.error))),
      ],
    ));
    if (confirm1 != true || !mounted) return;
    try {
      await dio.post(Endpoints.auditLogUndo(entry.idAction!));
      if (!mounted) return;
      AdminToast.show(context, message: 'Action annulée avec succès', isSuccess: true);
      _load();
    } catch (e) {
      if (!mounted) return;
      AdminToast.show(context, message: apiErrorString(e), isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack),
              const Text('Historique des actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('${_logs.length} action(s)', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ),
        const Divider(),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return AdminErrorState(message: _error!, onRetry: _load);
    if (_logs.isEmpty) return const AdminEmptyState(icon: Icons.history, message: 'Aucune action enregistrée');
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _logs.length,
        itemBuilder: (ctx, i) => _buildLogCard(_logs[i]),
      ),
    );
  }

  Widget _buildLogCard(AuditLogEntry entry) {
    final color = _actionColor(entry.action);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(_actionIcon(entry.action), size: 20, color: color),
        ),
        title: Row(
          children: [
            Text(_actionLabel(entry.action), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            if (entry.reverted) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                child: const Text('Annulée', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.accent)),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${entry.codeUtilisateur}  •  ${entry.details}', style: const TextStyle(fontSize: 12)),
            if (entry.dateAction != null) Text(entry.dateAction!, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
        trailing: entry.reverted
            ? null
            : TextButton.icon(
                onPressed: () => _undoAction(entry),
                icon: const Icon(Icons.undo, size: 16),
                label: const Text('Annuler', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
              ),
      ),
    );
  }
}
