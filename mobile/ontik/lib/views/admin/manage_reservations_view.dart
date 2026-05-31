import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/providers.dart';
import '../../models/reservation.dart';
import '../../widgets/crud_list_view.dart';

class ManageReservationsView extends ConsumerStatefulWidget {
  const ManageReservationsView({super.key});
  @override
  ConsumerState<ManageReservationsView> createState() => _ManageReservationsViewState();
}

class _ManageReservationsViewState extends ConsumerState<ManageReservationsView> {
  bool _loading = true;
  String? _error;
  List<Reservation> _reservations = [];

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final res = await ref.read(reservationRepositoryProvider).getAll();
      if (!mounted) return;
      setState(() { _reservations = res; _loading = false; _error = null; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<bool> _cancel(String id) async {
    try {
      await ref.read(reservationRepositoryProvider).cancel(int.parse(id));
      _loadData();
      return true;
    } catch (_) { return false; }
  }

  @override
  Widget build(BuildContext context) {
    return CrudListView(
      title: 'Réservations',
      isLoading: _loading,
      error: _error,
      items: _reservations.map((r) => CrudItem(
        id: r.idReservation.toString(),
        title: 'Réservation #${r.idReservation ?? '-'}',
        subtitle: 'Client: ${r.codeClient}  •  ${r.dateReservation?.toIso8601String().split('T').first ?? ''}  •  ${r.codeTickets?.length ?? 0} ticket(s)',
        leading: const CircleAvatar(backgroundColor: Color(0x339C27B0), child: Icon(Icons.book_online, color: Color(0xFF9C27B0))),
        data: {'id': r.idReservation},
      )).toList(),
      onDelete: _cancel,
      onRefresh: _loadData,
      emptyMessage: 'Aucune réservation trouvée',
    );
  }
}
