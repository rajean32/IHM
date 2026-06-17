import 'package:flutter/material.dart';
import 'package:ontik/models/lieu_model.dart';
import 'package:ontik/core/assets/app_colors.dart';

class SalleFormSheet extends StatefulWidget {
  final Salle? salle;
  final String codeLieu;
  const SalleFormSheet({super.key, this.salle, required this.codeLieu});

  static Future<Map<String, dynamic>?> show(BuildContext context, {Salle? salle, required String codeLieu}) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.7,
        expand: false,
        builder: (ctx, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          child: SalleFormSheet(salle: salle, codeLieu: codeLieu),
        ),
      ),
    );
  }

  @override
  State<SalleFormSheet> createState() => _SalleFormSheetState();
}

class _SalleFormSheetState extends State<SalleFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomCtrl;

  @override
  void initState() {
    super.initState();
    _nomCtrl = TextEditingController(text: widget.salle?.nomSalle ?? '');
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, {
      'nomSalle': _nomCtrl.text.trim(),
      'codeLieu': widget.codeLieu,
      if (widget.salle != null) 'numeroSalle': widget.salle!.numeroSalle,
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
              Text(widget.salle != null ? 'Modifier la salle' : 'Ajouter une salle', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomCtrl,
                decoration: const InputDecoration(labelText: 'Nom de la salle *'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Nom obligatoire' : null,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
                  const Spacer(),
                  ElevatedButton(onPressed: _submit, child: Text(widget.salle != null ? 'Modifier' : 'Ajouter')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
