import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/event_controller.dart';
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
  int _currentIndex = 0;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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
            padding: const EdgeInsets.all(16),
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
                    onSubmitted: (v) {
                      ref.read(eventListProvider.notifier).search(q: v, categorie: _selectedCategorie);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list),
                  onSelected: (v) {
                    setState(() => _selectedCategorie = v == 'All' ? null : v);
                    ref.read(eventListProvider.notifier).search(q: _searchCtrl.text, categorie: _selectedCategorie);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'All', child: Text('All')),
                    const PopupMenuItem(value: 'Concert', child: Text('Concert')),
                    const PopupMenuItem(value: 'Conference', child: Text('Conference')),
                    const PopupMenuItem(value: 'Sport', child: Text('Sport')),
                    const PopupMenuItem(value: 'Theatre', child: Text('Theatre')),
                  ],
                ),
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

  Widget _buildEventList(EventListState state) {
    if (state.isLoading) return const Center(child: CircularProgressIndicator());
    if (state.error != null) return Center(child: Text(state.error!));
    if (state.events.isEmpty) return const Center(child: Text('No events found'));

    return RefreshIndicator(
      onRefresh: () => ref.read(eventListProvider.notifier).loadUpcoming(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.events.length,
        itemBuilder: (context, index) {
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
