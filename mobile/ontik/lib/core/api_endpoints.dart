class ApiEndpoints {
  static const auth = AuthEndpoints();
  static const events = EventsEndpoints();
  static const reservations = ReservationsEndpoints();
  static const tickets = TicketsEndpoints();
  static const paiements = PaiementsEndpoints();
  static const clients = ClientEndpoints();
  static const organisateurs = OrganisateurEndpoints();
  static const admin = AdminEndpoints();
  static const categories = CategoriesEndpoints();
  static const lieux = LieuxEndpoints();
  static const salles = SallesEndpoints();
  static const places = PlacesEndpoints();
}

class AuthEndpoints {
  const AuthEndpoints();
  String get login => '/auth/login';
  String get register => '/auth/register';
  String forgotPassword() => '/auth/forgot-password';
  String resetPassword() => '/auth/reset-password';
  String changePassword() => '/auth/change-password';
  String get firstLoginUpdate => '/auth/first-login-update';
}

class EventsEndpoints {
  const EventsEndpoints();
  String get all => '/evenements';
  String byId(int id) => '/evenements/$id';
  String get search => '/evenements/search';
  String get upcoming => '/evenements/upcoming';
  String get popular => '/evenements/popular';
  String detail(int id) => '/evenements/$id/detail';
  String availableSeats(int id) => '/evenements/$id/places/available';
  String stats(int id) => '/evenements/$id/stats';
  String byOrganisateur(String code) => '/evenements?organisateur=$code';
  String byCategorie(String code) => '/evenements?categorie=$code';
  String byStatut(String statut) => '/evenements?statut=$statut';
}

class ReservationsEndpoints {
  const ReservationsEndpoints();
  String get all => '/reservations';
  String byId(int id) => '/reservations/$id';
  String update(int id) => '/reservations/$id';
  String cancel(int id) => '/reservations/$id/cancel';
  String tickets(int id) => '/reservations/$id/tickets';
}

class TicketsEndpoints {
  const TicketsEndpoints();
  String get all => '/tickets';
  String byId(String code) => '/tickets/$code';
  String qrcode(String code) => '/tickets/$code/qrcode';
  String get validate => '/tickets/validate';
}

class PaiementsEndpoints {
  const PaiementsEndpoints();
  String get all => '/paiements';
  String byId(int id) => '/paiements/$id';
  String status(int reservationId) => '/paiements/reservation/$reservationId/status';
  String get webhook => '/paiements/webhook';
}

class ClientEndpoints {
  const ClientEndpoints();
  String reservations(String code) => '/clients/$code/reservations';
  String tickets(String code) => '/clients/$code/tickets';
  String payments(String code) => '/clients/$code/payments';
}

class OrganisateurEndpoints {
  const OrganisateurEndpoints();
  String get all => '/organisateurs';
  String byId(String code) => '/organisateurs/$code';
  String dashboard(String code) => '/organisateurs/$code/dashboard';
}

class AdminEndpoints {
  const AdminEndpoints();
  String get dashboard => '/admin/dashboard';
}

class CategoriesEndpoints {
  const CategoriesEndpoints();
  String get all => '/categories';
  String byId(String code) => '/categories/$code';
}

class LieuxEndpoints {
  const LieuxEndpoints();
  String get all => '/lieux';
  String byId(int id) => '/lieux/$id';
}

class SallesEndpoints {
  const SallesEndpoints();
  String get all => '/salles';
  String byId(String numero) => '/salles/$numero';
}

class PlacesEndpoints {
  const PlacesEndpoints();
  String get all => '/places';
  String byId(String numero) => '/places/$numero';
}
