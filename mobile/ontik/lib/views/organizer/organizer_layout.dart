import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrganizerLayout extends StatelessWidget {
  final Widget child;
  const OrganizerLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ontik - Organisateur')),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateIndex(context),
        onDestinationSelected: (i) => _onTab(context, i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.event), label: 'Événements'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Compte'),
        ],
      ),
    );
  }

  int _calculateIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    if (loc == '/organizer') return 0;
    if (loc.startsWith('/organizer/events')) return 1;
    if (loc.startsWith('/organizer/account')) return 2;
    return 0;
  }

  void _onTab(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/organizer');
      case 1: context.go('/organizer/events');
      case 2: context.go('/organizer/account');
    }
  }
}
