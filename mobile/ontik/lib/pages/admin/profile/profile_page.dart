import 'package:flutter/material.dart';
import '../../../generated/app_localizations.dart';
import 'package:ontik/core/services/auth_service.dart';
import 'package:ontik/core/services/user_service.dart';
import 'package:ontik/core/api/dio_config.dart';
import 'package:ontik/core/routes/auth_routes.dart';
import 'package:ontik/core/routes/shared_routes.dart';
import 'package:ontik/core/assets/app_colors.dart';
import 'package:ontik/core/utils/error_helper.dart';
import 'package:ontik/widgets/profile_body.dart';
import 'package:ontik/pages/admin/history/action_history_page.dart';
import 'package:ontik/widgets/admin/admin_toast.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
                  Text(AppLocalizations.of(ctx)!.adminProfilePersonalInfo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 20),
                  TextField(controller: nomCtrl, enabled: isEditing, decoration: InputDecoration(labelText: AppLocalizations.of(ctx)!.adminProfileLastName, border: const OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: prenomsCtrl, enabled: isEditing, decoration: InputDecoration(labelText: AppLocalizations.of(ctx)!.adminProfileFirstName, border: const OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: emailCtrl, enabled: isEditing, decoration: InputDecoration(labelText: AppLocalizations.of(ctx)!.adminProfileEmail, border: const OutlineInputBorder()), keyboardType: TextInputType.emailAddress),
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
                            title: Text(AppLocalizations.of(ctx)!.commonConfirm),
                            content: Text(AppLocalizations.of(ctx)!.adminProfileSaveConfirm),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(dctx, false), child: Text(AppLocalizations.of(ctx)!.commonCancel)),
                              TextButton(onPressed: () => Navigator.pop(dctx, true), child: Text(AppLocalizations.of(ctx)!.commonConfirm)),
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
                          AdminToast.show(context, message: AppLocalizations.of(context)!.adminProfileUpdated, isSuccess: true);
                        } catch (e) {
                          setSheetState(() => saving = false);
                          if (!ctx.mounted) return;
                          AdminToast.show(ctx, message: apiErrorString(e), isSuccess: false);
                        }
                      },
                      child: saving
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(isEditing ? AppLocalizations.of(ctx)!.commonSave : AppLocalizations.of(ctx)!.commonEdit),
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
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.adminActionHistory)),
        body: const ActionHistoryPage(),
      ),
    ));
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.commonLogout),
        content: Text(AppLocalizations.of(context)!.settingsLogoutConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppLocalizations.of(context)!.commonCancel)),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService().logout();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, AuthRoutes.login, (route) => false);
            },
            child: Text(AppLocalizations.of(context)!.commonLogout, style: const TextStyle(color: AppColors.error)),
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
      name: displayName.isNotEmpty ? displayName : (userNom ?? 'Administrateur'),
      email: _email.isNotEmpty ? _email : (userCode ?? '—'),
      badge: 'ADMINISTRATEUR',
      badgeColor: AppColors.primary,
      onEditProfile: _showEditInfo,
      menuGroups: [
        ProfileMenuGroup(AppLocalizations.of(context)!.account, [
          ProfileMenuItem(AppLocalizations.of(context)!.personalInfo, Icons.person, onTap: _showEditInfo),
          ProfileMenuItem(AppLocalizations.of(context)!.settingsTitle, Icons.settings, onTap: () => Navigator.pushNamed(context, SharedRoutes.settings)),
          ProfileMenuItem(AppLocalizations.of(context)!.adminActionHistory, Icons.history, onTap: _showActionHistory),
        ]),
      ],
      onLogout: _logout,
    );
  }
}
