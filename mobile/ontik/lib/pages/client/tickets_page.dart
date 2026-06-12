import 'package:flutter/material.dart';
import '../../core/services/ticket_service.dart';
import '../../core/api/dio_config.dart';
import '../../core/api/endpoints.dart';
import '../../core/assets/app_colors.dart';
import '../../core/routes/client_routes.dart';
import '../../models/ticket_model.dart';
import '../../widgets/error_state.dart';
import '../../core/utils/error_helper.dart';

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
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.confirmation_number_outlined, size: 64, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text('Aucun billet', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTickets,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _tickets.length,
        itemBuilder: (context, index) {
          final ticket = _tickets[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.secondary,
                child: Icon(Icons.confirmation_number, color: Colors.white),
              ),
              title: Text(ticket.codeTicket, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: ticket.prix != null ? Text('Ar ${ticket.prix}') : null,
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  ClientRoutes.ticket,
                  arguments: {'code': ticket.codeTicket},
                );
              },
            ),
          );
        },
      ),
    );
  }
}