import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/assets/app_colors.dart';
import 'dashboard_page.dart';
import 'users_page.dart';
import 'events_page.dart';
import 'categories_page.dart';
import 'lieux_page.dart';
import 'places_page.dart';
import 'tickets_page.dart';
import 'reservations_page.dart';
import 'payments_page.dart';

class AdminLayout extends StatefulWidget {
  const AdminLayout({super.key});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  int _selectedIndex = 0;
  String? _placesSalleFilter;

  void _navigateToPlaces(String? salleFilter) {
    setState(() {
      _placesSalleFilter = salleFilter;
      _selectedIndex = 5;
    });
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const DashboardPage(),
      const UsersPage(),
      const EventsPage(),
      const CategoriesPage(),
      LieuxPage(onGestionPlaces: _navigateToPlaces),
      PlacesPage(
        key: ValueKey(_placesSalleFilter ?? '__all__'),
        initialSalleFilter: _placesSalleFilter,
      ),
      const TicketsPage(),
      const ReservationsPage(),
      const PaymentsPage(),
    ];

    final navDestinations = [
      const NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Dashboard')),
      const NavigationRailDestination(icon: Icon(Icons.people), label: Text('Utilisateurs')),
      const NavigationRailDestination(icon: Icon(Icons.event), label: Text('Événements')),
      const NavigationRailDestination(icon: Icon(Icons.category), label: Text('Catégories')),
      const NavigationRailDestination(icon: Icon(Icons.location_city), label: Text('Lieux')),
      const NavigationRailDestination(icon: Icon(Icons.meeting_room), label: Text('Places')),
      const NavigationRailDestination(icon: Icon(Icons.confirmation_number), label: Text('Tickets')),
      const NavigationRailDestination(icon: Icon(Icons.book_online), label: Text('Réservations')),
      const NavigationRailDestination(icon: Icon(Icons.payment), label: Text('Paiements')),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Image.asset('lib/utils/logo_icon.png', height: 28, fit: BoxFit.contain, color: Colors.white),
          const SizedBox(width: 8),
          const Text('Admin Panel'),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) => setState(() {
              _selectedIndex = i;
              if (i != 5) _placesSalleFilter = null;
            }),
            labelType: NavigationRailLabelType.all,
            backgroundColor: AppColors.card,
            indicatorColor: AppColors.primary.withValues(alpha: 0.15),
            selectedIconTheme: const IconThemeData(color: AppColors.primary),
            unselectedIconTheme: IconThemeData(color: AppColors.textSecondary),
            selectedLabelTextStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12),
            unselectedLabelTextStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            destinations: navDestinations,
          ),
          const VerticalDivider(width: 1, color: AppColors.divider),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: pages,
            ),
          ),
        ],
      ),
    );
  }
}
