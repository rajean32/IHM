class User {
  final String codeUtilisateur;
  final String nom;
  final String prenoms;
  final String? sexe;
  final DateTime? dateDeNaissance;
  final String email;
  final String tel;
  final String? codeAdministrateur;

  User({
    required this.codeUtilisateur,
    required this.nom,
    required this.prenoms,
    this.sexe,
    this.dateDeNaissance,
    required this.email,
    required this.tel,
    this.codeAdministrateur,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      codeUtilisateur: json['codeUtilisateur'] ?? '',
      nom: json['nom'] ?? '',
      prenoms: json['prenoms'] ?? '',
      sexe: json['sexe'],
      dateDeNaissance: json['dateDeNaissance'] != null
          ? DateTime.tryParse(json['dateDeNaissance'])
          : null,
      email: json['email'] ?? '',
      tel: json['tel'] ?? '',
      codeAdministrateur: json['codeAdministrateur'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codeUtilisateur': codeUtilisateur,
      'nom': nom,
      'prenoms': prenoms,
      'sexe': sexe,
      'dateDeNaissance': dateDeNaissance?.toIso8601String().split('T').first,
      'email': email,
      'tel': tel,
      'codeAdministrateur': codeAdministrateur,
    };
  }
}

class LoginResponse {
  final String token;
  final String codeUtilisateur;
  final String email;
  final String role;
  final bool isFirstLogin;

  LoginResponse({
    required this.token,
    required this.codeUtilisateur,
    required this.email,
    required this.role,
    this.isFirstLogin = false,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      codeUtilisateur: json['codeUtilisateur'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      isFirstLogin: json['firstLogin'] ?? false,
    );
  }
}

class UserDetail {
  final String codeUtilisateur;
  final String nom;
  final String prenoms;
  final String email;
  final String tel;
  final String role;
  final bool actif;
  final bool premiereConnexion;
  final String? sexe;
  final String? dateDeNaissance;

  UserDetail({
    required this.codeUtilisateur,
    required this.nom,
    required this.prenoms,
    required this.email,
    required this.tel,
    required this.role,
    this.actif = true,
    this.premiereConnexion = false,
    this.sexe,
    this.dateDeNaissance,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
      codeUtilisateur: json['codeUtilisateur'] ?? '',
      nom: json['nom'] ?? '',
      prenoms: json['prenoms'] ?? '',
      email: json['email'] ?? '',
      tel: json['tel'] ?? '',
      role: json['role'] ?? '',
      actif: json['actif'] ?? true,
      premiereConnexion: json['premiereConnexion'] ?? false,
      sexe: json['sexe'],
      dateDeNaissance: json['dateDeNaissance'],
    );
  }
}

class AuditLogEntry {
  final int? idAction;
  final String action;
  final String codeUtilisateur;
  final String entityType;
  final String? entityId;
  final String details;
  final String? dateAction;
  final bool reverted;

  AuditLogEntry({
    this.idAction,
    required this.action,
    required this.codeUtilisateur,
    this.entityType = '',
    this.entityId,
    required this.details,
    this.dateAction,
    this.reverted = false,
  });

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) {
    String? formattedDate;
    final rawDate = json['dateAction'];
    if (rawDate is List) {
      final parts = rawDate.cast<int>();
      if (parts.length >= 5) {
        formattedDate =
            '${parts[0]}-${parts[1].toString().padLeft(2, '0')}-${parts[2].toString().padLeft(2, '0')} '
            '${parts[3].toString().padLeft(2, '0')}:${parts[4].toString().padLeft(2, '0')}';
      }
    } else if (rawDate is String) {
      formattedDate = rawDate;
    }

    return AuditLogEntry(
      idAction: json['idAction'],
      action: json['action'] ?? '',
      codeUtilisateur: json['codeUtilisateur'] ?? '',
      entityType: json['entityType'] ?? '',
      entityId: json['entityId'],
      details: json['details'] ?? '',
      dateAction: formattedDate,
      reverted: json['reverted'] ?? false,
    );
  }
}
