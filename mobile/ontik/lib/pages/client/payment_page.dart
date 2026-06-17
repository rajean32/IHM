import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/paiement_service.dart';
import '../../core/api/dio_config.dart';
import '../../core/assets/app_colors.dart';
import '../../core/routes/client_routes.dart';
import '../../core/utils/error_helper.dart';
import '../../models/paiement_request_model.dart';
import '../../widgets/payment_method_selector.dart';
import '../../widgets/carte_bancaire_form.dart';
import '../../widgets/code_promo_field.dart';
import '../../generated/app_localizations.dart';

class PaymentPage extends StatefulWidget {
  final int eventId;
  final String eventTitle;
  final double amount;
  final List<Map<String, dynamic>> tickets;

  const PaymentPage({
    super.key,
    required this.eventId,
    this.eventTitle = '',
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
  final bool _estEtudiant = false;
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
        setState(() => _errorMessage = AppLocalizations.of(context)!.clientPaymentErrorTransactionRef);
        return;
      }
      if (_numeroTelephone == null || _numeroTelephone!.isEmpty) {
        setState(() => _errorMessage = AppLocalizations.of(context)!.clientPaymentErrorPhoneNumber);
        return;
      }
    } else {
      if (_carteInfo == null ||
          _carteInfo!['numeroCarte'] == null ||
          _carteInfo!['numeroCarte']!.isEmpty) {
        setState(() => _errorMessage = AppLocalizations.of(context)!.clientPaymentErrorCardInfo);
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
        setState(() => _errorMessage = AppLocalizations.of(context)!.clientPaymentErrorNotLoggedIn);
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

      final reduction = result['reductionAppliquee'] ?? 0.0;

      String message = AppLocalizations.of(context)!.clientPaymentSuccess;
      if (reduction > 0) {
        message = '${AppLocalizations.of(context)!.clientPaymentSuccessReduction} ${reduction.toStringAsFixed(0)} Ar.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.secondary),
      );

      Navigator.pushReplacementNamed(context, ClientRoutes.profile);
    } on TimeoutException {
      setState(() => _errorMessage = AppLocalizations.of(context)!.clientPaymentErrorTimeout);
    } catch (e) {
      final msg = apiErrorString(e);
      String displayMsg;
      if (msg.contains('déjà réservée') || msg.contains('indisponible')) {
        displayMsg = AppLocalizations.of(context)!.clientPaymentErrorSeatTaken;
      } else if (msg.contains('Fonds insuffisants')) {
        displayMsg = AppLocalizations.of(context)!.clientPaymentErrorInsufficientFunds;
      } else if (msg.contains('code promo') || msg.contains('Code promo')) {
        displayMsg = AppLocalizations.of(context)!.clientPaymentErrorPromoCode;
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

  String get _firstTypePlace =>
      widget.tickets.isNotEmpty
          ? (widget.tickets.first['typePlace'] as String? ?? 'STANDARD')
          : 'STANDARD';

  String get _firstNumeroPlace =>
      widget.tickets.isNotEmpty
          ? (widget.tickets.first['numeroPlace'] as String? ?? '—')
          : '—';

  Color _badgeColor(String? typePlace) {
    switch (typePlace?.toUpperCase()) {
      case 'VIP':
        return const Color(0xFF9C27B0);
      case 'PREMIUM':
        return const Color(0xFFFF6F00);
      case 'ORCHESTRE':
        return const Color(0xFF7B1FA2);
      case 'BALCON':
        return const Color(0xFF00897B);
      case 'LOGE':
        return const Color(0xFF5C6BC0);
      default:
        return const Color(0xFF00796B);
    }
  }

  String _formatAmount(double amount) {
    return '${amount.toStringAsFixed(0)} ${AppConstants.currency}';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_processing,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: ModalRoute.of(context)?.canPop == true
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 22),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null,
          title: Text(AppLocalizations.of(context)!.clientHomeDetailTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                final loc = AppLocalizations.of(context);
                if (loc == null) return;
                final text = '${loc.clientPaymentShareText}\n${loc.clientPaymentPrice}: ${AppConstants.currency}${widget.amount.toStringAsFixed(0)}';
                Clipboard.setData(ClipboardData(text: text));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.clientPaymentOrderCopied), backgroundColor: AppColors.secondary),
                );
              },
            ),
          ],
        ),
        body: _processing
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(AppLocalizations.of(context)!.clientPaymentProcessing),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRecapHeader(),
                    const SizedBox(height: 20),
                    _buildSummaryCard(),
                    const SizedBox(height: 24),
                    _buildSectionTitle(AppLocalizations.of(context)!.clientPaymentPaymentMethod),
                    const SizedBox(height: 12),
                    _buildPaymentMethods(),
                    const SizedBox(height: 16),
                    _buildPaymentForm(),
                    const SizedBox(height: 20),
                    _buildCodePromo(),
                    const SizedBox(height: 24),
                    _buildSecurityBadges(),
                    const SizedBox(height: 16),
                    _buildLegalDisclaimer(),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      _buildErrorMessage(),
                    ],
                  ],
                ),
              ),
        bottomNavigationBar: _processing ? null : _buildFooter(),
      ),
    );
  }

  Widget _buildRecapHeader() {
    return Row(
      children: [
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.clientPaymentSummary,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
          ),
        _buildBadge(_firstTypePlace),
      ],
    );
  }

  Widget _buildBadge(String typePlace) {
    final color = _badgeColor(typePlace);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        typePlace,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final seatCount = widget.tickets.length;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.ticketBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _summaryRow(AppLocalizations.of(context)!.clientPaymentVenue, widget.eventTitle.isNotEmpty ? widget.eventTitle : '${AppLocalizations.of(context)!.clientPaymentEventName} #${widget.eventId}', AppColors.textSecondary),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _summaryRow(AppLocalizations.of(context)!.clientPaymentPrice, _formatAmount(_montantFinal), AppColors.primary, highlight: true),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _summaryRow(AppLocalizations.of(context)!.clientPaymentRow, '—', AppColors.textSecondary),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _summaryRow(AppLocalizations.of(context)!.clientPaymentSeat, _firstNumeroPlace, AppColors.textSecondary),
          if (seatCount > 1) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            _summaryRow(AppLocalizations.of(context)!.clientPaymentTickets, '$seatCount places', AppColors.textSecondary),
          ],
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 16, color: AppColors.secondary),
                const SizedBox(width: 6),
                Text(
                  AppLocalizations.of(context)!.clientPaymentOrderVerified,
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, Color valueColor, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.5),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: highlight ? 16 : 13,
              fontWeight: highlight ? FontWeight.w700 : FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    );
  }

  Widget _buildPaymentMethods() {
    final methods = [
      ('card', AppLocalizations.of(context)!.clientPaymentCard, AppLocalizations.of(context)!.clientPaymentCardSubtitle, Icons.credit_card, PaymentMethod.carte),
      ('mvola', 'MVola', AppLocalizations.of(context)!.clientPaymentMvolaSubtitle, Icons.phone_android, PaymentMethod.mvola),
      ('orange', 'Orange Money', AppLocalizations.of(context)!.clientPaymentOrangeSubtitle, Icons.phone_iphone, PaymentMethod.orange),
      ('airtel', 'Airtel Money', AppLocalizations.of(context)!.clientPaymentAirtelSubtitle, Icons.phone, PaymentMethod.airtel),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.ticketBorder),
      ),
      child: Column(
        children: List.generate(methods.length, (i) {
          final (id, title, subtitle, icon, method) = methods[i];
          final isSelected = _selectedMethod == method;
          return Column(
            children: [
              if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
              InkWell(
                onTap: () => setState(() => _selectedMethod = method),
                borderRadius: BorderRadius.vertical(
                  top: i == 0 ? const Radius.circular(11) : Radius.zero,
                  bottom: i == methods.length - 1 ? const Radius.circular(11) : Radius.zero,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Icon(icon, size: 22, color: isSelected ? AppColors.primary : AppColors.textMuted),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              subtitle,
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.textMuted,
                            width: isSelected ? 6 : 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildPaymentForm() {
    if (_selectedMethod != PaymentMethod.carte) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.ticketBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.clientPaymentTransactionRef,
                  hintText: 'Ex: MV123456789',
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (v) => _referenceTransaction = v,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.clientPaymentPhoneNumber,
                  hintText: '0341234567',
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                keyboardType: TextInputType.phone,
                onChanged: (v) => _numeroTelephone = v,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.clientPaymentFullName,
                  hintText: 'Jean Rakoto',
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (v) => _nomComplet = v,
              ),
            ],
          ),
        ),
      );
    }
    return CarteBancaireForm(
      onChanged: (carte) => _carteInfo = carte,
    );
  }

  Widget _buildCodePromo() {
    return CodePromoField(
      onCodeChanged: _onCodeChanged,
      onValidate: _onCodeValidate,
      eventId: widget.eventId,
    );
  }

  Widget _buildSecurityBadges() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _badgeItem(Icons.lock, 'SECURED BY BCRYPT'),
          const SizedBox(width: 16),
          _badgeItem(Icons.verified_user, 'JWT PROTECTED'),
        ],
      ),
    );
  }

  Widget _badgeItem(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.3),
        ),
      ],
    );
  }

  Widget _buildLegalDisclaimer() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.security, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Icon(Icons.verified, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Icon(Icons.payment, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            AppLocalizations.of(context)!.clientPaymentSecurityDisclaimer,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.4),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(_errorMessage!, style: const TextStyle(fontSize: 13, color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            child: Text('${AppLocalizations.of(context)!.clientPaymentPay} ${_formatAmount(_montantFinal)}'),
          ),
        ),
      ),
    );
  }
}
