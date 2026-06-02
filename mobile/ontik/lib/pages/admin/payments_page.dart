import 'package:flutter/material.dart';
import '../../core/services/paiement_service.dart';
import '../../core/assets/app_colors.dart';
import '../../models/reservation_model.dart';
import '../../widgets/crud_list_view.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});
  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  bool _loading = true;
  String? _error;
  List<Paiement> _payments = [];
  final _api = PaiementService();

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final paymentsData = await _api.getPayments();
      if (!mounted) return;
      setState(() {
        _payments = paymentsData.map((e) => Paiement.fromJson(e as Map<String, dynamic>)).toList();
        _loading = false;
        _error = null;
      });
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
        title: 'Ar ${p.montant.toStringAsFixed(0)}',
        subtitle: 'Réservation #${p.idReservation}  •  ${p.modePaiement}  •  ${p.datePaiement.toIso8601String().split('T').first}',
        leading: const CircleAvatar(backgroundColor: Color(0x334CAF50), child: Icon(Icons.payment, color: AppColors.secondary)),
        data: {'montant': p.montant, 'modePaiement': p.modePaiement, 'date': p.datePaiement.toIso8601String()},
      )).toList(),
      onRefresh: _loadData,
      emptyMessage: 'Aucun paiement trouvé',
    );
  }
}
