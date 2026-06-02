import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF1565C0);
  static const primaryDark = Color(0xFF0D47A1);
  static const primaryLight = Color(0xFF42A5F5);
  static const secondary = Color(0xFF00C853);
  static const accent = Color(0xFFFF6F00);
  static const surface = Color(0xFFF0F2F5);
  static const card = Color(0xFFFFFFFF);
  static const error = Color(0xFFD32F2F);
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
  static const divider = Color(0xFFE5E7EB);
  static const fieldFill = Color(0xFFF5F7FA);
}

class AppConstants {
  static const currency = 'Ar';
  static const roleAdmin = 'ADMINISTRATEUR';
  static const roleOrganisateur = 'ORGANISATEUR';
  static const roleClient = 'CLIENT';

  static const placeTypes = ['Standard', 'VIP', 'Premium', 'Orchestre', 'Balcon', 'Loge'];

  static const Map<String, Color> placeTypeColors = {
    'Standard': Color(0xFF1565C0),
    'VIP': Color(0xFFD32F2F),
    'Premium': Color(0xFFFF6F00),
    'Orchestre': Color(0xFF7B1FA2),
    'Balcon': Color(0xFF00897B),
    'Loge': Color(0xFF5C6BC0),
  };

  static const Map<String, Color> statutColors = {
    'planifie': Color(0xFF1565C0),
    'valide': Color(0xFF00C853),
    'en_cours': Color(0xFFFF6F00),
    'termine': Color(0xFF6B7280),
    'annule': Color(0xFFD32F2F),
    'suspendu': Color(0xFFE65100),
  };

  static const Map<String, IconData> statutIcons = {
    'planifie': Icons.schedule,
    'valide': Icons.check_circle,
    'en_cours': Icons.play_circle,
    'termine': Icons.check_circle_outline,
    'annule': Icons.cancel,
    'suspendu': Icons.pause_circle,
  };
}

class AppTheme {
  static const primaryColor = AppColors.primary;
  static const primaryDark = AppColors.primaryDark;
  static const primaryLight = AppColors.primaryLight;
  static const secondaryColor = AppColors.secondary;
  static const accentColor = AppColors.accent;
  static const surfaceColor = AppColors.surface;
  static const cardColor = AppColors.card;
  static const errorColor = AppColors.error;
  static const textPrimary = AppColors.textPrimary;
  static const textSecondary = AppColors.textSecondary;
  static const dividerColor = AppColors.divider;

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: AppColors.primary,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.surface,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.card,
      indicatorColor: AppColors.primary.withValues(alpha: 0.15),
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      isDense: true,
    ),
    dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1, space: 1),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
