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
  final int? id;
  final String action;
  final String utilisateur;
  final String details;
  final String? timestamp;

  AuditLogEntry({
    this.id,
    required this.action,
    required this.utilisateur,
    required this.details,
    this.timestamp,
  });

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) {
    return AuditLogEntry(
      id: json['id'],
      action: json['action'] ?? '',
      utilisateur: json['utilisateur'] ?? '',
      details: json['details'] ?? '',
      timestamp: json['timestamp'],
    );
  }
}
