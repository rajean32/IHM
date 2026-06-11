import 'ticket_model.dart';

class Reservation {
  final int? idReservation;
  final DateTime? dateReservation;
  final String codeClient;
  final List<String>? codeTickets;
  final List<Ticket>? tickets;

  Reservation({
    this.idReservation,
    this.dateReservation,
    required this.codeClient,
    this.codeTickets,
    this.tickets,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      idReservation: json['idReservation'],
      dateReservation: json['dateReservation'] != null
          ? DateTime.tryParse(json['dateReservation'])
          : null,
      codeClient: json['codeClient'] ?? '',
      codeTickets: json['codeTickets'] != null
          ? List<String>.from(json['codeTickets'])
          : null,
      tickets: json['tickets'] != null
          ? (json['tickets'] as List).map((e) => Ticket.fromJson(e as Map<String, dynamic>)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idReservation != null) 'idReservation': idReservation,
      'dateReservation': dateReservation?.toIso8601String(),
      'codeClient': codeClient,
      if (codeTickets != null) 'codeTickets': codeTickets,
      if (tickets != null) 'tickets': tickets!.map((t) => t.toJson()).toList(),
    };
  }
}

class Paiement {
  final int? idPaiement;
  final double montant;
  final DateTime datePaiement;
  final String modePaiement;
  final int idReservation;

  Paiement({
    this.idPaiement,
    required this.montant,
    required this.datePaiement,
    required this.modePaiement,
    required this.idReservation,
  });

  factory Paiement.fromJson(Map<String, dynamic> json) {
    return Paiement(
      idPaiement: json['idPaiement'],
      montant: json['montant'] != null
          ? double.tryParse(json['montant'].toString()) ?? 0.0
          : 0.0,
      datePaiement: json['datePaiement'] != null
          ? DateTime.tryParse(json['datePaiement']) ?? DateTime.now()
          : DateTime.now(),
      modePaiement: json['modePaiement'] ?? '',
      idReservation: json['idReservation'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'montant': montant,
      'datePaiement': datePaiement.toIso8601String(),
      'modePaiement': modePaiement,
      'idReservation': idReservation,
    };
  }
}

class PaiementStatus {
  final int? idPaiement;
  final int idReservation;
  final double? montant;
  final String? modePaiement;
  final DateTime? datePaiement;
  final String status;

  PaiementStatus({
    this.idPaiement,
    required this.idReservation,
    this.montant,
    this.modePaiement,
    this.datePaiement,
    required this.status,
  });

  factory PaiementStatus.fromJson(Map<String, dynamic> json) {
    return PaiementStatus(
      idPaiement: json['idPaiement'],
      idReservation: json['idReservation'] ?? 0,
      montant: json['montant'] != null
          ? double.tryParse(json['montant'].toString())
          : null,
      modePaiement: json['modePaiement'],
      datePaiement: json['datePaiement'] != null
          ? DateTime.tryParse(json['datePaiement'])
          : null,
      status: json['status'] ?? 'PENDING',
    );
  }
}
