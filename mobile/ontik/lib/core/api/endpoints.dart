class Endpoints {
  static const base = 'http://localhost:8080/api';

  static const login = '$base/auth/login';
  static const register = '$base/auth/register';
  static const firstLogin = '$base/auth/first-login';

  static const events = '$base/evenements';
  static String eventById(int id) => '$base/evenements/$id';
  static String eventValidate(int id) => '$base/evenements/$id/validate';
  static String eventAvailablePlaces(int id) => '$base/evenements/$id/places/available';

  static const places = '$base/places';
  static String placeBySalle(String salle) => '$base/places?salle=$salle';

  static const reservations = '$base/reservations';
  static String reservationById(int id) => '$base/reservations/$id';

  static const payments = '$base/paiements';

  static const tickets = '$base/tickets';
  static String ticketByCode(String code) => '$base/tickets/$code';
  static const ticketValidate = '$base/tickets/validate';

  static const users = '$base/users';
  static const categories = '$base/categories';
  static const lieux = '$base/lieux';
  static const salles = '$base/salles';

  static const dashboard = '$base/dashboard';
  static String organizerDashboard(String code) => '$base/dashboard/organisateur/$code';

  static String typePricing(int eventId) => '$base/evenements/$eventId/pricing/type';
  static String assignType(int eventId) => '$base/evenements/$eventId/pricing/assign';

  static String organizerProfile(String code) => '$base/organisateurs/$code';
  static String organizerEventSalles(int eventId) => '$base/organisateur/evenements/$eventId/salles';
  static String organizerEventPlacesConfig(int eventId, String salle) => '$base/organisateur/evenements/$eventId/places/config?salle=$salle';
  static String organizerEventRowPricing(int eventId) => '$base/organisateur/evenements/$eventId/places/rang/pricing';
  static String organizerEventTypePricing(int eventId) => '$base/organisateur/evenements/$eventId/places/type/pricing';
  static String organizerEventAssignType(int eventId) => '$base/organisateur/evenements/$eventId/places/assign-type';
  static String organizerEventPlaceConfig(int eventId, String numeroPlace) => '$base/organisateur/evenements/$eventId/places/config/$numeroPlace';
}
