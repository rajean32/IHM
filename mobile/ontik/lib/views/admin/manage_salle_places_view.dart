import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/providers.dart';
import '../../models/venue.dart';
import '../../widgets/error_state.dart';

class ManageSallePlacesView extends ConsumerStatefulWidget {
  final String? initialSalleFilter;
  const ManageSallePlacesView({super.key, this.initialSalleFilter});
  @override
  ConsumerState<ManageSallePlacesView> createState() => _ManageSallePlacesViewState();
}

class _ManageSallePlacesViewState extends ConsumerState<ManageSallePlacesView> {
  bool _loading = true;
  String? _error;
  List<Salle> _salles = [];
  List<Lieu> _lieux = [];
  List<Place> _places = [];
  int? _selectedLieuId;
  Salle? _selectedSalle;
  bool _bulkMode = false;
  final Set<String> _selectedPlaceIds = {};

  final _salleSearchCtrl = TextEditingController();
  final _placeSearchCtrl = TextEditingController();
  final _rangCtrl = TextEditingController();
  final _debutCtrl = TextEditingController(text: '1');
  final _finCtrl = TextEditingController(text: '10');
  final _batchFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _salleSearchCtrl.dispose();
    _placeSearchCtrl.dispose();
    _rangCtrl.dispose();
    _debutCtrl.dispose();
    _finCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final salles = await ref.read(salleRepositoryProvider).getAll();
      final lieux = await ref.read(lieuRepositoryProvider).getAll();
      final places = await ref.read(placeRepositoryProvider).getAll();
      if (!mounted) return;
      setState(() {
        _salles = salles; _lieux = lieux; _places = places;
        _loading = false; _error = null;
        if (widget.initialSalleFilter != null && _selectedSalle == null) {
          _selectedSalle = _salles.cast<Salle?>().firstWhere(
            (s) => s!.numeroSalle == widget.initialSalleFilter,
            orElse: () => null,
          );
          if (_selectedSalle != null) _selectedLieuId = _selectedSalle!.idLieu;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<Salle> get _filteredSalles {
    var list = _salles;
    if (_selectedLieuId != null) {
      list = list.where((s) => s.idLieu == _selectedLieuId).toList();
    }
    final q = _salleSearchCtrl.text.toLowerCase().trim();
    if (q.isNotEmpty) {
      list = list.where((s) =>
        s.nomSalle.toLowerCase().contains(q) ||
        s.numeroSalle.toLowerCase().contains(q)
      ).toList();
    }
    return list;
  }

  List<Place> get _placesForSelectedSalle {
    if (_selectedSalle == null) return [];
    var list = _places.where((p) => p.numeroSalle == _selectedSalle!.numeroSalle).toList();
    final q = _placeSearchCtrl.text.toLowerCase().trim();
    if (q.isNotEmpty) {
      list = list.where((p) => p.numeroPlace.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  int _placeCount(String salleNum) => _places.where((p) => p.numeroSalle == salleNum).length;

  Future<void> _addSalle(Map<String, dynamic> data) async {
    await ref.read(salleRepositoryProvider).create(Salle(
      numeroSalle: data['numeroSalle'].toString().trim(),
      nomSalle: data['nomSalle'].toString().trim(),
      idLieu: int.tryParse(data['idLieu'].toString()),
    ));
    _loadData();
  }

  Future<bool> _deleteSalle(String id) async {
    try {
      await ref.read(salleRepositoryProvider).delete(id);
      if (_selectedSalle?.numeroSalle == id) _selectedSalle = null;
      _loadData();
      return true;
    } catch (_) { return false; }
  }

  Future<void> _deletePlace(String id) async {
    try {
      await ref.read(placeRepositoryProvider).delete(id);
      _loadData();
    } catch (_) {}
  }

  Future<void> _bulkDeletePlaces() async {
    for (final id in _selectedPlaceIds) {
      await ref.read(placeRepositoryProvider).delete(id);
    }
    setState(() { _selectedPlaceIds.clear(); _bulkMode = false; });
    _loadData();
  }

  Future<void> _generateBatch() async {
    if (!_batchFormKey.currentState!.validate()) return;
    if (_selectedSalle == null) return;
    final rang = _rangCtrl.text.trim();
    final start = int.tryParse(_debutCtrl.text) ?? 1;
    final end = int.tryParse(_finCtrl.text) ?? 10;
    try {
      for (int i = start; i <= end; i++) {
        await ref.read(placeRepositoryProvider).create(Place(
          numeroPlace: '$rang-$i',
          rang: rang,
          numeroSalle: _selectedSalle!.numeroSalle,
        ));
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${end - start + 1} places générées'), backgroundColor: Colors.green),
        );
      }
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
      }
    }
  }

  void _editPlace(Place place) {
    final numCtrl = TextEditingController(text: place.numeroPlace);
    final rangCtrl = TextEditingController(text: place.rang ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Text('Modifier la place', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: numCtrl,
              decoration: const InputDecoration(labelText: 'Numéro de place', border: OutlineInputBorder()),
              validator: (v) => v == null || v.trim().isEmpty ? 'Requis' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: rangCtrl,
              decoration: const InputDecoration(labelText: 'Rang', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                try {
                  await ref.read(placeRepositoryProvider).delete(place.numeroPlace);
                  await ref.read(placeRepositoryProvider).create(Place(
                    numeroPlace: numCtrl.text.trim(),
                    rang: rangCtrl.text.trim().isEmpty ? null : rangCtrl.text.trim(),
                    typePlace: place.typePlace,
                    numeroSalle: place.numeroSalle,
                  ));
                  if (ctx.mounted) Navigator.pop(ctx);
                  _loadData();
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
                  }
                }
              },
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Enregistrer'),
            ),
            const SizedBox(height: 16),
          ]),
        ),
      ),
    );
  }

  void _showSalleForm({Salle? salle}) {
    final numCtrl = TextEditingController(text: salle?.numeroSalle ?? '');
    final nomCtrl = TextEditingController(text: salle?.nomSalle ?? '');
    int? lieuId = salle?.idLieu;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(salle != null ? 'Modifier la salle' : 'Ajouter une salle', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: numCtrl,
              decoration: const InputDecoration(labelText: 'Numéro', border: OutlineInputBorder()),
              validator: (v) => v == null || v.trim().isEmpty ? 'Requis' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: nomCtrl,
              decoration: const InputDecoration(labelText: 'Nom', border: OutlineInputBorder()),
              validator: (v) => v == null || v.trim().isEmpty ? 'Requis' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: lieuId,
              decoration: const InputDecoration(labelText: 'Lieu parent', border: OutlineInputBorder()),
              items: _lieux.map((l) => DropdownMenuItem(value: l.idLieu, child: Text(l.nomLieu))).toList(),
              onChanged: (v) => lieuId = v,
              validator: (v) => v == null ? 'Requis' : null,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final data = {'numeroSalle': numCtrl.text.trim(), 'nomSalle': nomCtrl.text.trim(), 'idLieu': lieuId?.toString() ?? ''};
                if (salle != null) {
                  await ref.read(salleRepositoryProvider).delete(salle.numeroSalle);
                }
                await _addSalle(data);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: Text(salle != null ? 'Enregistrer' : 'Ajouter'),
            ),
            const SizedBox(height: 16),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null) return Scaffold(body: ErrorState(message: _error!, onRetry: _loadData));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Salles & Places'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLieuFilter(),
            const SizedBox(height: 8),
            _buildSearchBar(_salleSearchCtrl, 'Rechercher une salle...', () => setState(() {})),
            const SizedBox(height: 8),
            _buildSallesSection(),
            if (_selectedSalle != null) ...[
              const Divider(height: 32),
              _buildPlacesSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(TextEditingController ctrl, String hint, VoidCallback onChanged) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: ctrl.text.isNotEmpty
            ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { ctrl.clear(); setState(() {}); })
            : null,
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildLieuFilter() {
    return DropdownButtonFormField<int>(
      value: _selectedLieuId,
      decoration: const InputDecoration(
        labelText: 'Filtrer par lieu',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.filter_alt),
        isDense: true,
      ),
      isExpanded: true,
      items: [
        const DropdownMenuItem<int>(value: null, child: Text('Tous les lieux')),
        ..._lieux.map((l) => DropdownMenuItem(value: l.idLieu, child: Text(l.nomLieu))),
      ],
      onChanged: (v) => setState(() {
        _selectedLieuId = v;
        _selectedSalle = null;
        _selectedPlaceIds.clear();
        _bulkMode = false;
      }),
    );
  }

  Widget _buildSallesSection() {
    final filtered = _filteredSalles;
    final lieuMap = {for (final l in _lieux) l.idLieu: l};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Salles (${filtered.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _showSalleForm(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Ajouter'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (filtered.isEmpty)
          _emptyState('Aucune salle trouvée', Icons.meeting_room)
        else
          ...filtered.map((s) => Card(
            margin: const EdgeInsets.only(bottom: 6),
            child: ListTile(
              dense: true,
              leading: CircleAvatar(
                backgroundColor: _selectedSalle?.numeroSalle == s.numeroSalle
                    ? Colors.indigo.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.1),
                child: Text(
                  _placeCount(s.numeroSalle).toString(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _selectedSalle?.numeroSalle == s.numeroSalle ? Colors.indigo : Colors.grey,
                  ),
                ),
              ),
              title: Text(s.nomSalle, style: const TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text('N° ${s.numeroSalle}  •  ${lieuMap[s.idLieu]?.nomLieu ?? '-'}'),
              selected: _selectedSalle?.numeroSalle == s.numeroSalle,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () => setState(() {
                      _selectedSalle = _selectedSalle?.numeroSalle == s.numeroSalle ? null : s;
                      _selectedPlaceIds.clear();
                      _bulkMode = false;
                      _placeSearchCtrl.clear();
                      _rangCtrl.clear();
                      _debutCtrl.text = '1';
                      _finCtrl.text = '10';
                    }),
                    child: Text(
                      _selectedSalle?.numeroSalle == s.numeroSalle ? 'Fermer' : 'Gérer les places',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _showSalleForm(salle: s)),
                  IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.red), onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Confirmer'),
                        content: Text('Supprimer la salle ${s.nomSalle} ?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    );
                    if (confirm == true) _deleteSalle(s.numeroSalle);
                  }),
                ],
              ),
            ),
          )),
      ],
    );
  }

  Widget _buildPlacesSection() {
    final places = _placesForSelectedSalle;
    final grouped = <String, List<Place>>{};
    for (final p in places) {
      grouped.putIfAbsent(p.rang ?? '-', () => []).add(p);
    }
    final sortedRangs = grouped.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Gestion des places pour la salle : ${_selectedSalle!.nomSalle}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            if (places.isNotEmpty)
              TextButton.icon(
                onPressed: () => setState(() {
                  _bulkMode = !_bulkMode;
                  if (!_bulkMode) _selectedPlaceIds.clear();
                }),
                icon: Icon(_bulkMode ? Icons.close : Icons.checklist, size: 18),
                label: Text(_bulkMode ? 'Annuler' : 'Sélection multiple', style: const TextStyle(fontSize: 12)),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Batch generation form (no type)
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Form(
              key: _batchFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Génération en masse', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _rangCtrl,
                    decoration: const InputDecoration(labelText: 'Rang', hintText: 'B', border: OutlineInputBorder(), isDense: true),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Requis' : null,
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: TextFormField(
                      controller: _debutCtrl,
                      decoration: const InputDecoration(labelText: 'N° début', border: OutlineInputBorder(), isDense: true),
                      keyboardType: TextInputType.number,
                    )),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('→')),
                    Expanded(child: TextFormField(
                      controller: _finCtrl,
                      decoration: const InputDecoration(labelText: 'N° fin', border: OutlineInputBorder(), isDense: true),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final d = int.tryParse(_debutCtrl.text);
                        final f = int.tryParse(v ?? '');
                        if (f == null) return 'Invalide';
                        if (d != null && f < d) return '> début';
                        return null;
                      },
                    )),
                  ]),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _generateBatch,
                      icon: const Icon(Icons.auto_awesome, size: 18),
                      label: const Text('Générer'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Search bar for places
        _buildSearchBar(_placeSearchCtrl, 'Rechercher une place...', () => setState(() {})),
        const SizedBox(height: 8),

        // Places badge grid
        if (places.isEmpty && _placeSearchCtrl.text.isEmpty)
          _emptyState('Aucune place pour cette salle', Icons.event_seat)
        else if (places.isEmpty)
          _emptyState('Aucune place ne correspond à votre recherche', Icons.search_off)
        else
          ...sortedRangs.map((rang) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Rang $rang', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const Spacer(),
                    if (_bulkMode)
                      TextButton(
                        onPressed: () {
                          final rangIds = grouped[rang]!.map((p) => p.numeroPlace).toList();
                          setState(() {
                            final allSelected = rangIds.every((id) => _selectedPlaceIds.contains(id));
                            if (allSelected) _selectedPlaceIds.removeAll(rangIds);
                            else _selectedPlaceIds.addAll(rangIds);
                          });
                        },
                        child: Text(
                          grouped[rang]!.every((p) => _selectedPlaceIds.contains(p.numeroPlace))
                              ? 'Désélectionner' : 'Sélectionner',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: grouped[rang]!.map((p) => _buildPlaceBadge(p)).toList(),
                ),
              ],
            ),
          )),

        if (_bulkMode && _selectedPlaceIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Suppression groupée'),
                      content: Text('Supprimer ${_selectedPlaceIds.length} place(s) ?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  );
                  if (confirm == true) _bulkDeletePlaces();
                },
                icon: const Icon(Icons.delete_sweep, size: 18),
                label: Text('Supprimer ${_selectedPlaceIds.length} place(s)'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  Widget _emptyState(String message, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: Colors.grey.withValues(alpha: 0.4)),
              const SizedBox(height: 12),
              Text(message, style: const TextStyle(color: Colors.grey, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceBadge(Place place) {
    final isSelected = _selectedPlaceIds.contains(place.numeroPlace);
    return GestureDetector(
      onLongPress: _bulkMode
          ? null
          : () => showMenu(
              context: context,
              position: RelativeRect.fromLTRB(100, 300, 100, 300),
              items: [
                const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit, size: 18), title: Text('Modifier'), dense: true)),
                const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete, size: 18, color: Colors.red), title: Text('Supprimer'), dense: true)),
              ],
            ).then((v) {
              if (v == 'edit') _editPlace(place);
              else if (v == 'delete') {
                showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Supprimer'),
                    content: Text('Supprimer la place ${place.numeroPlace} ?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                ).then((v) { if (v == true) _deletePlace(place.numeroPlace); });
              }
            }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.indigo.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.indigo : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_bulkMode) ...[
              GestureDetector(
                onTap: () => setState(() {
                  if (isSelected) _selectedPlaceIds.remove(place.numeroPlace);
                  else _selectedPlaceIds.add(place.numeroPlace);
                }),
                child: Icon(
                  isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                  size: 16,
                  color: isSelected ? Colors.indigo : Colors.grey,
                ),
              ),
              const SizedBox(width: 4),
            ],
            GestureDetector(
              onTap: _bulkMode
                  ? () => setState(() {
                      if (isSelected) _selectedPlaceIds.remove(place.numeroPlace);
                      else _selectedPlaceIds.add(place.numeroPlace);
                    })
                  : () => _editPlace(place),
              child: Text(place.numeroPlace, style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.indigo : Colors.black87,
              )),
            ),
            if (!_bulkMode) ...[
              const SizedBox(width: 4),
              InkWell(
                onTap: () {
                  showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Supprimer'),
                      content: Text('Supprimer la place ${place.numeroPlace} ?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  ).then((v) { if (v == true) _deletePlace(place.numeroPlace); });
                },
                child: const Icon(Icons.close, size: 16, color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
