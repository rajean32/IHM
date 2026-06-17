import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/assets/app_colors.dart';
import '../generated/app_localizations.dart';

class CarteBancaireForm extends StatefulWidget {
  final Function(Map<String, String>) onChanged;

  const CarteBancaireForm({super.key, required this.onChanged});

  @override
  State<CarteBancaireForm> createState() => _CarteBancaireFormState();
}

class _CarteBancaireFormState extends State<CarteBancaireForm> {
  final _numeroCtrl = TextEditingController();
  final _expirationCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  final _nomCtrl = TextEditingController();

  @override
  void dispose() {
    _numeroCtrl.dispose();
    _expirationCtrl.dispose();
    _cvvCtrl.dispose();
    _nomCtrl.dispose();
    super.dispose();
  }

  void _notifyChange() {
    widget.onChanged({
      'numeroCarte': _numeroCtrl.text,
      'dateExpiration': _expirationCtrl.text,
      'cvv': _cvvCtrl.text,
      'nomTitulaire': _nomCtrl.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.widgetsCarteBancaireTitle,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _numeroCtrl,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.widgetsCarteBancaireCardNumber,
              hintText: AppLocalizations.of(context)!.widgetsCarteBancaireCardNumberHint,
              border: OutlineInputBorder(),
              isDense: true,
              prefixIcon: Icon(Icons.credit_card),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              _CardNumberFormatter(),
            ],
            onChanged: (_) => _notifyChange(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expirationCtrl,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.widgetsCarteBancaireExpiry,
                    hintText: AppLocalizations.of(context)!.widgetsCarteBancaireExpiryHint,
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.datetime,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    _ExpirationDateFormatter(),
                  ],
                  onChanged: (_) => _notifyChange(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _cvvCtrl,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.widgetsCarteBancaireCvv,
                    hintText: AppLocalizations.of(context)!.widgetsCarteBancaireCvvHint,
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  onChanged: (_) => _notifyChange(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nomCtrl,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.widgetsCarteBancaireCardholderName,
              hintText: AppLocalizations.of(context)!.widgetsCarteBancaireCardholderNameHint,
              border: OutlineInputBorder(),
              isDense: true,
            ),
            textCapitalization: TextCapitalization.characters,
            onChanged: (_) => _notifyChange(),
          ),
        ],
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(text[i]);
    }
    return newValue.copyWith(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class _ExpirationDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text.replaceAll('/', '');
    if (text.length >= 2) {
      final month = text.substring(0, 2);
      final year = text.length > 2 ? text.substring(2) : '';
      return newValue.copyWith(
        text: '$month/${year.length > 2 ? year.substring(0, 2) : year}',
        selection: TextSelection.collapsed(offset: month.length + 1 + (year.length > 2 ? 2 : year.length)),
      );
    }
    return newValue;
  }
}