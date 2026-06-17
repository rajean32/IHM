import 'package:flutter/material.dart';
import '../../core/api/dio_config.dart';
import '../../core/services/app_config.dart';
import '../../core/services/evenement_service.dart';
import '../../core/services/notification_service.dart';
import '../../models/evenement_model.dart';
import '../../widgets/notification_bell.dart';
import 'dashboard_page.dart';
import 'event_page.dart';
import 'profile_page.dart';
import '../../generated/app_localizations.dart';
import 'reservations_page.dart';

class OrganizerLayout extends StatefulWidget {
  const OrganizerLayout({super.key});

  @override
  State<OrganizerLayout> createState() => _OrganizerLayoutState();
}

class _OrganizerLayoutState extends State<OrganizerLayout> {
  int _currentIndex = 0;
  List<Evenement> _events = [];

  @override
  void initState() {
    super.initState();
    if (userCode != null) {
      NotificationManager.connect(userCode!, null);
      _loadEvents();
    }
  }

  @override
  void dispose() {
    NotificationManager.disconnect();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    try {
      final data = await EvenementService().getEvents(orgCode: userCode ?? '');
      if (!mounted) return;
      setState(() {
        _events = data.map((e) => Evenement.fromJson(e as Map<String, dynamic>)).toList();
      });
    } catch (_) {} 

  }

  void _navigateToEvents() {
    setState(() => _currentIndex = 1);
  }

  void _navigateToReservation(int eventId) {
    try {
      final ev = _events.firstWhere((e) => e.idEvenement == eventId);
      setActiveEvent(eventId, ev.titre);
    } catch (_) {
      setActiveEvent(eventId, '');
    }
    setState(() => _currentIndex = 2);
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
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        scrolledUnderElevation: 1.0,
        centerTitle: false,
        title: Row(children: [
          Image.asset('lib/utils/logo_icon.png', height: 28, fit: BoxFit.contain, color: Colors.white),
          const SizedBox(width: 8),
          Text(AppLocalizations.of(context)!.layoutTitle),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          const NotificationBell(),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardPage(onNavigateToEvents: _navigateToEvents),
          EventPage(
            onViewReservations: _navigateToReservation,
          ),
          const ReservationsPage(),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.dashboard), label: AppLocalizations.of(context)!.dashboard),
          NavigationDestination(icon: const Icon(Icons.event), label: AppLocalizations.of(context)!.events),
          NavigationDestination(icon: const Icon(Icons.receipt_long), label: AppLocalizations.of(context)!.reservations),
          NavigationDestination(icon: const Icon(Icons.person), label: AppLocalizations.of(context)!.account),
        ],
      ),
    );
  }
}
