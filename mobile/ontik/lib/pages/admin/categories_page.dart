import 'package:flutter/material.dart';
import '../../core/services/categorie_service.dart';
import '../../core/services/caracteristique_service.dart';
import '../../core/services/lieu_service.dart';
import '../../models/categorie_model.dart';
import '../../models/caracteristique_model.dart';
import '../../core/utils/error_helper.dart';
import '../../core/assets/app_colors.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});
  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  bool _loading = true;
  String? _error;
  List<Categorie> _categories = [];
  final _api = CategorieService();
  final _lieuService = LieuService();
  List<dynamic> _allSalles = [];
  String _filter = '';

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final cats = await _api.getCategories();
      final salles = await _lieuService.getSalles();
      if (!mounted) return;
      setState(() {
        _categories = cats.map((e) => Categorie.fromJson(e as Map<String, dynamic>)).toList();
        _allSalles = salles;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = apiErrorString(e); _loading = false; });
    }
  }

  void _showAddDialog() {
    final codeCtrl = TextEditingController();
    final nomCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollCtrl) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            controller: scrollCtrl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text('Ajouter une catégorie',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(height: 24),
                const SizedBox(height: 8),
                TextField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Code',
                    border: OutlineInputBorder(),
                    hintText: 'CAT01',
                  ),
                  maxLength: 10,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nomCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 100,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 500,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Annuler'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (codeCtrl.text.isEmpty || nomCtrl.text.isEmpty) return;
                          await _api.createCategory({
                            'codeCategorie': codeCtrl.text,
                            'nomCategorie': nomCtrl.text,
                            'description': descCtrl.text.isEmpty ? null : descCtrl.text,
                          });
                          if (ctx.mounted) Navigator.pop(ctx);
                          _loadData();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Ajouter'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openEditDialog(Categorie cat) async {
    final codeCtrl = TextEditingController(text: cat.codeCategorie);
    final nomCtrl = TextEditingController(text: cat.nomCategorie);
    final descCtrl = TextEditingController(text: cat.description ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollCtrl) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            controller: scrollCtrl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text('Modifier la catégorie',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(height: 24),
                const SizedBox(height: 8),
                TextField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Code',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 10,
                  enabled: false,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nomCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 100,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 500,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Annuler'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (nomCtrl.text.isEmpty) return;
                          await _api.updateCategory(cat.codeCategorie, {
                            'codeCategorie': codeCtrl.text,
                            'nomCategorie': nomCtrl.text,
                            'description': descCtrl.text.isEmpty ? null : descCtrl.text,
                          });
                          if (ctx.mounted) Navigator.pop(ctx);
                          _loadData();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Modifier'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openDeleteDialog(Categorie cat) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer la catégorie'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${cat.nomCategorie}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _api.deleteCategory(cat.codeCategorie);
      _loadData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Catégorie supprimée')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(apiErrorString(e)), backgroundColor: AppColors.error),
      );
    }
  }

  void _showManageCaracteristiques(Categorie cat) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => _CaracteristiquesPage(categorie: cat),
    )).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filter.isEmpty ? _categories : _categories.where((c) =>
    c.nomCategorie.toLowerCase().contains(_filter.toLowerCase()) ||
        c.codeCategorie.toLowerCase().contains(_filter.toLowerCase())
    ).toList();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(children: [
              const Text('Catégories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _filter = v),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text(_error!))
                : filtered.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.category, size: 48, color: AppColors.textSecondary.withValues(alpha: 0.4)),
                  const SizedBox(height: 12),
                  const Text('Aucune catégorie trouvée', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final c = filtered[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: Text(c.codeCategorie.isNotEmpty ? c.codeCategorie[0].toUpperCase() : '?',
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(c.nomCategorie, style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Code: ${c.codeCategorie}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          if (c.description != null && c.description!.isNotEmpty)
                            Text(c.description!, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton.icon(
                            onPressed: () => _showManageCaracteristiques(c),
                            icon: const Icon(Icons.list_alt, size: 18),
                            label: const Text('Caract.', style: TextStyle(fontSize: 11)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () => _openEditDialog(c),
                            tooltip: 'Modifier',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20, color: AppColors.error),
                            onPressed: () => _openDeleteDialog(c),
                            tooltip: 'Supprimer',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CaracteristiquesPage extends StatefulWidget {
  final Categorie categorie;
  const _CaracteristiquesPage({required this.categorie});

  @override
  State<_CaracteristiquesPage> createState() => _CaracteristiquesPageState();
}

class _CaracteristiquesPageState extends State<_CaracteristiquesPage> {
  final _caracService = CaracteristiqueService();
  List<Caracteristique> _items = [];
  bool _loading = true;
  String _filter = '';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _caracService.getByCategorie(widget.categorie.codeCategorie);
      if (!mounted) return;
      setState(() {
        _items = data.map((e) => Caracteristique.fromJson(e as Map<String, dynamic>)).toList();
        _loading = false;
      });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  void _showAddEditDialog({Caracteristique? existing}) {
    final nomCtrl = TextEditingController(text: existing?.nom ?? '');
    final ordreCtrl = TextEditingController(text: (existing?.ordreAffichage ?? _items.length).toString());
    final optionsCtrl = TextEditingController(text: existing?.options ?? '');
    String typeDonnee = existing?.typeDonnee ?? 'text';
    bool obligatoire = existing?.obligatoire ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollCtrl) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            controller: scrollCtrl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        existing != null ? 'Modifier la caractéristique' : 'Ajouter une caractéristique',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(height: 24),
                const SizedBox(height: 8),
                TextField(
                  controller: nomCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: typeDonnee,
                  decoration: const InputDecoration(
                    labelText: 'Type de donnée',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'text', child: Text('Texte')),
                    DropdownMenuItem(value: 'number', child: Text('Nombre')),
                    DropdownMenuItem(value: 'date', child: Text('Date')),
                    DropdownMenuItem(value: 'select', child: Text('Liste déroulante')),
                    DropdownMenuItem(value: 'boolean', child: Text('Oui/Non')),
                  ],
                  onChanged: (v) => setState(() => typeDonnee = v ?? 'text'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ordreCtrl,
                  decoration: const InputDecoration(
                    labelText: "Ordre d'affichage",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                if (typeDonnee == 'select') ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: optionsCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Options (séparées par virgule)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SwitchListTile(
                    title: const Text('Obligatoire'),
                    value: obligatoire,
                    onChanged: (v) => setState(() => obligatoire = v),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Annuler'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (nomCtrl.text.isEmpty) return;
                          final data = {
                            'nom': nomCtrl.text,
                            'typeDonnee': typeDonnee,
                            'obligatoire': obligatoire,
                            'ordreAffichage': int.tryParse(ordreCtrl.text) ?? 0,
                            'options': typeDonnee == 'select' ? optionsCtrl.text : null,
                            'codeCategorie': widget.categorie.codeCategorie,
                          };
                          if (existing != null) {
                            await _caracService.update(existing.idCaracteristique!, data);
                          } else {
                            await _caracService.create(data);
                          }
                          if (ctx.mounted) Navigator.pop(ctx);
                          _load();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(existing != null ? 'Enregistrer' : 'Ajouter'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _delete(Caracteristique c) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer'),
        content: Text('Supprimer la caractéristique "${c.nom}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _caracService.delete(c.idCaracteristique!);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filter.isEmpty ? _items : _items.where((c) =>
        c.nom.toLowerCase().contains(_filter.toLowerCase())
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Caractéristiques - ${widget.categorie.nomCategorie}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _filter = v),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.list_alt, size: 48, color: AppColors.textSecondary.withValues(alpha: 0.4)),
                  const SizedBox(height: 12),
                  const Text('Aucune caractéristique', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final c = filtered[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: Text(c.nom.isNotEmpty ? c.nom[0].toUpperCase() : '?',
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ),
                      title: Text('${c.nom}${c.obligatoire ? ' *' : ''}',
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text('Type: ${c.typeDonnee}${c.options != null ? ' (${c.options})' : ''} • Ordre: ${c.ordreAffichage ?? 0}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () => _showAddEditDialog(existing: c),
                            tooltip: 'Modifier',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20, color: AppColors.error),
                            onPressed: () => _delete(c),
                            tooltip: 'Supprimer',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}