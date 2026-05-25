import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../repositories/reservation_repository.dart';
import '../../repositories/ticket_repository.dart';
import '../../models/reservation.dart';
import '../../models/ticket.dart';
import '../../core/api_client.dart';
import '../../widgets/error_state.dart';

class MyReservationsView extends ConsumerStatefulWidget {
  const MyReservationsView({super.key});

  @override
  ConsumerState<MyReservationsView> createState() => _MyReservationsViewState();
}

class _MyReservationsViewState extends ConsumerState<MyReservationsView>
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
    final authState = ref.read(authControllerProvider);
    final clientCode = authState.user?.codeUtilisateur ?? '';
    if (clientCode.isEmpty) return;

    setState(() => _loading = true);
    try {
      final reservationRepo = ref.read(
        Provider<ReservationRepository>(
          (ref) => ReservationRepository(ref.watch(Provider<ApiClient>((ref) => ApiClient()))),
        ),
      );
      final ticketRepo = ref.read(
        Provider<TicketRepository>(
          (ref) => TicketRepository(ref.watch(Provider<ApiClient>((ref) => ApiClient()))),
        ),
      );

      final reservations = await reservationRepo.getByClient(clientCode);
      final tickets = await ticketRepo.getByClient(clientCode);

      if (!mounted) return;
      setState(() {
        _reservations = reservations;
        _tickets = tickets;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reservations'),
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
              onTap: () {
                if (r.idReservation != null) {
                  context.push('/payment/${r.idReservation}');
                }
              },
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
                backgroundColor: Colors.green,
                child: Icon(Icons.confirmation_number, color: Colors.white),
              ),
              title: Text('Ticket ${t.codeTicket}'),
              subtitle: t.prix != null ? Text('\$${t.prix}') : null,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/ticket/${t.codeTicket}'),
            ),
          );
        },
      ),
    );
  }
}
