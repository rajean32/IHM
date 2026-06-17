import 'package:flutter/material.dart';
import '../../core/api/dio_config.dart';
import '../../core/services/notification_service.dart';
import '../../core/assets/app_colors.dart';
import '../../widgets/notification_bell.dart';
import '../../localization/app_localizations.dart';
import 'dashboard_page.dart';
import 'users_page.dart';
import 'events_page.dart';
import 'categories_page.dart';
import 'lieux_page.dart';
import 'places_page.dart';
import 'tickets_page.dart';
import 'reservations_page.dart';
import 'payments_page.dart';
import 'profile_page.dart';

class AdminLayout extends StatefulWidget {
  const AdminLayout({super.key});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  int _selectedIndex = 0;
  String? _placesSalleFilter;

  @override
  void initState() {
    super.initState();
    if (userCode != null) {
      NotificationManager.connect(userCode!, null);
    }
  }

  @override
  void dispose() {
    NotificationManager.disconnect();
    super.dispose();
  }

  void _navigateToPlaces(String? salleFilter) {
    setState(() {
      _placesSalleFilter = salleFilter;
      _selectedIndex = 5;
    });
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
      const AdminProfilePage(),
    ];

    final navDestinations = [
      NavigationRailDestination(icon: const Icon(Icons.dashboard), label: Text(tr('admin.dashboard'))),
      NavigationRailDestination(icon: const Icon(Icons.people), label: Text(tr('admin.users'))),
      NavigationRailDestination(icon: const Icon(Icons.event), label: Text(tr('admin.events'))),
      NavigationRailDestination(icon: const Icon(Icons.category), label: Text(tr('admin.categories'))),
      NavigationRailDestination(icon: const Icon(Icons.location_city), label: Text(tr('admin.venues'))),
      NavigationRailDestination(icon: const Icon(Icons.meeting_room), label: Text(tr('admin.places'))),
      NavigationRailDestination(icon: const Icon(Icons.confirmation_number), label: Text(tr('admin.tickets'))),
      NavigationRailDestination(icon: const Icon(Icons.book_online), label: Text(tr('admin.reservations'))),
      NavigationRailDestination(icon: const Icon(Icons.payment), label: Text(tr('admin.payments'))),
      NavigationRailDestination(icon: const Icon(Icons.person), label: Text(tr('admin.account'))),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: ModalRoute.of(context)?.canPop == true
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 22),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Row(children: [
          Image.asset('lib/utils/logo_icon.png', height: 35, fit: BoxFit.contain, color: Colors.white),
          const SizedBox(width: 8),
          Text(tr('admin.layout.title')),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          const NotificationBell(),
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
