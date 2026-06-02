import 'evenement_model.dart';

class AdminDashboardStats {
  final int totalEvents;
  final int totalClients;
  final int totalOrganisateurs;
  final int totalReservations;
  final int totalTicketsSold;
  final double totalRevenue;
  final int totalLieux;
  final int totalSalles;
  final List<Evenement> recentEvents;
  final List<Map<String, dynamic>> topEvents;
  final Map<String, int> eventsByStatus;
  final Map<String, int> eventsByCategorie;

  AdminDashboardStats({
    this.totalEvents = 0,
    this.totalClients = 0,
    this.totalOrganisateurs = 0,
    this.totalReservations = 0,
    this.totalTicketsSold = 0,
    this.totalRevenue = 0,
    this.totalLieux = 0,
    this.totalSalles = 0,
    this.recentEvents = const [],
    this.topEvents = const [],
    this.eventsByStatus = const {},
    this.eventsByCategorie = const {},
  });

  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) {
    return AdminDashboardStats(
      totalEvents: json['totalEvents'] ?? 0,
      totalClients: json['totalClients'] ?? 0,
      totalOrganisateurs: json['totalOrganisateurs'] ?? 0,
      totalReservations: json['totalReservations'] ?? 0,
      totalTicketsSold: json['totalTicketsSold'] ?? 0,
      totalRevenue: json['totalRevenue'] != null
          ? double.tryParse(json['totalRevenue'].toString()) ?? 0
          : 0,
      totalLieux: json['totalLieux'] ?? 0,
      totalSalles: json['totalSalles'] ?? 0,
      recentEvents: json['recentEvents'] != null
          ? (json['recentEvents'] as List)
              .map((e) => Evenement.fromJson(e))
              .toList()
          : [],
      topEvents: json['topEvents'] != null
          ? (json['topEvents'] as List)
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
          : [],
      eventsByStatus: json['eventsByStatus'] != null
          ? (json['eventsByStatus'] as Map<String, dynamic>)
              .map((k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0))
          : {},
      eventsByCategorie: json['eventsByCategorie'] != null
          ? (json['eventsByCategorie'] as Map<String, dynamic>)
              .map((k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0))
          : {},
    );
  }
}

class OrganizerDashboardStats {
  final String codeOrganisateur;
  final int totalEvents;
  final int totalTicketsSold;
  final int totalReservations;
  final double totalRevenue;
  final int totalPlaces;
  final int placesDisponibles;
  final double fillRate;
  final List<Evenement> myEvents;
  final List<Evenement> topEvents;
  final List<DailySales> dailySales;

  OrganizerDashboardStats({
    this.codeOrganisateur = '',
    this.totalEvents = 0,
    this.totalTicketsSold = 0,
    this.totalReservations = 0,
    this.totalRevenue = 0,
    this.totalPlaces = 0,
    this.placesDisponibles = 0,
    this.fillRate = 0,
    this.myEvents = const [],
    this.topEvents = const [],
    this.dailySales = const [],
  });

  factory OrganizerDashboardStats.fromJson(Map<String, dynamic> json) {
    return OrganizerDashboardStats(
      codeOrganisateur: json['codeOrganisateur'] ?? '',
      totalEvents: json['totalEvents'] ?? 0,
      totalTicketsSold: json['totalTicketsSold'] ?? 0,
      totalReservations: json['totalReservations'] ?? 0,
      totalRevenue: json['totalRevenue'] != null
          ? double.tryParse(json['totalRevenue'].toString()) ?? 0
          : 0,
      totalPlaces: json['totalPlaces'] ?? 0,
      placesDisponibles: json['placesDisponibles'] ?? 0,
      fillRate: (json['fillRate'] ?? 0).toDouble(),
      myEvents: json['myEvents'] != null
          ? (json['myEvents'] as List)
              .map((e) => Evenement.fromJson(e))
              .toList()
          : [],
      topEvents: json['topEvents'] != null
          ? (json['topEvents'] as List)
              .map((e) => Evenement.fromJson(e))
              .toList()
          : [],
      dailySales: json['dailySales'] != null
          ? (json['dailySales'] as List)
              .map((e) => DailySales.fromJson(e))
              .toList()
          : [],
    );
  }
}

class DailySales {
  final String date;
  final int ticketsSold;
  final double revenue;

  DailySales({required this.date, this.ticketsSold = 0, this.revenue = 0});

  factory DailySales.fromJson(Map<String, dynamic> json) {
    return DailySales(
      date: json['date'] ?? '',
      ticketsSold: json['ticketsSold'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
    );
  }
}

class EventStats {
  final int idEvenement;
  final String titre;
  final int totalTickets;
  final int ticketsVendus;
  final int ticketsDisponibles;
  final double totalRevenue;
  final int totalReservations;
  final String statut;
  final Map<String, int> ticketsByType;

  EventStats({
    this.idEvenement = 0,
    this.titre = '',
    this.totalTickets = 0,
    this.ticketsVendus = 0,
    this.ticketsDisponibles = 0,
    this.totalRevenue = 0,
    this.totalReservations = 0,
    this.statut = '',
    this.ticketsByType = const {},
  });

  factory EventStats.fromJson(Map<String, dynamic> json) {
    return EventStats(
      idEvenement: json['idEvenement'] ?? 0,
      titre: json['titre'] ?? '',
      totalTickets: json['totalTickets'] ?? 0,
      ticketsVendus: json['ticketsVendus'] ?? 0,
      ticketsDisponibles: json['ticketsDisponibles'] ?? 0,
      totalRevenue: json['totalRevenue'] != null
          ? double.tryParse(json['totalRevenue'].toString()) ?? 0
          : 0,
      totalReservations: json['totalReservations'] ?? 0,
      statut: json['statut'] ?? '',
      ticketsByType: json['ticketsByType'] != null
          ? Map<String, int>.from(json['ticketsByType'])
          : {},
    );
  }
}
