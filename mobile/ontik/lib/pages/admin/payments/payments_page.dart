import 'package:flutter/material.dart';
import 'package:ontik/core/services/paiement_service.dart';
import 'package:ontik/models/reservation_model.dart';
import 'package:ontik/core/assets/app_colors.dart';
import 'package:ontik/core/utils/error_helper.dart';
import 'package:ontik/widgets/admin/admin_search_field.dart';
import 'package:ontik/widgets/admin/admin_empty_state.dart';
import 'package:ontik/widgets/admin/admin_error_state.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  final _service = PaiementService();
  final _searchCtrl = TextEditingController();
  bool _loading = true;
  String? _error;
  List<Paiement> _payments = [];
  List<Paiement> _filteredPayments = [];
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
      final data = await _service.getAllPayments();
      if (!mounted) return;
      final payments = data.map((e) => Paiement.fromJson(e as Map<String, dynamic>)).toList();
      setState(() { _payments = payments; _filteredPayments = payments; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = apiErrorString(e); _loading = false; });
    }
  }

  void _filter(String query) {
    _searchQuery = query.toLowerCase();
    setState(() {
      _filteredPayments = _payments.where((p) =>
        p.idPaiement?.toString().contains(_searchQuery) ?? false ||
        p.montant.toString().contains(_searchQuery) ||
        p.modePaiement.toLowerCase().contains(_searchQuery) ||
        p.idReservation.toString().contains(_searchQuery)
      ).toList();
    });
  }

  Color _modeColor(String mode) {
    switch (mode.toUpperCase()) {
      case 'CARTE': return AppColors.primary;
      case 'MVOLA': return AppColors.accent;
      default: return AppColors.secondary;
    }
  }

  IconData _modeIcon(String mode) {
    switch (mode.toUpperCase()) {
      case 'CARTE': return Icons.credit_card;
      case 'MVOLA': return Icons.phone_android;
      default: return Icons.payment;
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
              const Text('Paiements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.refresh, size: 20), onPressed: _load),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: AdminSearchField(
            hintText: 'Rechercher par ID, montant, mode...',
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
    if (_filteredPayments.isEmpty) {
      return AdminEmptyState(
        icon: Icons.payment,
        message: _searchQuery.isNotEmpty ? 'Aucun paiement trouvé' : 'Aucun paiement',
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredPayments.length,
        itemBuilder: (ctx, i) => _buildCard(_filteredPayments[i]),
      ),
    );
  }

  Widget _buildCard(Paiement p) {
    final color = _modeColor(p.modePaiement);
    final dateStr = '${p.datePaiement.day}/${p.datePaiement.month}/${p.datePaiement.year}';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(_modeIcon(p.modePaiement), color: color, size: 20),
        ),
        title: Text('Ar ${p.montant.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Réservation #${p.idReservation}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            Text('${p.modePaiement}  •  $dateStr', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
          child: Text(p.modePaiement, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
        ),
      ),
    );
  }
}
