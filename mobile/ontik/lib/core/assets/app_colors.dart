import 'package:flutter/material.dart';

class AppColors {
  // Primary - Bleu profond
  static const primary = Color(0xFF1565C0);
  static const primaryDark = Color(0xFF0D47A1);
  static const primaryLight = Color(0xFF42A5F5);
  
  // Secondary - Vert succès
  static const secondary = Color(0xFF00C853);
  
  // Accent - Orange
  static const accent = Color(0xFFFF6F00);
  
  // Surface & Card
  static const surface = Color(0xFFF5F7FA);
  static const card = Color(0xFFFFFFFF);
  
  // Error
  static const error = Color(0xFFD32F2F);
  static const errorLight = Color(0xFFFFEBEE);
  
  // Text
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
  static const textMuted = Color(0xFF9CA3AF);
  
  // Divider & Borders
  static const divider = Color(0xFFE5E7EB);
  static const border = Color(0xFFD1D5DB);
  
  // Input Fields
  static const fieldFill = Color(0xFFF0F2F5);
  static const fieldFocused = Color(0xFFE3F2FD);
  
  // Status colors
  static const statusPlanned = Color(0xFF1565C0);
  static const statusValid = Color(0xFF00C853);
  static const statusInProgress = Color(0xFFFF6F00);
  static const statusDone = Color(0xFF6B7280);
  static const statusCancelled = Color(0xFFD32F2F);
  static const statusSuspended = Color(0xFFE65100);
  
  // Place type colors
  static const placeStandard = Color(0xFF1565C0);
  static const placeVIP = Color(0xFF9C27B0);
  static const placePremium = Color(0xFFFF6F00);
  static const placeOrchestre = Color(0xFF7B1FA2);
  static const placeBalcon = Color(0xFF00897B);
  static const placeLoge = Color(0xFF5C6BC0);

  // Ticket card colors
  static const ticketBorder = Color(0xFFDFD7E3);
  static const ticketQrBg = Color(0xFFF9F1FC);
}

class AppConstants {
  static const currency = 'Ar';
  static const roleAdmin = 'ADMINISTRATEUR';
  static const roleOrganisateur = 'ORGANISATEUR';
  static const roleClient = 'CLIENT';

  static const placeTypes = ['Standard', 'VIP', 'Premium', 'Orchestre', 'Balcon', 'Loge'];

  static const Map<String, Color> placeTypeColors = {
    'Standard': AppColors.placeStandard,
    'VIP': AppColors.placeVIP,
    'Premium': AppColors.placePremium,
    'Orchestre': AppColors.placeOrchestre,
    'Balcon': AppColors.placeBalcon,
    'Loge': AppColors.placeLoge,
  };

  static const Map<String, Color> statutColors = {
    'planifie': AppColors.statusPlanned,
    'valide': AppColors.statusValid,
    'en_cours': AppColors.statusInProgress,
    'termine': AppColors.statusDone,
    'annule': AppColors.statusCancelled,
    'suspendu': AppColors.statusSuspended,
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
  // Constantes de compatibilité (anciennes références)
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
    brightness: Brightness.light,
    
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryLight,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
      onError: Colors.white,
      outline: AppColors.divider,
    ),
    
    scaffoldBackgroundColor: AppColors.surface,
    
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 1,
      shadowColor: AppColors.primary.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.divider.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
    ),
    
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.card,
      indicatorColor: AppColors.primary.withValues(alpha: 0.12),
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      elevation: 2,
      shadowColor: AppColors.primary.withValues(alpha: 0.06),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
        disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.fieldFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
      ),
      floatingLabelStyle: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 14,
      ),
      prefixIconColor: AppColors.textSecondary,
      suffixIconColor: AppColors.textSecondary,
    ),
    
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),
    
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.textPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
    ),
    
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.card,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.card,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.fieldFill,
      selectedColor: AppColors.primary.withValues(alpha: 0.12),
      labelStyle: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13,
      ),
      secondaryLabelStyle: const TextStyle(
        color: AppColors.primary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: AppColors.divider,
          width: 1,
        ),
      ),
    ),
    
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 32,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 24,
        letterSpacing: -0.5,
      ),
      titleLarge: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 20,
      ),
      titleMedium: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      bodyLarge: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        color: AppColors.textMuted,
        fontSize: 12,
        height: 1.4,
      ),
    ),
  );
}