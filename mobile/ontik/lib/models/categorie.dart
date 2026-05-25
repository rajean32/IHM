class Categorie {
  final String codeCategorie;
  final String nomCategorie;

  Categorie({required this.codeCategorie, required this.nomCategorie});

  factory Categorie.fromJson(Map<String, dynamic> json) {
    return Categorie(
      codeCategorie: json['codeCategorie'] ?? '',
      nomCategorie: json['nomCategorie'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codeCategorie': codeCategorie,
      'nomCategorie': nomCategorie,
    };
  }
}
