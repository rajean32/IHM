class Ville {
  final String code;
  final String nom;
  final String? region;
  final bool? actif;

  Ville({
    required this.code,
    required this.nom,
    this.region,
    this.actif,
  });

  factory Ville.fromJson(Map<String, dynamic> json) {
    return Ville(
      code: json['code'] as String,
      nom: json['nom'] as String,
      region: json['region'] as String?,
      actif: json['actif'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'nom': nom,
    if (region != null) 'region': region,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ville && code == other.code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => nom;
}
