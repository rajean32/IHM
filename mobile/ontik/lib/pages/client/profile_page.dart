import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/reservation_model.dart';
import '../../models/ticket_model.dart';
import '../../core/api/endpoints.dart';
import '../../core/services/reservation_service.dart';
import '../../core/api/dio_config.dart';
import '../../core/assets/app_colors.dart';
import '../../core/routes/client_routes.dart';
import '../../widgets/error_state.dart';
import '../../widgets/event_image_widget.dart';
import '../../core/utils/error_helper.dart';
import '../../core/services/app_config.dart';
import '../../localization/app_localizations.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
                              '${tr('client.profile.reservation')} #${r.idReservation}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                            if (r.dateReservation != null)
                              Text(
                                DateFormat('d MMMM yyyy \'à\' HH:mm', appLanguage).format(r.dateReservation!),
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
                  Text(tr('client.profile.ticketsTab'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  if (r.tickets != null && r.tickets!.isNotEmpty)
                    ...r.tickets!.map((t) => _buildTicketDetailTile(t))
                  else
                    Text(tr('client.profile.noTickets'), style: const TextStyle(color: AppColors.textMuted)),
                  const SizedBox(height: 16),
                  if (r.codeTickets != null && r.codeTickets!.isNotEmpty) ...[
                    Text(tr('client.profile.referenceCodes'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
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
                      Text('${tr('client.profile.seat')} ${t.numeroPlace}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    if (t.rang != null)
                      Text(' (${tr('client.profile.row')} ${t.rang})', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('client.profile.myReservations')),
        automaticallyImplyLeading: false,
        leading: ModalRoute.of(context)?.canPop == true
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 22),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        actions: const [],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: const Icon(Icons.receipt_long), text: tr('client.profile.reservationsTab')),
            Tab(icon: const Icon(Icons.confirmation_number), text: tr('client.profile.ticketsTab')),
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
            Text(tr('client.profile.noReservations'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(tr('client.profile.reservationsWillAppear'),
                style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
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
                            '${tr('client.profile.reservation')} #${r.idReservation}',
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
                              hasTickets ? firstTicket!.evenementTitre ?? '${tr('client.profile.reservation')} #${r.idReservation}' : '${tr('client.profile.reservation')} #${r.idReservation}',
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
                                ? DateFormat('d MMM yyyy', appLanguage).format(r.dateReservation!)
                                : tr('client.profile.unknownDate'),
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
                            '${r.tickets?.length ?? 0} ${tr('client.profile.ticketsCount')}',
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
                            Text(tr('client.profile.reservationReference'),
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
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
            Text(tr('client.profile.noTickets'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(tr('client.profile.ticketsWillAppear'),
                style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
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
                              t.evenementTitre ?? tr('client.profile.event'),
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
            _placementItem(Icons.meeting_room, tr('client.profile.room'), t.salleNom ?? '—'),
            Container(height: 24, width: 1, color: AppColors.divider),
            _placementItem(Icons.view_column, tr('client.profile.row'), t.rang ?? '—'),
            Container(height: 24, width: 1, color: AppColors.divider),
            _placementItem(Icons.event_seat, tr('client.profile.seat'), t.numeroPlace ?? '—'),
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
                          Text(tr('client.profile.reference'), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
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
                    child: Text(
                      tr('client.profile.expired'),
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
