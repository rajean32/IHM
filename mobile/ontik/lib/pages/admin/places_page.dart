import 'package:flutter/material.dart';
import '../../core/services/lieu_service.dart';
import '../../core/services/place_service.dart';
import '../../core/api/dio_config.dart';
import '../../core/api/endpoints.dart';
import '../../core/utils/error_helper.dart';
import '../../core/assets/app_colors.dart';
import '../../models/lieu_model.dart';
import '../../widgets/error_state.dart';
import '../../localization/app_localizations.dart';

class PlacesPage extends StatefulWidget {
  final String? initialSalleFilter;
  const PlacesPage({super.key, this.initialSalleFilter});
  @override
  State<PlacesPage> createState() => _PlacesPageState();
}

class _PlacesPageState extends State<PlacesPage> {
  bool _loading = true;
  String? _error;
  List<Salle> _salles = [];
  List<Lieu> _lieux = [];
  List<Place> _places = [];
  String? _selectedLieuCode;
  Salle? _selectedSalle;
  bool _bulkMode = false;
  final Set<String> _selectedPlaceIds = {};

  final _salleSearchCtrl = TextEditingController();
  final _placeSearchCtrl = TextEditingController();
  final _rangCtrl = TextEditingController();
  final _debutCtrl = TextEditingController(text: '1');
  final _finCtrl = TextEditingController(text: '10');
  final _batchFormKey = GlobalKey<FormState>();

  final _lieuService = LieuService();
  final _placeService = PlaceService();

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
      final sallesData = await _lieuService.getSalles();
      final lieuxData = await _lieuService.getLieux();
      final placesResp = await dio.get(Endpoints.places);
      final placesData = (placesResp.data['data'] as List?) ?? [];
      if (!mounted) return;
      setState(() {
        _salles = sallesData.map((e) => Salle.fromJson(e as Map<String, dynamic>)).toList();
        _lieux = lieuxData.map((e) => Lieu.fromJson(e as Map<String, dynamic>)).toList();
        _places = placesData.map((e) => Place.fromJson(e as Map<String, dynamic>)).toList();
        _loading = false;
        _error = null;
        if (widget.initialSalleFilter != null && _selectedSalle == null) {
          _selectedSalle = _salles.cast<Salle?>().firstWhere(
            (s) => s!.numeroSalle == widget.initialSalleFilter,
            orElse: () => null,
          );
          if (_selectedSalle != null) _selectedLieuCode = _selectedSalle!.codeLieu;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = apiErrorString(e); _loading = false; });
    }
  }

  List<Salle> get _filteredSalles {
    var list = _salles;
    if (_selectedLieuCode != null) {
      list = list.where((s) => s.codeLieu == _selectedLieuCode).toList();
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

  Future<bool> _deleteSalle(String id) async {
    try {
      await dio.delete('${Endpoints.salles}/$id');
      if (_selectedSalle?.numeroSalle == id) _selectedSalle = null;
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('admin.places.roomDeleted')), backgroundColor: AppColors.secondary),
      );
      _loadData();
      return true;
    } catch (_) { return false; }
  }

  Future<void> _deletePlace(String id) async {
    try {
      await _placeService.deletePlace(id);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('admin.places.placeDeleted')), backgroundColor: AppColors.secondary),
      );
      _loadData();
    } catch (_) {}
  }

  Future<void> _bulkDeletePlaces() async {
    final count = _selectedPlaceIds.length;
    for (final id in _selectedPlaceIds) {
      await _placeService.deletePlace(id);
    }
    setState(() { _selectedPlaceIds.clear(); _bulkMode = false; });
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$count ${tr('admin.places.placesDeleted')}'), backgroundColor: AppColors.secondary),
    );
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
        await _placeService.createPlace({
          'numeroPlace': '$rang-$i',
          'range': rang,
          'numeroSalle': _selectedSalle!.numeroSalle,
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${end - start + 1} ${tr('admin.places.generated')}'), backgroundColor: AppColors.secondary),
        );
      }
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(apiErrorString(e)), backgroundColor: AppColors.error));
      }
    }
  }

  void _editPlace(Place place) {
    final numCtrl = TextEditingController(text: place.numeroPlace);
    final rangCtrl = TextEditingController(text: place.range ?? '');
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
            Text(tr('admin.places.editPlace'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: numCtrl,
              decoration: InputDecoration(labelText: tr('admin.places.placeNumber'), border: const OutlineInputBorder()),
              validator: (v) => v == null || v.trim().isEmpty ? tr('admin.places.required') : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: rangCtrl,
              decoration: InputDecoration(labelText: tr('admin.places.row'), border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                try {
                  await _placeService.deletePlace(place.numeroPlace);
                  await _placeService.createPlace({
                    'numeroPlace': numCtrl.text.trim(),
                    'range': rangCtrl.text.trim().isEmpty ? null : rangCtrl.text.trim(),
                    'typePlace': place.typePlace,
                    'numeroSalle': place.numeroSalle,
                  });
                  if (ctx.mounted) Navigator.pop(ctx);
                  _loadData();
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(apiErrorString(e)), backgroundColor: AppColors.error));
                  }
                }
              },
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: Text(tr('common.save')),
            ),
            const SizedBox(height: 16),
          ]),
        ),
      ),
    );
  }

  void _showSalleForm({Salle? salle}) {
    final nomCtrl = TextEditingController(text: salle?.nomSalle ?? '');
    String? lieuCode = salle?.codeLieu;
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
            Text(salle != null ? tr('admin.places.editRoom') : tr('admin.places.addRoom'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: nomCtrl,
              decoration: InputDecoration(labelText: tr('admin.places.name'), border: const OutlineInputBorder()),
              validator: (v) => v == null || v.trim().isEmpty ? tr('admin.places.required') : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: lieuCode,
              decoration: InputDecoration(labelText: tr('admin.places.parentVenue'), border: const OutlineInputBorder()),
              items: _lieux.map((l) => DropdownMenuItem(value: l.code, child: Text(l.nomLieu))).toList(),
              onChanged: (v) => lieuCode = v,
              validator: (v) => v == null ? tr('admin.places.required') : null,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final data = {'nomSalle': nomCtrl.text.trim(), 'codeLieu': lieuCode};
                if (salle != null) {
                  await dio.delete('${Endpoints.salles}/${salle.numeroSalle}');
                }
                await dio.post(Endpoints.salles, data: data);
                if (ctx.mounted) Navigator.pop(ctx);
                _loadData();
              },
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: Text(salle != null ? tr('common.save') : tr('common.add')),
            ),
            const SizedBox(height: 16),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return ErrorState(message: _error!, onRetry: _loadData);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(tr('admin.places.title'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          ]),
          const SizedBox(height: 8),
          _buildLieuFilter(),
          const SizedBox(height: 8),
          _buildSearchBar(_salleSearchCtrl, tr('admin.places.searchRoom'), () => setState(() {})),
          const SizedBox(height: 8),
          _buildSallesSection(),
          if (_selectedSalle != null) ...[
            const Divider(height: 32),
            _buildPlacesSection(),
          ],
        ],
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
    return DropdownButtonFormField<String>(
      value: _selectedLieuCode,
      decoration: InputDecoration(
        labelText: tr('admin.places.filterByVenue'),
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.filter_alt),
        isDense: true,
      ),
      isExpanded: true,
      items: [
        DropdownMenuItem<String>(value: null, child: Text(tr('admin.places.allVenues'))),
        ..._lieux.map((l) => DropdownMenuItem(value: l.code, child: Text(l.nomLieu))),
      ],
      onChanged: (v) => setState(() {
        _selectedLieuCode = v;
        _selectedSalle = null;
        _selectedPlaceIds.clear();
        _bulkMode = false;
      }),
    );
  }

  Widget _buildSallesSection() {
    final filtered = _filteredSalles;
    final lieuMap = {for (final l in _lieux) l.code: l};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('${tr('admin.places.rooms')} (${filtered.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _showSalleForm(),
              icon: const Icon(Icons.add, size: 18),
              label: Text(tr('common.add')),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (filtered.isEmpty)
          _emptyState(tr('admin.places.noRooms'), Icons.meeting_room)
        else
          ...filtered.map((s) => Card(
            margin: const EdgeInsets.only(bottom: 6),
            child: ListTile(
              dense: true,
              leading: CircleAvatar(
                backgroundColor: _selectedSalle?.numeroSalle == s.numeroSalle
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.textSecondary.withValues(alpha: 0.1),
                child: Text(
                  _placeCount(s.numeroSalle).toString(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _selectedSalle?.numeroSalle == s.numeroSalle ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ),
              title: Text(s.nomSalle, style: const TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text('${lieuMap[s.codeLieu]?.nomLieu ?? '-'}  •  ${_placeCount(s.numeroSalle)} ${tr('admin.places.places')}'),
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
                      _selectedSalle?.numeroSalle == s.numeroSalle ? tr('admin.places.close') : tr('admin.places.managePlaces'),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _showSalleForm(salle: s)),
                  IconButton(icon: const Icon(Icons.delete, size: 18, color: AppColors.error), onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(tr('common.confirm')),
                        content: Text('${tr('admin.places.deleteRoom')} ${s.nomSalle} ?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr('common.cancel'))),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(tr('common.delete'), style: const TextStyle(color: AppColors.error))),
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
      grouped.putIfAbsent(p.range ?? '-', () => []).add(p);
    }
    final sortedRangs = grouped.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${tr('admin.places.manageForRoom')} ${_selectedSalle!.nomSalle}',
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
                label: Text(_bulkMode ? tr('common.cancel') : tr('admin.places.multiSelect'), style: const TextStyle(fontSize: 12)),
              ),
          ],
        ),
        const SizedBox(height: 8),

        Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Form(
              key: _batchFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr('admin.places.batchGenerate'), style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _rangCtrl,
                    decoration: InputDecoration(labelText: tr('admin.places.row'), hintText: tr('admin.places.rowHint'), border: const OutlineInputBorder(), isDense: true),
                    validator: (v) => v == null || v.trim().isEmpty ? tr('admin.places.required') : null,
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: TextFormField(
                      controller: _debutCtrl,
                      decoration: InputDecoration(labelText: tr('admin.places.startNum'), border: const OutlineInputBorder(), isDense: true),
                      keyboardType: TextInputType.number,
                    )),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('→')),
                    Expanded(child: TextFormField(
                      controller: _finCtrl,
                      decoration: InputDecoration(labelText: tr('admin.places.endNum'), border: const OutlineInputBorder(), isDense: true),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final d = int.tryParse(_debutCtrl.text);
                        final f = int.tryParse(v ?? '');
                        if (f == null) return tr('admin.places.invalid');
                        if (d != null && f < d) return '> ${tr('admin.places.startNum')}';
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
                      label: Text(tr('admin.places.generate')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        _buildSearchBar(_placeSearchCtrl, tr('admin.places.searchPlace'), () => setState(() {})),
        const SizedBox(height: 8),

        if (places.isEmpty && _placeSearchCtrl.text.isEmpty)
          _emptyState(tr('admin.places.noPlaces'), Icons.event_seat)
        else if (places.isEmpty)
          _emptyState(tr('admin.places.noSearchResults'), Icons.search_off)
        else
          ...sortedRangs.map((rang) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('${tr('admin.places.row')} $rang', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
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
                              ? tr('admin.places.deselect') : tr('admin.places.select'),
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
                      title: Text(tr('admin.places.bulkDelete')),
                      content: Text('${tr('admin.places.bulkDeleteConfirm')} ${_selectedPlaceIds.length} ${tr('admin.places.places')} ?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr('common.cancel'))),
                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(tr('common.delete'), style: const TextStyle(color: AppColors.error))),
                      ],
                    ),
                  );
                  if (confirm == true) _bulkDeletePlaces();
                },
                icon: const Icon(Icons.delete_sweep, size: 18),
                label: Text('${tr('common.delete')} ${_selectedPlaceIds.length} ${tr('admin.places.places')}'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
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
              Icon(icon, size: 48, color: AppColors.textSecondary.withValues(alpha: 0.4)),
              const SizedBox(height: 12),
              Text(message, style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
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
                PopupMenuItem(value: 'edit', child: ListTile(leading: const Icon(Icons.edit, size: 18), title: Text(tr('common.edit')), dense: true)),
                PopupMenuItem(value: 'delete', child: ListTile(leading: const Icon(Icons.delete, size: 18, color: AppColors.error), title: Text(tr('common.delete')), dense: true)),
              ],
            ).then((v) {
              if (v == 'edit') _editPlace(place);
              else if (v == 'delete') {
                showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(tr('common.delete')),
                    content: Text('${tr('admin.places.deletePlaceConfirm')} ${place.numeroPlace} ?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr('common.cancel'))),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(tr('common.delete'), style: const TextStyle(color: AppColors.error))),
                    ],
                  ),
                ).then((v) { if (v == true) _deletePlace(place.numeroPlace); });
              }
            }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.textSecondary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.textSecondary.withValues(alpha: 0.3),
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
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
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
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              )),
            ),
            if (!_bulkMode) ...[
              const SizedBox(width: 4),
              InkWell(
                onTap: () {
                  showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(tr('common.delete')),
                      content: Text('${tr('admin.places.deletePlaceConfirm')} ${place.numeroPlace} ?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr('common.cancel'))),
                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(tr('common.delete'), style: const TextStyle(color: AppColors.error))),
                      ],
                    ),
                  ).then((v) { if (v == true) _deletePlace(place.numeroPlace); });
                },
                child: const Icon(Icons.close, size: 16, color: AppColors.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
