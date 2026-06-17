import 'package:flutter/material.dart';
import 'package:ontik/core/services/user_service.dart';
import 'package:ontik/models/user_model.dart';
import 'package:ontik/core/assets/app_colors.dart';
import 'package:ontik/core/utils/error_helper.dart';
import 'package:ontik/widgets/admin/admin_search_field.dart';
import 'package:ontik/widgets/admin/admin_empty_state.dart';
import 'package:ontik/widgets/admin/admin_error_state.dart';
import 'package:ontik/widgets/admin/admin_toast.dart';
import 'package:ontik/widgets/admin/admin_confirmation_dialog.dart';
import 'user_details_sheet.dart';
import 'user_audit_page.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final _service = UserService();
  final _searchCtrl = TextEditingController();
  bool _loading = true;
  String? _error;
  List<UserDetail> _users = [];
  List<UserDetail> _filteredUsers = [];
  String _searchQuery = '';
  bool _showAudit = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _service.getUsers();
      if (!mounted) return;
      final users = data.map((e) => UserDetail.fromJson(e as Map<String, dynamic>)).toList();
      users.sort((a, b) => a.nom.compareTo(b.nom));
      setState(() { _users = users; _filteredUsers = users; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = apiErrorString(e); _loading = false; });
    }
  }

  void _filter(String query) {
    _searchQuery = query.toLowerCase();
    setState(() {
      _filteredUsers = _users.where((u) {
        final fullName = '${u.prenoms} ${u.nom}'.toLowerCase();
        return fullName.contains(_searchQuery) ||
            u.email.toLowerCase().contains(_searchQuery) ||
            u.codeUtilisateur.toLowerCase().contains(_searchQuery) ||
            u.role.toLowerCase().contains(_searchQuery);
      }).toList();
    });
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'ADMINISTRATEUR': return AppColors.error;
      case 'ORGANISATEUR': return AppColors.accent;
      case 'CLIENT': return AppColors.primary;
      default: return AppColors.textSecondary;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'ADMINISTRATEUR': return Icons.admin_panel_settings;
      case 'ORGANISATEUR': return Icons.badge;
      case 'CLIENT': return Icons.person;
      default: return Icons.person;
    }
  }

  Future<void> _toggleActive(UserDetail user) async {
    try {
      await _service.updateUser(user.codeUtilisateur, {'actif': !user.actif});
      if (!mounted) return;
      AdminToast.show(context, message: user.actif ? 'Utilisateur désactivé' : 'Utilisateur activé', isSuccess: true);
      _load();
    } catch (e) {
      if (!mounted) return;
      AdminToast.show(context, message: apiErrorString(e), isSuccess: false);
    }
  }

  Future<void> _changeRole(UserDetail user) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Changer le rôle'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'ORGANISATEUR'),
            child: const ListTile(leading: Icon(Icons.badge), title: Text('Organisateur')),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'CLIENT'),
            child: const ListTile(leading: Icon(Icons.person), title: Text('Client')),
          ),
        ],
      ),
    );
    if (choice == null || choice == user.role) return;
    try {
      await _service.updateUser(user.codeUtilisateur, {'role': choice});
      if (!mounted) return;
      AdminToast.show(context, message: 'Rôle changé avec succès', isSuccess: true);
      _load();
    } catch (e) {
      if (!mounted) return;
      AdminToast.show(context, message: apiErrorString(e), isSuccess: false);
    }
  }

  Future<void> _resetPassword(UserDetail user) async {
    final confirm = await AdminConfirmationDialog.show(
      context,
      title: 'Réinitialiser le mot de passe',
      message: 'Voulez-vous réinitialiser le mot de passe de ${user.prenoms} ${user.nom} ?',
      confirmLabel: 'Confirmer',
      confirmColor: AppColors.accent,
    );
    if (confirm != true) return;
    final pwdCtrl = TextEditingController();
    final pwd = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouveau mot de passe'),
        content: TextField(
          controller: pwdCtrl,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Mot de passe'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(ctx, pwdCtrl.text), child: const Text('Valider')),
        ],
      ),
    );
    pwdCtrl.dispose();
    if (pwd == null || pwd.isEmpty) return;
    try {
      await _service.updateUser(user.codeUtilisateur, {'password': pwd});
      if (!mounted) return;
      AdminToast.show(context, message: 'Mot de passe réinitialisé', isSuccess: true);
    } catch (e) {
      if (!mounted) return;
      AdminToast.show(context, message: apiErrorString(e), isSuccess: false);
    }
  }

  Future<void> _deleteUser(UserDetail user) async {
    final confirm = await AdminConfirmationDialog.show(
      context,
      title: 'Supprimer l\'utilisateur',
      message: 'Voulez-vous vraiment supprimer ${user.prenoms} ${user.nom} ?',
    );
    if (confirm != true) return;
    try {
      await _service.deleteUser(user.codeUtilisateur);
      if (!mounted) return;
      AdminToast.show(context, message: 'Utilisateur supprimé', isSuccess: true);
      _load();
    } catch (e) {
      if (!mounted) return;
      AdminToast.show(context, message: apiErrorString(e), isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showAudit) {
      return UserAuditPage(onBack: () => setState(() => _showAudit = false));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              const Text('Gestion utilisateurs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton.icon(
                onPressed: () => setState(() => _showAudit = true),
                icon: const Icon(Icons.history, size: 18),
                label: const Text('Audit', style: TextStyle(fontSize: 12)),
              ),
              IconButton(icon: const Icon(Icons.refresh, size: 20), onPressed: _load),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: AdminSearchField(
            hintText: 'Rechercher par nom, email, code, rôle...',
            controller: _searchCtrl,
            onChanged: _filter,
          ),
        ),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return AdminErrorState(message: _error!, onRetry: _load);
    if (_filteredUsers.isEmpty) {
      return AdminEmptyState(
        icon: _searchQuery.isNotEmpty ? Icons.search_off : Icons.people_outline,
        message: _searchQuery.isNotEmpty ? 'Aucun utilisateur trouvé' : 'Aucun utilisateur',
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredUsers.length,
        itemBuilder: (ctx, i) => _buildUserCard(_filteredUsers[i]),
      ),
    );
  }

  Widget _buildUserCard(UserDetail user) {
    final roleColor = _getRoleColor(user.role);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: roleColor.withValues(alpha: 0.15),
          child: Icon(_getRoleIcon(user.role), color: roleColor, size: 20),
        ),
        title: Text('${user.prenoms} ${user.nom}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text('${user.email}  •  ${user.role}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (user.actif ? AppColors.secondary : AppColors.error).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(user.actif ? 'Actif' : 'Inactif', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: user.actif ? AppColors.secondary : AppColors.error)),
            ),
            if (user.premiereConnexion) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Nouveau', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.accent)),
              ),
            ],
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.info_outline, size: 20),
              onPressed: () => UserDetailsSheet.show(context, user: user, onToggleActive: () => _toggleActive(user), onChangeRole: () => _changeRole(user), onResetPassword: () => _resetPassword(user), onDelete: () => _deleteUser(user)),
            ),
          ],
        ),
      ),
    );
  }
}
