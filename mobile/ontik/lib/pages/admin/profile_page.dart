import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/user_service.dart';
import '../../core/api/dio_config.dart';
import '../../core/routes/auth_routes.dart';
import '../../core/assets/app_colors.dart';
import '../../core/utils/error_helper.dart';
import '../../widgets/profile_body.dart';
import '../../widgets/two_factor_widget.dart';
import 'action_history_page.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  bool _loading = true;
  bool _is2faEnabled = false;
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
                  const Text('Informations personnelles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 20),
                  TextField(controller: nomCtrl, enabled: isEditing, decoration: const InputDecoration(labelText: 'Nom', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: prenomsCtrl, enabled: isEditing, decoration: const InputDecoration(labelText: 'Prénoms', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: emailCtrl, enabled: isEditing, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()), keyboardType: TextInputType.emailAddress),
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
                            title: const Text('Confirmer'),
                            content: const Text('Voulez-vous enregistrer les modifications ?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(dctx, false), child: const Text('Annuler')),
                              TextButton(onPressed: () => Navigator.pop(dctx, true), child: const Text('Confirmer')),
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
                            const SnackBar(content: Text('Informations mises à jour'), backgroundColor: AppColors.secondary),
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
                          : Text(isEditing ? 'Enregistrer' : 'Modifier'),
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

  void _showPasswordAnd2FA() {
    showPasswordAnd2FABottomSheet(
      context,
      _is2faEnabled,
      (val) {
        if (mounted) setState(() => _is2faEnabled = val);
      },
    );
  }

  void _showActionHistory() {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Historique des actions')),
        body: const ActionHistoryPage(),
      ),
    ));
  }

  void _showConnectedDevices() {
    final deviceName = Platform.isAndroid ? 'Android' : Platform.isIOS ? 'iOS' : 'Web';
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Appareils connectés',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.phone_android, size: 32, color: AppColors.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(deviceName, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('${userCode ?? "—"} • Appareil actuel',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Actif', style: TextStyle(fontSize: 11, color: AppColors.secondary)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  showDialog(
                    context: context,
                    builder: (dctx) => AlertDialog(
                      title: const Text('Déconnexion'),
                      content: const Text('Voulez-vous déconnecter tous les autres appareils ?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(dctx), child: const Text('Annuler')),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(dctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Tous les autres appareils ont été déconnectés'),
                                backgroundColor: AppColors.secondary,
                              ),
                            );
                          },
                          child: const Text('Déconnecter', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Déconnecter les autres appareils'),
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService().logout();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, AuthRoutes.login, (route) => false);
            },
            child: const Text('Déconnexion', style: TextStyle(color: AppColors.error)),
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
      badgeColor: const Color(0xFF1565C0),
      onEditProfile: _showEditInfo,
      menuGroups: [
        ProfileMenuGroup('Compte', [
          ProfileMenuItem('Informations personnelles', Icons.person, onTap: _showEditInfo),
          ProfileMenuItem('Historique des actions', Icons.history, onTap: _showActionHistory),
        ]),
        ProfileMenuGroup('Sécurité', [
          ProfileMenuItem('Mot de passe & 2FA', Icons.lock, status: 'Sécurisé', onTap: _showPasswordAnd2FA),
          ProfileMenuItem('Appareils connectés', Icons.devices, onTap: _showConnectedDevices),
        ]),
      ],
      onLogout: _logout,
    );
  }
}
