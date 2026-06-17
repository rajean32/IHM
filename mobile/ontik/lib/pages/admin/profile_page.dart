import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/user_service.dart';
import '../../core/api/dio_config.dart';
import '../../core/routes/auth_routes.dart';
import '../../core/assets/app_colors.dart';
import '../../core/utils/error_helper.dart';
import '../../localization/app_localizations.dart';
import '../../widgets/profile_body.dart';
import 'action_history_page.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  bool _loading = true;
  String _nom = '';
  String _prenoms = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    try {
      final code = userCode;
      if (code == null) {
        setState(() => _loading = false);
        return;
      }
      final resp = await UserService().getUsers();
      final users = resp.map((e) => Map<String, dynamic>.from(e as Map));
      final me = users.firstWhere(
        (u) => u['codeUtilisateur'] == code,
        orElse: () => <String, dynamic>{},
      );
      if (!mounted) return;
      setState(() {
        _nom = me['nom'] ?? userNom ?? '';
        _prenoms = me['prenoms'] ?? '';
        _email = me['email'] ?? '';
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _nom = userNom ?? '';
        _loading = false;
      });
    }
  }

  void _showEditInfo() {
    final origNom = _nom;
    final origPrenoms = _prenoms;
    final origEmail = _email;
    final nomCtrl = TextEditingController(text: _nom);
    final prenomsCtrl = TextEditingController(text: _prenoms);
    final emailCtrl = TextEditingController(text: _email);
    bool saving = false;
    bool isEditing = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24, right: 24, top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr('admin.profile.personalInfo'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 20),
                  TextField(controller: nomCtrl, enabled: isEditing, decoration: InputDecoration(labelText: tr('admin.profile.lastName'), border: const OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: prenomsCtrl, enabled: isEditing, decoration: InputDecoration(labelText: tr('admin.profile.firstName'), border: const OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: emailCtrl, enabled: isEditing, decoration: InputDecoration(labelText: tr('admin.profile.email'), border: const OutlineInputBorder()), keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: saving ? null : () async {
                        if (!isEditing) {
                          setSheetState(() => isEditing = true);
                          return;
                        }
                        final confirmed = await showDialog<bool>(
                          context: ctx,
                          builder: (dctx) => AlertDialog(
                            title: Text(tr('common.confirm')),
                            content: Text(tr('admin.profile.saveConfirm')),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(dctx, false), child: Text(tr('common.cancel'))),
                              TextButton(onPressed: () => Navigator.pop(dctx, true), child: Text(tr('common.confirm'))),
                            ],
                          ),
                        );
                        if (confirmed != true) {
                          nomCtrl.text = origNom;
                          prenomsCtrl.text = origPrenoms;
                          emailCtrl.text = origEmail;
                          setSheetState(() => isEditing = false);
                          return;
                        }
                        if (nomCtrl.text.trim().isEmpty) return;
                        setSheetState(() => saving = true);
                        try {
                          await UserService().updateUser(userCode ?? '', {
                            'nom': nomCtrl.text.trim(),
                            'prenoms': prenomsCtrl.text.trim(),
                            'email': emailCtrl.text.trim(),
                            'role': 'ADMINISTRATEUR',
                          });
                          if (!ctx.mounted) return;
                          Navigator.pop(ctx);
                          _loadProfile();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(tr('admin.profile.updated')), backgroundColor: AppColors.secondary),
                          );
                        } catch (e) {
                          setSheetState(() => saving = false);
                          if (!ctx.mounted) return;
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(content: Text(apiErrorString(e)), backgroundColor: AppColors.error),
                          );
                        }
                      },
                      child: saving
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(isEditing ? tr('common.save') : tr('common.edit')),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showActionHistory() {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: ModalRoute.of(context)?.canPop == true
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  onPressed: () => Navigator.pop(context),
                )
              : null,
          title: Text(tr('admin.profile.actionHistory')),
        ),
        body: const ActionHistoryPage(),
      ),
    ));
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('admin.profile.logout')),
        content: Text(tr('admin.profile.logoutConfirm')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('common.cancel'))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService().logout();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, AuthRoutes.login, (route) => false);
            },
            child: Text(tr('admin.profile.logout'), style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final displayName = '$_prenoms $_nom'.trim();
    return ProfileBody(
      name: displayName.isNotEmpty ? displayName : (userNom ?? tr('admin.profile.admin')),
      email: _email.isNotEmpty ? _email : (userCode ?? '—'),
      badge: tr('admin.profile.badge'),
      badgeColor: const Color(0xFF1565C0),
      onEditProfile: _showEditInfo,
      menuGroups: [
        ProfileMenuGroup(tr('admin.profile.account'), [
          ProfileMenuItem(tr('admin.profile.personalInfo'), Icons.person, onTap: _showEditInfo),
          ProfileMenuItem(tr('admin.profile.actionHistory'), Icons.history, onTap: _showActionHistory),
        ]),
      ],
      onLogout: _logout,
    );
  }
}
