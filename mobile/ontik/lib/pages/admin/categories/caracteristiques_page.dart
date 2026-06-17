import 'package:flutter/material.dart';
import 'package:ontik/core/services/caracteristique_service.dart';
import 'package:ontik/models/categorie_model.dart';
import 'package:ontik/models/caracteristique_model.dart';
import 'package:ontik/core/assets/app_colors.dart';
import 'package:ontik/core/utils/error_helper.dart';
import 'package:ontik/widgets/admin/admin_search_field.dart';
import 'package:ontik/widgets/admin/admin_empty_state.dart';
import 'package:ontik/widgets/admin/admin_error_state.dart';
import 'package:ontik/widgets/admin/admin_toast.dart';
import 'package:ontik/widgets/admin/admin_confirmation_dialog.dart';

class CaracteristiquesPage extends StatefulWidget {
  final Categorie categorie;
  const CaracteristiquesPage({super.key, required this.categorie});

  @override
  State<CaracteristiquesPage> createState() => _CaracteristiquesPageState();
}

class _CaracteristiquesPageState extends State<CaracteristiquesPage> {
  final _service = CaracteristiqueService();
  final _searchCtrl = TextEditingController();
  bool _loading = true;
  String? _error;
  List<Caracteristique> _items = [];
  List<Caracteristique> _filteredItems = [];
  String _searchQuery = '';
  final _types = ['text', 'number', 'date', 'select', 'boolean'];

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
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _service.getByCategorie(widget.categorie.codeCategorie);
      if (!mounted) return;
      final items = data.map((e) => Caracteristique.fromJson(e as Map<String, dynamic>)).toList();
      setState(() { _items = items; _filteredItems = items; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = apiErrorString(e); _loading = false; });
    }
  }

  void _filter(String query) {
    _searchQuery = query.toLowerCase();
    setState(() {
      _filteredItems = _items.where((c) => c.nom.toLowerCase().contains(_searchQuery)).toList();
    });
  }

  Future<void> _showForm({Caracteristique? item}) async {
    final nomCtrl = TextEditingController(text: item?.nom ?? '');
    final optionsCtrl = TextEditingController(text: item?.options ?? '');
    bool obligatoire = item?.obligatoire ?? false;
    int? ordre = item?.ordreAffichage;
    String? selectedType = item?.typeDonnee ?? 'text';

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollCtrl) => StatefulBuilder(
          builder: (ctx, setSheetState) => SingleChildScrollView(
            controller: scrollCtrl,
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Container(width: 32, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(height: 16),
                    Text(item == null ? 'Ajouter une caractéristique' : 'Modifier la caractéristique', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),
                    TextField(controller: nomCtrl, decoration: const InputDecoration(labelText: 'Nom *')),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(labelText: 'Type de donnée'),
                      items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (v) => setSheetState(() => selectedType = v),
                    ),
                    const SizedBox(height: 12),
                    TextField(controller: TextEditingController(text: ordre?.toString() ?? ''), keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Ordre d'affichage")),
                    if (selectedType == 'select') ...[
                      const SizedBox(height: 12),
                      TextField(controller: optionsCtrl, decoration: const InputDecoration(labelText: 'Options (séparées par virgule)'), maxLines: 2),
                    ],
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Obligatoire'),
                      value: obligatoire,
                      onChanged: (v) => setSheetState(() => obligatoire = v),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            if (nomCtrl.text.trim().isEmpty) return;
                            Navigator.pop(ctx, {
                              'nom': nomCtrl.text.trim(),
                              'typeDonnee': selectedType,
                              'obligatoire': obligatoire,
                              'ordreAffichage': int.tryParse(ordre?.toString() ?? ''),
                              'options': selectedType == 'select' ? optionsCtrl.text.trim() : null,
                              'codeCategorie': widget.categorie.codeCategorie,
                            });
                          },
                          child: Text(item == null ? 'Ajouter' : 'Modifier'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    nomCtrl.dispose();
    optionsCtrl.dispose();

    if (result == null) return;
    try {
      if (item != null) {
        await _service.update(item.idCaracteristique!, result);
      } else {
        await _service.create(result);
      }
      if (!mounted) return;
      AdminToast.show(context, message: item == null ? 'Caractéristique créée' : 'Caractéristique modifiée', isSuccess: true);
      _load();
    } catch (e) {
      if (!mounted) return;
      AdminToast.show(context, message: apiErrorString(e), isSuccess: false);
    }
  }

  Future<void> _delete(Caracteristique item) async {
    final confirm = await AdminConfirmationDialog.show(context, title: 'Supprimer', message: 'Supprimer "${item.nom}" ?');
    if (confirm != true) return;
    try {
      await _service.delete(item.idCaracteristique!);
      if (!mounted) return;
      AdminToast.show(context, message: 'Caractéristique supprimée', isSuccess: true);
      _load();
    } catch (e) {
      if (!mounted) return;
      AdminToast.show(context, message: apiErrorString(e), isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Caractéristiques - ${widget.categorie.nomCategorie}')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: AdminSearchField(
              hintText: 'Rechercher...',
              controller: _searchCtrl,
              onChanged: _filter,
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return AdminErrorState(message: _error!, onRetry: _load);
    if (_filteredItems.isEmpty) {
      return AdminEmptyState(
        icon: Icons.list_alt,
        message: 'Aucune caractéristique',
        actionLabel: 'Ajouter',
        onAction: () => _showForm(),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredItems.length,
        itemBuilder: (ctx, i) => _buildCard(_filteredItems[i]),
      ),
    );
  }

  Widget _buildCard(Caracteristique item) {
    final subtitle = 'Type: ${item.typeDonnee}${item.options != null ? ' (${item.options})' : ''}  •  Ordre: ${item.ordreAffichage ?? '-'}';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(item.nom.isNotEmpty ? item.nom[0].toUpperCase() : '?', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ),
        title: Text('${item.nom}${item.obligatoire ? ' *' : ''}', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _showForm(item: item)),
            IconButton(icon: const Icon(Icons.delete, size: 20, color: AppColors.error), onPressed: () => _delete(item)),
          ],
        ),
      ),
    );
  }
}
