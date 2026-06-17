import 'package:flutter/material.dart';
import '../../core/services/user_service.dart';
import '../../core/api/dio_config.dart';
import '../../core/api/endpoints.dart';
import '../../core/assets/app_colors.dart';
import '../../core/utils/error_helper.dart';
import '../../models/user_model.dart';
import '../../widgets/error_state.dart';
import '../../localization/app_localizations.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});
  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  bool _loading = true;
  String? _error;
  List<UserDetail> _users = [];
  List<AuditLogEntry> _auditLog = [];
  bool _showAudit = false;
  final _api = UserService();

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final usersData = await _api.getUsers();
      final auditResp = await dio.get(Endpoints.usersAuditLog);
      final auditData = (auditResp.data['data'] as List?) ?? [];
      if (!mounted) return;
      setState(() {
        _users = usersData.map((e) => UserDetail.fromJson(e as Map<String, dynamic>)).toList();
        _auditLog = auditData.map((e) => AuditLogEntry.fromJson(e as Map<String, dynamic>)).toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = apiErrorString(e); _loading = false; });
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
        title: Text(tr('admin.users.changeRole')),
        children: [
          SimpleDialogOption(onPressed: () => Navigator.pop(ctx, AppConstants.roleOrganisateur), child: Text(tr('admin.users.roleOrganizer'))),
          SimpleDialogOption(onPressed: () => Navigator.pop(ctx, AppConstants.roleClient), child: Text(tr('admin.users.roleClient'))),
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
        title: Text(tr('admin.users.resetPassword')),
        content: Text('${tr('admin.users.resetPassword')} ${user.nom} ${user.prenoms} ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr('common.cancel'))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(tr('common.confirm'))),
        ],
      ),
    );
    if (confirm != true) return;
    final newPassword = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: Text(tr('admin.users.newPassword')),
          content: TextField(
            controller: ctrl,
            obscureText: true,
            decoration: InputDecoration(
              labelText: tr('auth.login.password'),
              hintText: tr('admin.users.newPasswordHint'),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('common.cancel'))),
            TextButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: Text(tr('common.confirm'))),
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
        SnackBar(content: Text(tr('admin.users.passwordReset')), backgroundColor: AppColors.secondary),
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
        title: Text(tr('admin.users.deleteUser')),
        content: Text('${tr('admin.users.deleteUser')} ${user.nom} ${user.prenoms} (${user.codeUtilisateur}) ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr('common.cancel'))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(tr('common.delete'), style: const TextStyle(color: AppColors.error))),
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
            Text(tr('admin.users.management'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            TextButton.icon(
              onPressed: () => setState(() => _showAudit = !_showAudit),
              icon: Icon(_showAudit ? Icons.people : Icons.history, size: 18),
              label: Text(_showAudit ? tr('admin.users') : tr('admin.users.audit'), style: const TextStyle(fontSize: 12)),
            ),
            IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          ]),
        ),
        Expanded(
          child: _showAudit
              ? _buildAuditLog()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: _users.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.people_outline, size: 48, color: AppColors.textSecondary.withValues(alpha: 0.4)),
                              const SizedBox(height: 12),
                              Text(tr('admin.users.empty'), style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _users.length,
                          itemBuilder: (ctx, i) => _buildUserCard(_users[i]),
                        ),
                ),
        ),
      ],
    );
  }

  Widget _buildUserCard(UserDetail user) {
    final roleColor = user.role == AppConstants.roleAdmin
        ? AppColors.error : user.role == AppConstants.roleOrganisateur
            ? AppColors.accent : AppColors.primary;
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
                color: user.actif ? AppColors.secondary.withValues(alpha: 0.2) : AppColors.error.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(user.actif ? tr('admin.users.active') : tr('admin.users.inactive'), style: TextStyle(fontSize: 11, color: user.actif ? AppColors.secondary : AppColors.error)),
            ),
            if (user.premiereConnexion)
              Container(
                margin: const EdgeInsets.only(left: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(tr('admin.users.new'), style: const TextStyle(fontSize: 11, color: AppColors.accent)),
              ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${tr('admin.users.code')} ${user.codeUtilisateur}', style: const TextStyle(fontSize: 13)),
                Text('${tr('admin.users.tel')} ${user.tel}', style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.swap_horiz, size: 16),
                      label: Text(tr('admin.users.role')),
                      onPressed: () => _changeRole(user),
                    ),
                    ActionChip(
                      avatar: Icon(user.actif ? Icons.block : Icons.check_circle, size: 16),
                      label: Text(user.actif ? tr('admin.users.deactivate') : tr('admin.users.activate')),
                      onPressed: () => _toggleActive(user),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.lock_reset, size: 16),
                      label: Text(tr('admin.users.resetPwd')),
                      onPressed: () => _resetPassword(user),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.delete, size: 16),
                      label: Text(tr('common.delete')),
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
      return Center(child: Text(tr('admin.users.noActivity')));
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
