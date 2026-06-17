import 'package:flutter/material.dart';
import 'package:ontik/core/services/reservation_service.dart';
import 'package:ontik/models/reservation_model.dart';
import 'package:ontik/core/assets/app_colors.dart';
import 'package:ontik/core/utils/error_helper.dart';
import 'package:ontik/widgets/admin/admin_search_field.dart';
import 'package:ontik/widgets/admin/admin_empty_state.dart';
import 'package:ontik/widgets/admin/admin_error_state.dart';
import 'package:ontik/widgets/admin/admin_toast.dart';
import 'package:ontik/widgets/admin/admin_confirmation_dialog.dart';

class ReservationsPage extends StatefulWidget {
  const ReservationsPage({super.key});

  @override
  State<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> {
  final _service = ReservationService();
  final _searchCtrl = TextEditingController();
  bool _loading = true;
  String? _error;
  List<Reservation> _reservations = [];
  List<Reservation> _filteredReservations = [];
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
      final data = await _service.getReservations();
      if (!mounted) return;
      final reservations = data.map((e) => Reservation.fromJson(e as Map<String, dynamic>)).toList();
      setState(() { _reservations = reservations; _filteredReservations = reservations; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = apiErrorString(e); _loading = false; });
    }
  }

  void _filter(String query) {
    _searchQuery = query.toLowerCase();
    setState(() {
      _filteredReservations = _reservations.where((r) =>
        r.idReservation?.toString().contains(_searchQuery) ?? false ||
        r.codeClient.toLowerCase().contains(_searchQuery) ||
        (r.codeTickets?.join(', ').toLowerCase().contains(_searchQuery) ?? false) ||
        (r.dateReservation?.toString().contains(_searchQuery) ?? false)
      ).toList();
    });
  }

  bool _isCancelled(Reservation r) => r.codeTickets == null || r.codeTickets!.isEmpty;

  Future<void> _cancelReservation(Reservation r) async {
    final confirm = await AdminConfirmationDialog.show(
      context,
      title: 'Annuler la réservation',
      message: 'Voulez-vous annuler la réservation #${r.idReservation} ?',
      confirmLabel: 'Annuler',
      confirmColor: AppColors.error,
    );
    if (confirm != true) return;
    try {
      await _service.cancelReservation(r.idReservation!);
      if (!mounted) return;
      AdminToast.show(context, message: 'Réservation annulée', isSuccess: true);
      _load();
    } catch (e) {
      if (!mounted) return;
      AdminToast.show(context, message: apiErrorString(e), isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              const Text('Réservations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.refresh, size: 20), onPressed: _load),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: AdminSearchField(
            hintText: 'Rechercher par ID, client, date...',
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
    if (_filteredReservations.isEmpty) {
      return AdminEmptyState(
        icon: Icons.book_online,
        message: _searchQuery.isNotEmpty ? 'Aucune réservation trouvée' : 'Aucune réservation',
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredReservations.length,
        itemBuilder: (ctx, i) => _buildCard(_filteredReservations[i]),
      ),
    );
  }

  Widget _buildCard(Reservation r) {
    final cancelled = _isCancelled(r);
    final statusColor = cancelled ? AppColors.error : AppColors.secondary;
    final iconData = cancelled ? Icons.cancel : Icons.book_online;
    final dateStr = r.dateReservation != null ? '${r.dateReservation!.day}/${r.dateReservation!.month}/${r.dateReservation!.year}' : '';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.2),
          child: Icon(iconData, color: statusColor, size: 20),
        ),
        title: Text('Réservation #${r.idReservation ?? "?"}', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Client: ${r.codeClient}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            Text('$dateStr  •  ${r.codeTickets?.length ?? 0} ticket(s)', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
              child: Text(cancelled ? 'Annulée' : 'Active', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
            ),
            if (!cancelled) ...[
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.cancel, color: AppColors.error, size: 20),
                tooltip: 'Annuler',
                onPressed: () => _cancelReservation(r),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
