class ClientTicket {
  final String codeTicket;
  final double? prix;
  final String? evenementTitre;
  final String? dateEvenement;
  final String? heureEvenement;
  final String? lieuNom;
  final String? salleNom;
  final String? numeroPlace;
  final String? rang;
  final String? typePlace;
  final String? statut;

  ClientTicket({
    required this.codeTicket,
    this.prix,
    this.evenementTitre,
    this.dateEvenement,
    this.heureEvenement,
    this.lieuNom,
    this.salleNom,
    this.numeroPlace,
    this.rang,
    this.typePlace,
    this.statut,
  });

  factory ClientTicket.fromJson(Map<String, dynamic> json) {
    return ClientTicket(
      codeTicket: json['codeTicket'] ?? '',
      prix: json['prix'] != null ? double.tryParse(json['prix'].toString()) : null,
      evenementTitre: json['evenementTitre'],
      dateEvenement: json['dateEvenement'],
      heureEvenement: json['heureEvenement'],
      lieuNom: json['lieuNom'],
      salleNom: json['salleNom'],
      numeroPlace: json['numeroPlace'],
      rang: json['rang'],
      typePlace: json['typePlace'],
      statut: json['statut'],
    );
  }
}
