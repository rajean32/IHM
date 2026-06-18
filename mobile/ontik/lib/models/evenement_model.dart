import 'lieu_model.dart';
import 'caracteristique_model.dart';
import 'package:intl/intl.dart';

class StandingZone {
  final int? idZone;
  final int? idEvenement;
  final String nom;
  final int? capacite;
  final double prix;
  final String? statut;
  final int? reservationsActuelles;
  final int? placesDisponibles;

  StandingZone({
    this.idZone,
    this.idEvenement,
    required this.nom,
    this.capacite,
    required this.prix,
    this.statut,
    this.reservationsActuelles,
    this.placesDisponibles,
  });

  factory StandingZone.fromJson(Map<String, dynamic> json) {
    return StandingZone(
      idZone: json['idZone'],
      idEvenement: json['idEvenement'],
      nom: json['nom'] ?? '',
      capacite: json['capacite'],
      prix: double.tryParse(json['prix'].toString()) ?? 0,
      statut: json['statut'],
      reservationsActuelles: json['reservationsActuelles'],
      placesDisponibles: json['placesDisponibles'],
    );
  }
}

class Evenement {
  final int? idEvenement;
  final String titre;
  final String? description;
  final DateTime? dateEvenement;
  final DateTime? dateFin;
  final String? heureEvenement;
  final double? prix;
  final double? prixMin;
  final double? prixMax;
  final int? capacite;
  final String? image;
  final String? statut;
  final String? codeCategorie;
  final String? codeLieu;
  final String? typeAgencement;
  final String? numeroSalle;
  final String? nomSalle;
  final String codeOrganisateur;
  final String? motifAnnulation;
  final String? organisateurNom;
  final String? lieuNom;
  final String? categorieNom;
  final int? placesTotal;
  final int? placesDisponibles;
  final bool? isNew;
  final List<EvenementCaracteristiqueValeur>? caracteristiqueValeurs;

  Evenement({
    this.idEvenement,
    required this.titre,
    this.description,
    this.dateEvenement,
    this.dateFin,
    this.heureEvenement,
    this.prix,
    this.prixMin,
    this.prixMax,
    this.capacite,
    this.image,
    this.statut,
    this.codeCategorie,
    this.codeLieu,
    this.typeAgencement,
    this.numeroSalle,
    this.nomSalle,
    required this.codeOrganisateur,
    this.motifAnnulation,
    this.organisateurNom,
    this.lieuNom,
    this.categorieNom,
    this.placesTotal,
    this.placesDisponibles,
    this.isNew,
    this.caracteristiqueValeurs,
  });

  factory Evenement.fromJson(Map<String, dynamic> json) {
    return Evenement(
      idEvenement: json['idEvenement'],
      titre: json['titre'] ?? '',
      description: json['description'],
      dateEvenement: json['dateEvenement'] != null
          ? DateTime.tryParse(json['dateEvenement'])
          : null,
      dateFin: json['dateFin'] != null
          ? DateTime.tryParse(json['dateFin'])
          : null,
      heureEvenement: json['heureEvenement'],
      prix: json['prix'] != null
          ? double.tryParse(json['prix'].toString())
          : null,
      prixMin: json['prixMin'] != null
          ? double.tryParse(json['prixMin'].toString())
          : null,
      prixMax: json['prixMax'] != null
          ? double.tryParse(json['prixMax'].toString())
          : null,
      capacite: json['capacite'] != null
          ? int.tryParse(json['capacite'].toString())
          : null,
      image: json['image'],
      statut: json['statut'],
      codeCategorie: json['codeCategorie'],
      codeLieu: json['codeLieu'],
      typeAgencement: json['typeAgencement'],
      numeroSalle: json['numeroSalle'],
      nomSalle: json['nomSalle'],
      codeOrganisateur: json['codeOrganisateur'] ?? '',
      motifAnnulation: json['motifAnnulation'],
      organisateurNom: json['organisateurNom'],
      lieuNom: json['lieuNom'],
      categorieNom: json['categorieNom'],
      placesTotal: json['placesTotal'],
      placesDisponibles: json['placesDisponibles'],
      isNew: json['isNew'],
      caracteristiqueValeurs: json['caracteristiqueValeurs'] != null
          ? (json['caracteristiqueValeurs'] as List)
              .map((e) => EvenementCaracteristiqueValeur.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idEvenement != null) 'idEvenement': idEvenement,
      'titre': titre,
      'description': description,
      'dateEvenement': dateEvenement != null ? DateFormat('yyyy-MM-dd').format(dateEvenement!) : null,
      'dateFin': dateFin != null ? DateFormat('yyyy-MM-dd').format(dateFin!) : null,
      'heureEvenement': heureEvenement,
      'prix': prix,
      'capacite': capacite,
      'image': image,
      'statut': statut,
      'codeCategorie': codeCategorie,
      'codeLieu': codeLieu,
      'typeAgencement': typeAgencement,
      'numeroSalle': numeroSalle,
      'codeOrganisateur': codeOrganisateur,
      'motifAnnulation': motifAnnulation,
      if (caracteristiqueValeurs != null)
        'caracteristiqueValeurs': caracteristiqueValeurs!.map((v) => v.toJson()).toList(),
    };
  }
}

class EventDetail extends Evenement {
  final String? lieuAdresse;
  final String? lieuVille;
  final double? prixMin;
  final double? prixMax;
  final List<SeatingPlace>? places;
  final List<StandingZone>? standingZones;

  EventDetail({
    int? idEvenement,
    required String titre,
    String? description,
    DateTime? dateEvenement,
    DateTime? dateFin,
    String? heureEvenement,
    double? prix,
    int? capacite,
    String? image,
    String? statut,
    String? codeCategorie,
    String? codeLieu,
    String? typeAgencement,
    String? numeroSalle,
    String? nomSalle,
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
    this.standingZones,
    List<EvenementCaracteristiqueValeur>? caracteristiqueValeurs,
  }) : super(
          idEvenement: idEvenement,
          titre: titre,
          description: description,
          dateEvenement: dateEvenement,
          dateFin: dateFin,
          heureEvenement: heureEvenement,
          prix: prix,
          capacite: capacite,
          image: image,
          statut: statut,
          codeCategorie: codeCategorie,
          codeLieu: codeLieu,
          typeAgencement: typeAgencement,
          numeroSalle: numeroSalle,
          nomSalle: nomSalle,
          codeOrganisateur: codeOrganisateur,
          categorieNom: categorieNom,
          lieuNom: lieuNom,
          organisateurNom: organisateurNom,
          placesDisponibles: placesDisponibles,
          placesTotal: placesTotal,
          caracteristiqueValeurs: caracteristiqueValeurs,
        );

  factory EventDetail.fromJson(Map<String, dynamic> json) {
    return EventDetail(
      idEvenement: json['idEvenement'],
      titre: json['titre'] ?? '',
      description: json['description'],
      dateEvenement: json['dateEvenement'] != null
          ? DateTime.tryParse(json['dateEvenement'])
          : null,
      dateFin: json['dateFin'] != null
          ? DateTime.tryParse(json['dateFin'])
          : null,
      heureEvenement: json['heureEvenement'],
      prix: json['prix'] != null
          ? double.tryParse(json['prix'].toString())
          : null,
      capacite: json['capacite'] != null
          ? int.tryParse(json['capacite'].toString())
          : null,
      image: json['image'],
      statut: json['statut'],
      codeCategorie: json['codeCategorie'],
      codeLieu: json['codeLieu'],
      numeroSalle: json['numeroSalle'],
      nomSalle: json['nomSalle'],
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
      standingZones: json['standingZones'] != null
          ? (json['standingZones'] as List)
              .map((e) => StandingZone.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      caracteristiqueValeurs: json['caracteristiqueValeurs'] != null
          ? (json['caracteristiqueValeurs'] as List)
              .map((e) => EvenementCaracteristiqueValeur.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}
