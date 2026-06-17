import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api/dio_config.dart';
import '../../core/api/endpoints.dart';
import '../../core/routes/client_routes.dart';
import '../../core/assets/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/user_service.dart';
import '../../core/utils/error_helper.dart';
import '../../widgets/profile_body.dart';
import '../../widgets/two_factor_widget.dart';
import 'saved_events_page.dart';
import '../../generated/app_localizations.dart';
import '../../widgets/admin/admin_toast.dart';

class ClientProfilePage extends StatefulWidget {
  const ClientProfilePage({super.key});

  @override
  State<ClientProfilePage> createState() => _ClientProfilePageState();
}

class _ClientProfilePageState extends State<ClientProfilePage> {
  bool _loading = true;
  bool _is2faEnabled = false;
  int _ticketCount = 0;
  int _notifCount = 0;
  int _favoriteCount = 0;
  String _nom = '';
  String _prenoms = '';
  String _email = '';
  String _tel = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final code = userCode ?? '';
    if (code.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);
    try {
      final userResp = await UserService().getUserProfile(code);
      _nom = userResp['nom'] ?? '';
      _prenoms = userResp['prenoms'] ?? '';
      _email = userResp['email'] ?? '';
      _tel = userResp['tel'] ?? '';

      final ticketsResp = await dio.get('${Endpoints.tickets}?client=$code');
      final tickets = ticketsResp.data['data'] as List? ?? [];
      _ticketCount = tickets.length;
      _notifCount = 0;
      final prefs = await SharedPreferences.getInstance();
      _favoriteCount = (prefs.getStringList('event_favorites') ?? []).length;
    } catch (_) {
      _nom = userNom ?? '';
    }
    if (mounted) setState(() => _loading = false);
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
                  Text(AppLocalizations.of(context)!.clientProfilePersonalInfo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 20),
                  TextField(controller: nomCtrl, enabled: isEditing, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.clientProfileLastName, border: const OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: prenomsCtrl, enabled: isEditing, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.clientProfileFirstName, border: const OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: emailCtrl, enabled: isEditing, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()), keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 12),
                  TextField(controller: telCtrl, enabled: isEditing, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.clientProfilePhone, border: const OutlineInputBorder()), keyboardType: TextInputType.phone),
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
                            title: Text(AppLocalizations.of(context)!.clientProfileConfirm),
                            content: Text(AppLocalizations.of(context)!.clientProfileConfirmSave),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(dctx, false), child: Text(AppLocalizations.of(context)!.commonCancel)),
                              TextButton(onPressed: () => Navigator.pop(dctx, true), child: Text(AppLocalizations.of(context)!.clientProfileConfirm)),
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
                        if (nomCtrl.text.trim().isEmpty) return;
                        setSheetState(() => saving = true);
                        try {
                          await UserService().updateUserProfile(userCode ?? '', {
                            'nom': nomCtrl.text.trim(),
                            'prenoms': prenomsCtrl.text.trim(),
                            'email': emailCtrl.text.trim(),
                            'tel': telCtrl.text.trim(),
                          });
                          if (!ctx.mounted) return;
                          Navigator.pop(ctx);
                          _loadData();
                          if (!context.mounted) return;
                          AdminToast.show(context, message: AppLocalizations.of(context)!.clientProfileUpdated, isSuccess: true);
                        } catch (e) {
                          setSheetState(() => saving = false);
                          if (!ctx.mounted) return;
                          AdminToast.show(ctx, message: apiErrorString(e), isSuccess: false);
                        }
                      },
                      child: saving
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(isEditing ? AppLocalizations.of(context)!.commonSave : AppLocalizations.of(context)!.commonEdit),
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

  void _showPaymentHistory() async {
    final code = userCode ?? '';
    if (code.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.clientProfilePaymentMethods),
        content: SizedBox(
          width: double.maxFinite,
          child: Text(AppLocalizations.of(context)!.clientProfilePaymentHistoryComing),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppLocalizations.of(context)!.clientProfileClose)),
        ],
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.commonLogout),
        content: Text(AppLocalizations.of(context)!.clientProfileConfirmLogout),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppLocalizations.of(context)!.commonCancel)),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await clearSession();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            child: Text(AppLocalizations.of(context)!.commonLogout, style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    final code = userCode ?? '';
    if (code.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.settingsDeleteAccount),
        content: Text(AppLocalizations.of(context)!.settingsDeleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppLocalizations.of(context)!.commonCancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLocalizations.of(context)!.settingsConfirm, style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await UserService().deleteSelfAccount(code);
      await clearSession();
      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/splash', (route) => false);
    } catch (e) {
      if (!context.mounted) return;
      AdminToast.show(context, message: AppLocalizations.of(context)!.errorOccurred, isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final displayName = '$_prenoms $_nom'.trim();
    return ProfileBody(
      name: displayName.isNotEmpty ? displayName : (userNom ?? AppLocalizations.of(context)!.clientProfileUser),
      email: _email.isNotEmpty ? _email : (userCode ?? '—'),
      badge: 'CLIENT',
      badgeColor: AppColors.primary,
      stats: [
        ProfileStat(AppLocalizations.of(context)!.clientProfileReference, '$_ticketCount', Icons.confirmation_number),
        ProfileStat(AppLocalizations.of(context)!.clientProfileFavorites, '$_favoriteCount', Icons.bookmark),
        ProfileStat(AppLocalizations.of(context)!.clientProfileAlerts, '$_notifCount', Icons.notifications),
      ],
      onEditProfile: _showEditInfo,
      menuGroups: [
        ProfileMenuGroup(AppLocalizations.of(context)!.clientProfileAccountGroup, [
          ProfileMenuItem(AppLocalizations.of(context)!.clientProfilePersonalInfo, Icons.person, onTap: _showEditInfo),
          ProfileMenuItem(AppLocalizations.of(context)!.clientProfileMyReservations, Icons.event, onTap: () {
            Navigator.pushNamed(context, ClientRoutes.profile);
          }),
          ProfileMenuItem(AppLocalizations.of(context)!.clientProfileFavorites, Icons.bookmark, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedEventsPage()));
          }),
          ProfileMenuItem(AppLocalizations.of(context)!.clientProfilePaymentMethods, Icons.payments, onTap: _showPaymentHistory),
        ]),
        ProfileMenuGroup(AppLocalizations.of(context)!.clientProfileSecurityGroup, [
          ProfileMenuItem(AppLocalizations.of(context)!.clientProfilePassword2FA, Icons.lock, status: AppLocalizations.of(context)!.clientProfileSecure, onTap: _showPasswordAnd2FA),
          ProfileMenuItem(AppLocalizations.of(context)!.clientProfileConnectedDevices, Icons.devices, onTap: () {}),
          ProfileMenuItem(AppLocalizations.of(context)!.settingsDeleteAccount, Icons.delete_forever, onTap: _deleteAccount),
        ]),
      ],
      onLogout: _logout,
    );
  }
}
