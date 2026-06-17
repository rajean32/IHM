import 'package:flutter/material.dart';
import 'package:ontik/models/categorie_model.dart';
import 'package:ontik/core/assets/app_colors.dart';

class CategoryFormSheet extends StatefulWidget {
  final Categorie? category;
  const CategoryFormSheet({super.key, this.category});

  static Future<Map<String, dynamic>?> show(BuildContext context, {Categorie? category}) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          child: CategoryFormSheet(category: category),
        ),
      ),
    );
  }

  @override
  State<CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<CategoryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeCtrl;
  late final TextEditingController _nomCtrl;
  late final TextEditingController _descCtrl;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.category != null;
    _codeCtrl = TextEditingController(text: widget.category?.codeCategorie ?? '');
    _nomCtrl = TextEditingController(text: widget.category?.nomCategorie ?? '');
    _descCtrl = TextEditingController(text: widget.category?.description ?? '');
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nomCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, {
      'codeCategorie': _codeCtrl.text.trim(),
      'nomCategorie': _nomCtrl.text.trim(),
      'description': _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
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
              Text(_isEditing ? 'Modifier la catégorie' : 'Ajouter une catégorie', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeCtrl,
                enabled: !_isEditing,
                decoration: const InputDecoration(labelText: 'Code *', hintText: 'CAT01'),
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
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description', hintText: 'Description de la catégorie'),
                maxLength: 500,
                maxLines: 3,
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
