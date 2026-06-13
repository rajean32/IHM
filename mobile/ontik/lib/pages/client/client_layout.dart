import 'package:flutter/material.dart';
import '../../core/api/dio_config.dart';
import '../../core/routes/auth_routes.dart';
import '../../core/assets/app_colors.dart';
import 'client_profile_page.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'tickets_page.dart';

class ClientLayout extends StatefulWidget {
  const ClientLayout({super.key});

  @override
  State<ClientLayout> createState() => _ClientLayoutState();
}

class _ClientLayoutState extends State<ClientLayout> {
  int _currentIndex = 0;

  // Liste des pages
  final List<Widget> _pages = [
    const HomePage(),
    const MyTicketsPage(), // Page des tickets
    const ClientProfilePage(), // Page profil client
  ];

  void _logout() async {
    await clearSession();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AuthRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'lib/utils/logo_icon.png',
              height: 28,
              fit: BoxFit.contain,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            const Text('Ontik'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: _logout,
          ),
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
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.event),
            label: 'Événements',
          ),
          NavigationDestination(
            icon: Icon(Icons.confirmation_number),
            label: 'Mes billets',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}