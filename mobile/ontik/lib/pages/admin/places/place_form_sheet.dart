import 'package:flutter/material.dart';
import 'package:ontik/models/lieu_model.dart';
import 'package:ontik/core/assets/app_colors.dart';

class PlaceFormSheet extends StatefulWidget {
  final Place? place;
  const PlaceFormSheet({super.key, this.place});

  static Future<Map<String, dynamic>?> show(BuildContext context, {Place? place}) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: PlaceFormSheet(place: place),
      ),
    );
  }

  @override
  State<PlaceFormSheet> createState() => _PlaceFormSheetState();
}

class _PlaceFormSheetState extends State<PlaceFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _numCtrl;
  late final TextEditingController _rangCtrl;

  @override
  void initState() {
    super.initState();
    _numCtrl = TextEditingController(text: widget.place?.numeroPlace ?? '');
    _rangCtrl = TextEditingController(text: widget.place?.range ?? '');
  }

  @override
  void dispose() {
    _numCtrl.dispose();
    _rangCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, {
      'numeroPlace': _numCtrl.text.trim(),
      'rang': _rangCtrl.text.trim(),
      'numeroSalle': widget.place?.numeroSalle ?? '',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 32, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text(widget.place != null ? 'Modifier la place' : 'Ajouter une place', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _numCtrl,
              decoration: const InputDecoration(labelText: 'Numéro de place *'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Requis' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _rangCtrl,
              decoration: const InputDecoration(labelText: 'Rang'),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
                const Spacer(),
                ElevatedButton(onPressed: _submit, child: Text(widget.place != null ? 'Enregistrer' : 'Ajouter')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
