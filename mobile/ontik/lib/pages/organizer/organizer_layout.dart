import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'event_page.dart';
import 'profile_page.dart';

class OrganizerLayout extends StatefulWidget {
  const OrganizerLayout({super.key});

  @override
  State<OrganizerLayout> createState() => _OrganizerLayoutState();
}

class _OrganizerLayoutState extends State<OrganizerLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    EventPage(),
    ProfilePage(),
  ];

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
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.event), label: '\u00C9v\u00E9nements'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Compte'),
        ],
      ),
    );
  }
}
