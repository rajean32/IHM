import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/evenement_model.dart';
import '../../models/lieu_model.dart';
import '../../models/categorie_model.dart';
import '../../widgets/event_image_widget.dart';
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
  bool _promoDismissed = false;

  List<Evenement> _events = [];
  bool _isLoading = true;
  String? _error;

  static const _statusOptions = ['Tous', 'planifie', 'en_cours', 'termine', 'annule'];

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
      if (userVille != null && _selectedLieu == null) params['ville'] = userVille;

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
                        decoration: const InputDecoration(labelText: 'Min', border: OutlineInputBorder(), isDense: true),
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
                        decoration: const InputDecoration(labelText: 'Max', border: OutlineInputBorder(), isDense: true),
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

  String _formatDate(DateTime? date, String? time) {
    if (date == null) return '';
    final formatted = DateFormat('d MMMM yyyy', 'fr').format(date);
    if (time != null && time.length >= 5) {
      return '$formatted \u2022 ${time.substring(0, 5)}';
    }
    return formatted;
  }

  Color _badgeColor(String? label) {
    switch (label?.toUpperCase()) {
      case 'VIP':
        return const Color(0xFF9C27B0);
      case 'PREMIUM':
        return const Color(0xFFFF6F00);
      default:
        return const Color(0xFF673AB7);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFEF7FF),
      child: Column(
        children: [
          _buildSearchBar(),
          _buildCategories(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Rechercher un événement...',
                prefixIcon: Icon(Icons.search, color: const Color(0xFF673AB7).withValues(alpha: 0.6)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.divider.withValues(alpha: 0.5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.divider.withValues(alpha: 0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF673AB7)),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
              child: Icon(Icons.tune, color: const Color(0xFF673AB7)),
            ),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final chipData = <Map<String, String?>>[
      {'label': 'Tous', 'code': null},
      ..._categories.map((c) => {'label': c.nomCategorie, 'code': c.codeCategorie}),
    ];
    return Container(
      height: 44,
      margin: const EdgeInsets.only(top: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: chipData.map((data) {
          final code = data['code'];
          final label = data['label'] ?? '';
          final isSelected = code == _selectedCategorie;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (v) {
                setState(() => _selectedCategorie = v ? code : null);
                _applyFilters();
              },
              selectedColor: const Color(0xFF673AB7),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              backgroundColor: Colors.white,
              side: BorderSide(
                color: isSelected ? const Color(0xFF673AB7) : AppColors.divider.withValues(alpha: 0.5),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadEvents, child: const Text('Réessayer')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEvents,
      child: ListView(
        controller: _scrollCtrl,
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
        children: [
          const Text(
            '\u00C9v\u00E9nements \u00E0 la une',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 14),
          if (_events.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(child: Text('Aucun événement trouvé', style: TextStyle(color: AppColors.textSecondary))),
            )
          else
            ..._events.map((event) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildEventCard(event),
            )),
          if (!_promoDismissed) ...[
            const SizedBox(height: 8),
            _buildPromoBanner(),
          ],
        ],
      ),
    );
  }

  Widget _buildEventCard(Evenement event) {
    return GestureDetector(
      onTap: () {
        if (event.idEvenement != null) {
          Navigator.pushNamed(context, ClientRoutes.homeDetail, arguments: {'id': event.idEvenement});
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: event.image != null
                  ? eventImageWidget(event.image!, fit: BoxFit.cover, width: double.infinity)
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF673AB7).withValues(alpha: 0.7),
                            const Color(0xFF673AB7).withValues(alpha: 0.3),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Icon(Icons.event, size: 48, color: Colors.white.withValues(alpha: 0.4)),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          event.titre,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildEventBadge(event),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          _formatDate(event.dateEvenement, event.heureEvenement),
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          event.lieuNom ?? 'Lieu non spécifié',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    event.prix != null
                        ? 'À partir de ${event.prix!.toStringAsFixed(0)} ${AppConstants.currency}'
                        : 'Prix non disponible',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF673AB7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventBadge(Evenement event) {
    final label = event.categorieNom ?? event.statut ?? 'Standard';
    final color = _badgeColor(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.3),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF7C4DFF), Color(0xFF448AFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 12, 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '-20% sur votre premier billet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Utilisez le code SECURE20 lors du paiement.',
                    style: TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white60, size: 20),
              onPressed: () => setState(() => _promoDismissed = true),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}
