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

  static const List<String> validEventStatuts = ['planifie', 'en_cours', 'termine', 'annule'];

  static const Map<String, Color> statutColors = {
    'planifie': Color(0xFF2196F3),
    'en_cours': Color(0xFF4CAF50),
    'termine': Color(0xFF9E9E9E),
    'annule': Color(0xFFF44336),
  };
}
