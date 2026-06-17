import 'package:flutter/material.dart';
import '../../core/api/dio_config.dart';
import '../../core/api/endpoints.dart';
import '../../core/assets/app_colors.dart';
import '../../models/ticket_model.dart';
import '../../widgets/error_state.dart';
import '../../widgets/event_image_widget.dart';
import '../../core/utils/error_helper.dart';
import '../../core/utils/place_utils.dart';
import '../../generated/app_localizations.dart';
import 'free_seating_ticket_page.dart';
import 'numbered_seating_ticket_page.dart';
import 'mixed_seating_ticket_page.dart';

class TicketListPage extends StatefulWidget {
  final String? placementType;
  final String? organiserCode;
  final int? eventId;
  const TicketListPage({super.key, this.placementType, this.organiserCode, this.eventId});

  @override
  State<TicketListPage> createState() => _TicketListPageState();
}

class _TicketListPageState extends State<TicketListPage> {
  final _searchCtrl = TextEditingController();
  bool _loading = true;
  String? _error;
  List<Ticket> _tickets = [];
  String _placementFilter = 'all';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String get _effectiveFilter {
    if (_searchCtrl.text.trim().isNotEmpty) return 'all';
    if (_placementFilter != 'all') return _placementFilter;
    return widget.placementType ?? 'all';
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final queryParams = <String, dynamic>{};
      if (widget.organiserCode != null) {
        queryParams['org'] = widget.organiserCode;
      } else {
        final clientCode = userCode ?? '';
        if (clientCode.isEmpty) return;
        queryParams['client'] = clientCode;
      }
      if (widget.eventId != null) queryParams['eventId'] = widget.eventId;
      final resp = await dio.get(Endpoints.tickets, queryParameters: queryParams);
      final data = resp.data['data'] as List? ?? [];
      if (!mounted) return;
      setState(() {
        _tickets = data.map((e) => Ticket.fromJson(e as Map<String, dynamic>)).toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = apiErrorString(e); _loading = false; });
    }
  }

  List<Ticket> get _filtered {
    final search = _searchCtrl.text.trim().toLowerCase();
    List<Ticket> result = _tickets;
    if (search.isNotEmpty) {
      result = result.where((t) =>
        t.codeTicket.toLowerCase().contains(search) ||
        (t.evenementTitre?.toLowerCase().contains(search) ?? false)
      ).toList();
    } else if (_effectiveFilter != 'all') {
      result = result.where((t) => _detectPlacement(t) == _effectiveFilter).toList();
    }
    return result;
  }

  String? _detectPlacement(Ticket t) {
    if (t.zoneNom != null) return 'MIXTE';
    if (t.numeroPlace != null && t.rang != null) return 'NUMEROTE';
    return 'LIBRE';
  }

  void _openTicket(Ticket t) {
    final placement = _detectPlacement(t);
    final code = t.codeTicket;
    switch (placement) {
      case 'LIBRE':
        Navigator.push(context, MaterialPageRoute(builder: (_) => FreeSeatingTicketPage(ticketCode: code)));
        break;
      case 'NUMEROTE':
        Navigator.push(context, MaterialPageRoute(builder: (_) => NumberedSeatingTicketPage(ticketCode: code)));
        break;
      case 'MIXTE':
        Navigator.push(context, MaterialPageRoute(builder: (_) => MixedSeatingTicketPage(ticketCode: code)));
        break;
      default:
        Navigator.push(context, MaterialPageRoute(builder: (_) => NumberedSeatingTicketPage(ticketCode: code)));
    }
  }

  Color _badgeColor(String? type) {
    switch (type?.toUpperCase()) {
      case 'VIP': return const Color(0xFF9C27B0);
      case 'PREMIUM': return const Color(0xFFFF6F00);
      case 'ORCHESTRE': return const Color(0xFF7B1FA2);
      case 'BALCON': return const Color(0xFF00897B);
      case 'LOGE': return const Color(0xFF5C6BC0);
      default: return AppColors.placeStandard;
    }
  }

  String _formatDate(String? date, String? time) {
    if (date == null) return '';
    try {
      final dateOnly = date.contains('T') ? date.split('T').first : date;
      final parts = dateOnly.split('-');
      if (parts.length != 3) return date;
      final d = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      const months = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
      return '${d.day} ${months[d.month - 1]} ${d.year}${time != null && time.length >= 5 ? ' • ${time.substring(0, 5)}' : ''}';
    } catch (_) { return date ?? ''; }
  }

  String _placementLabel(String? placement) {
    switch (placement) {
      case 'LIBRE': return 'Libre';
      case 'NUMEROTE': return 'Numéroté';
      case 'MIXTE': return 'Mixte';
      default: return placement ?? '—';
    }
  }

  IconData _placementIcon(String? placement) {
    switch (placement) {
      case 'LIBRE': return Icons.accessibility_new;
      case 'NUMEROTE': return Icons.event_seat;
      case 'MIXTE': return Icons.meeting_room;
      default: return Icons.confirmation_number;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return ErrorState(message: _error!, onRetry: _load);

    final filtered = _filtered;

    if (_tickets.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.confirmation_number_outlined, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.clientTicketNoTickets, style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(AppLocalizations.of(context)!.clientTicketAfterPurchase, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
        ]),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildSearchBar()),
          SliverToBoxAdapter(child: _buildFilters()),
          if (filtered.isEmpty)
            SliverFillRemaining(
              child: Center(child: Text(AppLocalizations.of(context)!.clientTicketNoTickets,
                  style: TextStyle(color: AppColors.textSecondary))),
            )
          else
            SliverList(delegate: SliverChildBuilderDelegate((ctx, i) {
              final t = filtered[i];
              final placement = _detectPlacement(t);
              return Padding(
                padding: EdgeInsets.fromLTRB(16, i == 0 ? 8 : 0, 16, 12),
                child: _buildTicketCard(t, placement),
              );
            }, childCount: filtered.length)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: 'Rechercher par code ticket ou événement',
          prefixIcon: Icon(Icons.search, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildFilters() {
    final placements = ['all', 'LIBRE', 'NUMEROTE', 'MIXTE'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: placements.map((p) {
          final selected = _placementFilter == p;
          final label = p == 'all' ? 'Tous' : _placementLabel(p);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(label, style: TextStyle(fontSize: 12, color: selected ? Colors.white : null)),
              selected: selected,
              onSelected: (_) => setState(() => _placementFilter = p),
              selectedColor: AppColors.primary,
            ),
          );
        }).toList()),
      ),
    );
  }

  Widget _buildTicketCard(Ticket t, String? placement) {
    final isActive = t.statut == 'VALID' || t.statut == 'DISPONIBLE' || t.statut == 'RESERVEE' || t.statut == 'EN_ATTENTE';
    final accentColor = _badgeColor(t.typePlace).withValues(alpha: 0.08);

    return GestureDetector(
      onTap: () => _openTicket(t),
      child: Stack(children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.ticketBorder),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(11), topRight: Radius.circular(11)),
              child: SizedBox(
                height: 120, width: double.infinity,
                child: t.image != null
                    ? eventImageWidget(t.image, height: 120, width: double.infinity)
                    : Container(color: accentColor, child: Center(
                        child: Icon(Icons.event, size: 48, color: _badgeColor(t.typePlace).withValues(alpha: 0.3)),
                      )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                    child: Text(t.evenementTitre ?? AppLocalizations.of(context)!.clientTicketEvent,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 8),
                  _buildPlacementBadge(placement),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Icon(Icons.calendar_today, size: 13, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(_formatDate(t.dateEvenement, t.heureEvenement),
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ]),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
                  child: placement == 'LIBRE'
                      ? _infoItem(Icons.accessibility_new, 'Entrée libre', t.zoneNom ?? 'Générale')
                      : Row(children: [
                          _infoItem(Icons.meeting_room, AppLocalizations.of(context)!.clientTicketRoom, t.salleNom ?? '—'),
                          Container(height: 20, width: 1, color: AppColors.divider),
                          _infoItem(Icons.view_column, AppLocalizations.of(context)!.clientTicketRow, t.rang ?? '—'),
                          Container(height: 20, width: 1, color: AppColors.divider),
                          _infoItem(Icons.event_seat, AppLocalizations.of(context)!.clientTicketSeat, displayPlace(t.numeroPlace)),
                        ]),
                ),
                const SizedBox(height: 12),
              ]),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.ticketQrBg,
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(11), bottomRight: Radius.circular(11)),
              ),
              child: Row(children: [
                Icon(Icons.qr_code, size: 28, color: _badgeColor(t.typePlace)),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(AppLocalizations.of(context)!.clientTicketReference, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                  Text(t.codeTicket, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontFamily: 'monospace')),
                ]),
                const Spacer(),
                const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
              ]),
            ),
          ]),
        ),
        if (!isActive)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(12)),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.65), borderRadius: BorderRadius.circular(8)),
                  child: Text(AppLocalizations.of(context)!.clientTicketExpired,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: 1.5)),
                ),
              ),
            ),
          ),
      ]),
    );
  }

  Widget _buildPlacementBadge(String? placement) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(_placementIcon(placement), size: 12, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(_placementLabel(placement), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary)),
      ]),
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return Expanded(
      child: Column(children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ]),
    );
  }
}
