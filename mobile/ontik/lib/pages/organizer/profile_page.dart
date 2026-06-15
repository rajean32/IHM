import 'package:flutter/material.dart';
import '../../core/api/dio_config.dart';
import '../../core/assets/app_colors.dart';
import '../../core/services/user_service.dart';
import '../../core/routes/auth_routes.dart';
import '../../core/utils/error_helper.dart';
import '../../widgets/profile_body.dart';
import '../../widgets/two_factor_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _loading = true;
  bool _is2faEnabled = false;
  String _nom = '';
  String _prenoms = '';
  String _email = '';
  String _tel = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final code = userCode ?? '';
    if (code.isEmpty) return;
    setState(() => _loading = true);
    try {
      final data = await UserService().getOrganizerProfile(code);
      if (!mounted) return;
      setState(() {
        _nom = data['nom'] ?? '';
        _prenoms = data['prenoms'] ?? '';
        _email = data['email'] ?? '';
        _tel = data['tel'] ?? '';
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _showEditInfo() {
    final origNom = _nom;
    final origPrenoms = _prenoms;
    final origEmail = _email;
    final origTel = _tel;
    final nomCtrl = TextEditingController(text: _nom);
    final prenomsCtrl = TextEditingController(text: _prenoms);
    final emailCtrl = TextEditingController(text: _email);
    final telCtrl = TextEditingController(text: _tel);
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
                  const SizedBox(height: 12),
                  TextField(controller: telCtrl, enabled: isEditing, decoration: const InputDecoration(labelText: 'Téléphone', border: OutlineInputBorder()), keyboardType: TextInputType.phone),
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
                          telCtrl.text = origTel;
                          setSheetState(() => isEditing = false);
                          return;
                        }
                        setSheetState(() => saving = true);
                        try {
                          await UserService().updateOrganizerProfile(userCode ?? '', {
                            'nom': nomCtrl.text,
                            'prenoms': prenomsCtrl.text,
                            'email': emailCtrl.text,
                            'tel': telCtrl.text,
                          });
                          if (!ctx.mounted) return;
                          Navigator.pop(ctx);
                          _loadProfile();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profil mis à jour'), backgroundColor: AppTheme.secondaryColor),
                          );
                        } catch (e) {
                          setSheetState(() => saving = false);
                          if (!ctx.mounted) return;
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(content: Text(apiErrorString(e)), backgroundColor: AppTheme.errorColor),
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

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              clearSession();
              Navigator.of(context).pushNamedAndRemoveUntil(AuthRoutes.login, (route) => false);
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
      name: displayName.isNotEmpty ? displayName : (userNom ?? 'Organisateur'),
      email: _email.isNotEmpty ? _email : (userCode ?? '—'),
      badge: 'ORGANISATEUR',
      badgeColor: const Color(0xFF673AB7),
      onEditProfile: _showEditInfo,
      menuGroups: [
        ProfileMenuGroup('Compte', [
          ProfileMenuItem('Informations personnelles', Icons.person, onTap: _showEditInfo),
          ProfileMenuItem('Mes événements', Icons.event, onTap: () {}),
          ProfileMenuItem('Revenus', Icons.payments, onTap: () {}),
        ]),
        ProfileMenuGroup('Sécurité', [
          ProfileMenuItem('Mot de passe & 2FA', Icons.lock, status: 'Sécurisé', onTap: _showPasswordAnd2FA),
          ProfileMenuItem('Appareils connectés', Icons.devices, onTap: () {}),
        ]),
      ],
      onLogout: _logout,
    );
  }
}
