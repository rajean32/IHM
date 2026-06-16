import 'package:flutter/material.dart';
import '../../core/services/reservation_service.dart';
import '../../core/api/dio_config.dart';
import '../../core/api/endpoints.dart';
import '../../core/utils/error_helper.dart';
import '../../core/assets/app_colors.dart';
import '../../models/reservation_model.dart';

class ReservationsPage extends StatefulWidget {
  const ReservationsPage({super.key});
  @override
  State<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> {
  bool _loading = true;
  String? _error;
  List<Reservation> _reservations = [];
  List<Reservation> _filteredReservations = [];
  String _searchQuery = '';
  final _api = ReservationService();

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final resData = await _api.getReservations();
      if (!mounted) return;
      setState(() {
        _reservations = resData.map((e) => Reservation.fromJson(e as Map<String, dynamic>)).toList();
        _filteredReservations = _reservations;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = apiErrorString(e); _loading = false; });
    }
  }

  void _filterReservations(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredReservations = _reservations;
      } else {
        final q = query.toLowerCase();
        _filteredReservations = _reservations.where((r) {
          final id = r.idReservation?.toString() ?? '';
          final client = r.codeClient?.toLowerCase() ?? '';
          final tickets = r.codeTickets?.join(', ').toLowerCase() ?? '';
          final date = r.dateReservation?.toIso8601String().split('T').first ?? '';
          return id.contains(q) ||
              client.contains(q) ||
              tickets.contains(q) ||
              date.contains(q);
        }).toList();
      }
    });
  }

  Future<bool> _cancel(String id) async {
    try {
      await dio.put('${Endpoints.reservations}/$id/cancel');
      _loadData();
      return true;
    } catch (_) { return false; }
  }

  Future<void> _showCancelDialog(Reservation reservation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Annuler la réservation'),
        content: Text('Êtes-vous sûr de vouloir annuler la réservation #${reservation.idReservation} ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Annuler', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _cancel(reservation.idReservation!.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Réservation annulée'), backgroundColor: AppColors.secondary),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(children: [
            const Text('Réservations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Rechercher par ID, client, date...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: _filterReservations,
          ),
        ),
        Expanded(
          child: _filteredReservations.isEmpty
              ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.book_online, size: 48, color: AppColors.textSecondary.withValues(alpha: 0.4)),
                const SizedBox(height: 12),
                Text(
                  _searchQuery.isEmpty ? 'Aucune réservation trouvée' : 'Aucune réservation ne correspond à votre recherche',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                ),
              ],
            ),
          )
              : RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _filteredReservations.length,
              itemBuilder: (ctx, i) {
                final r = _filteredReservations[i];
                final ticketCount = r.codeTickets?.length ?? 0;

                // Une réservation est considérée comme annulée si elle n'a pas de tickets
                // ou si elle a été annulée via l'API (on peut vérifier via une propriété si elle existe)
                // Pour l'instant, on utilise le nombre de tickets comme indicateur
                final isCancelled = ticketCount == 0;

                // Couleur en fonction du nombre de tickets
                final statusColor = isCancelled
                    ? AppColors.error
                    : ticketCount > 0
                    ? AppColors.secondary
                    : AppColors.accent;

                final statusIcon = isCancelled ? Icons.cancel : Icons.book_online;
                final statusLabel = isCancelled ? 'Annulée' : 'Active';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: statusColor.withValues(alpha: 0.2),
                      child: Icon(
                        statusIcon,
                        color: statusColor,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'Réservation #${r.idReservation}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Client: ${r.codeClient ?? '-'}'),
                        Text(
                          '${r.dateReservation?.toIso8601String().split('T').first ?? ''}  •  $ticketCount ticket(s)',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(fontSize: 11, color: statusColor),
                          ),
                        ),
                        if (!isCancelled) ...[
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.cancel, size: 20, color: AppColors.error),
                            onPressed: () => _showCancelDialog(r),
                            tooltip: 'Annuler',
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}