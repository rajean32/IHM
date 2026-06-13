import 'package:flutter/material.dart';
import '../../models/evenement_model.dart';
import '../../models/lieu_model.dart';
import '../../models/categorie_model.dart';
import '../../widgets/event_card.dart';

import '../../core/services/categorie_service.dart';
import '../../core/services/lieu_service.dart';
import '../../core/api/dio_config.dart';
import '../../core/api/endpoints.dart';
import '../../core/assets/app_colors.dart';
import '../../core/routes/client_routes.dart';
import '../../core/utils/error_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchCtrl = TextEditingController();
  String? _selectedCategorie;
  String? _selectedStatut;
  String? _selectedLieu;
  DateTimeRange? _selectedDateRange;
  double? _prixMin;
  double? _prixMax;
  List<Lieu> _lieux = [];
  List<Categorie> _categories = [];
  final _scrollCtrl = ScrollController();

  List<Evenement> _events = [];
  bool _isLoading = true;
  String? _error;

  static const _statusOptions = [
    'Tous',
    'planifie',
    'en_cours',
    'termine',
    'annule',
  ];

  @override
  void initState() {
    super.initState();
    _loadFilterData();
    _loadEvents();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      // Pagination possible ici
    }
  }

  Future<void> _loadFilterData() async {
    try {
      final _lieuService = LieuService();
      final _categorieService = CategorieService();
      final lieuxData = await _lieuService.getLieux();
      final catsData = await _categorieService.getCategories();
      if (!mounted) return;
      setState(() {
        _lieux = lieuxData.map((e) => Lieu.fromJson(e as Map<String, dynamic>)).toList();
        _categories = catsData.map((e) => Categorie.fromJson(e as Map<String, dynamic>)).toList();
      });
    } catch (_) {}
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    try {
      final params = <String, dynamic>{};
      if (_searchCtrl.text.isNotEmpty) params['q'] = _searchCtrl.text;
      if (_selectedCategorie != null) params['categorie'] = _selectedCategorie;
      if (_selectedStatut != null) params['statut'] = _selectedStatut;
      if (_selectedLieu != null) params['codeLieu'] = _selectedLieu;
      if (_prixMin != null) params['prixMin'] = _prixMin;
      if (_prixMax != null) params['prixMax'] = _prixMax;

      final resp = await dio.get(
        Endpoints.events,
        queryParameters: params.isNotEmpty ? params : null,
      );
      final data = resp.data['data'] as List? ?? [];
      final events = data.map((e) => Evenement.fromJson(e as Map<String, dynamic>)).toList();
      if (!mounted) return;
      setState(() {
        _events = events;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = apiErrorString(e);
        _isLoading = false;
      });
    }
  }

  void _applyFilters() => _loadEvents();

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Filtres', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () {
                        setSheetState(() {
                          _selectedStatut = null;
                          _selectedLieu = null;
                          _selectedDateRange = null;
                          _prixMin = null;
                          _prixMax = null;
                        });
                      },
                      child: const Text('Réinitialiser'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Statut', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedStatut,
                  decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                  items: _statusOptions.map((s) => DropdownMenuItem(
                    value: s == 'Tous' ? null : s,
                    child: Text(s),
                  )).toList(),
                  onChanged: (v) => setSheetState(() => _selectedStatut = v),
                ),
                const SizedBox(height: 16),
                const Text('Lieu', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedLieu,
                  decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                  items: [
                    const DropdownMenuItem<String>(value: null, child: Text('Tous les lieux')),
                    ..._lieux.map((l) => DropdownMenuItem(
                      value: l.code,
                      child: Text(l.nomLieu),
                    )),
                  ],
                  onChanged: (v) => setSheetState(() => _selectedLieu = v),
                ),
                const SizedBox(height: 16),
                const Text('Date Range', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final range = await showDateRangePicker(
                      context: ctx,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      initialDateRange: _selectedDateRange,
                    );
                    if (range != null) setSheetState(() => _selectedDateRange = range);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                    child: Text(
                      _selectedDateRange != null
                          ? '${_selectedDateRange!.start.toIso8601String().split('T').first} \u2014 ${_selectedDateRange!.end.toIso8601String().split('T').first}'
                          : 'Sélectionner une plage',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Price Range', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Min',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => _prixMin = double.tryParse(v),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('\u2014'),
                    ),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Max',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => _prixMax = double.tryParse(v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _applyFilters();
                  },
                  child: const Text('Appliquer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Rechercher...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _applyFilters(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Badge(
                    isLabelVisible: _selectedStatut != null || _selectedLieu != null ||
                        _selectedDateRange != null || _prixMin != null || _prixMax != null,
                    child: const Icon(Icons.tune),
                  ),
                  onPressed: _showFilterSheet,
                ),
              ],
            ),
          ),
          // Chips catégories
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _buildCategoryChip('Tous', null),
                ..._categories.map((c) => _buildCategoryChip(c.nomCategorie, c.codeCategorie)),
              ],
            ),
          ),
          // Liste des événements
          Expanded(
            child: _buildEventList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? code) {
    final selected = _selectedCategorie == code;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (v) {
          setState(() => _selectedCategorie = v ? code : null);
          _applyFilters();
        },
      ),
    );
  }

  Widget _buildEventList() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));
    if (_events.isEmpty) return const Center(child: Text('Aucun événement trouvé'));

    return RefreshIndicator(
      onRefresh: _loadEvents,
      child: ListView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          return EventCard(
            event: event,
            onTap: () {
              if (event.idEvenement != null) {
                Navigator.pushNamed(context, ClientRoutes.homeDetail, arguments: {'id': event.idEvenement});
              }
            },
          );
        },
      ),
    );
  }
}