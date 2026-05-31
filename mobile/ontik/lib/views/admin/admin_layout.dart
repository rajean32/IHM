import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/auth_controller.dart';

class AdminLayout extends ConsumerWidget {
  final Widget child;

  const AdminLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.indigo),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.admin_panel_settings, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text('Administration', style: TextStyle(color: Colors.white, fontSize: 20)),
                  Text('Gestion de la plateforme', style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            _drawerItem(context, Icons.dashboard, 'Dashboard', '/admin'),
            _drawerItem(context, Icons.people, 'Utilisateurs', '/admin/users'),
            _drawerItem(context, Icons.event, 'Événements', '/admin/events'),
            _drawerItem(context, Icons.category, 'Catégories', '/admin/categories'),
            const Divider(),
            _drawerItem(context, Icons.location_city, 'Lieux', '/admin/lieux'),
            _drawerItem(context, Icons.meeting_room, 'Salles & Places', '/admin/salle-places'),
            const Divider(),
            _drawerItem(context, Icons.confirmation_number, 'Tickets', '/admin/tickets'),
            _drawerItem(context, Icons.book_online, 'Réservations', '/admin/reservations'),
            _drawerItem(context, Icons.payment, 'Paiements', '/admin/payments'),
          ],
        ),
      ),
      body: child,
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String label, String route) {
    final isActive = ModalRoute.of(context)?.settings.name == route ||
        ModalRoute.of(context)?.settings.name?.startsWith(route) == true;
    return ListTile(
      leading: Icon(icon, color: isActive ? Colors.indigo : null),
      title: Text(label, style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      selected: isActive,
      selectedTileColor: Colors.indigo.withValues(alpha: 0.08),
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
    );
  }
}
