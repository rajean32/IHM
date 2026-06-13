import 'caracteristique_model.dart';

class Categorie {
  final String codeCategorie;
  final String nomCategorie;
  final String? description;
  final DateTime? dateCreation;
  final List<Caracteristique>? caracteristiques;
  final List<String>? salleTypeCodes;

  Categorie({
    required this.codeCategorie,
    required this.nomCategorie,
    this.description,
    this.dateCreation,
    this.caracteristiques,
    this.salleTypeCodes,
  });

  factory Categorie.fromJson(Map<String, dynamic> json) {
    return Categorie(
      codeCategorie: json['codeCategorie'] ?? '',
      nomCategorie: json['nomCategorie'] ?? '',
      description: json['description'],
      dateCreation: json['dateCreation'] != null
          ? DateTime.tryParse(json['dateCreation'])
          : null,
      caracteristiques: json['caracteristiques'] != null
          ? (json['caracteristiques'] as List)
              .map((e) => Caracteristique.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      salleTypeCodes: json['salleTypeCodes'] != null
          ? (json['salleTypeCodes'] as List).cast<String>()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codeCategorie': codeCategorie,
      'nomCategorie': nomCategorie,
      'description': description,
    };
  }
}
