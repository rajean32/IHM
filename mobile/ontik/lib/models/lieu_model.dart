class Lieu {
  final String code;
  final String nomLieu;
  final String? adresse;
  final String? description;
  final String? ville;
  final String? villeCode;
  final List<Salle>? salles;

  Lieu({required this.code, required this.nomLieu, this.adresse, this.description, this.ville, this.villeCode, this.salles});

  factory Lieu.fromJson(Map<String, dynamic> json) {
    return Lieu(
      code: json['code'] ?? '',
      nomLieu: json['nomLieu'] ?? '',
      adresse: json['adresse'],
      description: json['description'],
      ville: json['ville'],
      villeCode: json['villeCode'],
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
      'description': description,
      'ville': ville,
      'villeCode': villeCode,
    };
  }
}

class Salle {
  final String numeroSalle;
  final String nomSalle;
  final String? type;
  final int? capacite;
  final String? range;
  final String? codeLieu;
  final String? nomLieu;
  final String? typeAgencement;
  final List<String>? typesEvenement;

  Salle({
    required this.numeroSalle, required this.nomSalle, this.type,
    this.capacite, this.range, this.codeLieu, this.nomLieu, this.typeAgencement, this.typesEvenement,
  });

  factory Salle.fromJson(Map<String, dynamic> json) {
    return Salle(
      numeroSalle: json['numeroSalle'] ?? '',
      nomSalle: json['nomSalle'] ?? '',
      type: json['type'], capacite: json['capacite'], range: json['range'],
      codeLieu: json['codeLieu'], nomLieu: json['nomLieu'],
      typeAgencement: json['typeAgencement'],
      typesEvenement: json['typesEvenement'] != null
          ? (json['typesEvenement'] as List).cast<String>() : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'numeroSalle': numeroSalle, 'nomSalle': nomSalle, 'type': type,
      'capacite': capacite, 'range': range, 'codeLieu': codeLieu,
      'typeAgencement': typeAgencement, 'typesEvenement': typesEvenement,
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
