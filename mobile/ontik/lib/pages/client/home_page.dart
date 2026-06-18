import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/evenement_model.dart';
import '../../models/lieu_model.dart';
import '../../models/categorie_model.dart';
import '../../widgets/event/event_card.dart';
import '../../widgets/event/event_filter_sheet.dart';
import '../../core/services/categorie_service.dart';
import '../../core/services/lieu_service.dart';
import '../../core/api/dio_config.dart';
import '../../core/api/endpoints.dart';
import '../../core/assets/app_colors.dart';
import '../../core/routes/client_routes.dart';
import '../../core/utils/error_helper.dart';
import '../../core/services/app_config.dart';
import '../../generated/app_localizations.dart';

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
  List<Evenement> _recentEvents = [];
  List<Evenement> _popularEvents = [];
  List<Evenement> _recommendedEvents = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFilterData();
    _loadEvents();
    _loadRecentEvents();
    _loadPopularEvents();
    _loadRecommendedEvents();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadFilterData() async {
    try {
      final lieuxData = await LieuService().getLieux();
      final catsData = await CategorieService().getCategories();
      if (!mounted) return;
      setState(() {
        _lieux = lieuxData
            .map((e) => Lieu.fromJson(e as Map<String, dynamic>))
            .toList();
        _categories = catsData
            .map((e) => Categorie.fromJson(e as Map<String, dynamic>))
            .toList();
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
      if (_selectedDateRange != null) {
        params['dateFrom'] = DateFormat(
          'yyyy-MM-dd',
        ).format(_selectedDateRange!.start);
        params['dateTo'] = DateFormat(
          'yyyy-MM-dd',
        ).format(_selectedDateRange!.end);
      }
      if (userVille != null &&
          _selectedLieu == null &&
          _selectedDateRange == null)
        params['ville'] = userVille;

      final hasSearch =
          params.containsKey('q') ||
          params.containsKey('prixMin') ||
          params.containsKey('prixMax') ||
          params.containsKey('codeLieu');
      final url = hasSearch ? '${Endpoints.events}/search' : Endpoints.events;

      final resp = await dio.get(
        url,
        queryParameters: params.isNotEmpty ? params : null,
      );
      final data = resp.data['data'] as List? ?? [];
      final events = data
          .map((e) => Evenement.fromJson(e as Map<String, dynamic>))
          .toList();
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

  Future<void> _loadRecentEvents() async {
    try {
      final resp = await dio.get(Endpoints.eventsRecent);
      final data = resp.data['data'] as List? ?? [];
      final events = data
          .map((e) => Evenement.fromJson(e as Map<String, dynamic>))
          .toList();
      if (!mounted) return;
      setState(() => _recentEvents = events);
    } catch (_) {}
  }

  Future<void> _loadPopularEvents() async {
    try {
      final resp = await dio.get(Endpoints.eventsPopular);
      final data = resp.data['data'] as List? ?? [];
      final events = data
          .map((e) => Evenement.fromJson(e as Map<String, dynamic>))
          .toList();
      if (!mounted) return;
      setState(() => _popularEvents = events);
    } catch (_) {}
  }

  Future<void> _loadRecommendedEvents() async {
    if (userCode == null || userCode!.isEmpty) return;
    try {
      final resp = await dio.get(Endpoints.recommendedEvents(userCode!));
      final data = resp.data['data'] as List? ?? [];
      final events = data
          .map((e) => Evenement.fromJson(e as Map<String, dynamic>))
          .toList();
      if (!mounted) return;
      setState(() => _recommendedEvents = events);
    } catch (_) {}
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      _loadEvents(),
      _loadRecentEvents(),
      _loadPopularEvents(),
      if (userCode != null && userCode!.isNotEmpty) _loadRecommendedEvents(),
    ]);
  }

  void _applyFilters() => _loadEvents();

  void _showFilterSheet() {
    EventFilterSheet.show(
      context,
      statut: _selectedStatut,
      lieu: _selectedLieu,
      dateRange: _selectedDateRange,
      prixMin: _prixMin,
      prixMax: _prixMax,
      lieux: _lieux,
      onApply: (result) {
        setState(() {
          _selectedStatut = result.statut;
          _selectedLieu = result.lieu;
          _selectedDateRange = result.dateRange;
          _prixMin = result.prixMin;
          _prixMax = result.prixMax;
        });
        _applyFilters();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
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
    final hasFilters =
        _selectedStatut != null ||
        _selectedLieu != null ||
        _selectedDateRange != null ||
        _prixMin != null ||
        _prixMax != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.clientHomeSearchHint,
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.primary.withValues(alpha: 0.6),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.divider.withValues(alpha: 0.5),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.divider.withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary),
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
              isLabelVisible: hasFilters,
              child: Icon(Icons.tune, color: AppColors.primary),
            ),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final chipData = <Map<String, String?>>[
      {'label': AppLocalizations.of(context)!.commonAll, 'code': null},
      ..._categories.map(
        (c) => {'label': c.nomCategorie, 'code': c.codeCategorie},
      ),
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
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              backgroundColor: Colors.white,
              side: BorderSide(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.divider.withValues(alpha: 0.5),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
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
            ElevatedButton(
              onPressed: _loadEvents,
              child: Text(AppLocalizations.of(context)!.clientHomeRetry),
            ),
          ],
        ),
      );
    }

    final hasRecent = _recentEvents.isNotEmpty;
    final hasRecommended = _recommendedEvents.isNotEmpty && userCode != null;
    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView(
        controller: _scrollCtrl,
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
        children: [
          if (hasRecent) ...[
            Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.clientHomeNewEvents,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _scrollCtrl.animateTo(
                    _scrollCtrl.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                  ),
                  child: Text(
                    '${AppLocalizations.of(context)!.seeAll} →',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 280,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _recentEvents.length > 3 ? 3 : _recentEvents.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  if (_recentEvents.length > 3 && i == 3) {
                    return _buildSeeMoreCard(
                      () => _scrollCtrl.animateTo(
                        _scrollCtrl.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                      ),
                    );
                  }
                  final event = _recentEvents[i];
                  return SizedBox(
                    width: 195,
                    child: EventCard(
                      event: event,
                      compact: false,
                      onTap: event.idEvenement != null
                          ? () => Navigator.pushNamed(
                              context,
                              ClientRoutes.homeDetail,
                              arguments: {'id': event.idEvenement},
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
          if (_popularEvents.isNotEmpty) ...[
            Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.clientHomePopularEvents,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _scrollCtrl.animateTo(
                    _scrollCtrl.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                  ),
                  child: Text(
                    '${AppLocalizations.of(context)!.seeAll} →',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 280,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _popularEvents.length > 3
                    ? 4
                    : _popularEvents.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  // if (_popularEvents.length > 3 && i == 3) {
                  //   return _buildSeeMoreCard(
                  //     () => _scrollCtrl.animateTo(
                  //       _scrollCtrl.position.maxScrollExtent,
                  //       duration: const Duration(milliseconds: 400),
                  //       curve: Curves.easeOut,
                  //     ),
                  //   );
                  // }
                  final event = _popularEvents[i];
                  return SizedBox(
                    width: 195,
                    child: EventCard(
                      event: event,
                      compact: false,
                      onTap: event.idEvenement != null
                          ? () => Navigator.pushNamed(
                              context,
                              ClientRoutes.homeDetail,
                              arguments: {'id': event.idEvenement},
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
          if (hasRecommended) ...[
            Text(
              'Recommandé pour vous',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _recommendedEvents.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final event = _recommendedEvents[i];
                  return SizedBox(
                    width: 260,
                    child: EventCard(
                      event: event,
                      compact: false,
                      onTap: event.idEvenement != null
                          ? () => Navigator.pushNamed(
                              context,
                              ClientRoutes.homeDetail,
                              arguments: {'id': event.idEvenement},
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
          Text(
            AppLocalizations.of(context)!.clientHomeFeatured,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          if (_events.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.clientHomeNoEvents,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            ..._events.map(
              (event) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: EventCard(
                  event: event,
                  onTap: event.idEvenement != null
                      ? () => Navigator.pushNamed(
                          context,
                          ClientRoutes.homeDetail,
                          arguments: {'id': event.idEvenement},
                        )
                      : null,
                ),
              ),
            ),
          if (!_promoDismissed) ...[
            const SizedBox(height: 8),
            _buildPromoBanner(),
          ],
        ],
      ),
    );
  }

  Widget _buildSeeMoreCard(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.primary,
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              AppLocalizations.of(context)!.seeAll,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF7C4DFF), Color(0xFF9C27B0)],
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
                  Text(
                    AppLocalizations.of(context)!.clientHomePromoTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.clientHomePromoSubtitle,
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
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
