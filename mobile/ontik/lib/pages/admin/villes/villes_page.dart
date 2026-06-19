import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/ville_service.dart';
import '../../../models/ville_model.dart';
import '../../../widgets/error_state.dart';
import '../../../core/utils/error_helper.dart';
import '../../../generated/app_localizations.dart';

class VillesPage extends StatefulWidget {
  const VillesPage({super.key});

  @override
  State<VillesPage> createState() => _VillesPageState();
}

class _VillesPageState extends State<VillesPage> {
  final _service = VilleService();
  final _searchCtrl = TextEditingController();
  bool _loading = true;
  String? _error;
  List<Ville> _villes = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final villes = await _service.getVilles(search: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim());
      if (!mounted) return;
      setState(() { _villes = villes; _loading = false; _error = null; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = apiErrorString(e); _loading = false; });
    }
  }

  Future<void> _showForm({Ville? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.nom ?? '');
    final regionCtrl = TextEditingController(text: existing?.region ?? '');
    final codeCtrl = TextEditingController(text: existing?.code ?? '');
    final isEditing = existing != null;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Modifier la ville' : 'Ajouter une ville'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: codeCtrl,
              decoration: const InputDecoration(labelText: 'Code', hintText: 'TNR'),
              inputFormatters: [UpperCaseTextFormatter(), LengthLimitingTextInputFormatter(10)],
              enabled: !isEditing,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nom', hintText: 'Antananarivo'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: regionCtrl,
              decoration: const InputDecoration(labelText: 'Région', hintText: 'Analamanga'),
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              try {
                final ville = Ville(
                  code: codeCtrl.text.trim().toUpperCase(),
                  nom: nameCtrl.text.trim(),
                  region: regionCtrl.text.trim().isEmpty ? null : regionCtrl.text.trim(),
                );
                if (isEditing) {
                  await _service.updateVille(existing.code, ville);
                } else {
                  await _service.createVille(ville);
                }
                if (!ctx.mounted) return;
                Navigator.pop(ctx, true);
              } catch (e) {
                if (!ctx.mounted) return;
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Erreur: ${apiErrorString(e)}')));
              }
            },
            child: Text(isEditing ? 'Modifier' : 'Ajouter'),
          ),
        ],
      ),
    );
    if (result == true) _load();
  }

  Future<void> _confirmDelete(Ville ville) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer'),
        content: Text('Supprimer "${ville.nom}" (${ville.code}) ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _service.deleteVille(ville.code);
        _load();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: ${apiErrorString(e)}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Villes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Rechercher une ville...',
              prefixIcon: const Icon(Icons.search, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            onChanged: (_) => _load(),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? ErrorState(message: _error!, onRetry: _load)
                  : _villes.isEmpty
                      ? Center(
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.location_city, size: 48, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                            const SizedBox(height: 12),
                            Text('Aucune ville trouvée', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                          ]),
                        )
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _villes.length,
                            itemBuilder: (ctx, i) {
                              final v = _villes[i];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                    child: Text(v.code, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary)),
                                  ),
                                  title: Text(v.nom, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  subtitle: v.region != null ? Text(v.region!, style: const TextStyle(fontSize: 12)) : null,
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (action) {
                                      if (action == 'edit') _showForm(existing: v);
                                      if (action == 'delete') _confirmDelete(v);
                                    },
                                    itemBuilder: (_) => [
                                      const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit, size: 18), title: Text('Modifier'))),
                                      const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete, size: 18), title: Text('Supprimer'))),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
        ),
      ]),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
