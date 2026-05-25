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
