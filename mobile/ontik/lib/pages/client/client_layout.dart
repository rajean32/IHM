import 'package:flutter/material.dart';
import '../../core/api/dio_config.dart';
import '../../core/services/notification_service.dart';
import '../../widgets/notification_bell.dart';
import '../../generated/app_localizations.dart';
import 'home_page.dart';
import '../ticket/ticket_list_page.dart';
import 'client_profile_page.dart';

class ClientLayout extends StatefulWidget {
  const ClientLayout({super.key});

  @override
  State<ClientLayout> createState() => _ClientLayoutState();
}

class _ClientLayoutState extends State<ClientLayout> {
  int _currentIndex = 0;

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

  final List<Widget> _pages = [
    const HomePage(),
    const TicketListPage(),
    const ClientProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(
              'lib/utils/logo_icon.png',
              height: 35,
              fit: BoxFit.contain,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            const Text('Ontik'),
          ],
        ),
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
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.event),
            label: AppLocalizations.of(context)!.clientHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.confirmation_number),
            label: AppLocalizations.of(context)!.clientTickets,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person),
            label: AppLocalizations.of(context)!.clientAccount,
          ),
        ],
      ),
    );
  }
}