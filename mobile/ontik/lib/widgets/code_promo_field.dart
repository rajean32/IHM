import 'package:flutter/material.dart';
import '../core/assets/app_colors.dart';

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

    // Simuler validation - dans la réalité, appeler l'API
    await Future.delayed(const Duration(milliseconds: 500));

    widget.onCodeChanged(code);
    widget.onValidate(true, code);

    setState(() {
      _isLoading = false;
      _isValid = true;
      _message = 'Code promo appliqué !';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Code promo',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Entrez votre code promo',
                  border: const OutlineInputBorder(),
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
                    _isValid ? Icons.check_circle : Icons.info_outline,
                    color: _isValid ? AppColors.secondary : AppColors.textSecondary,
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
              child: const Text('Appliquer'),
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
                color: _isValid ? AppColors.secondary : AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}