import 'package:flutter/material.dart';
import 'package:ontik/models/user_model.dart';
import 'package:ontik/core/assets/app_colors.dart';
import 'package:ontik/widgets/admin/admin_section_header.dart';

class UserDetailsSheet extends StatelessWidget {
  final UserDetail user;
  final VoidCallback? onToggleActive;
  final VoidCallback? onChangeRole;
  final VoidCallback? onResetPassword;
  final VoidCallback? onDelete;

  const UserDetailsSheet({
    super.key,
    required this.user,
    this.onToggleActive,
    this.onChangeRole,
    this.onResetPassword,
    this.onDelete,
  });

  static void show(BuildContext context, {required UserDetail user, VoidCallback? onToggleActive, VoidCallback? onChangeRole, VoidCallback? onResetPassword, VoidCallback? onDelete}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          child: UserDetailsSheet(user: user, onToggleActive: onToggleActive, onChangeRole: onChangeRole, onResetPassword: onResetPassword, onDelete: onDelete),
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'ADMINISTRATEUR': return AppColors.error;
      case 'ORGANISATEUR': return AppColors.accent;
      case 'CLIENT': return AppColors.primary;
      default: return AppColors.textSecondary;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'ADMINISTRATEUR': return Icons.admin_panel_settings;
      case 'ORGANISATEUR': return Icons.badge;
      default: return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleColor = _getRoleColor(user.role);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 32, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(radius: 30, backgroundColor: roleColor.withValues(alpha: 0.15), child: Text(user.prenoms.isNotEmpty ? user.prenoms[0].toUpperCase() : '?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: roleColor))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${user.prenoms} ${user.nom}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: roleColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getRoleIcon(user.role), size: 14, color: roleColor),
                          const SizedBox(width: 4),
                          Text(user.role, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: roleColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildChip(user.actif ? 'Actif' : 'Inactif', user.actif ? AppColors.secondary : AppColors.error),
              if (user.premiereConnexion) ...[
                const SizedBox(width: 8),
                _buildChip('Première connexion', AppColors.accent),
              ],
            ],
          ),
          AdminSectionHeader(icon: Icons.person_outline, title: 'Informations personnelles'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _infoRow(Icons.badge, 'Code', user.codeUtilisateur),
                  _infoRow(Icons.email, 'Email', user.email),
                  _infoRow(Icons.phone, 'Téléphone', user.tel),
                  if (user.sexe != null) _infoRow(Icons.wc, 'Sexe', user.sexe!),
                  if (user.dateDeNaissance != null) _infoRow(Icons.cake, 'Date naissance', user.dateDeNaissance!),
                ],
              ),
            ),
          ),
          AdminSectionHeader(icon: Icons.account_circle, title: 'Informations du compte'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _infoRow(Icons.badge, 'Rôle', user.role, valueColor: roleColor),
                  _infoRow(Icons.circle, 'Statut', user.actif ? 'Actif' : 'Inactif', valueColor: user.actif ? AppColors.secondary : AppColors.error),
                  _infoRow(Icons.login, 'Première connexion', user.premiereConnexion ? 'Oui' : 'Non', valueColor: user.premiereConnexion ? AppColors.accent : AppColors.textSecondary),
                ],
              ),
            ),
          ),
          AdminSectionHeader(icon: Icons.settings, title: 'Actions'),
          const SizedBox(height: 8),
          _actionButton(icon: Icons.swap_horiz, label: 'Changer le rôle', color: AppColors.primary, onTap: () { Navigator.pop(context); onChangeRole?.call(); }),
          const SizedBox(height: 8),
          _actionButton(icon: user.actif ? Icons.block : Icons.check_circle, label: user.actif ? 'Désactiver' : 'Activer', color: user.actif ? AppColors.error : AppColors.secondary, onTap: () { Navigator.pop(context); onToggleActive?.call(); }),
          const SizedBox(height: 8),
          _actionButton(icon: Icons.lock_reset, label: 'Réinitialiser mot de passe', color: AppColors.accent, onTap: () { Navigator.pop(context); onResetPassword?.call(); }),
          const SizedBox(height: 8),
          _actionButton(icon: Icons.delete, label: 'Supprimer utilisateur', color: AppColors.error, onTap: () { Navigator.pop(context); onDelete?.call(); }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
          Expanded(child: Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: valueColor ?? AppColors.textPrimary))),
        ],
      ),
    );
  }

  Widget _actionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.5)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
