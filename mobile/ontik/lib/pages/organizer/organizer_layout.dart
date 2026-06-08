import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'event_page.dart';
import 'profile_page.dart';
import 'tickets_page.dart';
import 'reservations_page.dart';

class OrganizerLayout extends StatefulWidget {
  const OrganizerLayout({super.key});

  @override
  State<OrganizerLayout> createState() => _OrganizerLayoutState();
}

class _OrganizerLayoutState extends State<OrganizerLayout> {
  int _currentIndex = 0;

  void _navigateToTicket(int eventId) {
    setState(() => _currentIndex = 2);
  }

  void _navigateToReservation(int eventId) {
    setState(() => _currentIndex = 3);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Image.asset('lib/utils/logo_icon.png', height: 28, fit: BoxFit.contain, color: Colors.white),
          const SizedBox(width: 8),
          const Text('Ontik - Organisateur'),
        ]),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const DashboardPage(),
          EventPage(
            onViewTickets: _navigateToTicket,
            onViewReservations: _navigateToReservation,
          ),
          const TicketsPage(),
          const ReservationsPage(),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.event), label: '\u00C9v\u00E9nements'),
          NavigationDestination(icon: Icon(Icons.confirmation_number), label: 'Tickets'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'R\u00E9servations'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Compte'),
        ],
      ),
    );
  }
}
