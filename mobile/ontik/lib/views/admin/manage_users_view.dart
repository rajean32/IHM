import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/providers.dart';
import '../../models/user_detail.dart';
import '../../core/constants.dart';
import '../../widgets/error_state.dart';

class ManageUsersView extends ConsumerStatefulWidget {
  const ManageUsersView({super.key});
  @override
  ConsumerState<ManageUsersView> createState() => _ManageUsersViewState();
}

class _ManageUsersViewState extends ConsumerState<ManageUsersView> {
  bool _loading = true;
  String? _error;
  List<UserDetail> _users = [];
  List<AuditLogEntry> _auditLog = [];
  bool _showAudit = false;

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(adminUserRepositoryProvider);
      final users = await repo.getAll();
      final audit = await repo.getAuditLog();
      if (!mounted) return;
      setState(() { _users = users; _auditLog = audit; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _toggleActive(UserDetail user) async {
    try {
      final repo = ref.read(adminUserRepositoryProvider);
      await repo.toggleActive(user.codeUtilisateur);
      _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _changeRole(UserDetail user) async {
    final role = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Changer le rôle'),
        children: [
          SimpleDialogOption(onPressed: () => Navigator.pop(ctx, AppConstants.roleOrganisateur), child: const Text('Organisateur')),
          SimpleDialogOption(onPressed: () => Navigator.pop(ctx, AppConstants.roleClient), child: const Text('Client')),
        ],
      ),
    );
    if (role == null) return;
    try {
      final repo = ref.read(adminUserRepositoryProvider);
      await repo.changeRole(user.codeUtilisateur, role);
      _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _resetPassword(UserDetail user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Réinitialiser mot de passe'),
        content: Text('Réinitialiser le mot de passe de ${user.nom} ${user.prenoms} ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirmer')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final repo = ref.read(adminUserRepositoryProvider);
      await repo.resetPassword(codeUtilisateur: user.codeUtilisateur);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mot de passe réinitialisé'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _deleteUser(UserDetail user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer utilisateur'),
        content: Text('Supprimer ${user.nom} ${user.prenoms} (${user.codeUtilisateur}) ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final repo = ref.read(adminUserRepositoryProvider);
      await repo.delete(user.codeUtilisateur);
      _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion utilisateurs'),
        actions: [
          TextButton.icon(
            onPressed: () => setState(() => _showAudit = !_showAudit),
            icon: Icon(_showAudit ? Icons.people : Icons.history),
            label: Text(_showAudit ? 'Users' : 'Audit'),
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorState(message: _error!, onRetry: _loadData)
              : _showAudit
                  ? _buildAuditLog()
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: _users.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.people_outline, size: 48, color: Colors.grey.withValues(alpha: 0.4)),
                                  const SizedBox(height: 12),
                                  const Text('Aucun utilisateur trouvé', style: TextStyle(color: Colors.grey, fontSize: 16)),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: _users.length,
                              itemBuilder: (ctx, i) => _buildUserCard(_users[i]),
                            ),
                    ),
    );
  }

  Widget _buildUserCard(UserDetail user) {
    final roleColor = user.role == AppConstants.roleAdmin
        ? Colors.red : user.role == AppConstants.roleOrganisateur
            ? Colors.orange : Colors.blue;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: roleColor.withValues(alpha: 0.2),
          child: Icon(Icons.person, color: roleColor),
        ),
        title: Text('${user.nom} ${user.prenoms}'),
        subtitle: Text('${user.email}  •  ${user.role}', style: const TextStyle(fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: user.actif ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(user.actif ? 'Actif' : 'Inactif', style: TextStyle(fontSize: 11, color: user.actif ? Colors.green : Colors.red)),
            ),
            if (user.premiereConnexion)
              Container(
                margin: const EdgeInsets.only(left: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Nouveau', style: TextStyle(fontSize: 11, color: Colors.orange)),
              ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Code: ${user.codeUtilisateur}', style: const TextStyle(fontSize: 13)),
                Text('Tél: ${user.tel}', style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.swap_horiz, size: 16),
                      label: const Text('Rôle'),
                      onPressed: () => _changeRole(user),
                    ),
                    ActionChip(
                      avatar: Icon(user.actif ? Icons.block : Icons.check_circle, size: 16),
                      label: Text(user.actif ? 'Désactiver' : 'Activer'),
                      onPressed: () => _toggleActive(user),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.lock_reset, size: 16),
                      label: const Text('Reset MDP'),
                      onPressed: () => _resetPassword(user),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.delete, size: 16),
                      label: const Text('Supprimer'),
                      onPressed: () => _deleteUser(user),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditLog() {
    if (_auditLog.isEmpty) {
      return const Center(child: Text('Aucune activité'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _auditLog.length,
      itemBuilder: (ctx, i) {
        final entry = _auditLog[i];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blueGrey.withValues(alpha: 0.2),
              child: const Icon(Icons.history, size: 20),
            ),
            title: Text(entry.action, style: const TextStyle(fontSize: 14)),
            subtitle: Text('${entry.utilisateur}  •  ${entry.details}', style: const TextStyle(fontSize: 12)),
          ),
        );
      },
    );
  }
}
