import 'package:flutter/material.dart';
import '../../core/api/dio_config.dart';
import '../../core/routes/client_routes.dart';
import '../../core/assets/app_colors.dart';

class ClientProfilePage extends StatelessWidget {
  const ClientProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const CircleAvatar(
          radius: 48,
          child: Icon(Icons.person, size: 48),
        ),
        const SizedBox(height: 16),
        Text(
          userNom ?? 'Utilisateur',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          userRole ?? 'CLIENT',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.receipt_long),
          title: const Text('Mes Réservations'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.pushNamed(context, ClientRoutes.profile),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.payment),
          title: const Text('Historique des paiements'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Naviguer vers historique paiements
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: AppColors.error),
          title: const Text('Déconnexion', style: TextStyle(color: AppColors.error)),
          onTap: () async {
            await clearSession();
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          },
        ),
      ],
    );
  }
}