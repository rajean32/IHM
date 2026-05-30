import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/event_controller.dart';
import '../../controllers/providers.dart';
import '../../models/categorie.dart';
import '../../models/venue.dart';
import '../../widgets/event_card.dart';
import 'my_reservations_view.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  final _searchCtrl = TextEditingController();
  String? _selectedCategorie;
  String? _selectedStatut;
  int? _selectedLieu;
  DateTimeRange? _selectedDateRange;
  double? _prixMin;
  double? _prixMax;
  int _currentIndex = 0;
  List<Lieu> _lieux = [];
  List<Categorie> _categories = [];
  final _scrollCtrl = ScrollController();

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
      ref.read(eventListProvider.notifier).loadMore();
    }
  }

  Future<void> _loadFilterData() async {
    try {
      final lieuRepo = ref.read(lieuRepositoryProvider);
      final catRepo = ref.read(categorieRepositoryProvider);
      final lieux = await lieuRepo.getAll();
      final cats = await catRepo.getAll();
      if (!mounted) return;
      setState(() {
        _lieux = lieux;
        _categories = cats;
      });
    } catch (_) {}
  }

  void _applyFilters() {
    ref.read(eventListProvider.notifier).search(
      q: _searchCtrl.text.isEmpty ? null : _searchCtrl.text,
      categorie: _selectedCategorie,
      statut: _selectedStatut,
      idLieu: _selectedLieu,
      prixMin: _prixMin,
      prixMax: _prixMax,
    );
  }

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
                    const Text('Filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                      child: const Text('Reset'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedStatut,
                  decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                  items: _statusOptions.map((s) => DropdownMenuItem(
                    value: s == 'Tous' ? null : s,
                    child: Text(s == 'Tous' ? 'All' : s),
                  )).toList(),
                  onChanged: (v) => setSheetState(() => _selectedStatut = v),
                ),
                const SizedBox(height: 16),
                const Text('Venue', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: _selectedLieu,
                  decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Venues')),
                    ..._lieux.map((l) => DropdownMenuItem(
                      value: l.idLieu,
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
                          ? '${_selectedDateRange!.start.toIso8601String().split('T').first} — ${_selectedDateRange!.end.toIso8601String().split('T').first}'
                          : 'Select date range',
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
                      child: Text('—'),
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
                  child: const Text('Apply Filters'),
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
    final eventState = ref.watch(eventListProvider);
    final authState = ref.watch(authControllerProvider);

    final pages = [
      _buildEventList(eventState),
      const MyReservationsView(),
      _buildProfilePage(authState),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ontik'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Search events...',
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
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _buildCategoryChip('All', null),
                ..._categories.map((c) => _buildCategoryChip(c.nomCategorie, c.codeCategorie)),
              ],
            ),
          ),
          Expanded(child: pages[_currentIndex]),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.event), label: 'Events'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'My Tickets'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
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

  Widget _buildEventList(EventListState state) {
    if (state.isLoading) return const Center(child: CircularProgressIndicator());
    if (state.error != null) return Center(child: Text(state.error!));
    if (state.events.isEmpty) return const Center(child: Text('No events found'));

    return RefreshIndicator(
      onRefresh: () => ref.read(eventListProvider.notifier).loadUpcoming(),
      child: ListView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.events.length + (ref.read(eventListProvider.notifier).hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.events.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final event = state.events[index];
          return EventCard(
            event: event,
            onTap: () => context.push('/event/${event.idEvenement}'),
          );
        },
      ),
    );
  }

  Widget _buildProfilePage(AuthState authState) {
    final user = authState.user;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const CircleAvatar(
          radius: 48,
          child: Icon(Icons.person, size: 48),
        ),
        const SizedBox(height: 16),
        Text(
          user?.email ?? 'User',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          user?.role ?? 'CLIENT',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.receipt_long),
          title: const Text('My Reservations'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/my-reservations'),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Logout', style: TextStyle(color: Colors.red)),
          onTap: () => ref.read(authControllerProvider.notifier).logout(),
        ),
      ],
    );
  }
}
