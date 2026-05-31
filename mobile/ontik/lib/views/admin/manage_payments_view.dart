import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/providers.dart';
import '../../models/reservation.dart';
import '../../widgets/crud_list_view.dart';

class ManagePaymentsView extends ConsumerStatefulWidget {
  const ManagePaymentsView({super.key});
  @override
  ConsumerState<ManagePaymentsView> createState() => _ManagePaymentsViewState();
}

class _ManagePaymentsViewState extends ConsumerState<ManagePaymentsView> {
  bool _loading = true;
  String? _error;
  List<Paiement> _payments = [];

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final payments = await ref.read(paiementRepositoryProvider).getAll();
      if (!mounted) return;
      setState(() { _payments = payments; _loading = false; _error = null; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CrudListView(
      title: 'Paiements',
      isLoading: _loading,
      error: _error,
      items: _payments.map((p) => CrudItem(
        id: p.idPaiement.toString(),
        title: '${p.montant.toStringAsFixed(0)} FCFA',
        subtitle: 'Réservation #${p.idReservation}  •  ${p.modePaiement}  •  ${p.datePaiement.toIso8601String().split('T').first}',
        leading: const CircleAvatar(backgroundColor: Color(0x334CAF50), child: Icon(Icons.payment, color: Color(0xFF4CAF50))),
        data: {'montant': p.montant, 'modePaiement': p.modePaiement, 'date': p.datePaiement.toIso8601String()},
      )).toList(),
      onRefresh: _loadData,
      emptyMessage: 'Aucun paiement trouvé',
    );
  }
}
