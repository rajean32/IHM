import 'lieu_model.dart';
import 'package:intl/intl.dart';

class Evenement {
  final int? idEvenement;
  final String titre;
  final String? description;
  final DateTime? dateEvenement;
  final String? heureEvenement;
  final String? image;
  final String? statut;
  final String? codeCategorie;
  final String? codeLieu;
  final String codeOrganisateur;
  final String? motifAnnulation;
  final String? organisateurNom;
  final String? lieuNom;
  final String? categorieNom;
  final int? placesTotal;
  final int? placesDisponibles;

  Evenement({
    this.idEvenement,
    required this.titre,
    this.description,
    this.dateEvenement,
    this.heureEvenement,
    this.image,
    this.statut,
    this.codeCategorie,
    this.codeLieu,
    required this.codeOrganisateur,
    this.motifAnnulation,
    this.organisateurNom,
    this.lieuNom,
    this.categorieNom,
    this.placesTotal,
    this.placesDisponibles,
  });

  factory Evenement.fromJson(Map<String, dynamic> json) {
    return Evenement(
      idEvenement: json['idEvenement'],
      titre: json['titre'] ?? '',
      description: json['description'],
      dateEvenement: json['dateEvenement'] != null
          ? DateTime.tryParse(json['dateEvenement'])
          : null,
      heureEvenement: json['heureEvenement'],
      image: json['image'],
      statut: json['statut'],
      codeCategorie: json['codeCategorie'],
      codeLieu: json['codeLieu'],
      codeOrganisateur: json['codeOrganisateur'] ?? '',
      motifAnnulation: json['motifAnnulation'],
      organisateurNom: json['organisateurNom'],
      lieuNom: json['lieuNom'],
      categorieNom: json['categorieNom'],
      placesTotal: json['placesTotal'],
      placesDisponibles: json['placesDisponibles'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idEvenement != null) 'idEvenement': idEvenement,
      'titre': titre,
      'description': description,
      'dateEvenement': dateEvenement != null ? DateFormat('yyyy-MM-dd').format(dateEvenement!) : null,
      'heureEvenement': heureEvenement,
      'image': image,
      'statut': statut,
      'codeCategorie': codeCategorie,
      'codeLieu': codeLieu,
      'codeOrganisateur': codeOrganisateur,
      'motifAnnulation': motifAnnulation,
    };
  }
}

class EventDetail extends Evenement {
  final String? lieuAdresse;
  final String? lieuVille;
  final double? prixMin;
  final double? prixMax;
  final List<SeatingPlace>? places;

  EventDetail({
    int? idEvenement,
    required String titre,
    String? description,
    DateTime? dateEvenement,
    String? heureEvenement,
    String? image,
    String? statut,
    String? codeCategorie,
    String? codeLieu,
    required String codeOrganisateur,
    String? categorieNom,
    String? lieuNom,
    this.lieuAdresse,
    this.lieuVille,
    String? organisateurNom,
    int? placesDisponibles,
    int? placesTotal,
    this.prixMin,
    this.prixMax,
    this.places,
  }) : super(
          idEvenement: idEvenement,
          titre: titre,
          description: description,
          dateEvenement: dateEvenement,
          heureEvenement: heureEvenement,
          image: image,
          statut: statut,
          codeCategorie: codeCategorie,
          codeLieu: codeLieu,
          codeOrganisateur: codeOrganisateur,
          categorieNom: categorieNom,
          lieuNom: lieuNom,
          organisateurNom: organisateurNom,
          placesDisponibles: placesDisponibles,
          placesTotal: placesTotal,
        );

  factory EventDetail.fromJson(Map<String, dynamic> json) {
    return EventDetail(
      idEvenement: json['idEvenement'],
      titre: json['titre'] ?? '',
      description: json['description'],
      dateEvenement: json['dateEvenement'] != null
          ? DateTime.tryParse(json['dateEvenement'])
          : null,
      heureEvenement: json['heureEvenement'],
      image: json['image'],
      statut: json['statut'],
      codeCategorie: json['codeCategorie'],
      codeLieu: json['codeLieu'],
      codeOrganisateur: json['codeOrganisateur'] ?? '',
      categorieNom: json['categorieNom'],
      lieuNom: json['lieuNom'],
      lieuAdresse: json['lieuAdresse'],
      lieuVille: json['lieuVille'],
      organisateurNom: json['organisateurNom'],
      placesDisponibles: json['placesDisponibles'],
      placesTotal: json['placesTotal'],
      prixMin: json['prixMin'] != null
          ? double.tryParse(json['prixMin'].toString())
          : null,
      prixMax: json['prixMax'] != null
          ? double.tryParse(json['prixMax'].toString())
          : null,
      places: json['places'] != null
          ? (json['places'] as List)
              .map((e) => SeatingPlace.fromJson(e))
              .toList()
          : null,
    );
  }
}
