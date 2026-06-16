import 'package:flutter/material.dart';
import '../../core/services/user_service.dart';
import '../../core/api/dio_config.dart';
import '../../core/api/endpoints.dart';
import '../../core/assets/app_colors.dart';
import '../../core/utils/error_helper.dart';
import '../../models/user_model.dart';
import '../../widgets/error_state.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});
  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  bool _loading = true;
  String? _error;
  List<UserDetail> _users = [];
  List<UserDetail> _filteredUsers = [];
  List<AuditLogEntry> _auditLog = [];
  bool _showAudit = false;
  final _api = UserService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final usersData = await _api.getUsers();
      final auditResp = await dio.get(Endpoints.usersAuditLog);
      final auditData = (auditResp.data['data'] as List?) ?? [];
      if (!mounted) return;
      setState(() {
        _users = usersData.map((e) => UserDetail.fromJson(e as Map<String, dynamic>)).toList();
        _filteredUsers = _users;
        _auditLog = auditData.map((e) => AuditLogEntry.fromJson(e as Map<String, dynamic>)).toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = apiErrorString(e); _loading = false; });
    }
  }

  void _filterUsers(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredUsers = _users;
      } else {
        final lowerQuery = query.toLowerCase();
        _filteredUsers = _users.where((user) =>
        user.nom.toLowerCase().contains(lowerQuery) ||
            user.prenoms.toLowerCase().contains(lowerQuery) ||
            user.email.toLowerCase().contains(lowerQuery) ||
            user.codeUtilisateur.toLowerCase().contains(lowerQuery) ||
            user.role.toLowerCase().contains(lowerQuery)
        ).toList();
      }
    });
  }

  Future<void> _showUserInfoModal(UserDetail user) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec avatar et nom
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: _getRoleColor(user.role).withValues(alpha: 0.2),
                    child: Text(
                      user.prenoms.isNotEmpty ? user.prenoms[0].toUpperCase() : '?',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _getRoleColor(user.role)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${user.prenoms} ${user.nom}',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getRoleColor(user.role).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getRoleIcon(user.role), size: 14, color: _getRoleColor(user.role)),
                              const SizedBox(width: 6),
                              Text(
                                user.role,
                                style: TextStyle(color: _getRoleColor(user.role), fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Statut
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: user.actif ? AppColors.secondary.withValues(alpha: 0.15) : AppColors.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      user.actif ? Icons.check_circle : Icons.cancel,
                      size: 16,
                      color: user.actif ? AppColors.secondary : AppColors.error,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      user.actif ? 'Actif' : 'Inactif',
                      style: TextStyle(
                        color: user.actif ? AppColors.secondary : AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (user.premiereConnexion) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Première connexion',
                          style: TextStyle(fontSize: 10, color: AppColors.accent),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Divider(height: 24),

              // Section Informations personnelles
              _sectionTitle('Informations personnelles', Icons.person_outline),
              const SizedBox(height: 8),
              _infoCard([
                _infoRow(Icons.badge, 'Code utilisateur', user.codeUtilisateur),
                _infoRow(Icons.email, 'Email', user.email),
                _infoRow(Icons.phone, 'Téléphone', user.tel),
                if (user.sexe != null) _infoRow(Icons.wc, 'Sexe', user.sexe!),
                if (user.dateDeNaissance != null) _infoRow(Icons.cake, 'Date de naissance', user.dateDeNaissance!),
              ]),
              const SizedBox(height: 16),

              // Section Compte (CORRIGÉ)
              _sectionTitle('Informations du compte', Icons.account_circle),
              const SizedBox(height: 8),
              _infoCard([
                _infoRow(Icons.admin_panel_settings, 'Rôle', user.role),
                _infoRow(
                  Icons.circle,
                  'Statut',
                  user.actif ? 'Actif' : 'Inactif',
                  color: user.actif ? AppColors.secondary : AppColors.error,
                ),
                _infoRow(
                  Icons.history,
                  'Première connexion',
                  user.premiereConnexion ? 'Oui' : 'Non',
                  color: user.premiereConnexion ? AppColors.accent : AppColors.textSecondary,
                ),
                // codeAdministrateur n'existe pas dans UserDetail, on utilise une valeur par défaut
                _infoRow(Icons.admin_panel_settings, 'Type', user.role),
              ]),
              const SizedBox(height: 16),

              // Section Actions rapides
              _sectionTitle('Actions', Icons.settings),
              const SizedBox(height: 8),
              _actionButton(
                icon: Icons.swap_horiz,
                label: 'Changer le rôle',
                color: AppColors.primary,
                onTap: () {
                  Navigator.pop(ctx);
                  _changeRole(user);
                },
              ),
              _actionButton(
                icon: user.actif ? Icons.block : Icons.check_circle,
                label: user.actif ? 'Désactiver' : 'Activer',
                color: user.actif ? AppColors.error : AppColors.secondary,
                onTap: () {
                  Navigator.pop(ctx);
                  _toggleActive(user);
                },
              ),
              _actionButton(
                icon: Icons.lock_reset,
                label: 'Réinitialiser le mot de passe',
                color: AppColors.accent,
                onTap: () {
                  Navigator.pop(ctx);
                  _resetPassword(user);
                },
              ),
              _actionButton(
                icon: Icons.delete,
                label: 'Supprimer l\'utilisateur',
                color: AppColors.error,
                onTap: () {
                  Navigator.pop(ctx);
                  _deleteUser(user);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _infoCard(List<Widget> children) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 18),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color.withValues(alpha: 0.4)),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
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
      default: return Icons.help;
    }
  }

  Future<void> _toggleActive(UserDetail user) async {
    try {
      await dio.put('${Endpoints.users}/${user.codeUtilisateur}/toggle-active');
      _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(apiErrorString(e)), backgroundColor: AppColors.error));
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
      await dio.put('${Endpoints.users}/${user.codeUtilisateur}/role', data: {'role': role});
      _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(apiErrorString(e)), backgroundColor: AppColors.error));
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
    final newPassword = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: const Text('Nouveau mot de passe'),
          content: TextField(
            controller: ctrl,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Mot de passe',
              hintText: 'Entrez un nouveau mot de passe',
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            TextButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: const Text('Confirmer')),
          ],
        );
      },
    );
    if (newPassword == null || newPassword.isEmpty) return;
    try {
      await dio.post(Endpoints.usersResetPassword, data: {
        'codeUtilisateur': user.codeUtilisateur,
        'newPassword': newPassword,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mot de passe réinitialisé'), backgroundColor: AppColors.secondary),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(apiErrorString(e)), backgroundColor: AppColors.error));
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
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _api.deleteUser(user.codeUtilisateur);
      _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(apiErrorString(e)), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return ErrorState(message: _error!, onRetry: _loadData);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
          child: Row(children: [
            const Text('Gestion utilisateurs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            TextButton.icon(
              onPressed: () => setState(() => _showAudit = !_showAudit),
              icon: Icon(_showAudit ? Icons.people : Icons.history, size: 18),
              label: Text(_showAudit ? 'Utilisateurs' : 'Audit', style: const TextStyle(fontSize: 12)),
            ),
            IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          ]),
        ),
        if (!_showAudit)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un utilisateur...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    _filterUsers('');
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.fieldFill,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                isDense: true,
              ),
              onChanged: _filterUsers,
            ),
          ),
        if (!_showAudit && _searchQuery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${_filteredUsers.length} utilisateur(s) trouvé(s)',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        Expanded(
          child: _showAudit
              ? _buildAuditLog()
              : RefreshIndicator(
            onRefresh: _loadData,
            child: _filteredUsers.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _searchQuery.isEmpty ? Icons.people_outline : Icons.search_off,
                    size: 48,
                    color: AppColors.textSecondary.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _searchQuery.isEmpty
                        ? 'Aucun utilisateur trouvé'
                        : 'Aucun utilisateur ne correspond à votre recherche',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _filteredUsers.length,
              itemBuilder: (ctx, i) => _buildUserCard(_filteredUsers[i]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(UserDetail user) {
    final roleColor = _getRoleColor(user.role);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: roleColor.withValues(alpha: 0.15),
          child: Icon(_getRoleIcon(user.role), color: roleColor),
        ),
        title: Text('${user.prenoms} ${user.nom}', style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${user.email}  •  ${user.role}', style: const TextStyle(fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: user.actif ? AppColors.secondary.withValues(alpha: 0.15) : AppColors.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                user.actif ? 'Actif' : 'Inactif',
                style: TextStyle(fontSize: 10, color: user.actif ? AppColors.secondary : AppColors.error, fontWeight: FontWeight.w600),
              ),
            ),
            if (user.premiereConnexion)
              Container(
                margin: const EdgeInsets.only(left: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Nouveau',
                  style: TextStyle(fontSize: 9, color: AppColors.accent, fontWeight: FontWeight.w600),
                ),
              ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.info_outline, size: 20),
              tooltip: 'Voir les informations',
              onPressed: () => _showUserInfoModal(user),
            ),
          ],
        ),
        onTap: () => _showUserInfoModal(user),
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
              backgroundColor: AppColors.textSecondary.withValues(alpha: 0.2),
              child: const Icon(Icons.history, size: 20),
            ),
            title: Text(entry.action, style: const TextStyle(fontSize: 14)),
            subtitle: Text('${entry.codeUtilisateur}  •  ${entry.details}', style: const TextStyle(fontSize: 12)),
          ),
        );
      },
    );
  }
}