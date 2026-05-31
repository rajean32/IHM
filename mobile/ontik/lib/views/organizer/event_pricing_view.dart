import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_endpoints.dart';
import '../../controllers/auth_controller.dart';
import '../../models/event_place_config.dart';
import '../../models/evenement.dart';
import '../../models/api_wrapper.dart';
import '../../core/constants.dart';
import '../../widgets/error_state.dart';

class EventPricingView extends ConsumerStatefulWidget {
  final Evenement event;
  const EventPricingView({super.key, required this.event});

  @override
  ConsumerState<EventPricingView> createState() => _EventPricingViewState();
}

class _EventPricingViewState extends ConsumerState<EventPricingView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _loadingSalles = true;
  String? _error;
  List<Map<String, dynamic>> _salles = [];
  String? _selectedSalle;

  List<EventPlaceConfig> _places = [];
  List<EventPlaceConfig> _filteredPlaces = [];
  bool _placesLoading = false;

  final _searchCtrl = TextEditingController();
  String? _typeFilter;
  List<String> _distinctTypes = [];

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSalles();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSalles() async {
    setState(() => _loadingSalles = true);
    try {
      final resp = await ref.read(apiClientProvider).get(ApiEndpoints.organizerPricing.eventSalles(widget.event.idEvenement!));
      final wrapper = ApiWrapper.fromJson(resp);
      final salles = wrapper.getDataList((e) => e as Map<String, dynamic>);
      if (!mounted) return;
      setState(() {
        _salles = salles;
        _loadingSalles = false;
        if (salles.isNotEmpty) {
          _selectedSalle = salles.first['numeroSalle'];
          _loadPlaces();
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loadingSalles = false; });
    }
  }

  Future<void> _loadPlaces() async {
    if (_selectedSalle == null) return;
    setState(() => _placesLoading = true);
    try {
      final resp = await ref.read(apiClientProvider).get(
        ApiEndpoints.organizerPricing.placesWithConfig(widget.event.idEvenement!, salle: _selectedSalle),
      );
      final wrapper = ApiWrapper.fromJson(resp);
      final data = wrapper.getDataList((e) => EventPlaceConfig.fromJson(e as Map<String, dynamic>));
      if (!mounted) return;
      setState(() {
        _places = data;
        _filteredPlaces = data;
        _placesLoading = false;
        _distinctTypes = data.map((p) => p.effectiveType).toSet().toList()..sort();
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

  Future<void> _applyRowPricing(String rang, String typePlace, double? prix) async {
    setState(() => _saving = true);
    try {
      await ref.read(apiClientProvider).put(
        ApiEndpoints.organizerPricing.rowPricing(widget.event.idEvenement!),
        data: {'rang': rang, 'typePlace': typePlace, 'prix': prix},
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tarification appliquée au rang $rang'), backgroundColor: Colors.green),
      );
      _loadPlaces();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _updateSinglePlace(EventPlaceConfig place, String typePlace, double? prix) async {
    try {
      final query = <String>[];
      if (typePlace.isNotEmpty) query.add('typePlace=$typePlace');
      if (prix != null) query.add('prix=$prix');
      var url = ApiEndpoints.organizerPricing.singlePlaceConfig(widget.event.idEvenement!, place.numeroPlace);
      if (query.isNotEmpty) url += '?${query.join('&')}';
      await ref.read(apiClientProvider).put(url);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Place ${place.numeroPlace} mise à jour'), backgroundColor: Colors.green),
      );
      _loadPlaces();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  List<String> get _distinctRangs =>
      _places.map((p) => p.range).whereType<String>().toSet().toList()..sort();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tarifs - ${widget.event.titre}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.table_rows), text: 'Par Rangée'),
            Tab(icon: Icon(Icons.grid_view), text: 'Grille'),
          ],
        ),
      ),
      body: _loadingSalles
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorState(message: _error!, onRetry: _loadSalles)
              : Column(children: [
                  _buildSalleSelector(),
                  Expanded(child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRowPricingTab(),
                      _buildSeatGridTab(),
                    ],
                  )),
                ]),
    );
  }

  Widget _buildSalleSelector() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(children: [
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
      ]),
    );
  }

  Widget _buildRowPricingTab() {
    final rangs = _distinctRangs;
    if (_placesLoading) return const Center(child: CircularProgressIndicator());
    if (rangs.isEmpty) return const Center(child: Text('Aucune rangée disponible'));

    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Text('Configurer le type et le prix pour chaque rangée. Les places individuelles configurées via la grille ne sont pas affectées.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: rangs.length,
          itemBuilder: (ctx, i) => _RowPricingTile(
            rang: rangs[i],
            places: _places.where((p) => p.range == rangs[i]).toList(),
            onApply: _applyRowPricing,
            saving: _saving,
          ),
        ),
      ),
    ]);
  }

  Widget _buildSeatGridTab() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Rechercher place...',
                prefixIcon: Icon(Icons.search, size: 20),
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
                ..._distinctTypes.map((t) => DropdownMenuItem<String>(
                  value: t,
                  child: Text(t, style: const TextStyle(fontSize: 12)),
                )),
              ],
              onChanged: (v) {
                setState(() => _typeFilter = v);
                _applyFilter();
              },
            ),
          ),
        ]),
      ),
      const SizedBox(height: 4),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(_legendRow(), style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ),
      Expanded(
        child: _placesLoading
            ? const Center(child: CircularProgressIndicator())
            : _filteredPlaces.isEmpty
                ? const Center(child: Text('Aucune place trouvée'))
                : _buildSeatGrid(),
      ),
    ]);
  }

  String _legendRow() {
    final total = _places.length;
    final configured = _places.where((p) => p.typePlaceOverride != null).length;
    return '$total places • $configured configurées';
  }

  Widget _buildSeatGrid() {
    final rangs = _filteredPlaces.map((p) => p.range).whereType<String>().toSet().toList()..sort();
    if (rangs.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _filteredPlaces.length,
        itemBuilder: (ctx, i) => _buildSeatListTile(_filteredPlaces[i]),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: rangs.length,
      itemBuilder: (ctx, ri) {
        final rowPlaces = _filteredPlaces.where((p) => p.range == rangs[ri]).toList()
          ..sort((a, b) => a.numeroPlace.compareTo(b.numeroPlace));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('Rangée ${rangs[ri]}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: rowPlaces.map((p) => _buildSeatChip(p)).toList(),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildSeatChip(EventPlaceConfig place) {
    final color = AppConstants.placeTypeColors[place.effectiveType] ?? Colors.grey;
    return GestureDetector(
      onTap: () => _showPlaceEditDialog(place),
      child: Tooltip(
        message: '${place.numeroPlace} • ${place.effectiveType} • ${place.effectivePrice.toStringAsFixed(2)}€',
        child: Container(
          width: 52,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: place.typePlaceOverride != null ? 0.3 : 0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withValues(alpha: 0.5), width: place.typePlaceOverride != null ? 1.5 : 0.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(place.numeroPlace.replaceAll(place.range ?? '', ''),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
              Text('${place.effectivePrice.toStringAsFixed(0)}€',
                  style: TextStyle(fontSize: 8, color: Colors.grey.shade700)),
            ],
          ),
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
          backgroundColor: (AppConstants.placeTypeColors[place.effectiveType] ?? Colors.grey).withValues(alpha: 0.2),
          child: Text(place.numeroPlace, style: const TextStyle(fontSize: 10)),
        ),
        title: Text('${place.numeroPlace}  ${place.range != null ? '(Rang ${place.range})' : ''}',
            style: const TextStyle(fontSize: 13)),
        subtitle: Text(
          '${place.effectiveType} • ${place.effectivePrice.toStringAsFixed(2)}€${place.typePlaceOverride != null ? ' (configuré)' : ''}',
          style: TextStyle(fontSize: 11, color: place.typePlaceOverride != null ? Colors.green : Colors.grey),
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
            value: selectedType,
            decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder(), isDense: true),
            items: AppConstants.placeTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) => selectedType = v!,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: prixCtrl,
            decoration: const InputDecoration(labelText: 'Prix (€)', border: OutlineInputBorder(), isDense: true),
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
    if (widget.places.isNotEmpty) {
      final first = widget.places.first;
      _selectedType = first.typePlaceOverride ?? first.typePlace ?? 'Standard';
      _prixCtrl.text = (first.prixOverride ?? first.prix)?.toStringAsFixed(2) ?? '';
    }
  }

  @override
  void didUpdateWidget(_RowPricingTile old) {
    super.didUpdateWidget(old);
    if (widget.places.isNotEmpty && old.places != widget.places) {
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
                  decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(10)),
                  child: Text('configuré', style: TextStyle(fontSize: 9, color: Colors.green.shade800)),
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
