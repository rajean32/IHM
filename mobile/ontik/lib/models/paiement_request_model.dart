class PaiementRequestModel {
  final String codeClient;
  final List<TicketItemModel> tickets;
  final String typePaiement;
  final String? referenceTransaction;
  final String? numeroTelephone;
  final String? nomComplet;
  final CarteBancaireModel? carte;
  final String? codePromo;
  final bool? estEtudiant;

  PaiementRequestModel({
    required this.codeClient,
    required this.tickets,
    required this.typePaiement,
    this.referenceTransaction,
    this.numeroTelephone,
    this.nomComplet,
    this.carte,
    this.codePromo,
    this.estEtudiant,
  });

  Map<String, dynamic> toJson() {
    return {
      'codeClient': codeClient,
      'tickets': tickets.map((t) => t.toJson()).toList(),
      'typePaiement': typePaiement,
      if (referenceTransaction != null) 'referenceTransaction': referenceTransaction,
      if (numeroTelephone != null) 'numeroTelephone': numeroTelephone,
      if (nomComplet != null) 'nomComplet': nomComplet,
      if (carte != null) 'carte': carte!.toJson(),
      if (codePromo != null) 'codePromo': codePromo,
      if (estEtudiant != null) 'estEtudiant': estEtudiant,
    };
  }
}

class TicketItemModel {
  final String codeTicket;
  final String numeroPlace;
  final int idEvenement;
  final double prix;
  final int? idZone;

  TicketItemModel({
    required this.codeTicket,
    required this.numeroPlace,
    required this.idEvenement,
    required this.prix,
    this.idZone,
  });

  Map<String, dynamic> toJson() {
    return {
      'codeTicket': codeTicket,
      'numeroPlace': numeroPlace,
      'idEvenement': idEvenement,
      'prix': prix,
      if (idZone != null) 'idZone': idZone,
    };
  }
}

class CarteBancaireModel {
  final String numeroCarte;
  final String dateExpiration;
  final String cvv;
  final String nomTitulaire;

  CarteBancaireModel({
    required this.numeroCarte,
    required this.dateExpiration,
    required this.cvv,
    required this.nomTitulaire,
  });

  Map<String, dynamic> toJson() {
    return {
      'numeroCarte': numeroCarte,
      'dateExpiration': dateExpiration,
      'cvv': cvv,
      'nomTitulaire': nomTitulaire,
    };
  }
}

class PaiementResultModel {
  final bool success;
  final String message;
  final int? idReservation;
  final int? idPaiement;
  final double? montantInitial;
  final double? reductionAppliquee;
  final double? montantFinal;
  final String? typeReduction;
  final String? statutPaiement;
  final DateTime? datePaiement;

  PaiementResultModel({
    required this.success,
    required this.message,
    this.idReservation,
    this.idPaiement,
    this.montantInitial,
    this.reductionAppliquee,
    this.montantFinal,
    this.typeReduction,
    this.statutPaiement,
    this.datePaiement,
  });

  factory PaiementResultModel.fromJson(Map<String, dynamic> json) {
    return PaiementResultModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      idReservation: json['idReservation'],
      idPaiement: json['idPaiement'],
      montantInitial: json['montantInitial'] != null
          ? double.tryParse(json['montantInitial'].toString())
          : null,
      reductionAppliquee: json['reductionAppliquee'] != null
          ? double.tryParse(json['reductionAppliquee'].toString())
          : null,
      montantFinal: json['montantFinal'] != null
          ? double.tryParse(json['montantFinal'].toString())
          : null,
      typeReduction: json['typeReduction'],
      statutPaiement: json['statutPaiement'],
      datePaiement: json['datePaiement'] != null
          ? DateTime.tryParse(json['datePaiement'])
          : null,
    );
  }
}