import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/reservation_controller.dart';
import '../../models/reservation.dart';

class PaymentView extends ConsumerStatefulWidget {
  final int reservationId;
  final double amount;
  const PaymentView({
    super.key,
    required this.reservationId,
    required this.amount,
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
    setState(() => _processing = true);
    try {
      final paiementRepo = ref.read(paiementRepositoryProvider);

      final paiement = Paiement(
        montant: widget.amount,
        datePaiement: DateTime.now(),
        modePaiement: _selectedMethod,
        idReservation: widget.reservationId,
      );

      await paiementRepo.create(paiement);
      final status = await paiementRepo.getPaymentStatus(widget.reservationId);

      if (!mounted) return;

      if (status.status == 'PAID' || status.status == 'COMPLETED' || status.status == 'CONFIRMED') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful!'),
            backgroundColor: Colors.green,
          ),
        );
        if (context.mounted) {
          context.go('/my-reservations');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment status: ${status.status}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
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
                      'Amount to Pay',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${widget.amount.toStringAsFixed(2)}',
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
              'Select Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._methods.map((m) => _buildPaymentOption(m)),
            const SizedBox(height: 32),
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
                    : const Text('Pay Now'),
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
