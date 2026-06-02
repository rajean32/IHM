import 'package:flutter/material.dart';
import '../../core/services/reservation_service.dart';
import '../../core/api/dio_config.dart';
import '../../core/api/endpoints.dart';

import '../../models/reservation_model.dart';
import '../../widgets/crud_list_view.dart';

class ReservationsPage extends StatefulWidget {
  const ReservationsPage({super.key});
  @override
  State<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> {
  bool _loading = true;
  String? _error;
  List<Reservation> _reservations = [];
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
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<bool> _cancel(String id) async {
    try {
      await dio.put('${Endpoints.reservations}/$id/cancel');
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
