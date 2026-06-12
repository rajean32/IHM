enum ModeReduction {
  CODE_PROMO,
  ETUDIANT,
  PREMIERES_RESERVATIONS,
}

class Reduction {
  final int? idReduction;
  final String? code;
  final ModeReduction mode;
  final double? tauxReduction;
  final double? valeurFixe;
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final int? utilisationMax;
  final int utilisationCount;
  final bool actif;
  final int? idEvenement;

  Reduction({
    this.idReduction,
    this.code,
    required this.mode,
    this.tauxReduction,
    this.valeurFixe,
    this.dateDebut,
    this.dateFin,
    this.utilisationMax,
    this.utilisationCount = 0,
    this.actif = true,
    this.idEvenement,
  });

  factory Reduction.fromJson(Map<String, dynamic> json) {
    return Reduction(
      idReduction: json['idReduction'],
      code: json['code'],
      mode: ModeReduction.values.firstWhere(
            (e) => e.toString().split('.').last == json['mode'],
        orElse: () => ModeReduction.CODE_PROMO,
      ),
      tauxReduction: json['tauxReduction'] != null
          ? double.tryParse(json['tauxReduction'].toString())
          : null,
      valeurFixe: json['valeurFixe'] != null
          ? double.tryParse(json['valeurFixe'].toString())
          : null,
      dateDebut: json['dateDebut'] != null
          ? DateTime.tryParse(json['dateDebut'])
          : null,
      dateFin: json['dateFin'] != null
          ? DateTime.tryParse(json['dateFin'])
          : null,
      utilisationMax: json['utilisationMax'],
      utilisationCount: json['utilisationCount'] ?? 0,
      actif: json['actif'] ?? true,
      idEvenement: json['idEvenement'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idReduction != null) 'idReduction': idReduction,
      if (code != null) 'code': code,
      'mode': mode.toString().split('.').last,
      if (tauxReduction != null) 'tauxReduction': tauxReduction,
      if (valeurFixe != null) 'valeurFixe': valeurFixe,
      if (dateDebut != null) 'dateDebut': dateDebut!.toIso8601String(),
      if (dateFin != null) 'dateFin': dateFin!.toIso8601String(),
      if (utilisationMax != null) 'utilisationMax': utilisationMax,
      'utilisationCount': utilisationCount,
      'actif': actif,
      if (idEvenement != null) 'idEvenement': idEvenement,
    };
  }
}

class ReductionResult {
  final double reductionAppliquee;
  final double montantFinal;
  final String? typeReduction;

  ReductionResult({
    required this.reductionAppliquee,
    required this.montantFinal,
    this.typeReduction,
  });
}