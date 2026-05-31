import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/auth_controller.dart';

class PaymentView extends ConsumerStatefulWidget {
  final int eventId;
  final double amount;
  final List<Map<String, dynamic>> tickets;

  const PaymentView({
    super.key,
    required this.eventId,
    required this.amount,
    required this.tickets,
  });

  @override
  ConsumerState<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends ConsumerState<PaymentView> {
  String _selectedMethod = 'CARTE';
  bool _processing = false;

  final _methods = const [
    {'value': 'CARTE', 'label': 'Credit Card', 'icon': Icons.credit_card},
    {'value': 'MOBILE_MONEY', 'label': 'Mobile Money', 'icon': Icons.phone_android},
    {'value': 'PAYPAL', 'label': 'PayPal', 'icon': Icons.account_balance_wallet},
  ];

  Future<void> _processPayment() async {
    if (widget.tickets.isEmpty) return;
    setState(() => _processing = true);
    try {
      final authState = ref.read(authControllerProvider);
      final clientCode = authState.user?.codeUtilisateur ?? '';
      final apiClient = ref.read(apiClientProvider);

      final ticketsPayload = widget.tickets.map((seat) => {
        'codeTicket': 'TKT-${widget.eventId}-${seat['numeroPlace']}-${DateTime.now().millisecondsSinceEpoch}',
        'prix': (seat['prix'] as num?)?.toDouble() ?? 0,
        'idEvenement': widget.eventId,
        'numeroPlace': seat['numeroPlace'],
      }).toList();

      await apiClient.post('/achat', data: {
        'codeClient': clientCode,
        'tickets': ticketsPayload,
        'modePaiement': _selectedMethod,
        'montant': widget.amount,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paiement réussi !'), backgroundColor: Colors.green),
      );
      if (context.mounted) {
        context.go('/my-reservations');
      }
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      String displayMsg = 'Échec du paiement';
      if (msg.contains('fonds insuffisants') || msg.contains('Fonds insuffisants')) {
        displayMsg = 'Fonds insuffisants : solde insuffisant pour effectuer cette transaction';
      } else if (msg.contains('already reserved') || msg.contains('concurrent')) {
        displayMsg = 'Place déjà réservée par un autre utilisateur. Veuillez réessayer.';
      } else if (msg.contains('API Error')) {
        displayMsg = msg.replaceAll('Exception: ', '');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(displayMsg), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paiement')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Montant à payer',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.amount.toStringAsFixed(2)} €',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Mode de paiement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._methods.map((m) => _buildPaymentOption(m)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _processing ? null : _processPayment,
                child: _processing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Payer maintenant'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(Map<String, dynamic> method) {
    final isSelected = _selectedMethod == method['value'];
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(method['icon'] as IconData),
        title: Text(method['label'] as String),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Colors.blue)
            : null,
        onTap: () => setState(() => _selectedMethod = method['value'] as String),
      ),
    );
  }
}
