class Lieu {
  final String code;
  final String nomLieu;
  final String? adresse;
  final String? ville;
  final List<Salle>? salles;

  Lieu({required this.code, required this.nomLieu, this.adresse, this.ville, this.salles});

  factory Lieu.fromJson(Map<String, dynamic> json) {
    return Lieu(
      code: json['code'] ?? '',
      nomLieu: json['nomLieu'] ?? '',
      adresse: json['adresse'],
      ville: json['ville'],
      salles: json['salles'] != null
          ? (json['salles'] as List).map((e) => Salle.fromJson(e as Map<String, dynamic>)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'nomLieu': nomLieu,
      'adresse': adresse,
      'ville': ville,
    };
  }
}

class Salle {
  final String numeroSalle;
  final String nomSalle;
  final String? codeLieu;

  Salle({required this.numeroSalle, required this.nomSalle, this.codeLieu});

  factory Salle.fromJson(Map<String, dynamic> json) {
    return Salle(
      numeroSalle: json['numeroSalle'] ?? '',
      nomSalle: json['nomSalle'] ?? '',
      codeLieu: json['codeLieu'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numeroSalle': numeroSalle,
      'nomSalle': nomSalle,
      'codeLieu': codeLieu,
    };
  }
}

class Place {
  final String numeroPlace;
  final String? range;
  final String? typePlace;
  final double? prix;
  final String? statut;
  final String numeroSalle;

  Place({
    required this.numeroPlace,
    this.range,
    this.typePlace,
    this.prix,
    this.statut,
    required this.numeroSalle,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      numeroPlace: json['numeroPlace'] ?? '',
      range: json['range'],
      typePlace: json['typePlace'],
      prix: json['prix'] != null ? double.tryParse(json['prix'].toString()) : null,
      statut: json['statut'],
      numeroSalle: json['numeroSalle'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numeroPlace': numeroPlace,
      'range': range,
      'typePlace': typePlace,
      'prix': prix,
      'statut': statut,
      'numeroSalle': numeroSalle,
    };
  }
}

class SeatingPlace {
  final String numeroPlace;
  final String? rang;
  final String? typePlace;
  final bool disponible;
  final double? prix;
  final String? salle;
  final String? statut;

  SeatingPlace({
    required this.numeroPlace,
    this.rang,
    this.typePlace,
    required this.disponible,
    this.prix,
    this.salle,
    this.statut,
  });

  factory SeatingPlace.fromJson(Map<String, dynamic> json) {
    return SeatingPlace(
      numeroPlace: json['numeroPlace'] ?? '',
      rang: json['rang'],
      typePlace: json['typePlace'],
      disponible: json['disponible'] ?? true,
      prix: json['prix'] != null ? double.tryParse(json['prix'].toString()) : null,
      salle: json['salle'],
      statut: json['statut'],
    );
  }
}
