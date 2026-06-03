import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/reservation_model.dart';
import '../../models/ticket_model.dart';
import '../../core/services/reservation_service.dart';
import '../../core/services/ticket_service.dart';
import '../../core/api/dio_config.dart';
import '../../core/api/endpoints.dart';
import '../../core/assets/app_colors.dart';
import '../../core/routes/client_routes.dart';
import '../../widgets/error_state.dart';
import '../../core/utils/error_helper.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = true;
  String? _error;
  List<Reservation> _reservations = [];
  List<Ticket> _tickets = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final clientCode = userCode ?? '';
    if (clientCode.isEmpty) return;

    setState(() => _loading = true);
    try {
      final _reservationService = ReservationService();
      final _ticketService = TicketService();
      final reservationsData = await _reservationService.getMyReservations(clientCode);
      final ticketsResp = await dio.get('${Endpoints.tickets}?client=$clientCode');
      final ticketsData = ticketsResp.data['data'] as List? ?? [];

      if (!mounted) return;
      setState(() {
        _reservations = reservationsData.map((e) => Reservation.fromJson(e as Map<String, dynamic>)).toList();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reservations'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, ClientRoutes.home);
            }
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.receipt_long), text: 'Reservations'),
            Tab(icon: Icon(Icons.confirmation_number), text: 'Tickets'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorState(message: _error!, onRetry: _loadData)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildReservationsList(),
                    _buildTicketsList(),
                  ],
                ),
    );
  }

  Widget _buildReservationsList() {
    if (_reservations.isEmpty) {
      return const Center(child: Text('No reservations yet'));
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _reservations.length,
        itemBuilder: (context, index) {
          final r = _reservations[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.event),
              ),
              title: Text('Reservation #${r.idReservation}'),
              subtitle: r.dateReservation != null
                  ? Text(DateFormat('MMM d, yyyy').format(r.dateReservation!))
                  : null,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _tabController.animateTo(1),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTicketsList() {
    if (_tickets.isEmpty) {
      return const Center(child: Text('No tickets yet'));
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _tickets.length,
        itemBuilder: (context, index) {
          final t = _tickets[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.secondary,
                child: Icon(Icons.confirmation_number, color: Colors.white),
              ),
              title: Text('Ticket ${t.codeTicket}'),
              subtitle: t.prix != null ? Text('Ar ${t.prix}') : null,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(
                context,
                ClientRoutes.ticket,
                arguments: {'code': t.codeTicket},
              ),
            ),
          );
        },
      ),
    );
  }
}
