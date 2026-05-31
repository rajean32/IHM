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
  static const organizerVenues = OrganizerVenueEndpoints();
  static const organizerPricing = OrganizerPricingEndpoints();
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
  String validate(int id) => '/evenements/$id/validate';
  String suspend(int id) => '/evenements/$id/suspend';
  String resume(int id) => '/evenements/$id/resume';
  String cancel(int id) => '/evenements/$id/cancel';
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
  String pdf(String code) => '/tickets/$code/pdf';
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

class OrganizerPricingEndpoints {
  const OrganizerPricingEndpoints();
  String rowPricing(int eventId) => '/organisateur/evenements/$eventId/places/rang/pricing';
  String placePricing(String numeroPlace) => '/organisateur/places/$numeroPlace/pricing';
  String eventPlaces(int eventId) => '/organisateur/evenements/$eventId/places';
  String eventSalles(int eventId) => '/organisateur/evenements/$eventId/salles';
  String eventRangs(int eventId, String salle) => '/organisateur/evenements/$eventId/rangs?salle=$salle';
  String placesWithConfig(int eventId, {String? salle}) => '/organisateur/evenements/$eventId/places/config${salle != null ? '?salle=$salle' : ''}';
  String singlePlaceConfig(int eventId, String numeroPlace) => '/organisateur/evenements/$eventId/places/config/$numeroPlace';
  String searchPlaces(int eventId, {String? q, String? type}) {
    final params = <String>[];
    if (q != null && q.isNotEmpty) params.add('q=$q');
    if (type != null && type.isNotEmpty) params.add('type=$type');
    final query = params.isEmpty ? '' : '?${params.join('&')}';
    return '/organisateur/evenements/$eventId/places/config/search$query';
  }
  String distinctTypes(int eventId) => '/organisateur/evenements/$eventId/places/config/types';
}

class PurchaseEndpoints {
  const PurchaseEndpoints();
  String get create => '/achat';
}

class AdminEndpoints {
  const AdminEndpoints();
  String get dashboard => '/admin/dashboard';
  String get activity => '/admin/activity';
  String get users => '/admin/users';
  String userById(String code) => '/admin/users/$code';
  String userRole(String code) => '/admin/users/$code/role';
  String toggleActive(String code) => '/admin/users/$code/toggle-active';
  String get resetPassword => '/admin/users/reset-password';
  String get auditLog => '/admin/users/audit-log';
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

class OrganizerVenueEndpoints {
  const OrganizerVenueEndpoints();
  String get lieux => '/organisateur/venues/lieux';
  String lieuById(int id) => '/organisateur/venues/lieux/$id';
  String get salles => '/organisateur/venues/salles';
  String salleById(String numero) => '/organisateur/venues/salles/$numero';
  String get places => '/organisateur/venues/places';
  String placeById(String numero) => '/organisateur/venues/places/$numero';
  String get batch => '/organisateur/venues/places/batch';
}
