import 'package:flutter/material.dart';
import 'package:ontik/models/lieu_model.dart';
import 'package:ontik/core/assets/app_colors.dart';

class LieuFormSheet extends StatefulWidget {
  final Lieu? lieu;
  const LieuFormSheet({super.key, this.lieu});

  static Future<Map<String, dynamic>?> show(BuildContext context, {Lieu? lieu}) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          child: LieuFormSheet(lieu: lieu),
        ),
      ),
    );
  }

  @override
  State<LieuFormSheet> createState() => _LieuFormSheetState();
}

class _LieuFormSheetState extends State<LieuFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeCtrl;
  late final TextEditingController _nomCtrl;
  late final TextEditingController _adresseCtrl;
  late final TextEditingController _villeCtrl;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.lieu != null;
    _codeCtrl = TextEditingController(text: widget.lieu?.code ?? '');
    _nomCtrl = TextEditingController(text: widget.lieu?.nomLieu ?? '');
    _adresseCtrl = TextEditingController(text: widget.lieu?.adresse ?? '');
    _villeCtrl = TextEditingController(text: widget.lieu?.ville ?? '');
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nomCtrl.dispose();
    _adresseCtrl.dispose();
    _villeCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, {
      'code': _codeCtrl.text.trim(),
      'nomLieu': _nomCtrl.text.trim(),
      'adresse': _adresseCtrl.text.trim().isEmpty ? null : _adresseCtrl.text.trim(),
      'ville': _villeCtrl.text.trim().isEmpty ? null : _villeCtrl.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 32, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text(_isEditing ? 'Modifier le lieu' : 'Ajouter un lieu', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeCtrl,
                enabled: !_isEditing,
                decoration: const InputDecoration(labelText: 'Code *', hintText: 'L01'),
                maxLength: 10,
                validator: (v) => v == null || v.trim().isEmpty ? 'Code obligatoire' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nomCtrl,
                decoration: const InputDecoration(labelText: 'Nom *'),
                maxLength: 100,
                validator: (v) => v == null || v.trim().isEmpty ? 'Nom obligatoire' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _adresseCtrl,
                decoration: const InputDecoration(labelText: 'Adresse'),
                maxLength: 200,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _villeCtrl,
                decoration: const InputDecoration(labelText: 'Ville'),
                maxLength: 100,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
                  const Spacer(),
                  ElevatedButton(onPressed: _submit, child: Text(_isEditing ? 'Modifier' : 'Ajouter')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
