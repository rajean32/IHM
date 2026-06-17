import 'package:flutter/material.dart';
import '../core/assets/app_colors.dart';
import '../generated/app_localizations.dart';

class ProfileStat {
  final String label;
  final String value;
  final IconData icon;
  const ProfileStat(this.label, this.value, this.icon);
}

class ProfileMenuItem {
  final String label;
  final IconData icon;
  final String? status;
  final VoidCallback? onTap;
  const ProfileMenuItem(this.label, this.icon, {this.status, this.onTap});
}

class ProfileMenuGroup {
  final String title;
  final List<ProfileMenuItem> items;
  const ProfileMenuGroup(this.title, this.items);
}

class ProfileBody extends StatelessWidget {
  final String name;
  final String email;
  final String badge;
  final Color badgeColor;
  final List<ProfileStat> stats;
  final List<ProfileMenuGroup> menuGroups;
  final VoidCallback? onLogout;
  final VoidCallback? onEditProfile;

  const ProfileBody({
    super.key,
    required this.name,
    required this.email,
    this.badge = 'VIP Member',
    this.badgeColor = const Color(0xFF9C27B0),
    this.stats = const [],
    this.menuGroups = const [],
    this.onLogout,
    this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFEF7FF),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          const SizedBox(height: 16),
          _buildProfileHeader(),
          const SizedBox(height: 20),
          if (stats.isNotEmpty) ...[
            _buildStatsRow(),
            const SizedBox(height: 24),
          ],
          ...menuGroups.map(_buildMenuGroup),
          if (onLogout != null) ...[
            const SizedBox(height: 8),
            _buildLogoutButton(context),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Material(
      color: Colors.transparent,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.divider.withValues(alpha: 0.5)),
        ),
        child: InkWell(
          onTap: onEditProfile,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF673AB7).withValues(alpha: 0.1),
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF673AB7),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      _buildBadge(),
                    ],
                  ),
                ),
                Icon(Icons.edit, size: 18, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        badge,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: badgeColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: stats.map((s) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(s.icon, size: 22, color: const Color(0xFF673AB7).withValues(alpha: 0.7)),
              const SizedBox(height: 6),
              Text(
                s.value,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              Text(
                s.label,
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuGroup(ProfileMenuGroup group) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              group.title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: List.generate(group.items.length, (i) {
                final item = group.items[i];
                return Column(
                  children: [
                    if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      leading: Icon(item.icon, size: 22, color: AppColors.textSecondary),
                      title: Text(
                        item.label,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                      ),
                      trailing: item.status != null
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.status!,
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.secondary),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
                              ],
                            )
                          : const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      onTap: item.onTap,
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: onLogout,
        icon: const Icon(Icons.logout, size: 18),
        label: Text(AppLocalizations.of(context)!.widgetsProfileLogout),
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFB00020),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
