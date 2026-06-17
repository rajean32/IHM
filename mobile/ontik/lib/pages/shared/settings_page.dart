import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import '../../generated/app_localizations.dart';
import '../../core/services/app_config.dart';
import '../../core/assets/app_colors.dart';
import '../../widgets/two_factor_widget.dart';
import '../../widgets/admin/admin_toast.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _is2faEnabled = false;

  @override
  void initState() {
    super.initState();
    appConfigNotifier.addListener(_onConfigChanged);
  }

  @override
  void dispose() {
    appConfigNotifier.removeListener(_onConfigChanged);
    super.dispose();
  }

  void _onConfigChanged() {
    if (mounted) setState(() {});
  }

  void _showPasswordAnd2FA() {
    showPasswordAnd2FABottomSheet(
      context,
      _is2faEnabled,
      (val) {
        if (mounted) setState(() => _is2faEnabled = val);
      },
    );
  }

  void _showConnectedDevices() {
    final deviceName = Platform.isAndroid ? 'Android' : Platform.isIOS ? 'iOS' : 'Web';
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx)!;
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.settingsConnectedDevices,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.phone_android, size: 32, color: AppColors.primary),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(deviceName, style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(l10n.settingsCurrentDevice,
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(l10n.settingsActive, style: const TextStyle(fontSize: 11, color: AppColors.secondary)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    AdminToast.show(context, message: l10n.settingsOthersDisconnected, isSuccess: true);
                  },
                  icon: const Icon(Icons.logout, size: 18),
                  label: Text(l10n.settingsDisconnectOthers),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLang = appLanguage;
    final currentTheme = appThemeMode;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: ModalRoute.of(context)?.canPop == true
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 22),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Text(l10n.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _sectionHeader(Icons.tune, l10n.settingsPreferences),
          const SizedBox(height: 4),
          _sectionSubHeader(l10n.settingsLanguage),
          const SizedBox(height: 6),
          _langTile('fr', l10n.settingsLanguageFr, currentLang == 'fr' ? cs.primary : null),
          _langTile('en', l10n.settingsLanguageEn, currentLang == 'en' ? cs.primary : null),
          const SizedBox(height: 16),
          _sectionSubHeader(l10n.settingsAppearance),
          const SizedBox(height: 6),
          _themeTile('light', l10n.settingsThemeLight, currentTheme == 'light', Icons.light_mode),
          _themeTile('dark', l10n.settingsThemeDark, currentTheme == 'dark', Icons.dark_mode),
          _themeTile('system', l10n.settingsThemeSystem, currentTheme == 'system', Icons.settings_brightness),
          const SizedBox(height: 24),
          _sectionHeader(Icons.shield_outlined, l10n.settingsSecurity),
          const SizedBox(height: 8),
          _securityTile(l10n.settingsPassword2fa, Icons.lock_outline, _showPasswordAnd2FA, l10n.settingsSecured),
          _securityTile(l10n.settingsConnectedDevices, Icons.devices_outlined, _showConnectedDevices),
          const SizedBox(height: 24),
          _sectionHeader(Icons.info_outline, l10n.settingsAbout),
          const SizedBox(height: 8),
          _actionTile(
            icon: Icons.info_outline,
            title: l10n.settingsAppVersion,
            trailing: Text('1.0.0', style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Row(children: [
      Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 6),
      Text(title, style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.primary,
      )),
    ]);
  }

  Widget _sectionSubHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(title, style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
      )),
    );
  }

  Widget _langTile(String code, String label, Color? activeColor) {
    final isSelected = activeColor != null;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected ? BorderSide(color: activeColor, width: 1.5) : BorderSide.none,
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        title: Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, fontSize: 14)),
        leading: Icon(Icons.language, color: isSelected ? activeColor : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: activeColor, size: 22)
            : Icon(Icons.radio_button_unchecked, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3), size: 20),
        onTap: () => setAppLanguage(code),
      ),
    );
  }

  Widget _themeTile(String value, String label, bool isSelected, IconData icon) {
    final color = isSelected ? Theme.of(context).colorScheme.primary : null;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected ? BorderSide(color: color!, width: 1.5) : BorderSide.none,
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        title: Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, fontSize: 14)),
        leading: Icon(icon, color: isSelected ? color : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: color, size: 22)
            : Icon(Icons.radio_button_unchecked, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3), size: 20),
        onTap: () => setAppTheme(value),
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    bool destructive = false,
    required VoidCallback onTap,
  }) {
    final c = destructive ? AppColors.error : Theme.of(context).colorScheme.primary;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Icon(icon, color: c, size: 22),
        title: Text(title, style: TextStyle(fontSize: 14, color: destructive ? AppColors.error : null)),
        subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))) : null,
        trailing: trailing ?? Icon(Icons.chevron_right, size: 20, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
        onTap: onTap,
      ),
    );
  }

  Widget _securityTile(String label, IconData icon, VoidCallback onTap, [String? status]) {
    return _actionTile(
      icon: icon,
      title: label,
      trailing: status != null ? _buildBadge(status, AppColors.secondary) : null,
      onTap: onTap,
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }

  void _showConfirmDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.commonCancel)),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                onConfirm();
              },
              child: Text(l10n.settingsConfirm, style: const TextStyle(color: AppColors.error)),
            ),
          ],
        );
      },
    );
  }
}
