class Lieu {
  final int? idLieu;
  final String nomLieu;
  final String? adresse;
  final String? ville;

  Lieu({this.idLieu, required this.nomLieu, this.adresse, this.ville});

  factory Lieu.fromJson(Map<String, dynamic> json) {
    return Lieu(
      idLieu: json['idLieu'],
      nomLieu: json['nomLieu'] ?? '',
      adresse: json['adresse'],
      ville: json['ville'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idLieu != null) 'idLieu': idLieu,
      'nomLieu': nomLieu,
      'adresse': adresse,
      'ville': ville,
    };
  }
}

class Salle {
  final String numeroSalle;
  final String nomSalle;
  final int? idLieu;

  Salle({required this.numeroSalle, required this.nomSalle, this.idLieu});

  factory Salle.fromJson(Map<String, dynamic> json) {
    return Salle(
      numeroSalle: json['numeroSalle'] ?? '',
      nomSalle: json['nomSalle'] ?? '',
      idLieu: json['idLieu'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numeroSalle': numeroSalle,
      'nomSalle': nomSalle,
      'idLieu': idLieu,
    };
  }
}

class Place {
  final String numeroPlace;
  final String? rang;
  final String? typePlace;
  final String numeroSalle;

  Place({
    required this.numeroPlace,
    this.rang,
    this.typePlace,
    required this.numeroSalle,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      numeroPlace: json['numeroPlace'] ?? '',
      rang: json['range'],
      typePlace: json['typePlace'],
      numeroSalle: json['numeroSalle'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numeroPlace': numeroPlace,
      'range': rang,
      'typePlace': typePlace,
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
