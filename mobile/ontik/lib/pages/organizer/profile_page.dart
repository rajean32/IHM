import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/api/dio_config.dart';
import '../../core/assets/app_colors.dart';
import '../../core/services/dashboard_service.dart';
import '../../core/services/user_service.dart';
import '../../core/services/ville_service.dart';
import '../../core/routes/auth_routes.dart';
import '../../core/utils/error_helper.dart';
import '../../models/dashboard_model.dart';
import '../../models/evenement_model.dart';
import '../../models/ville_model.dart';
import '../../widgets/profile_body.dart';
import '../../generated/app_localizations.dart';
import '../../widgets/admin/admin_toast.dart';
import '../client/home_detail_page.dart';

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
  String _sexe = '';
  String _villeNom = '';
  String _villeCode = '';
  String? _photoUrl;

  List<Ville> _villes = [];
  OrganizerDashboardStats? _stats;

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
      final results = await Future.wait([
        UserService().getOrganizerProfile(code),
        VilleService().getVilles(),
        DashboardService().getDashboard(orgCode: code),
      ]);
      final data = results[0] as Map<String, dynamic>;
      final villes = results[1] as List<Ville>;
      final dashData = results[2] as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _nom = data['nom'] ?? '';
        _prenoms = data['prenoms'] ?? '';
        _email = data['email'] ?? '';
        _tel = data['tel'] ?? '';
        _sexe = data['sexe'] ?? '';
        _villeNom = data['ville'] ?? '';
        _villeCode = data['villeCode'] ?? '';
        _photoUrl = data['photo'] as String?;
        _villes = villes;
        _stats = OrganizerDashboardStats.fromJson(dashData);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _stats = null;
      });
    }
  }

  void _showEditInfo() {
    final origNom = _nom;
    final origPrenoms = _prenoms;
    final origEmail = _email;
    final origTel = _tel;
    final origSexe = _sexe;
    final origVilleCode = _villeCode;
    final origVilleNom = _villeNom;
    final nomCtrl = TextEditingController(text: _nom);
    final prenomsCtrl = TextEditingController(text: _prenoms);
    final emailCtrl = TextEditingController(text: _email);
    final telCtrl = TextEditingController(text: _tel);
    final autreVilleCtrl = TextEditingController();

    String editingSexe = _sexe;
    Ville? editingVille = _villes.where((v) => v.code == _villeCode).firstOrNull;
    bool isAutreVille = editingVille == null && _villeNom.isNotEmpty;
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.personalInfo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 20),
                    TextField(controller: nomCtrl, enabled: isEditing, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.lastName, border: const OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextField(controller: prenomsCtrl, enabled: isEditing, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.firstName, border: const OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextField(controller: emailCtrl, enabled: isEditing, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.emailField, border: const OutlineInputBorder()), keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 12),
                    TextField(controller: telCtrl, enabled: isEditing, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.phone, border: const OutlineInputBorder()), keyboardType: TextInputType.phone),
                    const SizedBox(height: 12),
                    if (isEditing) ...[
                      DropdownButtonFormField<String>(
                        value: editingSexe.isEmpty ? null : editingSexe,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Genre', border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(value: 'M', child: Text('Masculin')),
                          DropdownMenuItem(value: 'F', child: Text('Féminin')),
                        ],
                        onChanged: (v) => setSheetState(() => editingSexe = v ?? ''),
                      ),
                      const SizedBox(height: 12),
                      if (isAutreVille)
                        TextField(
                          controller: autreVilleCtrl,
                          decoration: const InputDecoration(labelText: 'Ville (autre)', border: OutlineInputBorder()),
                        )
                      else
                        DropdownButtonFormField<Ville>(
                          value: _villes.contains(editingVille) ? editingVille : null,
                          isExpanded: true,
                          decoration: const InputDecoration(labelText: 'Ville', border: OutlineInputBorder()),
                          items: [
                            ..._villes.map((v) => DropdownMenuItem(value: v, child: Text(v.nom))),
                            DropdownMenuItem(
                              value: null,
                              child: TextButton.icon(
                                icon: const Icon(Icons.add_location_alt_outlined, size: 18),
                                label: const Text('Autre'),
                                onPressed: () => setSheetState(() { isAutreVille = true; editingVille = null; }),
                              ),
                            ),
                          ],
                          onChanged: (v) => setSheetState(() => editingVille = v),
                        ),
                      const SizedBox(height: 12),
                    ],
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
                            editingSexe = origSexe;
                            editingVille = _villes.where((v) => v.code == origVilleCode).firstOrNull;
                            isAutreVille = false;
                            setSheetState(() => isEditing = false);
                            return;
                          }
                          setSheetState(() => saving = true);
                          try {
                            final updateData = <String, dynamic>{
                              'nom': nomCtrl.text,
                              'prenoms': prenomsCtrl.text,
                              'email': emailCtrl.text,
                              'tel': telCtrl.text,
                              'sexe': editingSexe,
                            };
                            if (isAutreVille) {
                              updateData['ville'] = autreVilleCtrl.text.trim();
                            } else if (editingVille != null) {
                              updateData['ville'] = editingVille!.nom;
                              updateData['villeCode'] = editingVille!.code;
                            }
                            await UserService().updateOrganizerProfile(userCode ?? '', updateData);
                            if (!ctx.mounted) return;
                            Navigator.pop(ctx);
                            _loadProfile();
                            if (!context.mounted) return;
                            AdminToast.show(context, message: AppLocalizations.of(context)!.profileUpdated, isSuccess: true);
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
                      Text(AppLocalizations.of(context)!.revenue, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
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
                        _revenueStat(snap.data!, AppLocalizations.of(context)!.seatsAvailable, '${snap.data!.placesDisponibles}', Icons.event_seat, AppColors.primary),
                        const SizedBox(height: 16),
                        if (snap.data!.dailySales.isNotEmpty) ...[
                          const Divider(),
                          const SizedBox(height: 8),
                          Text(AppLocalizations.of(context)!.latestSales, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          ...snap.data!.dailySales.reversed.take(7).map((s) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(children: [
                              Text(s.date, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                              const Spacer(),
                              Text('${s.ticketsSold} billet(s)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                              const SizedBox(width: 12),
                              Text('${s.revenue.toStringAsFixed(0)} Ar', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary)),
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

  void _showMyEvents() {
    if (_stats == null || _stats!.myEvents.isEmpty) {
      AdminToast.show(context, message: 'Aucun événement trouvé', isSuccess: false);
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        expand: false,
        builder: (ctx, scrollCtrl) => ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(24),
          children: [
            Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
            )),
            const SizedBox(height: 16),
            Text('Mes événements (${_stats!.myEvents.length})', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ..._stats!.myEvents.map((e) => _eventCard(e)),
          ],
        ),
      ),
    );
  }

  Widget _eventCard(Evenement e) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: e.idEvenement == null ? null : () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => HomeDetailPage(eventId: e.idEvenement!),
        )),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.event, color: AppColors.primary, size: 22),
              ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(e.titre ?? 'Événement', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              if (e.dateEvenement != null)
                Text(DateFormat('dd/MM/yyyy').format(e.dateEvenement!), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ])),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ]),
        ),
      ),
    );
  }

  Future<void> _pickPhoto() async {
    final code = userCode ?? '';
    if (code.isEmpty) return;
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 800, maxHeight: 800);
      if (picked == null) return;
      final file = File(picked.path);
      await UserService().uploadPhoto(code, file);
      _loadProfile();
      if (!mounted) return;
      AdminToast.show(context, message: 'Photo mise à jour', isSuccess: true);
    } catch (e) {
      if (!mounted) return;
      AdminToast.show(context, message: apiErrorString(e), isSuccess: false);
    }
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
      Navigator.pushNamedAndRemoveUntil(context, AuthRoutes.splash, (r) => false);
    } catch (e) {
      if (!context.mounted) return;
      AdminToast.show(context, message: AppLocalizations.of(context)!.errorOccurred, isSuccess: false);
    }
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
            onPressed: () async {
              Navigator.pop(ctx);
              await clearSession();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, AuthRoutes.splash, (r) => false);
            },
            child: Text(AppLocalizations.of(ctx)!.commonLogout, style: const TextStyle(color: AppColors.error)),
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
      badgeColor: AppColors.primary,
      photoUrl: _photoUrl,
      onPhotoTap: _pickPhoto,
      onEditProfile: _showEditInfo,
      stats: _stats != null ? [
        ProfileStat('Événements', '${_stats!.totalEvents}', Icons.event),
        ProfileStat('Billets vendus', '${_stats!.totalTicketsSold}', Icons.confirmation_number),
        ProfileStat('Revenu total', '${_stats!.totalRevenue.toStringAsFixed(0)} Ar', Icons.payments),
      ] : [],
      menuGroups: [
        ProfileMenuGroup(AppLocalizations.of(context)!.account, [
          ProfileMenuItem(AppLocalizations.of(context)!.personalInfo, Icons.person, onTap: _showEditInfo),
          ProfileMenuItem('Mes événements', Icons.event, onTap: _showMyEvents),
          ProfileMenuItem(AppLocalizations.of(context)!.revenue, Icons.payments, onTap: _showRevenue),
          ProfileMenuItem(AppLocalizations.of(context)!.settingsTitle, Icons.settings, onTap: () => Navigator.pushNamed(context, '/settings')),
        ]),
        ProfileMenuGroup(AppLocalizations.of(context)!.settingsSecurity, [
          ProfileMenuItem(AppLocalizations.of(context)!.settingsDeleteAccount, Icons.delete_forever, onTap: _deleteAccount),
        ]),
      ],
      onLogout: _logout,
    );
  }
}
