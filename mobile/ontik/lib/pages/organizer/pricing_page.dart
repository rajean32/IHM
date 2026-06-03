import 'package:flutter/material.dart';
import '../../models/event_place_config_model.dart';
import '../../core/assets/app_colors.dart';
import '../../widgets/error_state.dart';
import '../../core/utils/error_helper.dart';
import '../../core/services/evenement_service.dart';
import '../../core/services/place_service.dart';

class PricingPage extends StatefulWidget {
  final int eventId;
  const PricingPage({super.key, required this.eventId});

  @override
  State<PricingPage> createState() => _PricingPageState();
}

class _PricingPageState extends State<PricingPage> {
  bool _loadingSalles = true;
  String? _error;
  String _eventTitle = '';
  List<Map<String, dynamic>> _salles = [];
  String? _selectedSalle;

  List<EventPlaceConfig> _places = [];
  List<EventPlaceConfig> _filteredPlaces = [];
  bool _placesLoading = false;

  final _searchCtrl = TextEditingController();
  String? _typeFilter;
  List<String> _distinctTypes = [];

  bool _saving = false;
  bool _gridExpanded = false;

  Set<String> _selectedRows = {};
  Set<String> _selectedPlaceIds = {};
  String _assignType = 'Standard';
  final _newTypeCtrl = TextEditingController();
  List<String> _availableTypes = [];

  final _evenementService = EvenementService();
  final _placeService = PlaceService();

  @override
  void initState() {
    super.initState();
    _loadSalles();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _newTypeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSalles() async {
    setState(() => _loadingSalles = true);
    try {
      final eventData = await _evenementService.getEventDetail(widget.eventId);
      if (mounted) setState(() => _eventTitle = eventData['titre'] ?? '');

      final salles = await _placeService.getOrganizerEventSalles(widget.eventId);
      if (!mounted) return;
      setState(() {
        _salles = salles.cast<Map<String, dynamic>>();
        _loadingSalles = false;
        if (salles.isNotEmpty) {
          _selectedSalle = salles.first['numeroSalle'] as String?;
          _loadPlaces();
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = apiErrorString(e); _loadingSalles = false; });
    }
  }

  Future<void> _loadPlaces() async {
    if (_selectedSalle == null) return;
    setState(() => _placesLoading = true);
    try {
      final raw = await _placeService.getPlacesConfig(widget.eventId, _selectedSalle!);
      final data = raw.map((e) => EventPlaceConfig.fromJson(e as Map<String, dynamic>)).toList();
      if (!mounted) return;
      setState(() {
        _places = data;
        _filteredPlaces = data;
        _placesLoading = false;
        _distinctTypes = data.map((p) => p.effectiveType).toSet().toList()..sort();
        _availableTypes = [...AppConstants.placeTypes, ..._distinctTypes.where((t) => !AppConstants.placeTypes.contains(t))].toSet().toList();
        _applyFilter();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _placesLoading = false; });
    }
  }

  void _applyFilter() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      _filteredPlaces = _places.where((p) {
        final matchesQuery = query.isEmpty ||
            p.numeroPlace.toLowerCase().contains(query) ||
            (p.range?.toLowerCase().contains(query) ?? false);
        final matchesType = _typeFilter == null || _typeFilter!.isEmpty ||
            p.effectiveType == _typeFilter;
        return matchesQuery && matchesType;
      }).toList();
    });
  }

  List<String> get _distinctRangs =>
      _places.map((p) => p.range).whereType<String>().toSet().toList()..sort();

  Map<String, List<EventPlaceConfig>> get _placesByType {
    final map = <String, List<EventPlaceConfig>>{};
    for (final p in _places) {
      final type = p.effectiveType;
      map.putIfAbsent(type, () => []);
      map[type]!.add(p);
    }
    return map;
  }

  List<String> get _allUsedTypes => _placesByType.keys.toList()..sort();

  Future<void> _applyRowPricing(String rang, String typePlace, double? prix) async {
    setState(() => _saving = true);
    try {
      await _placeService.applyRowPricing(widget.eventId, rang, typePlace, prix);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tarification appliquée au rang $rang'), backgroundColor: AppTheme.secondaryColor),
      );
      _loadPlaces();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(apiErrorString(e)), backgroundColor: AppTheme.errorColor),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _applyTypePricing(String typePlace, double? prix) async {
    if (prix == null) return;
    setState(() => _saving = true);
    try {
      await _placeService.applyOrganizerTypePricing(widget.eventId, typePlace, prix);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Prix appliqué au type $typePlace'), backgroundColor: AppTheme.secondaryColor),
      );
      _loadPlaces();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(apiErrorString(e)), backgroundColor: AppTheme.errorColor),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _assignTypeToSelected() async {
    if (_selectedRows.isEmpty && _selectedPlaceIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez au moins une rangée ou une place'), backgroundColor: AppTheme.accentColor),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final isNew = _assignType == '__new__' && _newTypeCtrl.text.trim().isNotEmpty;
      final typeToAssign = isNew ? _newTypeCtrl.text.trim() : _assignType;
      await _placeService.assignOrganizerTypes(widget.eventId, {
        'typePlace': typeToAssign,
        'placeIds': _selectedPlaceIds.toList(),
        'rows': _selectedRows.toList(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Type $typeToAssign assigné'), backgroundColor: AppTheme.secondaryColor),
      );
      setState(() {
        _selectedRows.clear();
        _selectedPlaceIds.clear();
      });
      _loadPlaces();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(apiErrorString(e)), backgroundColor: AppTheme.errorColor),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _updateSinglePlace(EventPlaceConfig place, String typePlace, double? prix) async {
    try {
      await _placeService.updatePlaceConfig(widget.eventId, place.numeroPlace, typePlace: typePlace, prix: prix);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Place ${place.numeroPlace} mise à jour'), backgroundColor: AppTheme.secondaryColor),
      );
      _loadPlaces();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(apiErrorString(e)), backgroundColor: AppTheme.errorColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tarifs - $_eventTitle')),
      body: _loadingSalles
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorState(message: _error!, onRetry: _loadSalles)
              : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_placesLoading) return const Center(child: CircularProgressIndicator());
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSalleSelector(),
          const SizedBox(height: 12),
          _buildTypePricingSection(),
          const Divider(height: 24),
          _buildAssignTypeSection(),
          const Divider(height: 24),
          _buildRowPricingSection(),
          const Divider(height: 24),
          _buildSeatGridSection(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSalleSelector() {
    return Row(children: [
      const Text('Salle: ', style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(width: 8),
      Expanded(
        child: DropdownButtonFormField<String>(
          value: _selectedSalle,
          isExpanded: true,
          decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
          items: _salles.map((s) => DropdownMenuItem<String>(
            value: s['numeroSalle'] as String,
            child: Text(s['nomSalle'] as String? ?? s['numeroSalle'] as String, style: const TextStyle(fontSize: 13)),
          )).toList(),
          onChanged: (v) {
            setState(() => _selectedSalle = v);
            _loadPlaces();
          },
        ),
      ),
    ]);
  }

  Widget _buildTypePricingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Prix par type de place', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Définissez le prix pour chaque type de place. Toutes les places de ce type seront mises à jour.',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        const SizedBox(height: 8),
        ..._allUsedTypes.map((type) => _buildTypePricingCard(type)),
      ],
    );
  }

  Widget _buildTypePricingCard(String type) {
    final places = _placesByType[type] ?? [];
    final configCount = places.where((p) => p.typePlaceOverride != null).length;
    final samplePrice = places.isNotEmpty ? places.first.effectivePrice : 0.0;
    final prixCtrl = TextEditingController(text: samplePrice > 0 ? samplePrice.toStringAsFixed(2) : '');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: (AppConstants.placeTypeColors[type] ?? AppTheme.textSecondary).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(type.substring(0, 1).toUpperCase(),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                      color: AppConstants.placeTypeColors[type] ?? AppTheme.textSecondary)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: Text(type, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
          Expanded(
            child: Text('${places.length} pl.',
                style: TextStyle(fontSize: 12, color: configCount > 0 ? AppTheme.secondaryColor : AppTheme.textSecondary)),
          ),
          SizedBox(
            width: 80,
            child: TextField(
              controller: prixCtrl,
              decoration: const InputDecoration(
                labelText: 'Prix', border: OutlineInputBorder(), isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: _saving ? null : () => _applyTypePricing(type, double.tryParse(prixCtrl.text)),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12)),
              child: _saving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Appliquer', style: TextStyle(fontSize: 11)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildAssignTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Affectation des types', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Sélectionnez les rangées ou places et assignez-leur un type.',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        const SizedBox(height: 8),
        _buildRowSelector(),
        const SizedBox(height: 8),
        _buildSelectedPlacesPreview(),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _availableTypes.contains(_assignType) ? _assignType : null,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Type à assigner', border: OutlineInputBorder(), isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              ),
              items: [
                ..._availableTypes.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12)))),
                const DropdownMenuItem(value: '__new__', child: Text('+ Nouveau type...', style: TextStyle(fontSize: 12, color: AppTheme.primaryColor))),
              ],
              onChanged: (v) => setState(() => _assignType = v!),
            ),
          ),
          if (_assignType == '__new__') ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 100,
              child: TextField(
                controller: _newTypeCtrl,
                decoration: const InputDecoration(
                  hintText: 'Nom', border: OutlineInputBorder(), isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                ),
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
          const SizedBox(width: 8),
          SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: _saving ? null : _assignTypeToSelected,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12)),
              child: _saving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Affecter', style: TextStyle(fontSize: 11)),
            ),
          ),
        ]),
        Text('${_selectedRows.length} rangée(s) • ${_selectedPlaceIds.length} place(s) sélectionnée(s)',
            style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _buildRowSelector() {
    final rangs = _distinctRangs;
    if (rangs.isEmpty) return const Text('Aucune rangée disponible', style: TextStyle(color: AppTheme.textSecondary));
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: rangs.map((rang) {
        final selected = _selectedRows.contains(rang);
        final placesInRow = _places.where((p) => p.range == rang).toList();
        final type = placesInRow.isNotEmpty ? placesInRow.first.effectiveType : '';
        return FilterChip(
          label: Text('$rang (${placesInRow.length})', style: TextStyle(fontSize: 11, color: selected ? Colors.white : null)),
          selected: selected,
          selectedColor: AppConstants.placeTypeColors[type] ?? AppTheme.primaryColor,
          onSelected: (v) {
            setState(() {
              if (v) { _selectedRows.add(rang); } else { _selectedRows.remove(rang); }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildSelectedPlacesPreview() {
    final selectedPlaces = _places.where((p) =>
        _selectedRows.contains(p.range) || _selectedPlaceIds.contains(p.numeroPlace)).toList();
    if (selectedPlaces.isEmpty) {
      return Text('Cliquez sur une place dans la grille ci-dessous pour la sélectionner',
          style: TextStyle(fontSize: 11, color: AppTheme.textSecondary));
    }
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: selectedPlaces.map((p) {
        final selected = _selectedPlaceIds.contains(p.numeroPlace);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (selected) { _selectedPlaceIds.remove(p.numeroPlace); }
              else { _selectedPlaceIds.add(p.numeroPlace); }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: selected ? AppTheme.primaryColor.withValues(alpha: 0.3) : AppTheme.textSecondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: selected ? AppTheme.primaryColor : AppTheme.textSecondary.withValues(alpha: 0.3)),
            ),
            child: Text(p.numeroPlace, style: TextStyle(fontSize: 10, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRowPricingSection() {
    final rangs = _distinctRangs;
    if (rangs.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tarification par rangée', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Configurer le type et le prix pour chaque rangée.',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        const SizedBox(height: 8),
        ...rangs.map((rang) => _RowPricingTile(
          rang: rang,
          places: _places.where((p) => p.range == rang).toList(),
          onApply: _applyRowPricing,
          saving: _saving,
        )),
      ],
    );
  }

  Widget _buildSeatGridSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _gridExpanded = !_gridExpanded),
          child: Row(children: [
            Icon(_gridExpanded ? Icons.expand_less : Icons.expand_more, size: 20),
            const SizedBox(width: 4),
            Text('Grille individuelle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryDark)),
          ]),
        ),
        if (_gridExpanded) ...[
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(
                  hintText: 'Rechercher place...', prefixIcon: Icon(Icons.search, size: 20),
                  border: OutlineInputBorder(), isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onChanged: (_) => _applyFilter(),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 120,
              child: DropdownButtonFormField<String>(
                value: _typeFilter,
                isExpanded: true,
                decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                hint: const Text('Type', style: TextStyle(fontSize: 12)),
                items: [
                  const DropdownMenuItem<String>(value: null, child: Text('Tous', style: TextStyle(fontSize: 12))),
                  ..._distinctTypes.map((t) => DropdownMenuItem<String>(value: t, child: Text(t, style: TextStyle(fontSize: 12)))),
                ],
                onChanged: (v) { setState(() => _typeFilter = v); _applyFilter(); },
              ),
            ),
          ]),
          const SizedBox(height: 4),
          Text(_legendRow(), style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          _buildSeatGrid(),
        ],
      ],
    );
  }

  String _legendRow() {
    final total = _places.length;
    final configured = _places.where((p) => p.typePlaceOverride != null).length;
    return '$total places • $configured configurées';
  }

  Widget _buildSeatGrid() {
    final rangs = _filteredPlaces.map((p) => p.range).whereType<String>().toSet().toList()..sort();
    if (rangs.isEmpty) {
      return Column(children: _filteredPlaces.map((p) => _buildSeatListTile(p)).toList());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rangs.map((rang) {
        final rowPlaces = _filteredPlaces.where((p) => p.range == rang).toList()
          ..sort((a, b) => a.numeroPlace.compareTo(b.numeroPlace));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('Rangée $rang',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            Wrap(spacing: 4, runSpacing: 4, children: rowPlaces.map((p) => _buildSeatChip(p)).toList()),
            const SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSeatChip(EventPlaceConfig place) {
    final color = AppConstants.placeTypeColors[place.effectiveType] ?? AppTheme.textSecondary;
    final isSelected = _selectedPlaceIds.contains(place.numeroPlace);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) { _selectedPlaceIds.remove(place.numeroPlace); }
          else { _selectedPlaceIds.add(place.numeroPlace); }
        });
      },
      onLongPress: () => _showPlaceEditDialog(place),
      child: Container(
        width: 52, height: 40,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.3) : color.withValues(alpha: place.typePlaceOverride != null ? 0.3 : 0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : color.withValues(alpha: 0.5),
            width: isSelected ? 2.0 : (place.typePlaceOverride != null ? 1.5 : 0.5),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(place.numeroPlace.replaceAll(place.range ?? '', ''),
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
            Text('${place.effectivePrice.toStringAsFixed(0)}${AppConstants.currency}',
                style: TextStyle(fontSize: 8, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatListTile(EventPlaceConfig place) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: (AppConstants.placeTypeColors[place.effectiveType] ?? AppTheme.textSecondary).withValues(alpha: 0.2),
          child: Text(place.numeroPlace, style: const TextStyle(fontSize: 10)),
        ),
        title: Text('${place.numeroPlace}  ${place.range != null ? '(Rang ${place.range})' : ''}',
            style: const TextStyle(fontSize: 13)),
        subtitle: Text(
          '${place.effectiveType} • ${place.effectivePrice.toStringAsFixed(2)}${AppConstants.currency}${place.typePlaceOverride != null ? ' (configuré)' : ''}',
          style: TextStyle(fontSize: 11, color: place.typePlaceOverride != null ? AppTheme.secondaryColor : AppTheme.textSecondary),
        ),
        trailing: const Icon(Icons.edit, size: 16),
        onTap: () => _showPlaceEditDialog(place),
      ),
    );
  }

  void _showPlaceEditDialog(EventPlaceConfig place) {
    String selectedType = place.typePlaceOverride ?? place.typePlace ?? 'Standard';
    final prixCtrl = TextEditingController(
        text: (place.prixOverride ?? place.prix)?.toStringAsFixed(2) ?? '');

    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text('Place ${place.numeroPlace}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _availableTypes.contains(selectedType) ? selectedType : null,
            decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder(), isDense: true),
            items: [
              ..._availableTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))),
              const DropdownMenuItem(value: '__new__', child: Text('+ Nouveau type...', style: TextStyle(color: AppTheme.primaryColor))),
            ],
            onChanged: (v) => selectedType = v ?? 'Standard',
          ),
          if (selectedType == '__new__') ...[
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(labelText: 'Nouveau type', border: OutlineInputBorder(), isDense: true),
              onChanged: (v) => selectedType = v,
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: prixCtrl,
            decoration: InputDecoration(labelText: 'Prix (${AppConstants.currency})', border: const OutlineInputBorder(), isDense: true),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(ctx);
            _updateSinglePlace(place, selectedType, double.tryParse(prixCtrl.text));
          },
          child: const Text('Enregistrer'),
        ),
      ],
    ));
  }
}

class _RowPricingTile extends StatefulWidget {
  final String rang;
  final List<EventPlaceConfig> places;
  final Future<void> Function(String rang, String typePlace, double? prix) onApply;
  final bool saving;

  const _RowPricingTile({
    required this.rang,
    required this.places,
    required this.onApply,
    required this.saving,
  });

  @override
  _RowPricingTileState createState() => _RowPricingTileState();
}

class _RowPricingTileState extends State<_RowPricingTile> {
  String _selectedType = 'Standard';
  final _prixCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateFromPlaces();
  }

  @override
  void didUpdateWidget(_RowPricingTile old) {
    super.didUpdateWidget(old);
    if (widget.places.isNotEmpty && old.places != widget.places) {
      _updateFromPlaces();
    }
  }

  void _updateFromPlaces() {
    if (widget.places.isNotEmpty) {
      final first = widget.places.first;
      _selectedType = first.typePlaceOverride ?? first.typePlace ?? 'Standard';
      _prixCtrl.text = (first.prixOverride ?? first.prix)?.toStringAsFixed(2) ?? '';
    }
  }

  @override
  void dispose() { _prixCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final anyConfigured = widget.places.any((p) => p.typePlaceOverride != null);
    final count = widget.places.length;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              CircleAvatar(
                radius: 14,
                child: Text(widget.rang, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Text('Rangée ${widget.rang}  ($count places)',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              if (anyConfigured)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppTheme.secondaryColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                  child: Text('configuré', style: TextStyle(fontSize: 9, color: AppTheme.secondaryColor)),
                ),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedType,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Type', border: OutlineInputBorder(), isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  ),
                  items: AppConstants.placeTypes.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12)))).toList(),
                  onChanged: (v) => setState(() => _selectedType = v!),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _prixCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Prix', border: OutlineInputBorder(), isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: widget.saving ? null : () {
                    widget.onApply(widget.rang, _selectedType, double.tryParse(_prixCtrl.text));
                  },
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12)),
                  child: widget.saving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Appliquer', style: TextStyle(fontSize: 11)),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
