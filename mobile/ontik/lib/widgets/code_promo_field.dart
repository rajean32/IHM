import 'package:flutter/material.dart';
import '../core/api/dio_config.dart';
import '../core/api/endpoints.dart';
import '../core/assets/app_colors.dart';
import '../core/utils/error_helper.dart';
import '../generated/app_localizations.dart';

class CodePromoField extends StatefulWidget {
  final Function(String?) onCodeChanged;
  final Function(bool, String?) onValidate;
  final int? eventId;

  const CodePromoField({
    super.key,
    required this.onCodeChanged,
    required this.onValidate,
    this.eventId,
  });

  @override
  State<CodePromoField> createState() => _CodePromoFieldState();
}

class _CodePromoFieldState extends State<CodePromoField> {
  final TextEditingController _controller = TextEditingController();
  bool _isValid = false;
  bool _isLoading = false;
  String? _message;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _validateCode() async {
    final code = _controller.text.trim().toUpperCase();
    if (code.isEmpty) {
      widget.onCodeChanged(null);
      setState(() {
        _isValid = false;
        _message = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    // Validation par API
    try {
      final resp = await dio.post(
        Endpoints.verifierCodePromo(code, widget.eventId ?? 0),
      );
      // Succès
      widget.onCodeChanged(code);
      widget.onValidate(true, code);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isValid = true;
        _message = AppLocalizations.of(context)!.widgetsCodePromoApplied;
      });
    } catch (e) {
      // Erreur API - Feature 20: colorer en rouge
      String errMsg = 'Code invalide';
      if (e.toString().contains('expiré')) {
        errMsg = 'Ce code promo a expiré';
      } else if (e.toString().contains('limite') || e.toString().contains('utilisation')) {
        errMsg = 'Ce code promo a atteint sa limite d\'utilisations';
      } else if (e.toString().contains('introuvable')) {
        errMsg = 'Code promo introuvable';
      } else if (e.toString().contains('pas encore valide')) {
        errMsg = 'Ce code promo n\'est pas encore valide';
      } else if (e.toString().contains('plus actif')) {
        errMsg = 'Ce code promo n\'est plus actif';
      } else if (e.toString().contains('pas valide pour cet événement')) {
        errMsg = 'Ce code promo n\'est pas valide pour cet événement';
      } else {
        errMsg = apiErrorString(e);
      }
      widget.onCodeChanged(null);
      widget.onValidate(false, null);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isValid = false;
        _message = errMsg;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.widgetsCodePromoLabel,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.widgetsCodePromoHint,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: (!_isValid && _message != null) ? Colors.red : Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: (!_isValid && _message != null) ? Colors.red : Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: (!_isValid && _message != null) ? Colors.red : AppColors.primary, width: 2),
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  suffixIcon: _isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                      : _controller.text.isNotEmpty
                      ? Icon(
                    _isValid ? Icons.check_circle : Icons.cancel,
                    color: _isValid ? AppColors.secondary : Colors.red,
                  )
                      : null,
                ),
                textCapitalization: TextCapitalization.characters,
                onChanged: (value) {
                  widget.onCodeChanged(value.isEmpty ? null : value);
                  setState(() {
                    _isValid = false;
                    _message = null;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _controller.text.isEmpty ? null : _validateCode,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                minimumSize: const Size(0, 48),
              ),
              child: Text(AppLocalizations.of(context)!.widgetsCodePromoApply),
            ),
          ],
        ),
        if (_message != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _message!,
              style: TextStyle(
                fontSize: 12,
                color: _isValid ? AppColors.secondary : Colors.red,
              ),
            ),
          ),
      ],
    );
  }
}