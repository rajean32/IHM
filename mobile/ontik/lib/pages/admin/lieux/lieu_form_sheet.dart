import 'package:flutter/material.dart';
import 'package:ontik/models/lieu_model.dart';
import 'package:ontik/core/services/ville_service.dart';
import 'package:ontik/models/ville_model.dart';

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
  late final TextEditingController _descriptionCtrl;
  bool _isEditing = false;

  List<Ville> _villes = [];
  Ville? _selectedVille;
  final _autreVilleCtrl = TextEditingController();
  bool _isAutreVille = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.lieu != null;
    _codeCtrl = TextEditingController(text: widget.lieu?.code ?? '');
    _nomCtrl = TextEditingController(text: widget.lieu?.nomLieu ?? '');
    _adresseCtrl = TextEditingController(text: widget.lieu?.adresse ?? '');
    _descriptionCtrl = TextEditingController(text: widget.lieu?.description ?? '');

    if (widget.lieu?.ville != null && widget.lieu!.ville!.isNotEmpty) {
      _autreVilleCtrl.text = widget.lieu!.ville!;
    }
    _loadVilles();
  }

  Future<void> _loadVilles() async {
    try {
      final villes = await VilleService().getVilles();
      if (!mounted) return;
      setState(() {
        _villes = villes;
        if (widget.lieu?.ville != null && widget.lieu!.ville!.isNotEmpty) {
          final match = villes.where((v) =>
            v.nom.toLowerCase() == widget.lieu!.ville!.toLowerCase() ||
            v.code.toLowerCase() == widget.lieu!.ville!.toLowerCase()
          ).firstOrNull;
          if (match != null) {
            _selectedVille = match;
          } else {
            _isAutreVille = true;
          }
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nomCtrl.dispose();
    _adresseCtrl.dispose();
    _descriptionCtrl.dispose();
    _autreVilleCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    String? villeNom;
    String? villeCode;
    if (_isAutreVille) {
      villeNom = _autreVilleCtrl.text.trim().isEmpty ? null : _autreVilleCtrl.text.trim();
    } else {
      villeNom = _selectedVille?.nom;
      villeCode = _selectedVille?.code;
    }
    Navigator.pop(context, {
      'code': _codeCtrl.text.trim(),
      'nomLieu': _nomCtrl.text.trim(),
      'adresse': _adresseCtrl.text.trim().isEmpty ? null : _adresseCtrl.text.trim(),
      'description': _descriptionCtrl.text.trim().isEmpty ? null : _descriptionCtrl.text.trim(),
      'ville': villeNom,
      'villeCode': villeCode,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 32, height: 4, decoration: BoxDecoration(color: theme.colorScheme.outline.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text(_isEditing ? 'Modifier le lieu' : 'Ajouter un lieu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
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
                controller: _descriptionCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 4,
                maxLength: 1000,
              ),
              const SizedBox(height: 12),
              _isAutreVille
                  ? TextFormField(
                      controller: _autreVilleCtrl,
                      decoration: InputDecoration(
                        labelText: 'Ville (autre)',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.list, size: 20),
                          onPressed: () => setState(() { _isAutreVille = false; _autreVilleCtrl.clear(); }),
                          tooltip: 'Choisir dans la liste',
                        ),
                      ),
                      maxLength: 100,
                    )
                  : DropdownButtonFormField<Ville>(
                      value: _villes.contains(_selectedVille) ? _selectedVille : null,
                      decoration: InputDecoration(
                        labelText: 'Ville',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => setState(() { _isAutreVille = true; _selectedVille = null; }),
                          tooltip: 'Saisir une autre ville',
                        ),
                      ),
                      items: _villes.map((v) => DropdownMenuItem(value: v, child: Text('${v.nom} (${v.code})'))).toList(),
                      onChanged: (v) => setState(() => _selectedVille = v),
                      isExpanded: true,
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
