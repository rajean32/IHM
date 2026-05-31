import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/providers.dart';
import '../../models/ticket.dart';
import '../../widgets/crud_list_view.dart';

class ManageTicketsView extends ConsumerStatefulWidget {
  const ManageTicketsView({super.key});
  @override
  ConsumerState<ManageTicketsView> createState() => _ManageTicketsViewState();
}

class _ManageTicketsViewState extends ConsumerState<ManageTicketsView> {
  bool _loading = true;
  String? _error;
  List<Ticket> _tickets = [];

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final tickets = await ref.read(ticketRepositoryProvider).getAll();
      if (!mounted) return;
      setState(() { _tickets = tickets; _loading = false; _error = null; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
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
        leading: const CircleAvatar(backgroundColor: Color(0x33FF9800), child: Icon(Icons.confirmation_number, color: Color(0xFFFF9800))),
        trailing: t.prix != null ? Text('${t.prix!.toStringAsFixed(0)} FCFA', style: const TextStyle(fontWeight: FontWeight.bold)) : null,
        data: {'codeTicket': t.codeTicket, 'prix': t.prix, 'numeroPlace': t.numeroPlace, 'idEvenement': t.idEvenement},
      )).toList(),
      onRefresh: _loadData,
      emptyMessage: 'Aucun ticket trouvé',
    );
  }
}
