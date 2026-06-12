class Endpoints {
  static const base = 'http://localhost:8081/api';

  static const login = '$base/auth/login';
  static const register = '$base/auth/register';
  static const firstLogin = '$base/auth/first-login-update';
  static const changePassword = '$base/auth/change-password';

  static const events = '$base/evenements';
  static String eventById(int id) => '$base/evenements/$id';
  static String eventValidate(int id) => '$base/evenements/$id/validate';
  static String eventAvailablePlaces(int id) => '$base/evenements/$id/places/available';
  static String eventImage(int id) => '$base/evenements/$id/image';

  static const places = '$base/places';
  static String placeBySalle(String salle) => '$base/places?salle=$salle';

  static const reservations = '$base/reservations';
  static String reservationById(int id) => '$base/reservations/$id';

  static const payments = '$base/achat';

  static const tickets = '$base/tickets';
  static String ticketByCode(String code) => '$base/tickets/$code';
  static const ticketValidate = '$base/tickets/validate';

  static const users = '$base/admin/users';
  static const usersAuditLog = '$base/admin/users/audit-log';
  static const usersResetPassword = '$base/admin/users/reset-password';
  static const categories = '$base/categories';
  static const lieux = '$base/lieux';
  static const salles = '$base/salles';

  static const dashboard = '$base/admin/dashboard';
  static String organizerDashboard(String code) => '$base/organisateurs/$code/dashboard';

  static String typePricing(int eventId) => '$base/organisateur/evenements/$eventId/places/type/pricing';
  static String assignType(int eventId) => '$base/organisateur/evenements/$eventId/places/assign-type';

  static String organizerEventTickets(int eventId) => '$base/organisateur/evenements/$eventId/tickets';
  static String organizerEventReservations(int eventId) => '$base/organisateur/evenements/$eventId/reservations';
  static String organizerReservationDetail(int id) => '$base/organisateur/reservations/$id';

  static String organizerProfile(String code) => '$base/organisateurs/$code';
  static String organizerEventSalles(int eventId) => '$base/organisateur/evenements/$eventId/salles';
  static String organizerEventPlacesConfig(int eventId, String salle) => '$base/organisateur/evenements/$eventId/places/config?salle=$salle';
  static String organizerEventRowPricing(int eventId) => '$base/organisateur/evenements/$eventId/places/rang/pricing';
  static String organizerEventTypePricing(int eventId) => '$base/organisateur/evenements/$eventId/places/type/pricing';
  static String organizerEventAssignType(int eventId) => '$base/organisateur/evenements/$eventId/places/assign-type';
  static String organizerEventPlaceConfig(int eventId, String numeroPlace) => '$base/organisateur/evenements/$eventId/places/config/$numeroPlace';

  // À AJOUTER dans le fichier endpoints.dart existant

// NOUVEAUX ENDPOINTS pour les réductions
  static const reductions = '$base/reductions';
  static String reductionById(int id) => '$base/reductions/$id';
  static String verifierCodePromo(String code, int idEvenement) => '$base/reductions/verifier?code=$code&idEvenement=$idEvenement';

// NOUVEAUX ENDPOINTS pour les films
  static const films = '$base/films';
  static const filmsAVenir = '$base/films/a-venir';
  static String filmById(int id) => '$base/films/$id';
  static String filmByEvenement(int idEvenement) => '$base/films/evenement/$idEvenement';
  static String seancesByFilm(int idFilm) => '$base/films/$idFilm/seances';

// NOUVEAU endpoint pour paiement avec réduction
  static const paymentProcessWithReduction = '$base/paiements/process-with-reduction';

// NOUVEAU endpoint pour remboursement
  static String rembourserReservation(int idReservation, String codeClient, bool isAnnulationEvenement) =>
      '$base/paiements/rembourser/$idReservation?codeClient=$codeClient&isAnnulationEvenement=$isAnnulationEvenement';

// NOUVEAU endpoint pour vérifier transaction mobile
  static String verifierTransaction(String reference, String typePaiement) =>
      '$base/paiements/transaction/verifier?reference=$reference&typePaiement=$typePaiement';

// NOUVEAU endpoint pour événements cinéma
  static const cinemaEvents = '$base/evenements/cinema';
}
