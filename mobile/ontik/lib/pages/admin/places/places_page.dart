import 'package:flutter/material.dart';
import 'package:ontik/core/services/lieu_service.dart';
import 'package:ontik/core/services/place_service.dart';
import 'package:ontik/models/lieu_model.dart';
import 'package:ontik/core/assets/app_colors.dart';
import 'package:ontik/core/utils/error_helper.dart';
import 'package:ontik/core/api/dio_config.dart';
import 'package:ontik/core/api/endpoints.dart';
import 'package:ontik/widgets/admin/admin_search_field.dart';
import 'package:ontik/widgets/admin/admin_empty_state.dart';
import 'package:ontik/widgets/admin/admin_error_state.dart';
import 'package:ontik/widgets/admin/admin_toast.dart';
import 'package:ontik/widgets/admin/admin_confirmation_dialog.dart';
import 'place_form_sheet.dart';
import 'batch_generation_card.dart';

class PlacesPage extends StatefulWidget {
  final String? initialSalleFilter;
  final VoidCallback? onBack;
  const PlacesPage({super.key, this.initialSalleFilter, this.onBack});

  @override
  State<PlacesPage> createState() => _PlacesPageState();
}

class _PlacesPageState extends State<PlacesPage> {
  final _lieuService = LieuService();
  final _placeService = PlaceService();
  final _salleSearchCtrl = TextEditingController();
  final _placeSearchCtrl = TextEditingController();
  bool _loading = true;
  String? _error;
  List<Lieu> _lieux = [];
  List<dynamic> _allSalles = [];
  List<Place> _places = [];
  String? _selectedLieuCode;
  Salle? _selectedSalle;
  String _salleSearch = '';
  String _placeSearch = '';
  bool _bulkMode = false;
  final Set<String> _selectedPlaceIds = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _salleSearchCtrl.dispose();
    _placeSearchCtrl.dispose();
    super.dispose();
  }

  List<dynamic> get _filteredSalles {
    var salles = _allSalles.where((s) => _selectedLieuCode == null || (s as Map<String, dynamic>)['codeLieu'] == _selectedLieuCode).toList();
    if (_salleSearch.isNotEmpty) {
      salles = salles.where((s) => (s as Map<String, dynamic>)['nomSalle'].toString().toLowerCase().contains(_salleSearch)).toList();
    }
    return salles;
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final lieuxData = await _lieuService.getLieux();
      final sallesData = await _lieuService.getSalles();
      if (!mounted) return;
      setState(() {
        _lieux = lieuxData.map((e) => Lieu.fromJson(e as Map<String, dynamic>)).toList();
        _allSalles = sallesData;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = apiErrorString(e); _loading = false; });
    }
  }

  Future<void> _loadPlaces() async {
    if (_selectedSalle == null) return;
    try {
      final data = await _placeService.getPlacesBySalle(_selectedSalle!.numeroSalle);
      if (!mounted) return;
      setState(() { _places = data.map((e) => Place.fromJson(e as Map<String, dynamic>)).toList(); });
    } catch (_) {}
  }

  String _lieuName(String code) => _lieux.where((l) => l.code == code).firstOrNull?.nomLieu ?? code;

  int _placeCount(String salleNum) => _places.where((p) => p.numeroSalle == salleNum).length;

  List<Place> get _filteredPlaces {
    var list = _places;
    if (_placeSearch.isNotEmpty) {
      list = list.where((p) => p.numeroPlace.toLowerCase().contains(_placeSearch.toLowerCase())).toList();
    }
    return list;
  }

  Map<String, List<Place>> get _placesByRang {
    final map = <String, List<Place>>{};
    for (final p in _filteredPlaces) {
      final rang = p.range ?? '?';
      map.putIfAbsent(rang, () => []);
      map[rang]!.add(p);
    }
    return map;
  }

  Future<void> _generateBatch(String rang, int debut, int fin) async {
    if (_selectedSalle == null) return;
    try {
      for (int i = debut; i <= fin; i++) {
        await dio.post(Endpoints.places, data: {
          'numeroPlace': '$rang-$i',
          'rang': rang,
          'numeroSalle': _selectedSalle!.numeroSalle,
        });
      }
      if (!mounted) return;
      AdminToast.show(context, message: 'Places générées', isSuccess: true);
      _loadPlaces();
    } catch (e) {
      if (!mounted) return;
      AdminToast.show(context, message: apiErrorString(e), isSuccess: false);
    }
  }

  Future<void> _deletePlace(String numeroPlace) async {
    try {
      await _placeService.deletePlace(numeroPlace);
      if (!mounted) return;
      AdminToast.show(context, message: 'Place supprimée', isSuccess: true);
      _loadPlaces();
    } catch (e) {
      if (!mounted) return;
      AdminToast.show(context, message: apiErrorString(e), isSuccess: false);
    }
  }

  Future<void> _bulkDelete() async {
    if (_selectedPlaceIds.isEmpty) return;
    final confirm = await AdminConfirmationDialog.show(context, title: 'Suppression groupée', message: 'Supprimer ${_selectedPlaceIds.length} place(s) ?');
    if (confirm != true) return;
    try {
      for (final id in _selectedPlaceIds) {
        await _placeService.deletePlace(id);
      }
      if (!mounted) return;
      AdminToast.show(context, message: '${_selectedPlaceIds.length} place(s) supprimée(s)', isSuccess: true);
      setState(() { _selectedPlaceIds.clear(); _bulkMode = false; });
      _loadPlaces();
    } catch (e) {
      if (!mounted) return;
      AdminToast.show(context, message: apiErrorString(e), isSuccess: false);
    }
  }

  Future<void> _editPlace(Place place) async {
    final result = await PlaceFormSheet.show(context, place: place);
    if (result == null) return;
    try {
      await _placeService.deletePlace(place.numeroPlace);
      await _placeService.createPlace(result);
      if (!mounted) return;
      AdminToast.show(context, message: 'Place modifiée', isSuccess: true);
      _loadPlaces();
    } catch (e) {
      if (!mounted) return;
      AdminToast.show(context, message: apiErrorString(e), isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                if (widget.onBack != null)
                  IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack),
                const Text('Salles & Places', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.refresh, size: 20), onPressed: _load),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: AdminSearchField(
                    hintText: 'Rechercher une salle...',
                    controller: _salleSearchCtrl,
                    onChanged: (v) => setState(() => _salleSearch = v.toLowerCase()),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedLieuCode,
                  hint: const Text('Tous', style: TextStyle(fontSize: 13)),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Tous les lieux', style: TextStyle(fontSize: 13))),
                    ..._lieux.map((l) => DropdownMenuItem(value: l.code, child: Text(l.nomLieu, style: TextStyle(fontSize: 13)))),
                  ],
                  onChanged: (v) => setState(() => _selectedLieuCode = v),
                ),
              ],
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return AdminErrorState(message: _error!, onRetry: _load);

    return Column(
      children: [
        Expanded(
          flex: 2,
          child: _buildSallesSection(),
        ),
        if (_selectedSalle != null)
          Expanded(
            flex: 3,
            child: _buildPlacesSection(),
          ),
      ],
    );
  }

  Widget _buildSallesSection() {
    final salles = _filteredSalles;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('Salles (${salles.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: salles.isEmpty
              ? const AdminEmptyState(icon: Icons.meeting_room, message: 'Aucune salle trouvée')
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: salles.length,
                  itemBuilder: (ctx, i) {
                    final s = Salle.fromJson(salles[i] as Map<String, dynamic>);
                    final isSelected = _selectedSalle?.numeroSalle == s.numeroSalle;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 4),
                      child: ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          backgroundColor: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.textSecondary.withValues(alpha: 0.1),
                          child: Text('${_placeCount(s.numeroSalle)}', style: TextStyle(fontSize: 11, color: isSelected ? AppColors.primary : AppColors.textSecondary)),
                        ),
                        title: Text(s.nomSalle, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                        subtitle: Text('${_lieuName(s.codeLieu ?? '')}  •  ${_placeCount(s.numeroSalle)} place(s)', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () => setState(() { _selectedSalle = isSelected ? null : s; _selectedPlaceIds.clear(); _bulkMode = false; if (s == _selectedSalle) _loadPlaces(); }),
                              child: Text(isSelected ? 'Fermer' : 'Gérer', style: const TextStyle(fontSize: 11)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPlacesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Text('Places — ${_selectedSalle!.nomSalle}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton.icon(
                onPressed: () => setState(() { _bulkMode = !_bulkMode; _selectedPlaceIds.clear(); }),
                icon: Icon(_bulkMode ? Icons.close : Icons.checklist, size: 18),
                label: Text(_bulkMode ? 'Annuler' : 'Sélection', style: const TextStyle(fontSize: 11)),
              ),
            ],
          ),
        ),
        BatchGenerationCard(onGenerate: _generateBatch),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: AdminSearchField(
            hintText: 'Rechercher une place...',
            controller: _placeSearchCtrl,
            onChanged: (v) => setState(() => _placeSearch = v.toLowerCase()),
          ),
        ),
        Expanded(
          child: _filteredPlaces.isEmpty
              ? const AdminEmptyState(icon: Icons.event_seat, message: 'Aucune place')
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: _placesByRang.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Text('Rang ${entry.key}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              if (_bulkMode) ...[
                                const Spacer(),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      final allSelected = entry.value.every((p) => _selectedPlaceIds.contains(p.numeroPlace));
                                      for (final p in entry.value) {
                                        if (allSelected) { _selectedPlaceIds.remove(p.numeroPlace); } else { _selectedPlaceIds.add(p.numeroPlace); }
                                      }
                                    });
                                  },
                                  child: Text(entry.value.every((p) => _selectedPlaceIds.contains(p.numeroPlace)) ? 'Tout désélectionner' : 'Tout sélectionner', style: const TextStyle(fontSize: 10)),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: entry.value.map((p) => _buildPlaceBadge(p)).toList(),
                        ),
                        const SizedBox(height: 8),
                      ],
                    );
                  }).toList(),
                ),
        ),
        if (_bulkMode && _selectedPlaceIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _bulkDelete,
                icon: const Icon(Icons.delete_sweep),
                label: Text('Supprimer ${_selectedPlaceIds.length} place(s)'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceBadge(Place place) {
    final isSelected = _selectedPlaceIds.contains(place.numeroPlace);
    return GestureDetector(
      onTap: _bulkMode
          ? () => setState(() { if (isSelected) { _selectedPlaceIds.remove(place.numeroPlace); } else { _selectedPlaceIds.add(place.numeroPlace); } })
          : () => _editPlace(place),
      onLongPress: _bulkMode ? null : () async {
        final action = await showMenu<String>(
          context: context,
          position: RelativeRect.fromLTRB(100, 100, 200, 200),
          items: [
            const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit, size: 18), title: Text('Modifier', style: TextStyle(fontSize: 13)))),
            const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete, size: 18, color: AppColors.error), title: Text('Supprimer', style: TextStyle(fontSize: 13, color: AppColors.error)))),
          ],
        );
        if (action == 'edit') _editPlace(place);
        if (action == 'delete') {
          final confirm = await AdminConfirmationDialog.show(context, title: 'Supprimer', message: 'Supprimer "${place.numeroPlace}" ?');
          if (confirm == true) _deletePlace(place.numeroPlace);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.textSecondary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider, width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_bulkMode)
              Icon(isSelected ? Icons.check_box : Icons.check_box_outline_blank, size: 14, color: isSelected ? AppColors.primary : AppColors.textMuted),
            if (_bulkMode) const SizedBox(width: 4),
            Text(place.numeroPlace, style: TextStyle(fontSize: 11, color: isSelected ? AppColors.primary : AppColors.textPrimary)),
            if (!_bulkMode) ...[
              const SizedBox(width: 2),
              GestureDetector(
                onTap: () async {
                  final confirm = await AdminConfirmationDialog.show(context, title: 'Supprimer', message: 'Supprimer "${place.numeroPlace}" ?');
                  if (confirm == true) _deletePlace(place.numeroPlace);
                },
                child: const Icon(Icons.close, size: 12, color: AppColors.textMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
