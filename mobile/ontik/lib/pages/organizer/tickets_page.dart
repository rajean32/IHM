import 'package:flutter/material.dart';
import '../../core/services/evenement_service.dart';
import '../../core/services/ticket_service.dart';
import '../../core/api/dio_config.dart';
import '../../models/evenement_model.dart';
import '../../core/assets/app_colors.dart';
import '../../widgets/error_state.dart';
import '../../core/utils/error_helper.dart';
import 'reservation_detail_page.dart';
import 'create_event_page.dart';

class TicketsPage extends StatefulWidget {
  const TicketsPage({super.key});

  @override
  State<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  bool _loading = true;
  String? _error;
  List<Evenement> _events = [];
  int? _selectedEventId;
  List<Map<String, dynamic>> _tickets = [];
  bool _loadingTickets = false;
  String? _ticketsError;
  String _periodFilter = 'all';

  @override
  void initState() { super.initState(); _loadEvents(); }

  Future<void> _loadEvents() async {
    final orgCode = userCode ?? '';
    if (orgCode.isEmpty) {
      if (mounted) setState(() { _loading = false; _error = 'Code organisateur introuvable. Reconnectez-vous.'; });
      return;
    }
    setState(() => _loading = true);
    try {
      final data = await EvenementService().getEvents(orgCode: orgCode);
      final events = data.map((e) => Evenement.fromJson(e as Map<String, dynamic>)).toList();
      if (!mounted) return;
      setState(() { _events = events; _loading = false; _error = null; _ticketsError = null; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = apiErrorString(e); _loading = false; });
    }
  }

  Future<void> _loadTickets(int eventId) async {
    setState(() { _selectedEventId = eventId; _loadingTickets = true; _ticketsError = null; });
    try {
      final data = await TicketService().getEventTickets(eventId);
      if (!mounted) return;
      setState(() { _tickets = [...data.cast<Map<String, dynamic>>()]; _loadingTickets = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _tickets = []; _loadingTickets = false; _ticketsError = apiErrorString(e); });
    }
  }

  Color _statusColor(String? statut) {
    switch (statut) {
      case 'PAYE': return AppTheme.secondaryColor;
      case 'EN_ATTENTE': return AppTheme.accentColor;
      case 'DISPONIBLE': return AppTheme.textSecondary;
      case 'CHECKED_IN': return AppTheme.primaryColor;
      default: return AppTheme.textSecondary;
    }
  }

  String _statusLabel(String? statut) {
    switch (statut) {
      case 'PAYE': return 'Payé';
      case 'EN_ATTENTE': return 'En attente';
      case 'DISPONIBLE': return 'Disponible';
      case 'CHECKED_IN': return 'Scanné';
      default: return statut ?? 'Inconnu';
    }
  }

  String _fmtPrix(dynamic p) {
    if (p == null) return '-';
    return '${p.toString()} Ar';
  }

  @override
  Widget build(BuildContext context) {
    final filteredTickets = _tickets.where((t) {
      if (_periodFilter == 'all') return true;
      if (_periodFilter == 'paid') return t['statut'] == 'PAYE' || t['statut'] == 'CHECKED_IN';
      if (_periodFilter == 'pending') return t['statut'] == 'EN_ATTENTE' || t['statut'] == 'DISPONIBLE';
      return true;
    }).toList();

    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorState(message: _error!, onRetry: _loadEvents)
              : Column(children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: Row(children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _selectedEventId,
                          decoration: const InputDecoration(labelText: 'Événement', border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                          items: _events.map((e) => DropdownMenuItem(value: e.idEvenement, child: Text(e.titre, style: const TextStyle(fontSize: 12)))).toList(),
                          onChanged: (v) { if (v != null) _loadTickets(v); },
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 90,
                        child: DropdownButtonFormField<String>(
                          value: _periodFilter,
                          isExpanded: true,
                          decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 8)),
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('Tous', style: TextStyle(fontSize: 11))),
                            DropdownMenuItem(value: 'paid', child: Text('Payés', style: TextStyle(fontSize: 11))),
                            DropdownMenuItem(value: 'pending', child: Text('En att.', style: TextStyle(fontSize: 11))),
                          ],
                          onChanged: (v) => setState(() => _periodFilter = v!),
                        ),
                      ),
                    ]),
                  ),
                  if (_ticketsError != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                      child: Card(
                        color: AppTheme.errorColor.withValues(alpha: 0.08),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(children: [
                            const Icon(Icons.error_outline, size: 16, color: AppTheme.errorColor),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_ticketsError!, style: const TextStyle(fontSize: 11, color: AppTheme.errorColor))),
                            TextButton(
                              onPressed: () { if (_selectedEventId != null) _loadTickets(_selectedEventId!); },
                              child: const Text('Réessayer', style: TextStyle(fontSize: 10)),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  Expanded(
                    child: _loadingTickets
                        ? const Center(child: CircularProgressIndicator())
                        : _selectedEventId == null
                            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.confirmation_number, size: 48, color: AppTheme.textSecondary.withValues(alpha: 0.4)),
                                const SizedBox(height: 12),
                                const Text('Sélectionnez un événement', style: TextStyle(color: AppTheme.textSecondary)),
                              ]))
                            : filteredTickets.isEmpty
                                ? const Center(child: Text('Aucun billet', style: TextStyle(color: AppTheme.textSecondary)))
                                : RefreshIndicator(
                                    onRefresh: () => _loadTickets(_selectedEventId!),
                                    child: ListView.builder(
                                      padding: const EdgeInsets.all(8),
                                      itemCount: filteredTickets.length,
                                      itemBuilder: (ctx, i) {
                                        final t = filteredTickets[i];
                                        final code = t['codeTicket'] ?? '';
                                        final place = t['numeroPlace'] ?? '-';
                                        final rang = t['rang'] ?? '';
                                        final type = t['typePlace'] ?? '';
                                        final prix = _fmtPrix(t['prix']);
                                        final client = t['clientNom'] ?? 'Inconnu';
                                        final statut = t['statut'] as String?;
                                        final sc = _statusColor(statut);
                                        final idReservation = t['idReservation'];
                                        return Card(
                                          margin: const EdgeInsets.symmetric(vertical: 4),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(children: [
                                                  Expanded(
                                                    child: Text(code, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, fontFamily: 'monospace')),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: sc.withValues(alpha: 0.15),
                                                      borderRadius: BorderRadius.circular(10),
                                                      border: Border.all(color: sc.withValues(alpha: 0.4)),
                                                    ),
                                                    child: Text(_statusLabel(statut), style: TextStyle(fontSize: 10, color: sc, fontWeight: FontWeight.w600)),
                                                  ),
                                                ]),
                                                const SizedBox(height: 8),
                                                Row(children: [
                                                  _chip(Icons.event_seat, 'Place $place'),
                                                  if (rang.isNotEmpty) ...[
                                                    const SizedBox(width: 8),
                                                    _chip(Icons.format_line_spacing, 'Rang $rang'),
                                                  ],
                                                ]),
                                                const SizedBox(height: 4),
                                                Row(children: [
                                                  if (type.isNotEmpty) ...[
                                                    _chip(Icons.category, type),
                                                    const SizedBox(width: 8),
                                                  ],
                                                  Text(prix, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor)),
                                                  const Spacer(),
                                                  Icon(Icons.person, size: 14, color: AppTheme.textSecondary),
                                                  const SizedBox(width: 4),
                                                  Text(client, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                                ]),
                                                const Divider(height: 12),
                                                Row(children: [
                                                  if (idReservation != null)
                                                    Expanded(
                                                      child: SizedBox(
                                                        height: 28,
                                                        child: OutlinedButton.icon(
                                                          onPressed: () => _openReservation(idReservation is int ? idReservation : int.parse(idReservation.toString())),
                                                          icon: const Icon(Icons.receipt, size: 12),
                                                          label: const Text('Réservation', style: TextStyle(fontSize: 10)),
                                                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4)),
                                                        ),
                                                      ),
                                                    ),
                                                  if (idReservation != null) const SizedBox(width: 8),
                                                  Expanded(
                                                    child: SizedBox(
                                                      height: 28,
                                                      child: OutlinedButton.icon(
                                                        onPressed: _selectedEventId != null ? () => _showEventDetail(_selectedEventId!) : null,
                                                        icon: const Icon(Icons.event, size: 12),
                                                        label: const Text('Événement', style: TextStyle(fontSize: 10)),
                                                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4)),
                                                      ),
                                                    ),
                                                  ),
                                                ]),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                  ),
                ]),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: AppTheme.textSecondary),
        const SizedBox(width: 3),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      ]),
    );
  }

  void _openReservation(int id) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => ReservationDetailPage(id: id)));
  }

  void _showEventDetail(int eventId) async {
    final event = _events.where((e) => e.idEvenement == eventId).firstOrNull;
    if (event == null) return;
    await Navigator.push(context, MaterialPageRoute(builder: (_) => CreateEventPage(event: event)));
    _loadEvents();
  }
}
