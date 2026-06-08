import 'package:flutter/material.dart';
import '../../core/services/evenement_service.dart';
import '../../core/services/reservation_service.dart';
import '../../core/api/dio_config.dart';
import '../../models/evenement_model.dart';
import '../../core/assets/app_colors.dart';
import '../../widgets/error_state.dart';
import '../../core/utils/error_helper.dart';
import 'reservation_detail_page.dart';
import 'create_event_page.dart';

class ReservationsPage extends StatefulWidget {
  const ReservationsPage({super.key});

  @override
  State<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> {
  bool _loading = true;
  String? _error;
  List<Evenement> _events = [];
  int? _selectedEventId;
  List<Map<String, dynamic>> _reservations = [];
  bool _loadingReservations = false;
  String? _reservationsError;
  String _periodFilter = 'all';
  final Set<int> _expandedIds = {};

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
      setState(() { _events = events; _loading = false; _error = null; _reservationsError = null; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = apiErrorString(e); _loading = false; });
    }
  }

  Future<void> _loadReservations(int eventId) async {
    setState(() { _selectedEventId = eventId; _loadingReservations = true; _expandedIds.clear(); _reservationsError = null; });
    try {
      final data = await ReservationService().getEventReservations(eventId);
      if (!mounted) return;
      setState(() { _reservations = [...data.cast<Map<String, dynamic>>()]; _loadingReservations = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _reservations = []; _loadingReservations = false; _reservationsError = apiErrorString(e); });
    }
  }

  void _openDetail(int id) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => ReservationDetailPage(id: id)));
    if (_selectedEventId != null) _loadReservations(_selectedEventId!);
  }

  String _formatDate(dynamic d) {
    if (d == null) return '-';
    final s = d.toString();
    if (s.length >= 10) return s.substring(0, 10);
    return s;
  }

  double _totalMontant() {
    double total = 0;
    for (final r in _reservations) {
      final m = r['paiement'];
      if (m is Map) {
        total += double.tryParse(m['montant']?.toString() ?? '0') ?? 0;
      }
    }
    return total;
  }

  List<Map<String, dynamic>> _getTickets(dynamic r) {
    final tickets = r['tickets'];
    if (tickets is List) return tickets.cast<Map<String, dynamic>>();
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final filtered = _reservations.where((r) {
      if (_periodFilter == 'all') return true;
      final dateStr = _formatDate(r['dateReservation']);
      if (dateStr == '-') return true;
      final date = DateTime.tryParse(dateStr);
      if (date == null) return true;
      final diff = now.difference(date);
      if (_periodFilter == 'today' && diff.inDays == 0) return true;
      if (_periodFilter == 'week' && diff.inDays < 7) return true;
      if (_periodFilter == 'month' && diff.inDays < 30) return true;
      return false;
    }).toList();

    final totalAmount = _totalMontant();

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
                          onChanged: (v) { if (v != null) _loadReservations(v); },
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
                            DropdownMenuItem(value: 'today', child: Text('Aujourd\'hui', style: TextStyle(fontSize: 11))),
                            DropdownMenuItem(value: 'week', child: Text('7 jours', style: TextStyle(fontSize: 11))),
                            DropdownMenuItem(value: 'month', child: Text('30 jours', style: TextStyle(fontSize: 11))),
                          ],
                          onChanged: (v) => setState(() => _periodFilter = v!),
                        ),
                      ),
                    ]),
                  ),
                  if (_selectedEventId != null && !_loadingReservations && filtered.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Card(
                        color: AppTheme.primaryColor.withValues(alpha: 0.06),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(children: [
                            const Icon(Icons.trending_up, size: 18, color: AppTheme.primaryColor),
                            const SizedBox(width: 8),
                            Text('${filtered.length} réservation(s)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            const Spacer(),
                            Text('${totalAmount.toStringAsFixed(0)} Ar', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor)),
                          ]),
                        ),
                      ),
                    ),
                  if (_reservationsError != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                      child: Card(
                        color: AppTheme.errorColor.withValues(alpha: 0.08),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(children: [
                            const Icon(Icons.error_outline, size: 16, color: AppTheme.errorColor),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_reservationsError!, style: const TextStyle(fontSize: 11, color: AppTheme.errorColor))),
                            TextButton(
                              onPressed: () { if (_selectedEventId != null) _loadReservations(_selectedEventId!); },
                              child: const Text('Réessayer', style: TextStyle(fontSize: 10)),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  Expanded(
                    child: _loadingReservations
                        ? const Center(child: CircularProgressIndicator())
                        : _selectedEventId == null
                            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.receipt_long, size: 48, color: AppTheme.textSecondary.withValues(alpha: 0.4)),
                                const SizedBox(height: 12),
                                const Text('Sélectionnez un événement', style: TextStyle(color: AppTheme.textSecondary)),
                              ]))
                            : filtered.isEmpty
                                ? const Center(child: Text('Aucune réservation', style: TextStyle(color: AppTheme.textSecondary)))
                                : RefreshIndicator(
                                    onRefresh: () => _loadReservations(_selectedEventId!),
                                    child: ListView.builder(
                                      padding: const EdgeInsets.all(8),
                                      itemCount: filtered.length,
                                      itemBuilder: (ctx, i) {
                                        final r = filtered[i];
                                        final id = r['idReservation'] ?? r['id'];
                                        final idInt = id is int ? id : int.parse(id.toString());
                                        final client = r['clientNom'] ?? r['codeClient'] ?? 'Inconnu';
                                        final date = _formatDate(r['dateReservation']);
                                        final tickets = _getTickets(r);
                                        final nbTickets = tickets.length;
                                        final paiement = r['paiement'];
                                        final isExpanded = _expandedIds.contains(idInt);
                                        final m = paiement is Map ? paiement['montant']?.toString() ?? '-' : '-';
                                        return Card(
                                          margin: const EdgeInsets.symmetric(vertical: 4),
                                          child: Column(
                                            children: [
                                              ListTile(
                                                leading: CircleAvatar(
                                                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                                                  child: const Icon(Icons.receipt, size: 20, color: AppTheme.primaryColor),
                                                ),
                                                title: Text('Réservation #$idInt', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                                subtitle: Text('$client • $date', style: const TextStyle(fontSize: 11)),
                                                trailing: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text('$m Ar', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryColor)),
                                                    const SizedBox(width: 4),
                                                    Icon(isExpanded ? Icons.expand_less : Icons.expand_more, size: 20),
                                                  ],
                                                ),
                                                onTap: () => setState(() {
                                                  if (isExpanded) { _expandedIds.remove(idInt); } else { _expandedIds.add(idInt); }
                                                }),
                                              ),
                                              if (isExpanded) ...[
                                                const Divider(height: 1),
                                                Padding(
                                                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text('$nbTickets billet(s)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                                                      const SizedBox(height: 4),
                                                      ...tickets.map((t) => Container(
                                                        margin: const EdgeInsets.symmetric(vertical: 2),
                                                        padding: const EdgeInsets.all(8),
                                                        decoration: BoxDecoration(
                                                          color: AppTheme.surfaceColor,
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: Row(children: [
                                                          Expanded(
                                                            child: Text(t['codeTicket']?.toString() ?? '', style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
                                                          ),
                                                          if (t['numeroPlace'] != null)
                                                            Text('Place ${t['numeroPlace']}', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                                                          if (t['prix'] != null) ...[
                                                            const SizedBox(width: 8),
                                                            Text('${t['prix']} Ar', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                                          ],
                                                        ]),
                                                      )),
                                                      const SizedBox(height: 8),
                                                      Row(children: [
                                                        Expanded(
                                                          child: SizedBox(
                                                            height: 28,
                                                            child: OutlinedButton.icon(
                                                              onPressed: () => _openDetail(idInt),
                                                              icon: const Icon(Icons.info_outline, size: 12),
                                                              label: const Text('Détail complet', style: TextStyle(fontSize: 10)),
                                                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4)),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Expanded(
                                                          child: SizedBox(
                                                            height: 28,
                                                            child: OutlinedButton.icon(
                                                              onPressed: () async {
                                                                final event = _events.where((e) => e.idEvenement == _selectedEventId).firstOrNull;
                                                                if (event == null) return;
                                                                await Navigator.push(context, MaterialPageRoute(builder: (_) => CreateEventPage(event: event)));
                                                                if (_selectedEventId != null) _loadReservations(_selectedEventId!);
                                                              },
                                                              icon: const Icon(Icons.event, size: 12),
                                                              label: const Text('Voir événement', style: TextStyle(fontSize: 10)),
                                                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4)),
                                                            ),
                                                          ),
                                                        ),
                                                      ]),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                  ),
                 ]),
    );
  }
}
