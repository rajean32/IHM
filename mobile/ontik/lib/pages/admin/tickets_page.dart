import 'package:flutter/material.dart';
import '../../core/services/ticket_service.dart';
import '../../core/assets/app_colors.dart';
import '../../models/ticket_model.dart';
import '../../core/utils/error_helper.dart';

class TicketsPage extends StatefulWidget {
  const TicketsPage({super.key});
  @override
  State<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  bool _loading = true;
  String? _error;
  List<Ticket> _tickets = [];
  List<Ticket> _filteredTickets = [];
  String _searchQuery = '';
  final _api = TicketService();

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final ticketsData = await _api.getTickets();
      if (!mounted) return;
      setState(() {
        _tickets = ticketsData.map((e) => Ticket.fromJson(e as Map<String, dynamic>)).toList();
        _filteredTickets = _tickets;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = apiErrorString(e); _loading = false; });
    }
  }

  void _filterTickets(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredTickets = _tickets;
      } else {
        final q = query.toLowerCase();
        _filteredTickets = _tickets.where((t) {
          final code = t.codeTicket?.toLowerCase() ?? '';
          final place = t.numeroPlace?.toLowerCase() ?? '';
          final event = t.idEvenement?.toString() ?? '';
          final prix = t.prix?.toString() ?? '';
          return code.contains(q) ||
              place.contains(q) ||
              event.contains(q) ||
              prix.contains(q);
        }).toList();
      }
    });
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
            const Text('Tickets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Rechercher par code, place, événement...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: _filterTickets,
          ),
        ),
        Expanded(
          child: _filteredTickets.isEmpty
              ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.confirmation_number, size: 48, color: AppColors.textSecondary.withValues(alpha: 0.4)),
                const SizedBox(height: 12),
                Text(
                  _searchQuery.isEmpty ? 'Aucun ticket trouvé' : 'Aucun ticket ne correspond à votre recherche',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                ),
              ],
            ),
          )
              : RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _filteredTickets.length,
              itemBuilder: (ctx, i) {
                final t = _filteredTickets[i];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                      child: const Icon(Icons.confirmation_number, color: AppColors.accent, size: 20),
                    ),
                    title: Text(
                      t.codeTicket,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Place: ${t.numeroPlace ?? '-'}'),
                        Text(
                          'Événement #${t.idEvenement ?? '-'}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    trailing: t.prix != null
                        ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Ar ${t.prix!.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                    )
                        : null,
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