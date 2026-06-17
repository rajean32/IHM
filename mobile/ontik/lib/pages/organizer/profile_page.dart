import 'package:flutter/material.dart';
import '../../core/api/dio_config.dart';
import '../../core/assets/app_colors.dart';
import '../../core/services/dashboard_service.dart';
import '../../core/services/user_service.dart';
import '../../core/routes/auth_routes.dart';
import '../../core/utils/error_helper.dart';
import '../../models/dashboard_model.dart';
import '../../widgets/profile_body.dart';
import '../../generated/app_localizations.dart';

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
                  Text(AppLocalizations.of(context)!.personalInfo, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 20),
                  TextField(controller: nomCtrl, enabled: isEditing, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.lastName, border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: prenomsCtrl, enabled: isEditing, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.firstName, border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: emailCtrl, enabled: isEditing, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.emailField, border: OutlineInputBorder()), keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 12),
                  TextField(controller: telCtrl, enabled: isEditing, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.phone, border: OutlineInputBorder()), keyboardType: TextInputType.phone),
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
                            content: Text(AppLocalizations.of(context)!.saveChangesConfirm),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(dctx, false), child: Text(AppLocalizations.of(dctx)!.commonCancel)),
                              TextButton(onPressed: () => Navigator.pop(dctx, true), child: Text(AppLocalizations.of(dctx)!.commonConfirm)),
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
                            SnackBar(content: Text(AppLocalizations.of(context)!.profileUpdated), backgroundColor: AppTheme.secondaryColor),
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

  void _showRevenue() async {
    final orgCode = userCode ?? '';
    if (orgCode.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return FutureBuilder<OrganizerDashboardStats>(
          future: DashboardService().getDashboard(orgCode: orgCode).then((d) => OrganizerDashboardStats.fromJson(d)),
          builder: (ctx, snap) {
            return DraggableScrollableSheet(
              initialChildSize: 0.55,
              minChildSize: 0.4,
              maxChildSize: 0.75,
              expand: false,
              builder: (ctx, scrollCtrl) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: ListView(
                    controller: scrollCtrl,
                    children: [
                      Center(
                        child: Container(width: 40, height: 4,
                          decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(AppLocalizations.of(context)!.revenue, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 20),
                      if (snap.connectionState == ConnectionState.waiting)
                        const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
                      else if (snap.hasError)
                        Center(child: Text(AppLocalizations.of(context)!.loadError, style: TextStyle(color: AppTheme.errorColor, fontSize: 13)))
                      else ...[
                        _revenueStat(snap.data!, AppLocalizations.of(context)!.totalRevenue, '${snap.data!.totalRevenue.toStringAsFixed(0)} Ar', Icons.payments, AppColors.secondary),
                        const SizedBox(height: 12),
                        _revenueStat(snap.data!, AppLocalizations.of(context)!.ticketsSold, '${snap.data!.totalTicketsSold}', Icons.confirmation_number, AppColors.primary),
                        const SizedBox(height: 12),
                        _revenueStat(snap.data!, AppLocalizations.of(context)!.fillRate, '${snap.data!.fillRate.toStringAsFixed(1)}%', Icons.pie_chart, AppColors.accent),
                        const SizedBox(height: 12),
                        _revenueStat(snap.data!, AppLocalizations.of(context)!.seatsAvailable, '${snap.data!.placesDisponibles}', Icons.event_seat, const Color(0xFF7B1FA2)),
                        const SizedBox(height: 16),
                        if (snap.data!.dailySales.isNotEmpty) ...[
                          const Divider(),
                          const SizedBox(height: 8),
                          Text(AppLocalizations.of(context)!.latestSales, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          ...snap.data!.dailySales.reversed.take(7).map((s) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(children: [
                              Text(s.date, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                              const Spacer(),
                              Text('${s.ticketsSold} billet(s)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                              const SizedBox(width: 12),
                              Text('${s.revenue.toStringAsFixed(0)} Ar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary)),
                            ]),
                          )),
                        ],
                      ],
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _revenueStat(OrganizerDashboardStats stats, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary))),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ]),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.commonLogout),
        content: Text(AppLocalizations.of(context)!.logoutConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppLocalizations.of(ctx)!.commonCancel)),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(context, '/splash', (r) => false);
            },
            child: Text(AppLocalizations.of(ctx)!.commonLogout, style: TextStyle(color: AppColors.error)),
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
      name: displayName.isNotEmpty ? displayName : (userNom ?? AppLocalizations.of(context)!.profileTitle),
      email: _email.isNotEmpty ? _email : (userCode ?? '—'),
      badge: 'ORGANISATEUR',
      badgeColor: const Color(0xFF673AB7),
      onEditProfile: _showEditInfo,
      menuGroups: [
        ProfileMenuGroup(AppLocalizations.of(context)!.account, [
          ProfileMenuItem(AppLocalizations.of(context)!.personalInfo, Icons.person, onTap: _showEditInfo),
          ProfileMenuItem(AppLocalizations.of(context)!.revenue, Icons.payments, onTap: _showRevenue),
          ProfileMenuItem(AppLocalizations.of(context)!.settingsTitle, Icons.settings, onTap: () => Navigator.pushNamed(context, '/settings')),
        ]),
      ],
      onLogout: _logout,
    );
  }
}
