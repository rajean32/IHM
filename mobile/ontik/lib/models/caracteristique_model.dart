class Caracteristique {
  final int? idCaracteristique;
  final String nom;
  final String typeDonnee;
  final bool obligatoire;
  final int? ordreAffichage;
  final String? options;
  final String? codeCategorie;

  Caracteristique({
    this.idCaracteristique,
    required this.nom,
    required this.typeDonnee,
    this.obligatoire = false,
    this.ordreAffichage,
    this.options,
    this.codeCategorie,
  });

  factory Caracteristique.fromJson(Map<String, dynamic> json) {
    return Caracteristique(
      idCaracteristique: json['idCaracteristique'],
      nom: json['nom'] ?? '',
      typeDonnee: json['typeDonnee'] ?? 'text',
      obligatoire: json['obligatoire'] ?? false,
      ordreAffichage: json['ordreAffichage'],
      options: json['options'],
      codeCategorie: json['codeCategorie'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idCaracteristique != null) 'idCaracteristique': idCaracteristique,
      'nom': nom,
      'typeDonnee': typeDonnee,
      'obligatoire': obligatoire,
      'ordreAffichage': ordreAffichage,
      'options': options,
      'codeCategorie': codeCategorie,
    };
  }
}

class EvenementCaracteristiqueValeur {
  final int? idValeur;
  final int? idEvenement;
  final int idCaracteristique;
  final String? nomCaracteristique;
  final String? typeDonnee;
  final String valeur;

  EvenementCaracteristiqueValeur({
    this.idValeur,
    this.idEvenement,
    required this.idCaracteristique,
    this.nomCaracteristique,
    this.typeDonnee,
    required this.valeur,
  });

  factory EvenementCaracteristiqueValeur.fromJson(Map<String, dynamic> json) {
    return EvenementCaracteristiqueValeur(
      idValeur: json['idValeur'],
      idEvenement: json['idEvenement'],
      idCaracteristique: json['idCaracteristique'] ?? 0,
      nomCaracteristique: json['nomCaracteristique'],
      typeDonnee: json['typeDonnee'],
      valeur: json['valeur'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idValeur != null) 'idValeur': idValeur,
      if (idEvenement != null) 'idEvenement': idEvenement,
      'idCaracteristique': idCaracteristique,
      if (nomCaracteristique != null) 'nomCaracteristique': nomCaracteristique,
      if (typeDonnee != null) 'typeDonnee': typeDonnee,
      'valeur': valeur,
    };
  }
}
