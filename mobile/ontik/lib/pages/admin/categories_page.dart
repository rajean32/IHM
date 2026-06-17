import 'package:flutter/material.dart';
import '../../core/services/categorie_service.dart';
import '../../core/services/caracteristique_service.dart';
import '../../core/services/lieu_service.dart';
import '../../models/categorie_model.dart';
import '../../models/caracteristique_model.dart';
import '../../core/utils/error_helper.dart';
import '../../core/assets/app_colors.dart';
import '../../localization/app_localizations.dart';

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
        title: Text(tr('admin.categories.add')),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: codeCtrl, decoration: InputDecoration(labelText: tr('admin.categories.code'), border: const OutlineInputBorder(), hintText: tr('admin.categories.codeHint')), maxLength: 10),
            const SizedBox(height: 8),
            TextField(controller: nomCtrl, decoration: InputDecoration(labelText: tr('admin.categories.name'), border: const OutlineInputBorder()), maxLength: 100),
            const SizedBox(height: 8),
            TextField(controller: descCtrl, decoration: InputDecoration(labelText: tr('admin.categories.description'), border: const OutlineInputBorder()), maxLength: 500, maxLines: 3),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('common.cancel'))),
          ElevatedButton(onPressed: () async {
            if (codeCtrl.text.isEmpty || nomCtrl.text.isEmpty) return;
            await _api.createCategory({
              'codeCategorie': codeCtrl.text,
              'nomCategorie': nomCtrl.text,
              'description': descCtrl.text.isEmpty ? null : descCtrl.text,
            });
            if (ctx.mounted) Navigator.pop(ctx);
            _loadData();
          }, child: Text(tr('common.add'))),
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
        title: Text(tr('admin.categories.edit')),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: codeCtrl, decoration: InputDecoration(labelText: tr('admin.categories.code'), border: const OutlineInputBorder()), maxLength: 10, enabled: false),
            const SizedBox(height: 8),
            TextField(controller: nomCtrl, decoration: InputDecoration(labelText: tr('admin.categories.name'), border: const OutlineInputBorder()), maxLength: 100),
            const SizedBox(height: 8),
            TextField(controller: descCtrl, decoration: InputDecoration(labelText: tr('admin.categories.description'), border: const OutlineInputBorder()), maxLength: 500, maxLines: 3),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('common.cancel'))),
          ElevatedButton(onPressed: () async {
            if (nomCtrl.text.isEmpty) return;
            await _api.updateCategory(cat.codeCategorie, {
              'codeCategorie': codeCtrl.text,
              'nomCategorie': nomCtrl.text,
              'description': descCtrl.text.isEmpty ? null : descCtrl.text,
            });
            if (ctx.mounted) Navigator.pop(ctx);
            _loadData();
          }, child: Text(tr('common.edit'))),
        ],
      ),
    );
  }

  Future<void> _openDeleteDialog(Categorie cat) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('admin.categories.deleteTitle')),
        content: Text('${tr('admin.categories.deleteTitle')} "${cat.nomCategorie}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr('common.cancel'))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: Text(tr('common.delete'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _api.deleteCategory(cat.codeCategorie);
      _loadData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('admin.categories.deleted'))));
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: ModalRoute.of(context)?.canPop == true
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(tr('admin.categories')),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _categories.isEmpty
                  ? Center(child: Text(tr('admin.categories.empty')))
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
                                      PopupMenuItem(value: 'edit', child: ListTile(leading: const Icon(Icons.edit, size: 18), title: Text(tr('common.edit'), style: const TextStyle(fontSize: 13)))),
                                      PopupMenuItem(value: 'delete', child: ListTile(leading: const Icon(Icons.delete, size: 18, color: AppTheme.errorColor), title: Text(tr('common.delete'), style: const TextStyle(fontSize: 13, color: AppTheme.errorColor)))),
                                    ],
                                  ),
                                ]),
                                const SizedBox(height: 8),
                                Row(children: [
                                  _actionChip(Icons.list_alt, tr('admin.categories.features'), () => _showManageCaracteristiques(c)),
                                  const SizedBox(width: 4),
                                  _actionChip(Icons.meeting_room, tr('admin.categories.rooms'), () => _showManageSalleTypes(c)),
                                  const SizedBox(width: 4),
                                  _actionChip(Icons.settings, tr('admin.categories.config'), () => _showManageSpecificConfig(c)),
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
          title: Text(existing != null ? tr('admin.categories.editFeature') : tr('admin.categories.addFeature')),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: nomCtrl, decoration: InputDecoration(labelText: tr('admin.categories.featureName'), border: const OutlineInputBorder())),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: typeDonnee,
                decoration: InputDecoration(labelText: tr('admin.categories.dataType'), border: const OutlineInputBorder()),
                items: [
                  DropdownMenuItem(value: 'text', child: Text(tr('admin.categories.dataTypeText'))),
                  DropdownMenuItem(value: 'number', child: Text(tr('admin.categories.dataTypeNumber'))),
                  DropdownMenuItem(value: 'date', child: Text(tr('admin.categories.dataTypeDate'))),
                  DropdownMenuItem(value: 'select', child: Text(tr('admin.categories.dataTypeSelect'))),
                  DropdownMenuItem(value: 'boolean', child: Text(tr('admin.categories.dataTypeBoolean'))),
                ],
                onChanged: (v) => setDState(() => typeDonnee = v ?? 'text'),
              ),
              const SizedBox(height: 8),
              TextField(controller: ordreCtrl, decoration: InputDecoration(labelText: tr('admin.categories.displayOrder'), border: const OutlineInputBorder()), keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              if (typeDonnee == 'select')
                TextField(controller: optionsCtrl, decoration: InputDecoration(labelText: tr('admin.categories.optionsHint'), border: const OutlineInputBorder())),
              const SizedBox(height: 8),
              SwitchListTile(title: Text(tr('admin.categories.required')), value: obligatoire, onChanged: (v) => setDState(() => obligatoire = v)),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('common.cancel'))),
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
            }, child: Text(existing != null ? tr('common.save') : tr('common.add'))),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(Caracteristique c) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('common.confirm')),
        content: Text('${tr('admin.categories.deleteFeature')} "${c.nom}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr('common.cancel'))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(tr('common.delete'), style: const TextStyle(color: AppTheme.errorColor))),
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: ModalRoute.of(context)?.canPop == true
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text('${tr('admin.categories.featuresTitle')} ${widget.categorie.nomCategorie}'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(child: Text(tr('admin.categories.noFeatures')))
              : ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (ctx, i) {
                    final c = _items[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      child: ListTile(
                        title: Text('${c.nom}${c.obligatoire ? ' *' : ''}', style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text('${tr('admin.categories.typeLabel')} ${c.typeDonnee}${c.options != null ? ' (${c.options})' : ''} • ${tr('admin.categories.orderLabel')} ${c.ordreAffichage ?? 0}'),
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
            Text(tr('admin.categories.compatibleRoomTypes'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
          ]),
          const Divider(),
          Text('${tr('admin.categories.selectRooms')} "${widget.categorie.nomCategorie}"',
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
            child: Text(tr('common.save')),
          ),
        ]),
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
        SnackBar(content: Text(tr('admin.categories.configSaved'))),
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
        Text(tr('admin.categories.cinemaConfig'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(controller: rows, decoration: InputDecoration(labelText: tr('admin.categories.numRows'), border: const OutlineInputBorder()), keyboardType: TextInputType.number,
          onChanged: (v) => _config['nbRangees'] = int.tryParse(v)),
        const SizedBox(height: 8),
        TextField(controller: seatsPerRow, decoration: InputDecoration(labelText: tr('admin.categories.seatsPerRow'), border: const OutlineInputBorder()), keyboardType: TextInputType.number,
          onChanged: (v) => _config['placesParRangee'] = int.tryParse(v)),
        const SizedBox(height: 8),
        TextField(controller: allees, decoration: InputDecoration(labelText: tr('admin.categories.aisles'), border: const OutlineInputBorder()),
          onChanged: (v) => _config['allees'] = v),
        const SizedBox(height: 8),
        TextField(controller: largeur, decoration: InputDecoration(labelText: tr('admin.categories.aisleWidth'), border: const OutlineInputBorder()), keyboardType: TextInputType.number,
          onChanged: (v) => _config['largeurAllee'] = double.tryParse(v)),
      ]),
    );
  }

  Widget _buildConcertConfig() {
    final zones = (_config['zones'] as List<dynamic>?)?.cast<Map<String, dynamic>>().toList() ?? [];

    return Column(children: [
      Row(children: [
        Text(tr('admin.categories.freeZones'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const Spacer(),
        IconButton(icon: const Icon(Icons.add), onPressed: () => _showAddZoneDialog()),
      ]),
      const SizedBox(height: 8),
      if (zones.isEmpty)
        Text(tr('admin.categories.noZones'), style: const TextStyle(color: AppTheme.textSecondary))
      else
        Expanded(
          child: ListView.builder(
            itemCount: zones.length,
            itemBuilder: (ctx, i) {
              final zone = zones[i];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text('${zone['nom'] ?? '${tr('admin.categories.zone')} ${i + 1}'}'),
                  subtitle: Text('${tr('admin.categories.capacity')} ${zone['capacite']} • ${tr('admin.categories.price')} ${zone['prix']}'),
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
        title: Text(tr('admin.categories.addZone')),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nomCtrl, decoration: InputDecoration(labelText: tr('admin.categories.name'), border: const OutlineInputBorder())),
          const SizedBox(height: 8),
          TextField(controller: capaciteCtrl, decoration: InputDecoration(labelText: tr('admin.categories.maxCapacity'), border: const OutlineInputBorder()), keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          TextField(controller: prixCtrl, decoration: InputDecoration(labelText: tr('admin.categories.ticketPrice'), border: const OutlineInputBorder()), keyboardType: TextInputType.number),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('common.cancel'))),
          ElevatedButton(onPressed: () {
            if (nomCtrl.text.isEmpty) return;
            final z = (_config['zones'] as List<dynamic>?) ?? [];
            z.add({'nom': nomCtrl.text, 'capacite': int.tryParse(capaciteCtrl.text) ?? 0, 'prix': double.tryParse(prixCtrl.text) ?? 0.0});
            _config['zones'] = z;
            Navigator.pop(ctx);
            setState(() {});
          }, child: Text(tr('common.add'))),
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
        title: Text('${tr('admin.categories.editZone')} ${index + 1}'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nomCtrl, decoration: InputDecoration(labelText: tr('admin.categories.name'), border: const OutlineInputBorder())),
          const SizedBox(height: 8),
          TextField(controller: capaciteCtrl, decoration: InputDecoration(labelText: tr('admin.categories.maxCapacity'), border: const OutlineInputBorder()), keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          TextField(controller: prixCtrl, decoration: InputDecoration(labelText: tr('admin.categories.ticketPrice'), border: const OutlineInputBorder()), keyboardType: TextInputType.number),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('common.cancel'))),
          ElevatedButton(onPressed: () {
            if (nomCtrl.text.isEmpty) return;
            final z = List<Map<String, dynamic>>.from((_config['zones'] as List<dynamic>?) ?? []);
            z[index] = {'nom': nomCtrl.text, 'capacite': int.tryParse(capaciteCtrl.text) ?? 0, 'prix': double.tryParse(prixCtrl.text) ?? 0.0};
            _config['zones'] = z;
            Navigator.pop(ctx);
            setState(() {});
          }, child: Text(tr('common.save'))),
        ],
      ),
    );
  }

  Widget _buildSportsConfig() {
    final blocs = (_config['blocs'] as List<dynamic>?)?.cast<Map<String, dynamic>>().toList() ?? [];

    return Column(children: [
      Row(children: [
        Text(tr('admin.categories.stands'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const Spacer(),
        IconButton(icon: const Icon(Icons.add), onPressed: () => _showAddBlockDialog()),
      ]),
      const SizedBox(height: 8),
      if (blocs.isEmpty)
        Text(tr('admin.categories.noBlocks'), style: const TextStyle(color: AppTheme.textSecondary))
      else
        Expanded(
          child: ListView.builder(
            itemCount: blocs.length,
            itemBuilder: (ctx, i) {
              final block = blocs[i];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text('${block['type'] ?? '${tr('admin.categories.block')} ${i + 1}'}'),
                  subtitle: Text('${tr('admin.categories.seats')} ${block['places']} • ${tr('admin.categories.price')} ${block['prix']}'),
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
        title: Text(tr('admin.categories.addBlock')),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: typeCtrl, decoration: InputDecoration(labelText: tr('admin.categories.blockType'), border: const OutlineInputBorder())),
          const SizedBox(height: 8),
          TextField(controller: placesCtrl, decoration: InputDecoration(labelText: tr('admin.categories.numSeats'), border: const OutlineInputBorder()), keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          TextField(controller: prixCtrl, decoration: InputDecoration(labelText: tr('admin.categories.price'), border: const OutlineInputBorder()), keyboardType: TextInputType.number),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('common.cancel'))),
          ElevatedButton(onPressed: () {
            if (typeCtrl.text.isEmpty) return;
            final b = (_config['blocs'] as List<dynamic>?) ?? [];
            b.add({'type': typeCtrl.text, 'places': int.tryParse(placesCtrl.text) ?? 0, 'prix': double.tryParse(prixCtrl.text) ?? 0.0});
            _config['blocs'] = b;
            Navigator.pop(ctx);
            setState(() {});
          }, child: Text(tr('common.add'))),
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
        title: Text('${tr('admin.categories.editBlock')} ${index + 1}'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: typeCtrl, decoration: InputDecoration(labelText: tr('admin.categories.type'), border: const OutlineInputBorder())),
          const SizedBox(height: 8),
          TextField(controller: placesCtrl, decoration: InputDecoration(labelText: tr('admin.categories.numSeats'), border: const OutlineInputBorder()), keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          TextField(controller: prixCtrl, decoration: InputDecoration(labelText: tr('admin.categories.price'), border: const OutlineInputBorder()), keyboardType: TextInputType.number),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('common.cancel'))),
          ElevatedButton(onPressed: () {
            if (typeCtrl.text.isEmpty) return;
            final b = List<Map<String, dynamic>>.from((_config['blocs'] as List<dynamic>?) ?? []);
            b[index] = {'type': typeCtrl.text, 'places': int.tryParse(placesCtrl.text) ?? 0, 'prix': double.tryParse(prixCtrl.text) ?? 0.0};
            _config['blocs'] = b;
            Navigator.pop(ctx);
            setState(() {});
          }, child: Text(tr('common.save'))),
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
        content = Center(child: Text(tr('admin.categories.noConfig')));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${tr('admin.categories.configFor')} ${widget.categorie.nomCategorie}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Divider(height: 24),
        Expanded(child: content),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.textSecondary),
              child: Text(tr('common.close')),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _saveConfig,
            child: Text(tr('common.save')),
            ),
          ),
        ]),
      ]),
    );
  }
}
