import 'package:flutter/material.dart';
import '../../generated/app_localizations.dart';
import 'package:ontik/core/assets/app_colors.dart';
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

  void _navigateToPlaces(String? salleFilter) {
    setState(() { _placesSalleFilter = salleFilter; _selectedIndex = 6; });
  }

  void _onItemTapped(int index) {
    if (index == 4) {
      _showMoreSheet();
      return;
    }
    if (_selectedIndex == 6) setState(() => _placesSalleFilter = null);
    setState(() => _selectedIndex = index);
  }

  void _showMoreSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.adminMoreOptions, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 24),
            _sheetOption(ctx, Icons.location_city, AppLocalizations.of(context)!.adminVenues, () { Navigator.pop(ctx); setState(() => _selectedIndex = 5); }),
            _sheetOption(ctx, Icons.event_seat, AppLocalizations.of(context)!.adminPlaces, () { Navigator.pop(ctx); setState(() { _placesSalleFilter = null; _selectedIndex = 6; }); }),
            _sheetOption(ctx, Icons.confirmation_number, AppLocalizations.of(context)!.adminTickets, () { Navigator.pop(ctx); setState(() => _selectedIndex = 7); }),
            _sheetOption(ctx, Icons.book_online, AppLocalizations.of(context)!.adminReservations, () { Navigator.pop(ctx); setState(() => _selectedIndex = 8); }),
            _sheetOption(ctx, Icons.payment, AppLocalizations.of(context)!.adminPayments, () { Navigator.pop(ctx); setState(() => _selectedIndex = 9); }),
            _sheetOption(ctx, Icons.person, AppLocalizations.of(context)!.adminAccount, () { Navigator.pop(ctx); setState(() => _selectedIndex = 10); }),
            _sheetOption(ctx, Icons.history, AppLocalizations.of(context)!.adminActionHistory, () { Navigator.pop(ctx); setState(() => _selectedIndex = 11); }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sheetOption(BuildContext ctx, IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  Widget _buildBody() {
    if (_selectedIndex <= 3) {
      return IndexedStack(
        index: _selectedIndex,
        children: const [
          DashboardPage(),
          UsersPage(),
          EventsPage(),
          CategoriesPage(),
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
        leading: ModalRoute.of(context)?.canPop == true
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 22),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
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
