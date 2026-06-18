import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../core/api/dio_config.dart';
import '../../core/api/endpoints.dart';
import '../../core/assets/app_colors.dart';
import '../../core/routes/client_routes.dart';
import '../../models/ticket_model.dart';
import '../../widgets/error_state.dart';
import '../../widgets/event_image_widget.dart';
import '../../core/utils/error_helper.dart';
import '../../core/utils/place_utils.dart';
import '../../generated/app_localizations.dart';

class MyTicketsPage extends StatefulWidget {
  const MyTicketsPage({super.key});

  @override
  State<MyTicketsPage> createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage> {
  bool _loading = true;
  String? _error;
  List<Ticket> _tickets = [];

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    final clientCode = userCode ?? '';
    if (clientCode.isEmpty) return;

    setState(() => _loading = true);
    try {
      final ticketsResp = await dio.get('${Endpoints.tickets}?client=$clientCode');
      final ticketsData = ticketsResp.data['data'] as List? ?? [];
      if (!mounted) return;
      setState(() {
        _tickets = ticketsData.map((e) => Ticket.fromJson(e as Map<String, dynamic>)).toList();
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return ErrorState(message: _error!, onRetry: _loadTickets);
    }
    if (_tickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.confirmation_number_outlined, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.clientTicketNoTickets, style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(AppLocalizations.of(context)!.clientTicketAfterPurchase,
                style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTickets,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        children: [
          _buildIntro(),
          const SizedBox(height: 24),
          ..._tickets.map((t) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildTicketCard(t),
          )),
        ],
      ),
    );
  }

  Widget _buildIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.clientTicketMyTickets,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text(AppLocalizations.of(context)!.clientTicketManageTickets,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildBadge(String? typePlace) {
    final color = _badgeColor(typePlace);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        typePlace ?? 'STANDARD',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _badgeColor(String? typePlace) {
    switch (typePlace?.toUpperCase()) {
      case 'VIP':
        return const Color(0xFF9C27B0);
      case 'PREMIUM':
        return const Color(0xFFFF6F00);
      case 'ORCHESTRE':
        return const Color(0xFF7B1FA2);
      case 'BALCON':
        return const Color(0xFF00897B);
      case 'LOGE':
        return const Color(0xFF5C6BC0);
      default:
        return AppColors.placeStandard;
    }
  }

  Color _cardAccentColor(String? typePlace) {
    switch (typePlace?.toUpperCase()) {
      case 'VIP':
        return const Color(0xFFF3E5F5);
      case 'PREMIUM':
        return const Color(0xFFFFF3E0);
      case 'ORCHESTRE':
        return const Color(0xFFF3E5F5);
      case 'BALCON':
        return const Color(0xFFE0F2F1);
      case 'LOGE':
        return const Color(0xFFE8EAF6);
      default:
        return const Color(0xFFE0F2F1);
    }
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

  String _formatSimpleDate(String? date) {
    if (date == null) return '';
    try {
      final dateOnly = date.contains('T') ? date.split('T').first : date;
      final parts = dateOnly.split('-');
      if (parts.length != 3) return date;
      final d = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      const months = [
        'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
        'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
      ];
      return '${d.day} ${months[d.month - 1]} ${d.year}';
    } catch (_) {
      return date ?? '';
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
                // Event image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(11),
                    topRight: Radius.circular(11),
                  ),
                  child: SizedBox(
                    height: 140,
                    width: double.infinity,
                    child: t.image != null
                        ? eventImageWidget(
                            t.image,
                            height: 140,
                            width: double.infinity,
                          )
                        : Container(
                            color: accentColor,
                            child: Center(
                              child: Icon(
                                Icons.event,
                                size: 48,
                                color: _badgeColor(t.typePlace).withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                  ),
                ),
                // Details section
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
                              t.evenementTitre ?? AppLocalizations.of(context)!.clientTicketEvent,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildBadge(t.typePlace),
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
                      const SizedBox(height: 8),
                      if (t.dateReservation != null)
                        Row(
                          children: [
                            Icon(Icons.receipt_long, size: 13, color: AppColors.textMuted),
                            SizedBox(width: 5),
                            Text(
                              '${AppLocalizations.of(context)!.clientTicketBookedOn} ${_formatSimpleDate(t.dateReservation)}',
                              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      if (t.datePublication != null)
                        Padding(
                          padding: EdgeInsets.only(top: 3),
                          child: Row(
                            children: [
                              Icon(Icons.new_releases, size: 13, color: AppColors.textMuted),
                              SizedBox(width: 5),
                              Text(
                                '${AppLocalizations.of(context)!.clientTicketPublishedOn} ${_formatSimpleDate(t.datePublication)}',
                                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 12),
                      // Placement grid
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: t.zoneNom != null
                            ? Row(children: [_placementItem(Icons.accessibility_new, 'Zone', t.zoneNom!)])
                            : Row(
                                children: [
                                  _placementItem(Icons.meeting_room, AppLocalizations.of(context)!.clientTicketRoom, t.salleNom ?? '—'),
                                  Container(height: 24, width: 1, color: AppColors.divider),
                                  _placementItem(Icons.view_column, AppLocalizations.of(context)!.clientTicketRow, t.rang ?? '—'),
                                  Container(height: 24, width: 1, color: AppColors.divider),
                                  _placementItem(Icons.event_seat, AppLocalizations.of(context)!.clientTicketSeat, displayPlace(t.numeroPlace)),
                                ],
                              ),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
                // QR section
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: t.qrCodeBase64 != null
                            ? Image.memory(
                                base64Decode(t.qrCodeBase64!.contains(',')
                                    ? t.qrCodeBase64!.split(',').last
                                    : t.qrCodeBase64!),
                                width: 80,
                                height: 80,
                                fit: BoxFit.contain,
                              )
                            : Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.qr_code, size: 28, color: _badgeColor(t.typePlace)),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context)!.clientTicketReference,
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          const SizedBox(height: 2),
                          Text(
                            t.codeTicket,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              fontFamily: 'monospace',
                            ),
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
          // Expired overlay with glassmorphism
          if (!isActive)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.hourglass_empty, color: Colors.white.withValues(alpha: 0.7), size: 16),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.clientTicketExpired,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
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
          Text(value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
