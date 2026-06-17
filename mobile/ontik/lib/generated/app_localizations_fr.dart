// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get dashboard => 'Dashboard';

  @override
  String get events => 'Événements';

  @override
  String get tickets => 'Tickets';

  @override
  String get reservations => 'Réservations';

  @override
  String get account => 'Compte';

  @override
  String get layoutTitle => 'Ontik - Organisateur';

  @override
  String get profileTitle => 'Profil';

  @override
  String get overview => 'Aperçu';

  @override
  String eventsActive(Object count) {
    return '$count événements actifs';
  }

  @override
  String get manage => 'Gérer';

  @override
  String get revenue => 'Recettes';

  @override
  String get fillRate => 'Remplissage';

  @override
  String get ticketsSold => 'Billets vendus';

  @override
  String get seatsAvailable => 'Places dispo.';

  @override
  String get myEvents => 'Mes événements';

  @override
  String get seeAll => 'Tout voir';

  @override
  String get salesEvolution => 'Évolution des ventes';

  @override
  String get topEvents => 'Top événements';

  @override
  String get suspendEventTitle => 'Suspendre l\'événement';

  @override
  String suspendConfirm(Object event) {
    return 'Suspendre \"$event\" ? Les réservations existantes seront conservées.';
  }

  @override
  String get suspend => 'Suspendre';

  @override
  String get eventSuspended => 'Événement suspendu';

  @override
  String get eventResumed => 'Événement réactivé';

  @override
  String get cancelEventTitle => 'Annuler l\'événement';

  @override
  String cancelConfirm(Object event) {
    return 'Êtes-vous sûr d\'annuler \"$event\" ?';
  }

  @override
  String get cancelNotify => 'Les clients réservés seront notifiés.';

  @override
  String get cancelReason => 'Motif d\'annulation';

  @override
  String get cancelEvent => 'Annuler l\'événement';

  @override
  String get eventCancelled => 'Événement annulé';

  @override
  String get info => 'Info';

  @override
  String get reactivate => 'Réactiver';

  @override
  String get noEvents => 'Aucun événement';

  @override
  String get createEvent => 'Créer un événement';

  @override
  String get statusLabel => 'Statut';

  @override
  String get dateLabel => 'Date';

  @override
  String get timeLabel => 'Heure';

  @override
  String get countdownLabel => 'Compte à rebours';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get categoryLabel => 'Catégorie';

  @override
  String get locationLabel => 'Lieu';

  @override
  String get organizerLabel => 'Organisateur';

  @override
  String get featuresLabel => 'Caractéristiques';

  @override
  String get feature => 'Caractéristique';

  @override
  String endedMin(Object count) {
    return 'Terminé il y a $count min';
  }

  @override
  String endedH(Object count) {
    return 'Terminé il y a ${count}h';
  }

  @override
  String endedD(Object count) {
    return 'Terminé il y a ${count}j';
  }

  @override
  String endedMonths(Object count) {
    return 'Terminé il y a $count mois';
  }

  @override
  String endedYears(Object count) {
    return 'Terminé il y a $count an(s)';
  }

  @override
  String startsMin(Object count) {
    return 'Commence dans $count min';
  }

  @override
  String startsH(Object count) {
    return 'Commence dans ${count}h';
  }

  @override
  String startsD(Object count) {
    return 'Commence dans ${count}j';
  }

  @override
  String get personalInfo => 'Informations personnelles';

  @override
  String get lastName => 'Nom';

  @override
  String get firstName => 'Prénoms';

  @override
  String get phone => 'Téléphone';

  @override
  String get saveChangesConfirm =>
      'Voulez-vous enregistrer les modifications ?';

  @override
  String get profileUpdated => 'Profil mis à jour';

  @override
  String get totalRevenue => 'Revenu total';

  @override
  String get loadError => 'Erreur de chargement';

  @override
  String get latestSales => 'Dernières ventes';

  @override
  String get logoutConfirm => 'Voulez-vous vraiment vous déconnecter ?';

  @override
  String get orgCodeMissing =>
      'Code organisateur introuvable. Reconnectez-vous.';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get last7Days => '7 jours';

  @override
  String get last30Days => '30 jours';

  @override
  String get searchClient => 'Rechercher un client...';

  @override
  String get paid => 'Payé';

  @override
  String get pending => 'En attente';

  @override
  String get cancelled => 'Annulé';

  @override
  String reservationCount(Object count) {
    return '$count réservation(s)';
  }

  @override
  String get noReservationsForEvent => 'Aucune réservation pour cet événement';

  @override
  String get selectEvent => 'Sélectionnez un événement';

  @override
  String get noReservations => 'Aucune réservation';

  @override
  String ticketCount(Object count) {
    return '$count billet(s)';
  }

  @override
  String get fullDetail => 'Détail complet';

  @override
  String get viewEvent => 'Voir événement';

  @override
  String get available => 'Disponible';

  @override
  String get scanned => 'Scanné';

  @override
  String get pendingShort => 'En att.';

  @override
  String pricingTitle(Object title) {
    return 'Tarifs - $title';
  }

  @override
  String get roomLabel => 'Salle:';

  @override
  String get priceByType => 'Prix par type de place';

  @override
  String get priceByTypeDesc =>
      'Définissez le prix pour chaque type de place. Toutes les places de ce type seront mises à jour.';

  @override
  String get price => 'Prix';

  @override
  String get apply => 'Appliquer';

  @override
  String get typeAssignment => 'Affectation des types';

  @override
  String get typeAssignmentDesc =>
      'Sélectionnez les rangées ou places et assignez-leur un type.';

  @override
  String get typeToAssign => 'Type à assigner';

  @override
  String get newType => '+ Nouveau type...';

  @override
  String get assign => 'Affecter';

  @override
  String selectionCount(Object rows, Object seats) {
    return '$rows rangée(s) • $seats place(s) sélectionnée(s)';
  }

  @override
  String get noRows => 'Aucune rangée disponible';

  @override
  String get clickSeatToSelect =>
      'Cliquez sur une place dans la grille ci-dessous pour la sélectionner';

  @override
  String get rowPricing => 'Tarification par rangée';

  @override
  String get rowPricingDesc =>
      'Configurer le type et le prix pour chaque rangée.';

  @override
  String get seatGrid => 'Grille individuelle';

  @override
  String get searchSeat => 'Rechercher place...';

  @override
  String get type => 'Type';

  @override
  String seatCountLabel(Object configured, Object total) {
    return '$total places • $configured configurées';
  }

  @override
  String get configured => 'configuré';

  @override
  String priceWithCurrency(Object currency) {
    return 'Prix ($currency)';
  }

  @override
  String get newTypeName => 'Nouveau type';

  @override
  String get confirmRefund => 'Confirmer le remboursement';

  @override
  String get refundsTitle => 'Remboursements et annulations';

  @override
  String get cancelledBadge => 'ANNULÉ';

  @override
  String get refundAction => 'Rembourser';

  @override
  String get dataExport => 'Export des données';

  @override
  String get selectEventExport =>
      'Sélectionnez un événement pour exporter les données';

  @override
  String get ticketsCsv => 'Billets CSV';

  @override
  String get reservationsCsv => 'Réserv. CSV';

  @override
  String get scanTicket => 'Scanner un billet';

  @override
  String get scanNext => 'Scanner suivant';

  @override
  String get alignQr => 'Alignez le code QR dans le cadre';

  @override
  String get ticketValid => 'Billet valide';

  @override
  String get ticketInvalid => 'Billet invalide';

  @override
  String get stepInfos => 'Infos';

  @override
  String get stepDateTime => 'Date & Heure';

  @override
  String get stepLocation => 'Lieu & Places';

  @override
  String get stepSummary => 'Récapitulatif';

  @override
  String get editEvent => 'Modifier l\'événement';

  @override
  String get cancelEdit => 'Annuler la modification ?';

  @override
  String get cancelCreate => 'Annuler la création ?';

  @override
  String get unsavedChanges =>
      'Les modifications non enregistrées seront perdues.';

  @override
  String get eventUpdated => 'Événement modifié';

  @override
  String get eventCreated => 'Événement créé';

  @override
  String get publishEvent => 'Publier l\'événement';

  @override
  String get statusSuspended => 'Suspendu';

  @override
  String get statusCancelled => 'Annulé';

  @override
  String get statusUpcoming => 'À venir';

  @override
  String get statusInProgress => 'En cours';

  @override
  String get statusEnded => 'Terminé';

  @override
  String get eventLabel => 'Événement';

  @override
  String get periodToday => 'Aujourd\'hui';

  @override
  String get period7days => '7 jours';

  @override
  String get period30days => '30 jours';

  @override
  String get searchClientHint => 'Rechercher un client...';

  @override
  String get statusPaid => 'Payé';

  @override
  String get statusPending => 'En attente';

  @override
  String get statusCancelledShort => 'Annulé';

  @override
  String get retryButton => 'Réessayer';

  @override
  String get unknownClient => 'Inconnu';

  @override
  String ticketsCount(Object count) {
    return '$count billet(s)';
  }

  @override
  String seatPlace(Object seat) {
    return 'Place $seat';
  }

  @override
  String get fullDetailButton => 'Détail complet';

  @override
  String get viewEventButton => 'Voir événement';

  @override
  String reservationHeader(Object id) {
    return 'Réservation #$id';
  }

  @override
  String get clientSection => 'Client';

  @override
  String get nameField => 'Nom';

  @override
  String get codeField => 'Code';

  @override
  String get emailField => 'Email';

  @override
  String get phoneField => 'Téléphone';

  @override
  String get paymentSection => 'Paiement';

  @override
  String get amountField => 'Montant';

  @override
  String get modeField => 'Mode';

  @override
  String get paymentDateField => 'Date';

  @override
  String get statusField => 'Statut';

  @override
  String get ticketsSection => 'Billets';

  @override
  String get noTicketsText => 'Aucun billet';

  @override
  String seatPlaceDetail(Object seat) {
    return 'Place $seat';
  }

  @override
  String rowDetail(Object row) {
    return 'Rang $row';
  }

  @override
  String get orgCodeMissingReconnect =>
      'Code organisateur introuvable. Reconnectez-vous.';

  @override
  String get paidStatus => 'Payé';

  @override
  String get pendingStatus => 'En attente';

  @override
  String get availableStatus => 'Disponible';

  @override
  String get scannedStatus => 'Scanné';

  @override
  String get unknownStatus => 'Inconnu';

  @override
  String get eventDropdown => 'Événement';

  @override
  String get allFilter => 'Tous';

  @override
  String get paidFilter => 'Payés';

  @override
  String get pendingFilter => 'En att.';

  @override
  String pricingAppliedRow(Object row) {
    return 'Tarification appliquée au rang $row';
  }

  @override
  String pricingAppliedType(Object type) {
    return 'Prix appliqué au type $type';
  }

  @override
  String get selectMinRowOrSeat =>
      'Sélectionnez au moins une rangée ou une place';

  @override
  String typeAssignedMsg(Object type) {
    return 'Type $type assigné';
  }

  @override
  String seatUpdatedMsg(Object seat) {
    return 'Place $seat mise à jour';
  }

  @override
  String pricingHeader(Object title) {
    return 'Tarifs - $title';
  }

  @override
  String get roomSelector => 'Salle:';

  @override
  String get priceByTypeTitle => 'Prix par type de place';

  @override
  String get priceField => 'Prix';

  @override
  String get applyButton => 'Appliquer';

  @override
  String get typeAssignmentTitle => 'Affectation des types';

  @override
  String get newTypeOption => '+ Nouveau type...';

  @override
  String get namePlaceholder => 'Nom';

  @override
  String get assignButton => 'Affecter';

  @override
  String get noRowsAvailable => 'Aucune rangée disponible';

  @override
  String get rowPricingTitle => 'Tarification par rangée';

  @override
  String get seatGridTitle => 'Grille individuelle';

  @override
  String get searchSeatHint => 'Rechercher place...';

  @override
  String get typeDropdown => 'Type';

  @override
  String get allOption => 'Tous';

  @override
  String seatCountConfigured(Object configured, Object total) {
    return '$total places • $configured configurées';
  }

  @override
  String seatDialogTitle(Object seat) {
    return 'Place $seat';
  }

  @override
  String get newTypeLabel => 'Nouveau type';

  @override
  String priceCurrency(Object currency) {
    return 'Prix ($currency)';
  }

  @override
  String get cancelButton => 'Annuler';

  @override
  String get saveButton => 'Enregistrer';

  @override
  String rowTitle(Object count, Object row) {
    return 'Rangée $row  ($count places)';
  }

  @override
  String get configuredBadge => 'configuré';

  @override
  String get typeField => 'Type';

  @override
  String get confirmRefundTitle => 'Confirmer le remboursement';

  @override
  String confirmRefundText(Object id) {
    return 'Voulez-vous annuler et rembourser la réservation #$id ?';
  }

  @override
  String get cancelRefundButton => 'Annuler';

  @override
  String get confirmRefundButton => 'Confirmer';

  @override
  String refundResultMessage(Object amount, Object currency, Object id) {
    return 'Réservation #$id annulée. Remboursement: $amount $currency';
  }

  @override
  String get cancelledBadgeLabel => 'ANNULÉ';

  @override
  String get refundActionButton => 'Rembourser';

  @override
  String get exportTitle => 'Export des données';

  @override
  String get exportSubtitle =>
      'Sélectionnez un événement pour exporter les données';

  @override
  String get noEventsExport => 'Aucun événement';

  @override
  String get exportTicketsCsv => 'Billets CSV';

  @override
  String get exportReservationsCsv => 'Réserv. CSV';

  @override
  String get exportAllButton => 'Tout';

  @override
  String exportSavedMessage(Object filename) {
    return 'Fichier sauvegardé: $filename';
  }

  @override
  String exportErrorPrefix(Object message) {
    return 'Erreur: $message';
  }

  @override
  String get scanTitle => 'Scanner un billet';

  @override
  String get scanAlignQr => 'Alignez le code QR dans le cadre';

  @override
  String get scanValid => 'Billet valide';

  @override
  String get scanInvalid => 'Billet invalide';

  @override
  String scanCodeLabel(Object code) {
    return 'Code : $code';
  }

  @override
  String scanEventLabel(Object event) {
    return 'Événement : $event';
  }

  @override
  String scanPlaceLabel(Object place) {
    return 'Place : $place';
  }

  @override
  String scanClientLabel(Object client) {
    return 'Client : $client';
  }

  @override
  String get stepLocationSeats => 'Lieu & Places';

  @override
  String get stepPricing => 'Prix';

  @override
  String get editEventTitle => 'Modifier l\'événement';

  @override
  String createEventTitle(Object name, Object step) {
    return 'Créer un événement — Étape $step/5 : $name';
  }

  @override
  String get cancelEditTitle => 'Annuler la modification ?';

  @override
  String get cancelCreateTitle => 'Annuler la création ?';

  @override
  String get unsavedWarning =>
      'Les modifications non enregistrées seront perdues.';

  @override
  String get continueButton => 'Continuer';

  @override
  String get cancelButton2 => 'Annuler';

  @override
  String get backButton => 'Retour';

  @override
  String get nextButton => 'Suivant';

  @override
  String get eventUpdatedMsg => 'Événement modifié';

  @override
  String get eventCreatedMsg => 'Événement créé';

  @override
  String get publishButton => 'Publier l\'événement';

  @override
  String get editButton => 'Modifier l\'événement';

  @override
  String get generalInfo => 'Informations générales';

  @override
  String get titleRequired => 'Titre *';

  @override
  String get requiredMarker => 'Requis';

  @override
  String get addPoster => 'Ajouter une affiche';

  @override
  String get genreRequired => 'Genre *';

  @override
  String get placementType => 'Type de placement';

  @override
  String get placementFree => 'Placement\nLibre';

  @override
  String get placementNumbered => 'Placement\nNuméroté';

  @override
  String get placementMixed => 'Placement\nMixte';

  @override
  String featuresCategory(Object category) {
    return 'Caractéristiques $category';
  }

  @override
  String get selectDatePlaceholder => 'Sélectionner une date';

  @override
  String get dateTimeTitle => 'Date & Heure';

  @override
  String get dateRequired => 'Date *';

  @override
  String get selectDateHint => 'Sélectionner la date';

  @override
  String get numDaysRequired => 'Nombre de jours *';

  @override
  String get dayUnit => 'jour';

  @override
  String get daysUnit => 'jours';

  @override
  String get startTimeRequired => 'Heure début *';

  @override
  String get selectTimeHint => 'Sélectionner l\'heure';

  @override
  String get durationHours => 'Durée (heures)';

  @override
  String get durationMinutes => 'Durée (minutes)';

  @override
  String totalDurationLabel(Object duration) {
    return 'Durée totale : $duration';
  }

  @override
  String dateRangeLabel(Object days, Object end, Object start) {
    return 'Du $start au $end ($days jour(s))';
  }

  @override
  String get locationConfig => 'Lieu & Configuration';

  @override
  String get venueDropdown => 'Lieu / Bâtiment';

  @override
  String get withoutRoom => 'Sans salle spécifique';

  @override
  String get noRoomsAvailable => 'Aucune salle disponible';

  @override
  String get capacityLabel => 'Capacité';

  @override
  String get unlimitedCapacity => 'Sans limite de personnes';

  @override
  String get maxPeopleLabel => 'Nombre max de personnes';

  @override
  String get unlimitedHint => 'Laissez vide pour illimité';

  @override
  String get seatTypesPricingLabel => 'Types de places tarifs';

  @override
  String get pricePrefix => 'Ar ';

  @override
  String get addStandingZoneTitle => 'Ajouter une zone debout';

  @override
  String get zoneNameLabel => 'Nom de la zone';

  @override
  String get zoneNameHint => 'Fosse, Balcon...';

  @override
  String get zoneCapacityLabel => 'Capacité max';

  @override
  String get unlimitedToggle => 'Illimité';

  @override
  String get limitedToggle => 'Limitée';

  @override
  String get zonePriceLabel => 'Prix unitaire (Ar)';

  @override
  String get addZoneButton => 'Ajouter la zone';

  @override
  String capacityPlaces(Object capacity) {
    return '$capacity pl.';
  }

  @override
  String get seatTypesLabel => 'Types de places';

  @override
  String get seatTypesDesc =>
      'Créez les catégories de places (Standard, VIP, Fosse, Balcon...)';

  @override
  String get newTypeHint => 'Nouveau type...';

  @override
  String get roomRequiredLabel => 'Salle *';

  @override
  String get standingZonesLabel => 'Zones debout';

  @override
  String zoneCapacityInfo(Object capacity) {
    return '$capacity pers. max';
  }

  @override
  String get zoneCapacityUnlimited => 'Sans limite';

  @override
  String zonePricePrefix(Object price) {
    return 'Ar $price';
  }

  @override
  String get pricingDesc => 'Définissez le prix pour chaque type de place.';

  @override
  String get selectRoomFirstHint =>
      'Veuillez d\'abord sélectionner une salle à l\'étape précédente.';

  @override
  String get seatPlanConfig => 'Configurer le plan de salle';

  @override
  String get individualSeats => 'Places individuelles';

  @override
  String seatsSelectedCount(Object count) {
    return '$count sélectionnée(s)';
  }

  @override
  String get assignTariff => 'Affecter un type de tarif';

  @override
  String pendingAssignments(Object count) {
    return 'Assignations ($count)';
  }

  @override
  String get clearAll => 'Tout effacer';

  @override
  String rowAssignmentText(Object row, Object type) {
    return 'Rangée $row → $type';
  }

  @override
  String seatAssignmentText(Object seat, Object type) {
    return 'Place $seat → $type';
  }

  @override
  String placesCountSuffix(Object count) {
    return '$count place(s)';
  }

  @override
  String get tariffTypeTitle => 'Type de tarif';

  @override
  String get noTypesWithPrice => 'Aucun type de place avec prix défini.';

  @override
  String get applyTariff => 'Appliquer';

  @override
  String get summaryTitle => 'Récapitulatif';

  @override
  String get dateTimeSection => 'Date & Heure';

  @override
  String untilDate(Object date, Object days) {
    return 'Jusqu\'au $date ($days jours)';
  }

  @override
  String timeDisplay(Object time) {
    return '$time';
  }

  @override
  String durationDisplay(Object duration) {
    return 'Durée : $duration';
  }

  @override
  String get locationSection => 'Lieu';

  @override
  String capacityDisplay(Object capacity) {
    return 'Capacité : $capacity personnes';
  }

  @override
  String get placementPricingSection => 'Placement & Tarifs';

  @override
  String get placementFreeDisplay => 'Placement libre';

  @override
  String get placementMixedDisplay => 'Mixte';

  @override
  String get placementNumberedDisplay => 'Numéroté';

  @override
  String typesDisplay(Object types) {
    return '$types';
  }

  @override
  String standingZonesCount(Object count) {
    return '$count zone(s) debout';
  }

  @override
  String priceDisplay(Object price, Object type) {
    return '$type : Ar $price';
  }

  @override
  String get featuresSection => 'Caractéristiques';

  @override
  String featureDisplay(Object name, Object value) {
    return '$name : $value';
  }

  @override
  String get rowPrefix => 'Row';

  @override
  String get noRowLabel => 'No rows';

  @override
  String reservationCountPlain(Object count) {
    return '$count reservation(s)';
  }

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonBack => 'Retour';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonConfirm => 'Confirmer';

  @override
  String get commonEdit => 'Modifier';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonLogout => 'Déconnexion';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsPreferences => 'Préférences';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageFr => 'Français';

  @override
  String get settingsLanguageEn => 'Anglais';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String get settingsThemeSystem => 'Système';

  @override
  String get settingsSecurity => 'Sécurité';

  @override
  String get settingsAccount => 'Compte';

  @override
  String get settingsPassword2fa => 'Mot de passe & 2FA';

  @override
  String get settingsSecured => 'Sécurisé';

  @override
  String get settingsConnectedDevices => 'Appareils connectés';

  @override
  String get settingsCurrentDevice => 'Appareil actuel';

  @override
  String get settingsActive => 'Actif';

  @override
  String get settingsOthersDisconnected =>
      'Tous les autres appareils ont été déconnectés';

  @override
  String get settingsDisconnectOthers => 'Déconnecter les autres appareils';

  @override
  String get settingsLogoutConfirm => 'Voulez-vous vous déconnecter ?';

  @override
  String get settingsDeleteAccount => 'Supprimer le compte';

  @override
  String get settingsIrreversible => 'Cette action est irréversible';

  @override
  String get settingsDeleteConfirm =>
      'Voulez-vous vraiment supprimer votre compte ? Cette action est irréversible.';

  @override
  String get settingsNotImplemented => 'Fonctionnalité pas encore implémentée';

  @override
  String get settingsConfirm => 'Confirmer';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get settingsAppVersion => 'Version de l\'application';
}
