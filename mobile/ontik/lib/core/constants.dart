import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Ontik';
  static const String tokenKey = 'token';
  static const String userRoleKey = 'role';
  static const String userCodeKey = 'userCode';
  static const String userEmailKey = 'userEmail';

  static const String roleAdmin = 'ADMINISTRATEUR';
  static const String roleOrganisateur = 'ORGANISATEUR';
  static const String roleClient = 'CLIENT';

  static const List<String> placeTypes = ['Standard', 'VIP', 'Premium', 'Ultra-VIP'];

  static const Map<String, Color> placeTypeColors = {
    'Standard': Color(0xFF607D8B),
    'VIP': Color(0xFF9C27B0),
    'Premium': Color(0xFFFF9800),
    'Ultra-VIP': Color(0xFFE91E63),
  };

  static const List<String> validEventStatuts = ['planifie', 'en_cours', 'termine', 'annule', 'suspendu', 'valide'];

  static const Map<String, Color> statutColors = {
    'planifie': Color(0xFF2196F3),
    'en_cours': Color(0xFF4CAF50),
    'termine': Color(0xFF9E9E9E),
    'annule': Color(0xFFF44336),
    'suspendu': Color(0xFFFF9800),
    'valide': Color(0xFF2196F3),
  };

  static const Map<String, IconData> statutIcons = {
    'planifie': Icons.schedule,
    'en_cours': Icons.play_circle,
    'termine': Icons.check_circle,
    'annule': Icons.cancel,
    'suspendu': Icons.pause_circle,
    'valide': Icons.verified,
  };
}
