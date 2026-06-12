import 'evenement_model.dart';

class Film {
  final int? idFilm;
  final String titre;
  final String? synopsis;
  final String? realisateur;
  final String? acteurs;
  final int? dureeMinutes;
  final String? affiche;
  final String? bandeAnnonce;
  final List<SeanceCinema>? seances;

  Film({
    this.idFilm,
    required this.titre,
    this.synopsis,
    this.realisateur,
    this.acteurs,
    this.dureeMinutes,
    this.affiche,
    this.bandeAnnonce,
    this.seances,
  });

  factory Film.fromJson(Map<String, dynamic> json) {
    return Film(
      idFilm: json['idFilm'],
      titre: json['titre'] ?? '',
      synopsis: json['synopsis'],
      realisateur: json['realisateur'],
      acteurs: json['acteurs'],
      dureeMinutes: json['dureeMinutes'],
      affiche: json['affiche'],
      bandeAnnonce: json['bandeAnnonce'],
      seances: json['seances'] != null
          ? (json['seances'] as List)
          .map((e) => SeanceCinema.fromJson(e))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idFilm != null) 'idFilm': idFilm,
      'titre': titre,
      if (synopsis != null) 'synopsis': synopsis,
      if (realisateur != null) 'realisateur': realisateur,
      if (acteurs != null) 'acteurs': acteurs,
      if (dureeMinutes != null) 'dureeMinutes': dureeMinutes,
      if (affiche != null) 'affiche': affiche,
      if (bandeAnnonce != null) 'bandeAnnonce': bandeAnnonce,
    };
  }
}

class SeanceCinema {
  final int? idSeance;
  final int idFilm;
  final int idEvenement;
  final DateTime dateSeance;
  final String heureSeance;
  final String? version;
  final String? langue;
  final String? sousTitres;
  final Evenement? evenement;
  final Film? film;

  SeanceCinema({
    this.idSeance,
    required this.idFilm,
    required this.idEvenement,
    required this.dateSeance,
    required this.heureSeance,
    this.version,
    this.langue,
    this.sousTitres,
    this.evenement,
    this.film,
  });

  factory SeanceCinema.fromJson(Map<String, dynamic> json) {
    return SeanceCinema(
      idSeance: json['idSeance'],
      idFilm: json['idFilm'] ?? 0,
      idEvenement: json['idEvenement'] ?? 0,
      dateSeance: json['dateSeance'] != null
          ? DateTime.parse(json['dateSeance'])
          : DateTime.now(),
      heureSeance: json['heureSeance'] ?? '20:00:00',
      version: json['version'],
      langue: json['langue'],
      sousTitres: json['sousTitres'],
      evenement: json['evenement'] != null
          ? Evenement.fromJson(json['evenement'])
          : null,
      film: json['film'] != null ? Film.fromJson(json['film']) : null,
    );
  }
}