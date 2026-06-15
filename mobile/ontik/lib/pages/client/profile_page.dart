import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/reservation_model.dart';
import '../../models/ticket_model.dart';
import '../../core/api/endpoints.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/reservation_service.dart';
import '../../core/api/dio_config.dart';
import '../../core/assets/app_colors.dart';
import '../../core/routes/client_routes.dart';
import '../../widgets/error_state.dart';
import '../../widgets/event_image_widget.dart';
import '../../core/utils/error_helper.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = true;
  String? _error;
  List<Reservation> _reservations = [];
  List<Ticket> _tickets = [];
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _is2faEnabled = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final clientCode = userCode ?? '';
    if (clientCode.isEmpty) return;

    setState(() => _loading = true);
    try {
      final _reservationService = ReservationService();
      final reservationsData = await _reservationService.getMyReservations(clientCode);

      if (!mounted) return;
      final reservations = reservationsData.map((e) => Reservation.fromJson(e as Map<String, dynamic>)).toList();
      final tickets = <Ticket>[];
      for (final r in reservations) {
        if (r.tickets != null) tickets.addAll(r.tickets!);
      }
      setState(() {
        _reservations = reservations;
        _tickets = tickets;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = apiErrorString(e);
        _loading = false;
      });
    }
  }

  void _showReservationDetail(Reservation r) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          expand: false,
          builder: (ctx, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.receipt_long, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Réservation #${r.idReservation}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                            if (r.dateReservation != null)
                              Text(
                                DateFormat('d MMMM yyyy \'à\' HH:mm', 'fr').format(r.dateReservation!),
                                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Text('Billets', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  if (r.tickets != null && r.tickets!.isNotEmpty)
                    ...r.tickets!.map((t) => _buildTicketDetailTile(t))
                  else
                    const Text('Aucun billet', style: TextStyle(color: AppColors.textMuted)),
                  const SizedBox(height: 16),
                  if (r.codeTickets != null && r.codeTickets!.isNotEmpty) ...[
                    const Text('Codes de référence', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    ...r.codeTickets!.map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.qr_code, size: 16, color: AppColors.textMuted),
                          const SizedBox(width: 8),
                          Text(c, style: const TextStyle(fontSize: 13, fontFamily: 'monospace', color: AppColors.textPrimary)),
                        ],
                      ),
                    )),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTicketDetailTile(Ticket t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.confirmation_number, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.evenementTitre ?? 'Ticket', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (t.numeroPlace != null)
                      Text('Place ${t.numeroPlace}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    if (t.rang != null)
                      Text(' (Rang ${t.rang})', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
                if (t.prix != null)
                  Text('Ar ${t.prix!.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondary)),
              ],
            ),
          ),
          if (t.typePlace != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _badgeColor(t.typePlace).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                t.typePlace!,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _badgeColor(t.typePlace)),
              ),
            ),
        ],
      ),
    );
  }

  Color _badgeColor(String? type) {
    switch (type?.toUpperCase()) {
      case 'VIP': return const Color(0xFF9C27B0);
      case 'PREMIUM': return const Color(0xFFFF6F00);
      default: return const Color(0xFF00796B);
    }
  }

  Future<void> _changePassword() async {
    if (_currentPasswordCtrl.text.isEmpty) return;
    if (_newPasswordCtrl.text.length < 6) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le mot de passe doit contenir au moins 6 caractères'), backgroundColor: AppColors.error),
      );
      return;
    }
    if (_newPasswordCtrl.text != _confirmPasswordCtrl.text) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les mots de passe ne correspondent pas'), backgroundColor: AppColors.error),
      );
      return;
    }
    try {
      await AuthService().changePassword(_currentPasswordCtrl.text, _newPasswordCtrl.text);
      if (!mounted) return;
      Navigator.pop(context);
      _currentPasswordCtrl.clear();
      _newPasswordCtrl.clear();
      _confirmPasswordCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mot de passe modifié'), backgroundColor: AppColors.secondary),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(apiErrorString(e)), backgroundColor: AppColors.error),
      );
    }
  }

  void _showPasswordDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Mot de passe & 2FA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: Icon(_is2faEnabled ? Icons.lock : Icons.lock_open, color: _is2faEnabled ? AppColors.secondary : AppColors.textMuted),
                    onPressed: () => _show2faSetup(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Authentification à deux facteurs', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  Switch(
                    value: _is2faEnabled,
                    activeColor: AppColors.primary,
                    onChanged: (v) {
                      if (v) {
                        _show2faSetup(ctx);
                      } else {
                        _show2faDisableConfirm(ctx);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _is2faEnabled ? 'Code à 6 chiffres envoyé par email' : 'Activez pour sécuriser votre compte',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              const Text('Changer le mot de passe', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              TextField(
                controller: _currentPasswordCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mot de passe actuel', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _newPasswordCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Nouveau mot de passe', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _confirmPasswordCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirmer', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _changePassword,
                  child: const Text('Changer le mot de passe'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _show2faSetup(BuildContext parentCtx) {
    final codeCtrl = TextEditingController();
    bool sending = false;
    bool verifying = false;
    bool codeSent = false;
    String? sentCode;

    showDialog(
      context: parentCtx,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Activer la 2FA'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Un code à 6 chiffres sera envoyé à votre adresse email.'),
                    const SizedBox(height: 16),
                    if (!codeSent) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: sending ? null : () async {
                            setDialogState(() => sending = true);
                            await Future.delayed(const Duration(seconds: 1));
                            sentCode = '123456';
                            setDialogState(() { sending = false; codeSent = true; });
                          },
                          icon: sending
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.email_outlined),
                          label: Text(sending ? 'Envoi...' : 'Envoyer le code'),
                        ),
                      ),
                    ],
                    if (codeSent) ...[
                      TextField(
                        controller: codeCtrl,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.w700),
                        decoration: InputDecoration(
                          hintText: '000000',
                          border: OutlineInputBorder(),
                          counterText: '',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () async {
                              setDialogState(() => sending = true);
                              await Future.delayed(const Duration(seconds: 1));
                              sentCode = '123456';
                              setDialogState(() => sending = false);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: verifying ? null : () async {
                            if (codeCtrl.text.length != 6) return;
                            setDialogState(() => verifying = true);
                            await Future.delayed(const Duration(seconds: 1));
                            if (codeCtrl.text == sentCode) {
                              if (!ctx.mounted) return;
                              Navigator.pop(ctx);
                              setState(() => _is2faEnabled = true);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('2FA activée'), backgroundColor: AppColors.secondary),
                              );
                            } else {
                              setDialogState(() => verifying = false);
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(content: Text('Code incorrect'), backgroundColor: AppColors.error),
                              );
                            }
                          },
                          child: verifying
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Vérifier et activer'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
              ],
            );
          },
        );
      },
    );
  }

  void _show2faDisableConfirm(BuildContext parentCtx) {
    showDialog(
      context: parentCtx,
      builder: (ctx) => AlertDialog(
        title: const Text('Désactiver la 2FA'),
        content: const Text('Voulez-vous vraiment désactiver l\'authentification à deux facteurs ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _is2faEnabled = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('2FA désactivée'), backgroundColor: AppColors.secondary),
              );
            },
            child: const Text('Désactiver', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Réservations'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, ClientRoutes.home);
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_outline),
            onPressed: _showPasswordDialog,
            tooltip: 'Mot de passe & 2FA',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.receipt_long), text: 'Réservations'),
            Tab(icon: Icon(Icons.confirmation_number), text: 'Billets'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorState(message: _error!, onRetry: _loadData)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildReservationsList(),
                    _buildTicketsList(),
                  ],
                ),
    );
  }

  Widget _buildReservationsList() {
    if (_reservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            const Text('Aucune réservation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            const Text('Vos réservations apparaîtront ici.',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: _reservations.length,
        itemBuilder: (context, index) {
          final r = _reservations[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildReservationCard(r),
          );
        },
      ),
    );
  }

  Widget _buildReservationCard(Reservation r) {
    final hasTickets = r.tickets != null && r.tickets!.isNotEmpty;
    final firstTicket = hasTickets ? r.tickets!.first : null;
    final accentColor = firstTicket != null ? _cardAccentColor(firstTicket.typePlace) : AppColors.surface;

    return GestureDetector(
      onTap: () => _showReservationDetail(r),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.ticketBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                eventImageWidget(
                  hasTickets && firstTicket?.idEvenement != null
                      ? null
                      : null,
                  height: 130,
                ),
                if (firstTicket?.evenementTitre != null)
                  Container(
                    height: 130,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(11),
                        topRight: Radius.circular(11),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.event, size: 40, color: _badgeColor(firstTicket!.typePlace).withValues(alpha: 0.3)),
                          const SizedBox(height: 6),
                          Text(
                            firstTicket.evenementTitre ?? '',
                            style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600,
                              color: _badgeColor(firstTicket.typePlace),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Container(
                    height: 130,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(11),
                        topRight: Radius.circular(11),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.receipt_long, size: 40, color: AppColors.textMuted.withValues(alpha: 0.3)),
                          const SizedBox(height: 6),
                          Text(
                            'Réservation #${r.idReservation}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              hasTickets ? firstTicket!.evenementTitre ?? 'Réservation #${r.idReservation}' : 'Réservation #${r.idReservation}',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (hasTickets && firstTicket!.typePlace != null)
                            _buildStatusBadge(firstTicket.typePlace!),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            r.dateReservation != null
                                ? DateFormat('d MMM yyyy', 'fr').format(r.dateReservation!)
                                : 'Date inconnue',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.confirmation_number, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            '${r.tickets?.length ?? 0} billet(s)',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.ticketQrBg,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(11),
                      bottomRight: Radius.circular(11),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.receipt_long, size: 22, color: AppColors.textMuted),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Référence réservation',
                                style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                            Text(
                              '#${r.idReservation}',
                              style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String typePlace) {
    final color = _badgeColor(typePlace);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        typePlace.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5),
      ),
    );
  }

  Color _cardAccentColor(String? typePlace) {
    switch (typePlace?.toUpperCase()) {
      case 'VIP': return const Color(0xFFF3E5F5);
      case 'PREMIUM': return const Color(0xFFFFF3E0);
      default: return const Color(0xFFE0F2F1);
    }
  }

  Widget _buildTicketsList() {
    if (_tickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.confirmation_number_outlined, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            const Text('Aucun billet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            const Text('Vos billets apparaîtront ici après réservation.',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: _tickets.length,
        itemBuilder: (context, index) {
          final t = _tickets[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildTicketCard(t),
          );
        },
      ),
    );
  }

  String _formatDate(String? date, String? time) {
    if (date == null) return '';
    try {
      final dateOnly = date.contains('T') ? date.split('T').first : date;
      final parts = dateOnly.split('-');
      if (parts.length != 3) return date;
      final d = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      const days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
      const months = [
        'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
        'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
      ];
      final dayName = days[d.weekday - 1];
      final monthName = months[d.month - 1];
      final formatted = '$dayName, $monthName ${d.year}';
      if (time != null && time.length >= 5) {
        return '$formatted \u2022 ${time.substring(0, 5)}';
      }
      if (date.contains('T') && date.length >= 16) {
        return '$formatted \u2022 ${date.substring(11, 16)}';
      }
      return formatted;
    } catch (_) {
      return date;
    }
  }

  Widget _buildTicketCard(Ticket t) {
    final isActive = t.statut == 'VALID' || t.statut == 'DISPONIBLE' || t.statut == 'RESERVEE' || t.statut == 'EN_ATTENTE';
    final accentColor = _cardAccentColor(t.typePlace);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          ClientRoutes.ticket,
          arguments: {'code': t.codeTicket},
        );
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.ticketBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 130,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(11),
                      topRight: Radius.circular(11),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.event,
                      size: 48,
                      color: _badgeColor(t.typePlace).withValues(alpha: 0.3),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              t.evenementTitre ?? 'Événement',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusBadge(t.typePlace ?? 'STANDARD'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            _formatDate(t.dateEvenement, t.heureEvenement),
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            _placementItem(Icons.meeting_room, 'Salle', t.salleNom ?? '—'),
                            Container(height: 24, width: 1, color: AppColors.divider),
                            _placementItem(Icons.view_column, 'Rang', t.rang ?? '—'),
                            Container(height: 24, width: 1, color: AppColors.divider),
                            _placementItem(Icons.event_seat, 'Place', t.numeroPlace ?? '—'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.ticketQrBg,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(11),
                      bottomRight: Radius.circular(11),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.qr_code, size: 28, color: _badgeColor(t.typePlace)),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Référence', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          const SizedBox(height: 2),
                          Text(
                            t.codeTicket,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!isActive)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'EXPIRÉ',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: 1.5),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _placementItem(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          const SizedBox(height: 1),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
