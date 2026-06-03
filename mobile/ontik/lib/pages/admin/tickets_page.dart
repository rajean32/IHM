import 'package:flutter/material.dart';
import '../../core/services/ticket_service.dart';
import '../../core/assets/app_colors.dart';
import '../../models/ticket_model.dart';
import '../../widgets/crud_list_view.dart';
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
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = apiErrorString(e); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CrudListView(
      title: 'Tickets',
      isLoading: _loading,
      error: _error,
      items: _tickets.map((t) => CrudItem(
        id: t.codeTicket,
        title: t.codeTicket,
        subtitle: 'Place: ${t.numeroPlace ?? '-'}  •  Événement #${t.idEvenement ?? '-'}',
        leading: const CircleAvatar(backgroundColor: Color(0x33FF9800), child: Icon(Icons.confirmation_number, color: AppColors.accent)),
        trailing: t.prix != null ? Text('Ar ${t.prix!.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)) : null,
        data: {'codeTicket': t.codeTicket, 'prix': t.prix, 'numeroPlace': t.numeroPlace, 'idEvenement': t.idEvenement},
      )).toList(),
      onRefresh: _loadData,
      emptyMessage: 'Aucun ticket trouvé',
    );
  }
}
