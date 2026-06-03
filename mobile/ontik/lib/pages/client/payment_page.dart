import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/services/paiement_service.dart';
import '../../core/api/dio_config.dart';

import '../../core/assets/app_colors.dart';
import '../../core/routes/client_routes.dart';
import '../../core/utils/error_helper.dart';

class PaymentPage extends StatefulWidget {
  final int eventId;
  final double amount;
  final List<Map<String, dynamic>> tickets;

  const PaymentPage({
    super.key,
    required this.eventId,
    required this.amount,
    required this.tickets,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _processing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _processPayment());
  }

  Future<void> _processPayment() async {
    if (widget.tickets.isEmpty) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, ClientRoutes.profile);
      return;
    }

    setState(() {
      _processing = true;
      _errorMessage = null;
    });

    try {
      final clientCode = userCode ?? '';
      if (clientCode.isEmpty) {
        setState(() => _errorMessage = 'Utilisateur non connecté');
        return;
      }

      final ticketsPayload = widget.tickets.map((seat) => {
        'codeTicket': 'TKT-${widget.eventId}-${seat['numeroPlace']}-${DateTime.now().millisecondsSinceEpoch}',
        'numeroPlace': seat['numeroPlace'],
        'idEvenement': widget.eventId,
        'prix': (seat['prix'] as num?)?.toDouble() ?? 0.0,
      }).toList();

      final _paiementService = PaiementService();
      await _paiementService.processPayment({
        'codeClient': clientCode,
        'tickets': ticketsPayload,
        'modePaiement': 'GRATUIT',
        'montant': widget.amount,
      }).timeout(const Duration(seconds: 15));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Réservation réussie !'), backgroundColor: AppColors.secondary),
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, ClientRoutes.profile);
    } on TimeoutException {
      if (!mounted) return;
      setState(() => _errorMessage = 'Le serveur ne répond pas. Vérifiez votre connexion et réessayez.');
    } catch (e) {
      if (!mounted) return;
      final msg = apiErrorString(e);

      String displayMsg;
      if (msg.contains('409') || msg.contains('concurrence') || msg.contains('déjà réservée') || msg.contains('indisponible') || msg.contains('en attente')) {
        displayMsg = 'Place déjà réservée ou indisponible. Veuillez réessayer.';
      } else if (msg.contains('402') || msg.contains('Fonds insuffisants')) {
        displayMsg = 'Fonds insuffisants pour effectuer cette transaction.';
      } else if (msg.contains('500') || msg.contains('Internal Server')) {
        displayMsg = 'Erreur serveur. Veuillez réessayer plus tard.';
      } else {
        displayMsg = msg;
      }

      setState(() => _errorMessage = displayMsg);
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Réservation')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _processing
              ? const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Traitement de la réservation...'),
                  ],
                )
              : _errorMessage != null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _processPayment,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Réessayer'),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(context, ClientRoutes.profile),
                          child: const Text('Voir mes réservations'),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, size: 64, color: AppColors.secondary),
                        const SizedBox(height: 16),
                        const Text('Réservation terminée', style: TextStyle(fontSize: 18)),
                      ],
                    ),
        ),
      ),
    );
  }
}
