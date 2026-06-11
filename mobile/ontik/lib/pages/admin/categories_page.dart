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

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ajouter une catégorie'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Code', border: OutlineInputBorder(), hintText: 'CAT01'), maxLength: 10),
            const SizedBox(height: 8),
            TextField(controller: nomCtrl, decoration: const InputDecoration(labelText: 'Nom', border: OutlineInputBorder()), maxLength: 100),
            const SizedBox(height: 8),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()), maxLength: 500, maxLines: 3),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(onPressed: () async {
            if (codeCtrl.text.isEmpty || nomCtrl.text.isEmpty) return;
            await _api.createCategory({
              'codeCategorie': codeCtrl.text,
              'nomCategorie': nomCtrl.text,
              'description': descCtrl.text.isEmpty ? null : descCtrl.text,
            });
            if (ctx.mounted) Navigator.pop(ctx);
            _loadData();
          }, child: const Text('Ajouter')),
        ],
      ),
    );
  }

  void _openEditDialog(Categorie cat) async {
    final codeCtrl = TextEditingController(text: cat.codeCategorie);
    final nomCtrl = TextEditingController(text: cat.nomCategorie);
    final descCtrl = TextEditingController(text: cat.description ?? '');

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Modifier la catégorie'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Code', border: OutlineInputBorder()), maxLength: 10, enabled: false),
            const SizedBox(height: 8),
            TextField(controller: nomCtrl, decoration: const InputDecoration(labelText: 'Nom', border: OutlineInputBorder()), maxLength: 100),
            const SizedBox(height: 8),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()), maxLength: 500, maxLines: 3),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(onPressed: () async {
            if (nomCtrl.text.isEmpty) return;
            await _api.updateCategory(cat.codeCategorie, {
              'codeCategorie': codeCtrl.text,
              'nomCategorie': nomCtrl.text,
              'description': descCtrl.text.isEmpty ? null : descCtrl.text,
            });
            if (ctx.mounted) Navigator.pop(ctx);
            _loadData();
          }, child: const Text('Modifier')),
        ],
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
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
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
        SnackBar(content: Text(apiErrorString(e)), backgroundColor: AppTheme.errorColor),
      );
    }
  }

  void _showManageCaracteristiques(Categorie cat) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => _CaracteristiquesPage(categorie: cat),
    )).then((_) => _loadData());
  }

  void _showManageSalleTypes(Categorie cat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _SalleTypeSelector(
        categorie: cat,
        allSalles: _allSalles,
        onChanged: () => _loadData(),
      ),
    );
  }

  void _showManageSpecificConfig(Categorie cat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _SpecificConfigPage(
        categorie: cat,
        onChanged: () => _loadData(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catégories')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _categories.isEmpty
                  ? const Center(child: Text('Aucune catégorie trouvée'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _categories.length,
                      itemBuilder: (ctx, i) {
                        final c = _categories[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  CircleAvatar(
                                    child: Text(c.codeCategorie.isNotEmpty ? c.codeCategorie[0].toUpperCase() : '?'),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(c.nomCategorie, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        const SizedBox(height: 2),
                                        Text('Code: ${c.codeCategorie}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                        if (c.description != null && c.description!.isNotEmpty)
                                          Text(c.description!, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (v) {
                                      if (v == 'edit') _openEditDialog(c);
                                      if (v == 'delete') _openDeleteDialog(c);
                                    },
                                    itemBuilder: (ctx) => [
                                      const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit, size: 18), title: Text('Modifier', style: TextStyle(fontSize: 13)))),
                                      const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete, size: 18, color: AppTheme.errorColor), title: Text('Supprimer', style: TextStyle(fontSize: 13, color: AppTheme.errorColor)))),
                                    ],
                                  ),
                                ]),
                                const SizedBox(height: 8),
                                Row(children: [
                                  _actionChip(Icons.list_alt, 'Caractéristiques', () => _showManageCaracteristiques(c)),
                                  const SizedBox(width: 4),
                                  _actionChip(Icons.meeting_room, 'Salles', () => _showManageSalleTypes(c)),
                                  const SizedBox(width: 4),
                                  _actionChip(Icons.settings, 'Config', () => _showManageSpecificConfig(c)),
                                ]),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _actionChip(IconData icon, String label, VoidCallback onPressed) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 10)),
      onPressed: onPressed,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
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

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title: Text(existing != null ? 'Modifier la caractéristique' : 'Ajouter une caractéristique'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: nomCtrl, decoration: const InputDecoration(labelText: 'Nom', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: typeDonnee,
                decoration: const InputDecoration(labelText: 'Type de donnée', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'text', child: Text('Texte')),
                  DropdownMenuItem(value: 'number', child: Text('Nombre')),
                  DropdownMenuItem(value: 'date', child: Text('Date')),
                  DropdownMenuItem(value: 'select', child: Text('Liste déroulante')),
                  DropdownMenuItem(value: 'boolean', child: Text('Oui/Non')),
                ],
                onChanged: (v) => setDState(() => typeDonnee = v ?? 'text'),
              ),
              const SizedBox(height: 8),
              TextField(controller: ordreCtrl, decoration: const InputDecoration(labelText: 'Ordre d\'affichage', border: OutlineInputBorder()), keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              if (typeDonnee == 'select')
                TextField(controller: optionsCtrl, decoration: const InputDecoration(labelText: 'Options (séparées par virgule)', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              SwitchListTile(title: const Text('Obligatoire'), value: obligatoire, onChanged: (v) => setDState(() => obligatoire = v)),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            ElevatedButton(onPressed: () async {
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
            }, child: Text(existing != null ? 'Enregistrer' : 'Ajouter')),
          ],
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
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer', style: TextStyle(color: AppTheme.errorColor))),
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
    return Scaffold(
      appBar: AppBar(title: Text('Caractéristiques - ${widget.categorie.nomCategorie}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('Aucune caractéristique'))
              : ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (ctx, i) {
                    final c = _items[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      child: ListTile(
                        title: Text('${c.nom}${c.obligatoire ? ' *' : ''}', style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text('Type: ${c.typeDonnee}${c.options != null ? ' (${c.options})' : ''} • Ordre: ${c.ordreAffichage ?? 0}'),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _showAddEditDialog(existing: c)),
                          IconButton(icon: const Icon(Icons.delete, size: 20, color: AppTheme.errorColor), onPressed: () => _delete(c)),
                        ]),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(onPressed: () => _showAddEditDialog(), child: const Icon(Icons.add)),
    );
  }
}

class _SalleTypeSelector extends StatefulWidget {
  final Categorie categorie;
  final List<dynamic> allSalles;
  final VoidCallback onChanged;
  const _SalleTypeSelector({required this.categorie, required this.allSalles, required this.onChanged});

  @override
  State<_SalleTypeSelector> createState() => _SalleTypeSelectorState();
}

class _SalleTypeSelectorState extends State<_SalleTypeSelector> {
  late List<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = List<String>.from(widget.categorie.salleTypeCodes ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            const Text('Types de salle compatibles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
          ]),
          const Divider(),
          Text('Sélectionnez les salles compatibles avec "${widget.categorie.nomCategorie}"',
              style: TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: widget.allSalles.map((s) {
                final numero = s['numeroSalle'] as String;
                final nom = s['nomSalle'] as String;
                final selected = _selectedIds.contains(numero);
                return CheckboxListTile(
                  value: selected,
                  onChanged: (v) => setState(() {
                    if (v == true) { _selectedIds.add(numero); }
                    else { _selectedIds.remove(numero); }
                  }),
                  title: Text(nom),
                  subtitle: Text(numero),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              final currentIds = widget.categorie.salleTypeCodes ?? [];
              final toAdd = _selectedIds.where((id) => !currentIds.contains(id)).toList();
              final toRemove = currentIds.where((id) => !_selectedIds.contains(id)).toList();
              try {
                for (final id in toAdd) {
                  await CategorieService().addSalleType(widget.categorie.codeCategorie, id);
                }
                for (final id in toRemove) {
                  await CategorieService().removeSalleType(widget.categorie.codeCategorie, id);
                }
                widget.onChanged();
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(apiErrorString(e))));
                }
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}

class _SpecificConfigPage extends StatefulWidget {
  final Categorie categorie;
  final VoidCallback onChanged;
  const _SpecificConfigPage({required this.categorie, required this.onChanged});

  @override
  State<_SpecificConfigPage> createState() => _SpecificConfigPageState();
}

class _SpecificConfigPageState extends State<_SpecificConfigPage> {
  Map<String, dynamic> _config = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    setState(() => _loading = true);
    try {
      final config = await CategorieService().getCategorieSpecificConfig(widget.categorie.codeCategorie);
      if (!mounted) return;
      setState(() { _config = config ?? {}; _loading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _saveConfig() async {
    try {
      await CategorieService().updateCategorieSpecificConfig(widget.categorie.codeCategorie, _config);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuration spécifique enregistrée')),
      );
      widget.onChanged();
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(apiErrorString(e)), backgroundColor: AppTheme.errorColor),
      );
    }
  }

  Widget _buildCinemaConfig() {
    final rows = TextEditingController(text: (_config['nbRangees']?.toString() ?? ''));
    final seatsPerRow = TextEditingController(text: (_config['placesParRangee']?.toString() ?? ''));
    final allees = TextEditingController(text: (_config['allees']?.toString() ?? ''));
    final largeur = TextEditingController(text: (_config['largeurAllee']?.toString() ?? ''));

    return StatefulBuilder(
      builder: (ctx, setDState) => Column(children: [
        const Text('Configuration salle de cinéma', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(controller: rows, decoration: const InputDecoration(labelText: 'Nombre de rangées', border: OutlineInputBorder()), keyboardType: TextInputType.number,
          onChanged: (v) => _config['nbRangees'] = int.tryParse(v)),
        const SizedBox(height: 8),
        TextField(controller: seatsPerRow, decoration: const InputDecoration(labelText: 'Sièges par rangée', border: OutlineInputBorder()), keyboardType: TextInputType.number,
          onChanged: (v) => _config['placesParRangee'] = int.tryParse(v)),
        const SizedBox(height: 8),
        TextField(controller: allees, decoration: const InputDecoration(labelText: 'Allées (ex: B,D)', border: OutlineInputBorder()),
          onChanged: (v) => _config['allees'] = v),
        const SizedBox(height: 8),
        TextField(controller: largeur, decoration: const InputDecoration(labelText: 'Largeur allée', border: OutlineInputBorder()), keyboardType: TextInputType.number,
          onChanged: (v) => _config['largeurAllee'] = double.tryParse(v)),
      ]),
    );
  }

  Widget _buildConcertConfig() {
    final zones = (_config['zones'] as List<dynamic>?)?.cast<Map<String, dynamic>>().toList() ?? [];

    return Column(children: [
      Row(children: [
        const Text('Zones de placement libre', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const Spacer(),
        IconButton(icon: const Icon(Icons.add), onPressed: () => _showAddZoneDialog()),
      ]),
      const SizedBox(height: 8),
      if (zones.isEmpty)
        const Text('Aucune zone configurée', style: TextStyle(color: AppTheme.textSecondary))
      else
        Expanded(
          child: ListView.builder(
            itemCount: zones.length,
            itemBuilder: (ctx, i) {
              final zone = zones[i];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text('${zone['nom'] ?? 'Zone ${i + 1}'}'),
                  subtitle: Text('Capacité: ${zone['capacite']} • Prix: ${zone['prix']}'),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _showEditZoneDialog(i, zone)),
                    IconButton(icon: const Icon(Icons.delete, size: 18, color: AppTheme.errorColor), onPressed: () {
                      zones.removeAt(i);
                      _config['zones'] = zones;
                      setState(() {});
                    }),
                  ]),
                ),
              );
            },
          ),
        ),
    ]);
  }

  void _showAddZoneDialog() {
    final nomCtrl = TextEditingController();
    final capaciteCtrl = TextEditingController();
    final prixCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ajouter une zone'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nomCtrl, decoration: const InputDecoration(labelText: 'Nom', border: OutlineInputBorder())),
          const SizedBox(height: 8),
          TextField(controller: capaciteCtrl, decoration: const InputDecoration(labelText: 'Capacité max', border: OutlineInputBorder()), keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          TextField(controller: prixCtrl, decoration: const InputDecoration(labelText: 'Prix billet', border: OutlineInputBorder()), keyboardType: TextInputType.number),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(onPressed: () {
            if (nomCtrl.text.isEmpty) return;
            final z = (_config['zones'] as List<dynamic>?) ?? [];
            z.add({'nom': nomCtrl.text, 'capacite': int.tryParse(capaciteCtrl.text) ?? 0, 'prix': double.tryParse(prixCtrl.text) ?? 0.0});
            _config['zones'] = z;
            Navigator.pop(ctx);
            setState(() {});
          }, child: const Text('Ajouter')),
        ],
      ),
    );
  }

  void _showEditZoneDialog(int index, Map<String, dynamic> zone) {
    final nomCtrl = TextEditingController(text: zone['nom']);
    final capaciteCtrl = TextEditingController(text: zone['capacite'].toString());
    final prixCtrl = TextEditingController(text: zone['prix'].toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Modifier zone ${index + 1}'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nomCtrl, decoration: const InputDecoration(labelText: 'Nom', border: OutlineInputBorder())),
          const SizedBox(height: 8),
          TextField(controller: capaciteCtrl, decoration: const InputDecoration(labelText: 'Capacité max', border: OutlineInputBorder()), keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          TextField(controller: prixCtrl, decoration: const InputDecoration(labelText: 'Prix billet', border: OutlineInputBorder()), keyboardType: TextInputType.number),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(onPressed: () {
            if (nomCtrl.text.isEmpty) return;
            final z = List<Map<String, dynamic>>.from((_config['zones'] as List<dynamic>?) ?? []);
            z[index] = {'nom': nomCtrl.text, 'capacite': int.tryParse(capaciteCtrl.text) ?? 0, 'prix': double.tryParse(prixCtrl.text) ?? 0.0};
            _config['zones'] = z;
            Navigator.pop(ctx);
            setState(() {});
          }, child: const Text('Enregistrer')),
        ],
      ),
    );
  }

  Widget _buildSportsConfig() {
    final blocs = (_config['blocs'] as List<dynamic>?)?.cast<Map<String, dynamic>>().toList() ?? [];

    return Column(children: [
      Row(children: [
        const Text('Blocs de tribunes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const Spacer(),
        IconButton(icon: const Icon(Icons.add), onPressed: () => _showAddBlockDialog()),
      ]),
      const SizedBox(height: 8),
      if (blocs.isEmpty)
        const Text('Aucun bloc configuré', style: TextStyle(color: AppTheme.textSecondary))
      else
        Expanded(
          child: ListView.builder(
            itemCount: blocs.length,
            itemBuilder: (ctx, i) {
              final block = blocs[i];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text('${block['type'] ?? 'Bloc ${i + 1}'}'),
                  subtitle: Text('Places: ${block['places']} • Prix: ${block['prix']}'),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _showEditBlockDialog(i, block)),
                    IconButton(icon: const Icon(Icons.delete, size: 18, color: AppTheme.errorColor), onPressed: () {
                      blocs.removeAt(i);
                      _config['blocs'] = blocs;
                      setState(() {});
                    }),
                  ]),
                ),
              );
            },
          ),
        ),
    ]);
  }

  void _showAddBlockDialog() {
    final typeCtrl = TextEditingController();
    final placesCtrl = TextEditingController();
    final prixCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ajouter un bloc'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: typeCtrl, decoration: const InputDecoration(labelText: 'Type (ex: Tribune A)', border: OutlineInputBorder())),
          const SizedBox(height: 8),
          TextField(controller: placesCtrl, decoration: const InputDecoration(labelText: 'Nombre de places', border: OutlineInputBorder()), keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          TextField(controller: prixCtrl, decoration: const InputDecoration(labelText: 'Prix', border: OutlineInputBorder()), keyboardType: TextInputType.number),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(onPressed: () {
            if (typeCtrl.text.isEmpty) return;
            final b = (_config['blocs'] as List<dynamic>?) ?? [];
            b.add({'type': typeCtrl.text, 'places': int.tryParse(placesCtrl.text) ?? 0, 'prix': double.tryParse(prixCtrl.text) ?? 0.0});
            _config['blocs'] = b;
            Navigator.pop(ctx);
            setState(() {});
          }, child: const Text('Ajouter')),
        ],
      ),
    );
  }

  void _showEditBlockDialog(int index, Map<String, dynamic> block) {
    final typeCtrl = TextEditingController(text: block['type']);
    final placesCtrl = TextEditingController(text: block['places'].toString());
    final prixCtrl = TextEditingController(text: block['prix'].toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Modifier bloc ${index + 1}'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: typeCtrl, decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder())),
          const SizedBox(height: 8),
          TextField(controller: placesCtrl, decoration: const InputDecoration(labelText: 'Nombre de places', border: OutlineInputBorder()), keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          TextField(controller: prixCtrl, decoration: const InputDecoration(labelText: 'Prix', border: OutlineInputBorder()), keyboardType: TextInputType.number),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(onPressed: () {
            if (typeCtrl.text.isEmpty) return;
            final b = List<Map<String, dynamic>>.from((_config['blocs'] as List<dynamic>?) ?? []);
            b[index] = {'type': typeCtrl.text, 'places': int.tryParse(placesCtrl.text) ?? 0, 'prix': double.tryParse(prixCtrl.text) ?? 0.0};
            _config['blocs'] = b;
            Navigator.pop(ctx);
            setState(() {});
          }, child: const Text('Enregistrer')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    Widget content;
    switch (widget.categorie.codeCategorie) {
      case 'CINEMA':
        content = _buildCinemaConfig();
        break;
      case 'CONCERT':
        content = _buildConcertConfig();
        break;
      case 'SPORTS':
        content = _buildSportsConfig();
        break;
      default:
        content = const Center(child: Text('Aucune configuration spécifique disponible pour cette catégorie'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Configuration : ${widget.categorie.nomCategorie}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Divider(height: 24),
        Expanded(child: content),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.textSecondary),
              child: const Text('Fermer'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _saveConfig,
              child: const Text('Enregistrer'),
            ),
          ),
        ]),
      ]),
    );
  }
}
