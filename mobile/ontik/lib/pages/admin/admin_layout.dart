import 'package:flutter/material.dart';
import '../../generated/app_localizations.dart';
import 'package:ontik/core/routes/shared_routes.dart';
import 'package:ontik/widgets/notification_bell.dart';
import 'dashboard/dashboard_page.dart';
import 'users/users_page.dart';
import 'events/events_page.dart';
import 'categories/categories_page.dart';
import 'lieux/lieux_page.dart';
import 'places/places_page.dart';
import 'tickets/tickets_page.dart';
import 'reservations/reservations_page.dart';
import 'payments/payments_page.dart';
import 'profile/profile_page.dart';
import 'history/action_history_page.dart';

class AdminLayout extends StatefulWidget {
  const AdminLayout({super.key});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  int _selectedIndex = 0;
  String? _placesSalleFilter;
  final Map<int, int> _tabRefreshCounters = {};

  void _navigateToPlaces(String? salleFilter) {
    setState(() { _placesSalleFilter = salleFilter; _selectedIndex = 6; });
  }

  void _onItemTapped(int index) {
    if (index == 4) {
      _showMoreSheet();
      return;
    }
    if (_selectedIndex == 6) setState(() => _placesSalleFilter = null);
    setState(() {
      _selectedIndex = index;
      _tabRefreshCounters[index] = (_tabRefreshCounters[index] ?? 0) + 1;
    });
  }

  void _showMoreSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 6),
              Container(
                width: 32, height: 3,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Text(AppLocalizations.of(context)!.adminMoreOptions, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
              const Divider(height: 8),
              _sheetOption(ctx, Icons.location_city, AppLocalizations.of(context)!.adminVenues, () { Navigator.pop(ctx); setState(() => _selectedIndex = 5); }),
              _sheetOption(ctx, Icons.event_seat, AppLocalizations.of(context)!.adminPlaces, () { Navigator.pop(ctx); setState(() { _placesSalleFilter = null; _selectedIndex = 6; }); }),
              _sheetOption(ctx, Icons.confirmation_number, AppLocalizations.of(context)!.adminTickets, () { Navigator.pop(ctx); setState(() => _selectedIndex = 7); }),
              _sheetOption(ctx, Icons.book_online, AppLocalizations.of(context)!.adminReservations, () { Navigator.pop(ctx); setState(() => _selectedIndex = 8); }),
              _sheetOption(ctx, Icons.payment, AppLocalizations.of(context)!.adminPayments, () { Navigator.pop(ctx); setState(() => _selectedIndex = 9); }),
              _sheetOption(ctx, Icons.person, AppLocalizations.of(context)!.adminAccount, () { Navigator.pop(ctx); setState(() => _selectedIndex = 10); }),
              _sheetOption(ctx, Icons.history, AppLocalizations.of(context)!.adminActionHistory, () { Navigator.pop(ctx); setState(() => _selectedIndex = 11); }),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetOption(BuildContext ctx, IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
      trailing: Icon(Icons.chevron_right, size: 20, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
      onTap: onTap,
    );
  }

  Widget _buildBody() {
    if (_selectedIndex <= 3) {
      return IndexedStack(
        index: _selectedIndex,
        children: [
          DashboardPage(key: ValueKey('dash_${_tabRefreshCounters[0] ?? 0}')),
          UsersPage(key: ValueKey('users_${_tabRefreshCounters[1] ?? 0}')),
          EventsPage(key: ValueKey('events_${_tabRefreshCounters[2] ?? 0}')),
          CategoriesPage(key: ValueKey('cats_${_tabRefreshCounters[3] ?? 0}')),
        ],
      );
    }
    switch (_selectedIndex) {
      case 5: return LieuxPage(onGestionPlaces: _navigateToPlaces);
      case 6: return PlacesPage(initialSalleFilter: _placesSalleFilter, onBack: () => setState(() => _selectedIndex = 5));
      case 7: return const TicketsPage();
      case 8: return const ReservationsPage();
      case 9: return const PaymentsPage();
      case 10: return const ProfilePage();
      case 11: return const ActionHistoryPage();
      default: return const DashboardPage();
    }
  }

  int get _navIndex {
    if (_selectedIndex <= 3) return _selectedIndex;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Row(
          children: [
            Image.asset('lib/utils/logo_icon.png', height: 28),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.adminLayoutTitle, style: const TextStyle(fontSize: 16)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, SharedRoutes.settings),
          ),
          const NotificationBell(),
        ],
      ),
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: _onItemTapped,
        destinations: [
          NavigationDestination(icon: const Icon(Icons.dashboard_outlined), selectedIcon: const Icon(Icons.dashboard), label: AppLocalizations.of(context)!.adminDashboard),
          NavigationDestination(icon: const Icon(Icons.people_outlined), selectedIcon: const Icon(Icons.people), label: AppLocalizations.of(context)!.adminUsers),
          NavigationDestination(icon: const Icon(Icons.event_outlined), selectedIcon: const Icon(Icons.event), label: AppLocalizations.of(context)!.adminEvents),
          NavigationDestination(icon: const Icon(Icons.category_outlined), selectedIcon: const Icon(Icons.category), label: AppLocalizations.of(context)!.adminConfig),
          NavigationDestination(icon: const Icon(Icons.more_horiz), selectedIcon: const Icon(Icons.more_horiz), label: AppLocalizations.of(context)!.adminMore),
        ],
      ),
    );
  }
}
