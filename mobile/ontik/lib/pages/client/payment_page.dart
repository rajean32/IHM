import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/services/paiement_service.dart';
import '../../core/api/dio_config.dart';
import '../../core/assets/app_colors.dart';
import '../../core/routes/client_routes.dart';
import '../../core/utils/error_helper.dart';
import '../../models/paiement_request_model.dart';
import '../../widgets/payment_method_selector.dart';
import '../../widgets/carte_bancaire_form.dart';
import '../../widgets/code_promo_field.dart';

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

  PaymentMethod _selectedMethod = PaymentMethod.mvola;
  String? _referenceTransaction;
  String? _numeroTelephone;
  String? _nomComplet;
  Map<String, String>? _carteInfo;
  String? _codePromo;
  bool _estEtudiant = false;
  double _reduction = 0;
  double _montantFinal = 0;

  @override
  void initState() {
    super.initState();
    _montantFinal = widget.amount;
  }

  Future<void> _processPayment() async {
    if (widget.tickets.isEmpty) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, ClientRoutes.profile);
      return;
    }

    if (_selectedMethod != PaymentMethod.carte) {
      if (_referenceTransaction == null || _referenceTransaction!.isEmpty) {
        setState(() => _errorMessage = 'La référence de transaction est requise');
        return;
      }
      if (_numeroTelephone == null || _numeroTelephone!.isEmpty) {
        setState(() => _errorMessage = 'Le numéro de téléphone est requis');
        return;
      }
    } else {
      if (_carteInfo == null ||
          _carteInfo!['numeroCarte'] == null ||
          _carteInfo!['numeroCarte']!.isEmpty) {
        setState(() => _errorMessage = 'Les informations de carte sont requises');
        return;
      }
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

      final ticketsPayload = widget.tickets.map((seat) => TicketItemModel(
        codeTicket: 'TKT-${widget.eventId}-${seat['numeroPlace']}-${DateTime.now().millisecondsSinceEpoch}',
        numeroPlace: seat['numeroPlace']!,
        idEvenement: widget.eventId,
        prix: (seat['prix'] as num?)?.toDouble() ?? 0.0,
      )).toList();

      final paiementRequest = PaiementRequestModel(
        codeClient: clientCode,
        tickets: ticketsPayload,
        typePaiement: _selectedMethod.label,
        referenceTransaction: _referenceTransaction,
        numeroTelephone: _numeroTelephone,
        nomComplet: _nomComplet,
        carte: _carteInfo != null
            ? CarteBancaireModel(
          numeroCarte: _carteInfo!['numeroCarte']!,
          dateExpiration: _carteInfo!['dateExpiration']!,
          cvv: _carteInfo!['cvv']!,
          nomTitulaire: _carteInfo!['nomTitulaire']!,
        )
            : null,
        codePromo: _codePromo,
        estEtudiant: _estEtudiant,
      );

      final _paiementService = PaiementService();
      final result = await _paiementService.processPaymentWithReduction(paiementRequest);

      if (!mounted) return;

      final montantFinal = result['montantFinal'] ?? widget.amount;
      final reduction = result['reductionAppliquee'] ?? 0.0;

      String message = 'Réservation réussie !';
      if (reduction > 0) {
        message = 'Réservation réussie ! Réduction de ${reduction.toStringAsFixed(0)} Ar appliquée.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.secondary),
      );

      Navigator.pushReplacementNamed(context, ClientRoutes.profile);
    } on TimeoutException {
      setState(() => _errorMessage = 'Le serveur ne répond pas. Vérifiez votre connexion.');
    } catch (e) {
      final msg = apiErrorString(e);
      String displayMsg;
      if (msg.contains('déjà réservée') || msg.contains('indisponible')) {
        displayMsg = 'Place déjà réservée ou indisponible. Veuillez réessayer.';
      } else if (msg.contains('Fonds insuffisants')) {
        displayMsg = 'Fonds insuffisants pour effectuer cette transaction.';
      } else if (msg.contains('code promo') || msg.contains('Code promo')) {
        displayMsg = 'Code promo invalide ou expiré.';
      } else {
        displayMsg = msg;
      }
      setState(() => _errorMessage = displayMsg);
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  void _updateMontant() {
    double reduction = 0;
    if (_estEtudiant) reduction += widget.amount * 0.10;
    if (_codePromo != null && _codePromo!.isNotEmpty) reduction += widget.amount * 0.20;
    if (reduction > widget.amount * 0.50) reduction = widget.amount * 0.50;
    setState(() {
      _reduction = reduction;
      _montantFinal = widget.amount - reduction;
    });
  }

  void _onCodeChanged(String? code) {
    _codePromo = code;
    _updateMontant();
  }

  void _onCodeValidate(bool isValid, String? code) {
    if (isValid && code != null) _updateMontant();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paiement')),
      body: _processing
          ? const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Traitement du paiement...'),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Montant initial:', style: TextStyle(fontSize: 16)),
                        Text('${widget.amount.toStringAsFixed(0)} Ar',
                            style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                    if (_reduction > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Réduction:', style: TextStyle(color: AppColors.secondary)),
                          Text('- ${_reduction.toStringAsFixed(0)} Ar',
                              style: TextStyle(color: AppColors.secondary)),
                        ],
                      ),
                    ],
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total à payer:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('${_montantFinal.toStringAsFixed(0)} Ar',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),


            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: CodePromoField(
                  onCodeChanged: _onCodeChanged,
                  onValidate: _onCodeValidate,
                  eventId: widget.eventId,
                ),
              ),
            ),

            const SizedBox(height: 16),

            PaymentMethodSelector(
              initialValue: _selectedMethod,
              onChanged: (method) => setState(() => _selectedMethod = method),
            ),

            const SizedBox(height: 16),

            if (_selectedMethod != PaymentMethod.carte) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Référence de transaction',
                          hintText: 'Ex: MV123456789',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) => _referenceTransaction = v,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Numéro de téléphone',
                          hintText: '0341234567',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        onChanged: (v) => _numeroTelephone = v,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Nom complet',
                          hintText: 'Jean Rakoto',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) => _nomComplet = v,
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              CarteBancaireForm(
                onChanged: (carte) => _carteInfo = carte,
              ),
            ],

            const SizedBox(height: 24),

            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_errorMessage!, style: const TextStyle(color: AppColors.error))),
                  ],
                ),
              ),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Payer ${_montantFinal.toStringAsFixed(0)} Ar',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}