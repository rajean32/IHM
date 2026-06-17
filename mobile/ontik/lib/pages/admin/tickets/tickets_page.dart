import 'package:flutter/material.dart';
import 'package:ontik/core/services/ticket_service.dart';
import 'package:ontik/models/ticket_model.dart';
import 'package:ontik/core/assets/app_colors.dart';
import 'package:ontik/core/utils/error_helper.dart';
import 'package:ontik/widgets/admin/admin_search_field.dart';
import 'package:ontik/widgets/admin/admin_empty_state.dart';
import 'package:ontik/widgets/admin/admin_error_state.dart';

class TicketsPage extends StatefulWidget {
  const TicketsPage({super.key});

  @override
  State<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  final _service = TicketService();
  final _searchCtrl = TextEditingController();
  bool _loading = true;
  String? _error;
  List<Ticket> _tickets = [];
  List<Ticket> _filteredTickets = [];
  String _searchQuery = '';

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

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _service.getTickets();
      if (!mounted) return;
      final tickets = data.map((e) => Ticket.fromJson(e as Map<String, dynamic>)).toList();
      setState(() { _tickets = tickets; _filteredTickets = tickets; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = apiErrorString(e); _loading = false; });
    }
  }

  void _filter(String query) {
    _searchQuery = query.toLowerCase();
    setState(() {
      _filteredTickets = _tickets.where((t) =>
        t.codeTicket.toLowerCase().contains(_searchQuery) ||
        (t.numeroPlace?.toLowerCase().contains(_searchQuery) ?? false) ||
        (t.idEvenement?.toString().contains(_searchQuery) ?? false) ||
        (t.prix?.toString().contains(_searchQuery) ?? false)
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              const Text('Tickets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.refresh, size: 20), onPressed: _load),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: AdminSearchField(
            hintText: 'Rechercher par code, place, événement...',
            controller: _searchCtrl,
            onChanged: _filter,
          ),
        ),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return AdminErrorState(message: _error!, onRetry: _load);
    if (_filteredTickets.isEmpty) {
      return AdminEmptyState(
        icon: Icons.confirmation_number,
        message: _searchQuery.isNotEmpty ? 'Aucun ticket ne correspond' : 'Aucun ticket trouvé',
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredTickets.length,
        itemBuilder: (ctx, i) => _buildCard(_filteredTickets[i]),
      ),
    );
  }

  Widget _buildCard(Ticket ticket) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.accent.withValues(alpha: 0.2),
          child: const Icon(Icons.confirmation_number, color: AppColors.accent, size: 20),
        ),
        title: Text(ticket.codeTicket, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Place: ${ticket.numeroPlace ?? "-"}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            Text('Événement #${ticket.idEvenement ?? "-"}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        trailing: ticket.prix != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Ar ${ticket.prix!.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary)),
              )
            : null,
      ),
    );
  }
}
