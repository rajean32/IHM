class Ticket {
  final String codeTicket;
  final double? prix;
  final String? numeroPlace;
  final int? idEvenement;

  Ticket({
    required this.codeTicket,
    this.prix,
    this.numeroPlace,
    this.idEvenement,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      codeTicket: json['codeTicket'] ?? '',
      prix: json['prix'] != null ? double.tryParse(json['prix'].toString()) : null,
      numeroPlace: json['numeroPlace'],
      idEvenement: json['idEvenement'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codeTicket': codeTicket,
      if (prix != null) 'prix': prix,
      'numeroPlace': numeroPlace,
      'idEvenement': idEvenement,
    };
  }
}

class TicketQRResponse {
  final String codeTicket;
  final String qrCodeBase64;
  final String evenementTitre;
  final String placeNumero;
  final String? rang;
  final String? typePlace;
  final String? prix;
  final String? status;

  TicketQRResponse({
    required this.codeTicket,
    required this.qrCodeBase64,
    required this.evenementTitre,
    required this.placeNumero,
    this.rang,
    this.typePlace,
    this.prix,
    this.status,
  });

  factory TicketQRResponse.fromJson(Map<String, dynamic> json) {
    return TicketQRResponse(
      codeTicket: json['codeTicket'] ?? '',
      qrCodeBase64: json['qrCodeBase64'] ?? '',
      evenementTitre: json['evenementTitre'] ?? '',
      placeNumero: json['placeNumero'] ?? '',
      rang: json['rang'],
      typePlace: json['typePlace'],
      prix: json['prix'],
      status: json['status'],
    );
  }
}

class TicketValidationResponse {
  final bool valid;
  final String codeTicket;
  final String evenementTitre;
  final String placeNumero;
  final String? clientNom;
  final String? message;

  TicketValidationResponse({
    required this.valid,
    required this.codeTicket,
    required this.evenementTitre,
    required this.placeNumero,
    this.clientNom,
    this.message,
  });

  factory TicketValidationResponse.fromJson(Map<String, dynamic> json) {
    return TicketValidationResponse(
      valid: json['valid'] ?? false,
      codeTicket: json['codeTicket'] ?? '',
      evenementTitre: json['evenementTitre'] ?? '',
      placeNumero: json['placeNumero'] ?? '',
      clientNom: json['clientNom'],
      message: json['message'],
    );
  }
}
