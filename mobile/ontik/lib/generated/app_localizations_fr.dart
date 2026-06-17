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
  String get commonAll => 'Tous';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get commonDelete => 'Supprimer';

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

  @override
  String get appTitle => 'Ontik';

  @override
  String get appLoading => 'Chargement...';

  @override
  String get splashTitle => 'Ontik';

  @override
  String get authLoginTitle => 'Connexion';

  @override
  String get authLoginEmail => 'Email';

  @override
  String get authLoginPassword => 'Mot de passe';

  @override
  String get authLoginSubmit => 'Se connecter';

  @override
  String get authLoginForgotPassword => 'Mot de passe oublié ?';

  @override
  String get authLoginNoAccount => 'Pas encore de compte ?';

  @override
  String get authLoginRegister => 'S\'inscrire';

  @override
  String get authLoginWelcome => 'Bon retour';

  @override
  String get authRegisterTitle => 'Inscription';

  @override
  String get authRegisterSubmit => 'S\'inscrire';

  @override
  String get authRegisterHaveAccount => 'Déjà un compte ?';

  @override
  String get authRegisterLogin => 'Se connecter';

  @override
  String get authForgotPasswordTitle => 'Mot de passe oublié';

  @override
  String get authRegisterSuccess => 'Inscription réussie. Connectez-vous.';

  @override
  String get clientHome => 'Événements';

  @override
  String get clientTickets => 'Mes billets';

  @override
  String get clientAccount => 'Compte';

  @override
  String get clientProfileTitle => 'Mon Profil';

  @override
  String get clientLayoutTitle => 'Ontik';

  @override
  String get clientHomeFilters => 'Filtres';

  @override
  String get clientHomeReset => 'Réinitialiser';

  @override
  String get clientHomeStatus => 'Statut';

  @override
  String get clientHomeVenue => 'Lieu';

  @override
  String get clientHomeAllVenues => 'Tous les lieux';

  @override
  String get clientHomeSelectDateRange => 'Sélectionner une plage';

  @override
  String get clientHomeApply => 'Appliquer';

  @override
  String get clientHomeSearchHint => 'Rechercher un événement...';

  @override
  String get clientHomeFeatured => 'Événements à la une';

  @override
  String get clientHomeNoEvents => 'Aucun événement trouvé';

  @override
  String get clientHomeVenueNotSpecified => 'Lieu non spécifié';

  @override
  String get clientHomePriceUnavailable => 'Prix non disponible';

  @override
  String get clientHomeStandard => 'Standard';

  @override
  String get clientHomePromoTitle => '-20% sur votre premier billet';

  @override
  String get clientHomePromoSubtitle =>
      'Utilisez le code SECURE20 lors du paiement.';

  @override
  String get clientHomeRetry => 'Réessayer';

  @override
  String get clientHomeDetailShare => 'Partager';

  @override
  String get clientHomeDetailRetry => 'Réessayer';

  @override
  String get clientHomeDetailEventNotFound => 'Événement non trouvé';

  @override
  String get clientHomeDetailEvent => 'ÉVÉNEMENT';

  @override
  String get clientHomeDetailDate => 'Date';

  @override
  String get clientHomeDetailTime => 'Heure';

  @override
  String get clientHomeDetailVenueNotSpecified => 'Lieu non spécifié';

  @override
  String get clientHomeDetailAbout => 'À propos de l\'événement';

  @override
  String get clientHomeDetailNoDescription => 'Aucune description disponible.';

  @override
  String get clientHomeDetailCharacteristic => 'Caractéristique';

  @override
  String get clientHomeDetailAvailableZones => 'Zones disponibles';

  @override
  String get clientHomeDetailUnlimitedSeats => 'Places illimitées';

  @override
  String get clientHomeDetailPlacesAvailable => 'places disponibles';

  @override
  String get clientHomeDetailPriceUnavailable => 'Prix non disponible';

  @override
  String get clientHomeDetailFrom => 'À partir de';

  @override
  String get clientHomeDetailBook => 'RÉSERVER MA PLACE';

  @override
  String get clientProfileMyReservations => 'Mes Réservations';

  @override
  String get clientProfileReservationsTab => 'Réservations';

  @override
  String get clientProfileTicketsTab => 'Billets';

  @override
  String get clientProfileReferenceCodes => 'Codes de référence';

  @override
  String get clientProfileNoReservations => 'Aucune réservation';

  @override
  String get clientProfileReservationsWillAppear =>
      'Vos réservations apparaîtront ici.';

  @override
  String get clientProfileUnknownDate => 'Date inconnue';

  @override
  String get clientProfileReservationReference => 'Référence réservation';

  @override
  String get clientProfileNoTickets => 'Aucun billet';

  @override
  String get clientProfileTicketsWillAppear =>
      'Vos billets apparaîtront ici après réservation.';

  @override
  String get clientProfileEvent => 'Événement';

  @override
  String get clientProfileRoom => 'Salle';

  @override
  String get clientProfileRow => 'Rang';

  @override
  String get clientProfileSeat => 'Place';

  @override
  String get clientProfileReference => 'Référence';

  @override
  String get clientProfileExpired => 'EXPIRÉ';

  @override
  String get clientProfileReservation => 'Réservation';

  @override
  String get clientProfileTicketsCount => 'billet(s)';

  @override
  String get clientProfilePersonalInfo => 'Informations personnelles';

  @override
  String get clientProfileLastName => 'Nom';

  @override
  String get clientProfileFirstName => 'Prénoms';

  @override
  String get clientProfilePhone => 'Téléphone';

  @override
  String get clientProfileConfirm => 'Confirmer';

  @override
  String get clientProfileConfirmSave =>
      'Voulez-vous enregistrer les modifications ?';

  @override
  String get clientProfileUpdated => 'Informations mises à jour';

  @override
  String get clientProfilePaymentMethods => 'Moyens de paiement';

  @override
  String get clientProfilePaymentHistoryComing =>
      'Historique des paiements - fonctionnalité à venir.';

  @override
  String get clientProfileClose => 'Fermer';

  @override
  String get clientProfileConfirmLogout =>
      'Voulez-vous vraiment vous déconnecter ?';

  @override
  String get clientProfileUser => 'Utilisateur';

  @override
  String get clientProfileFavorites => 'Favoris';

  @override
  String get clientProfileAlerts => 'Alertes';

  @override
  String get clientProfileAccountGroup => 'Compte';

  @override
  String get clientProfileSecurityGroup => 'Sécurité';

  @override
  String get clientProfilePassword2FA => 'Mot de passe & 2FA';

  @override
  String get clientProfileSecure => 'Sécurisé';

  @override
  String get clientProfileConnectedDevices => 'Appareils connectés';

  @override
  String get clientReservationShare => 'Partager';

  @override
  String get clientReservationEventNotFound => 'Événement non trouvé';

  @override
  String get clientReservationNoSeatsAvailable => 'Aucune place disponible';

  @override
  String get clientReservationStage => 'SCÈNE / STAGE';

  @override
  String get clientReservationSelectBlock =>
      'Sélectionnez un bloc pour voir les places disponibles';

  @override
  String get clientReservationNoSeatsInBlock =>
      'Aucune place disponible dans ce bloc';

  @override
  String get clientReservationBlockView => 'Vue depuis le bloc';

  @override
  String get clientReservationNoStandingZones =>
      'Aucune zone debout disponible';

  @override
  String get clientReservationStandingZones => 'Zones debout';

  @override
  String get clientReservationUnlimitedSeats => 'Places illimitées';

  @override
  String get clientReservationSelectedSeats => 'PLACES SÉLECTIONNÉES';

  @override
  String get clientReservationConfirmSelection => 'Confirmer la sélection';

  @override
  String get clientReservationSelectInBlock =>
      'Sélectionnez vos places dans le bloc';

  @override
  String get clientReservationPlaces => 'places';

  @override
  String get clientReservationRemainingSeats => 'place(s) restante(s) sur';

  @override
  String get clientReservationTickets => 'billet(s)';

  @override
  String get clientReservationEstimatedTotal => 'TOTAL ESTIMÉ';

  @override
  String get clientPaymentProcessing => 'Traitement du paiement...';

  @override
  String get clientPaymentPaymentMethod => 'Mode de paiement';

  @override
  String get clientPaymentSummary => 'Récapitulatif';

  @override
  String get clientPaymentVenue => 'SALLE';

  @override
  String get clientPaymentEvent => 'Événement';

  @override
  String get clientPaymentPrice => 'PRIX';

  @override
  String get clientPaymentRow => 'RANG';

  @override
  String get clientPaymentSeat => 'PLACE';

  @override
  String get clientPaymentTickets => 'BILLETS';

  @override
  String get clientPaymentOrderVerified => 'Commande vérifiée';

  @override
  String get clientPaymentCard => 'Carte Bancaire';

  @override
  String get clientPaymentCardSubtitle => 'Visa, Mastercard, AMEX';

  @override
  String get clientPaymentMvolaSubtitle => 'Paiement mobile MVola';

  @override
  String get clientPaymentOrangeSubtitle => 'Paiement mobile Orange';

  @override
  String get clientPaymentAirtelSubtitle => 'Paiement mobile Airtel';

  @override
  String get clientPaymentTransactionRef => 'Référence de transaction';

  @override
  String get clientPaymentPhoneNumber => 'Numéro de téléphone';

  @override
  String get clientPaymentFullName => 'Nom complet';

  @override
  String get clientPaymentSecurityDisclaimer =>
      'Vos données de paiement sont cryptées de bout en bout. Nous sommes certifiés PCI-DSS Level 1.';

  @override
  String get clientPaymentErrorTransactionRef =>
      'La référence de transaction est requise';

  @override
  String get clientPaymentErrorPhoneNumber =>
      'Le numéro de téléphone est requis';

  @override
  String get clientPaymentErrorCardInfo =>
      'Les informations de carte sont requises';

  @override
  String get clientPaymentErrorNotLoggedIn => 'Utilisateur non connecté';

  @override
  String get clientPaymentSuccess => 'Réservation réussie !';

  @override
  String get clientPaymentErrorTimeout =>
      'Le serveur ne répond pas. Vérifiez votre connexion.';

  @override
  String get clientPaymentErrorSeatTaken =>
      'Place déjà réservée ou indisponible. Veuillez réessayer.';

  @override
  String get clientPaymentErrorInsufficientFunds =>
      'Fonds insuffisants pour effectuer cette transaction.';

  @override
  String get clientPaymentErrorPromoCode => 'Code promo invalide ou expiré.';

  @override
  String get clientPaymentSuccessReduction =>
      'Réservation réussie ! Réduction de';

  @override
  String get clientPaymentPay => 'Payer';

  @override
  String get clientTicketTitle => 'Billet';

  @override
  String get clientTicketNotFound => 'Billet non trouvé';

  @override
  String get clientTicketValid => 'VALIDE';

  @override
  String get clientTicketInvalid => 'INVALIDE';

  @override
  String get clientTicketDownloadPDF => 'Télécharger PDF';

  @override
  String get clientTicketEvent => 'Événement';

  @override
  String get clientTicketSeat => 'Place';

  @override
  String get clientTicketRow => 'Rangée';

  @override
  String get clientTicketType => 'Type';

  @override
  String get clientTicketZone => 'Zone';

  @override
  String get clientTicketPrice => 'Prix';

  @override
  String get clientTicketHolder => 'Titulaire';

  @override
  String get clientTicketNoTickets => 'Aucun billet';

  @override
  String get clientTicketAfterPurchase =>
      'Vos billets apparaîtront ici après achat.';

  @override
  String get clientTicketMyTickets => 'Mes Tickets';

  @override
  String get clientTicketManageTickets => 'Gérez vos accès et vos réservations';

  @override
  String get clientTicketRoom => 'Salle';

  @override
  String get clientTicketPdfSaved => 'PDF enregistré dans';

  @override
  String get clientTicketDownloadFailed => 'Échec du téléchargement :';

  @override
  String get clientTicketReference => 'Référence';

  @override
  String get clientTicketExpired => 'EXPIRÉ';

  @override
  String get adminDashboard => 'Tableau de bord';

  @override
  String get adminUsers => 'Users';

  @override
  String get adminEvents => 'Événements';

  @override
  String get adminCategories => 'Catégories';

  @override
  String get adminVenues => 'Lieux';

  @override
  String get adminPlaces => 'Places';

  @override
  String get adminTickets => 'Tickets';

  @override
  String get adminReservations => 'Réservations';

  @override
  String get adminPayments => 'Paiements';

  @override
  String get adminAccount => 'Compte';

  @override
  String get adminLayoutTitle => 'Panneau d\'administration';

  @override
  String get adminConfig => 'Configuration';

  @override
  String get adminMore => 'Plus';

  @override
  String get adminMoreOptions => 'Plus d\'options';

  @override
  String get adminDashboardRecentEvents => 'Recent Events';

  @override
  String get adminDashboardAnalytics => 'Analytics';

  @override
  String get adminDashboardByStatus => 'By status';

  @override
  String get adminDashboardByCategory => 'By category';

  @override
  String get adminDashboardStatEvents => 'Events';

  @override
  String get adminDashboardStatClients => 'Clients';

  @override
  String get adminDashboardStatOrganizers => 'Organizers';

  @override
  String get adminDashboardStatRevenue => 'Revenue';

  @override
  String get adminDashboardStatVenues => 'Venues';

  @override
  String get adminDashboardStatRooms => 'Rooms';

  @override
  String get adminEventsInfo => 'Information';

  @override
  String get adminEventsLogistics => 'Logistics';

  @override
  String get adminEventsCapacity => 'Capacity';

  @override
  String get adminEventsVenue => 'Venue';

  @override
  String get adminEventsDate => 'Date';

  @override
  String get adminEventsTime => 'Time';

  @override
  String get adminEventsNoSeatsConfigured => 'No seats configured';

  @override
  String get adminEventsFeatures => 'Features';

  @override
  String get adminEventsActions => 'Actions';

  @override
  String get adminEventsValidate => 'Validate / Approve';

  @override
  String get adminEventsValidated => 'Event validated';

  @override
  String get adminEventsReactivate => 'Reactivate';

  @override
  String get adminEventsReactivated => 'Event reactivated';

  @override
  String get adminEventsSuspend => 'Suspend';

  @override
  String get adminEventsSuspended => 'Event suspended';

  @override
  String get adminEventsCancelEvent => 'Cancel Event';

  @override
  String get adminEventsCancelled => 'Event cancelled';

  @override
  String get adminEventsContactOrganizer => 'Contact Organizer';

  @override
  String get adminEventsCancelReason => 'Cancellation reason *';

  @override
  String get adminEventsCancelReasonHint => 'Mandatory reason';

  @override
  String get adminEventsContactOptions => 'Contact options:';

  @override
  String get adminEventsSendEmail => 'Send an email';

  @override
  String get adminEventsEmailNotImplemented => 'Email feature not implemented';

  @override
  String get adminEventsInternalChat => 'Internal chat';

  @override
  String get adminEventsOpenChat => 'Open chat';

  @override
  String get adminEventsChatNotImplemented => 'Chat feature not implemented';

  @override
  String get adminEventsEmpty => 'No events found';

  @override
  String get adminUsersChangeRole => 'Change role';

  @override
  String get adminUsersRoleOrganizer => 'Organizer';

  @override
  String get adminUsersRoleClient => 'Client';

  @override
  String get adminUsersResetPassword => 'Reset password';

  @override
  String get adminUsersNewPassword => 'New password';

  @override
  String get adminUsersNewPasswordHint => 'Enter a new password';

  @override
  String get adminUsersPasswordReset => 'Password reset';

  @override
  String get adminUsersDeleteUser => 'Delete user';

  @override
  String get adminUsersManagement => 'User management';

  @override
  String get adminUsersAudit => 'Audit';

  @override
  String get adminUsersEmpty => 'No users found';

  @override
  String get adminUsersActive => 'Active';

  @override
  String get adminUsersInactive => 'Inactive';

  @override
  String get adminUsersNew => 'New';

  @override
  String get adminUsersRole => 'Role';

  @override
  String get adminUsersDeactivate => 'Deactivate';

  @override
  String get adminUsersActivate => 'Activate';

  @override
  String get adminUsersResetPwd => 'Reset PWD';

  @override
  String get adminUsersNoActivity => 'No activity';

  @override
  String get adminCategoriesAdd => 'Add category';

  @override
  String get adminCategoriesCode => 'Code';

  @override
  String get adminCategoriesCodeHint => 'CAT01';

  @override
  String get adminCategoriesName => 'Name';

  @override
  String get adminCategoriesDescription => 'Description';

  @override
  String get adminCategoriesEdit => 'Edit category';

  @override
  String get adminCategoriesDeleteTitle => 'Delete category';

  @override
  String get adminCategoriesDeleted => 'Category deleted';

  @override
  String get adminCategoriesEmpty => 'No categories found';

  @override
  String get adminCategoriesFeatures => 'Features';

  @override
  String get adminCategoriesRooms => 'Rooms';

  @override
  String get adminCategoriesConfig => 'Config';

  @override
  String get adminCategoriesAddFeature => 'Add a feature';

  @override
  String get adminCategoriesEditFeature => 'Edit feature';

  @override
  String get adminCategoriesDataType => 'Data type';

  @override
  String get adminCategoriesDataTypeText => 'Text';

  @override
  String get adminCategoriesDataTypeNumber => 'Number';

  @override
  String get adminCategoriesDataTypeDate => 'Date';

  @override
  String get adminCategoriesDataTypeSelect => 'Dropdown list';

  @override
  String get adminCategoriesDataTypeBoolean => 'Yes/No';

  @override
  String get adminCategoriesDisplayOrder => 'Display order';

  @override
  String get adminCategoriesOptions => 'Options (comma separated)';

  @override
  String get adminCategoriesRequired => 'Required';

  @override
  String get adminCategoriesNoFeatures => 'No features';

  @override
  String get adminCategoriesCompatibleRoomTypes => 'Compatible room types';

  @override
  String get adminCategoriesConfigSaved => 'Specific configuration saved';

  @override
  String get adminCategoriesCinemaConfig => 'Cinema room configuration';

  @override
  String get adminCategoriesNumRows => 'Number of rows';

  @override
  String get adminCategoriesSeatsPerRow => 'Seats per row';

  @override
  String get adminCategoriesAisles => 'Aisles (ex: B,D)';

  @override
  String get adminCategoriesAisleWidth => 'Aisle width';

  @override
  String get adminCategoriesFreeSeatingZones => 'Free seating zones';

  @override
  String get adminCategoriesNoZones => 'No zones configured';

  @override
  String get adminCategoriesAddZone => 'Add a zone';

  @override
  String get adminCategoriesMaxCapacity => 'Max capacity';

  @override
  String get adminCategoriesTicketPrice => 'Ticket price';

  @override
  String get adminCategoriesStandsBlocks => 'Stand blocks';

  @override
  String get adminCategoriesNoBlocks => 'No blocks configured';

  @override
  String get adminCategoriesAddBlock => 'Add a block';

  @override
  String get adminCategoriesBlockType => 'Type (ex: Stand A)';

  @override
  String get adminCategoriesNumSeats => 'Number of seats';

  @override
  String get adminCategoriesPrice => 'Price';

  @override
  String get adminCategoriesType => 'Type';

  @override
  String get adminCategoriesNoSpecificConfig =>
      'No specific configuration available for this category';

  @override
  String get adminVenuesRoomsFor => 'Rooms —';

  @override
  String get adminVenuesNoRooms => 'No rooms for this venue';

  @override
  String get adminVenuesAddRoom => 'Add a room';

  @override
  String get adminVenuesManageSeats => 'Manage seats';

  @override
  String get adminVenuesRoomName => 'Room name';

  @override
  String get adminVenuesVenueCode => 'Venue code';

  @override
  String get adminVenuesName => 'Name';

  @override
  String get adminVenuesAddress => 'Address';

  @override
  String get adminVenuesCity => 'City';

  @override
  String get adminVenuesEmpty => 'No venues found';

  @override
  String get adminVenuesSelectRoomType => 'Select rooms compatible with';

  @override
  String get adminPlacesRoomDeleted => 'Room deleted';

  @override
  String get adminPlacesSeatDeleted => 'Seat deleted';

  @override
  String get adminPlacesEditSeat => 'Edit seat';

  @override
  String get adminPlacesSeatNumber => 'Seat number';

  @override
  String get adminPlacesRow => 'Row';

  @override
  String get adminPlacesEditRoom => 'Edit room';

  @override
  String get adminPlacesAddRoom => 'Add a room';

  @override
  String get adminPlacesParentVenue => 'Parent venue';

  @override
  String get adminPlacesRoomsAndSeats => 'Rooms & Seats';

  @override
  String get adminPlacesSearchRoom => 'Search a room...';

  @override
  String get adminPlacesFilterByVenue => 'Filter by venue';

  @override
  String get adminPlacesAllVenues => 'All venues';

  @override
  String get adminPlacesNoRooms => 'No rooms found';

  @override
  String get adminPlacesManageSeats => 'Manage seats';

  @override
  String get adminPlacesMultiSelect => 'Multi select';

  @override
  String get adminPlacesBatchGeneration => 'Batch generation';

  @override
  String get adminPlacesRowHint => 'B';

  @override
  String get adminPlacesStartNum => 'Start #';

  @override
  String get adminPlacesEndNum => 'End #';

  @override
  String get adminPlacesGenerate => 'Generate';

  @override
  String get adminPlacesSearchSeat => 'Search a seat...';

  @override
  String get adminPlacesNoSeats => 'No seats for this room';

  @override
  String get adminPlacesNoSeatsMatch => 'No seats match your search';

  @override
  String get adminPlacesDeselect => 'Deselect';

  @override
  String get adminPlacesSelect => 'Select';

  @override
  String get adminPlacesBulkDelete => 'Bulk delete';

  @override
  String get adminTicketsEmpty => 'No tickets found';

  @override
  String get adminReservationsEmpty => 'No reservations found';

  @override
  String get adminPaymentsEmpty => 'No payments found';

  @override
  String get adminProfilePersonalInfo => 'Informations personnelles';

  @override
  String get adminProfileLastName => 'Last name';

  @override
  String get adminProfileFirstName => 'First name';

  @override
  String get adminProfileSaveConfirm => 'Do you want to save the changes?';

  @override
  String get adminProfileUpdated => 'Information updated';

  @override
  String get adminProfileActionHistory => 'Action history';

  @override
  String get adminProfileLogoutConfirm => 'Do you really want to log out?';

  @override
  String get adminActionHistoryUndoAction => 'Undo action';

  @override
  String get adminActionHistoryYesUndo => 'Yes, undo';

  @override
  String get adminActionHistoryActionUndone => 'Action undone';

  @override
  String get adminActionHistoryCreateUser => 'User creation';

  @override
  String get adminActionHistoryUpdateUser => 'User update';

  @override
  String get adminActionHistoryChangeRole => 'Role change';

  @override
  String get adminActionHistoryDeactivateUser => 'User deactivation';

  @override
  String get adminActionHistoryActivateUser => 'User activation';

  @override
  String get adminActionHistoryResetPassword => 'Password reset';

  @override
  String get adminActionHistoryDeleteUser => 'User deletion';

  @override
  String get adminActionHistoryPaymentMade => 'Payment made';

  @override
  String get adminActionHistoryRefund => 'Refund';

  @override
  String get adminActionHistoryTitle => 'Action history';

  @override
  String get adminActionHistoryEmpty => 'No actions recorded';

  @override
  String get adminActionHistoryReverted => 'Reverted';

  @override
  String get adminActionHistoryUndo => 'Undo';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsEmpty => 'No notifications';

  @override
  String get notificationsNotConnected => 'User not connected';

  @override
  String get notificationsMarkAllRead => 'Mark all as read';

  @override
  String get notificationsMarkAllReadShort => 'Read all';

  @override
  String get notificationsFilterAll => 'All';

  @override
  String get notificationsFilterPayments => 'Payments';

  @override
  String get notificationsFilterFailed => 'Failed';

  @override
  String get notificationsFilterReservations => 'Reservations';

  @override
  String get notificationsFilterCancellations => 'Cancellations';

  @override
  String get notificationsFilterCancelled => 'Cancelled';

  @override
  String get notificationsFilterApproved => 'Approved';

  @override
  String get notificationsFilterUpdated => 'Updated';

  @override
  String get notificationsFilterSuspended => 'Suspended';

  @override
  String get notificationsFilterScanned => 'Scanned';

  @override
  String get notificationsFilterReused => 'Reused';

  @override
  String get notificationsFilterRefunded => 'Refunded';

  @override
  String get notificationsAll => 'All';

  @override
  String get notificationsUnread => 'Unread';

  @override
  String get notificationsRead => 'Read';

  @override
  String get notificationsNoResults => 'No results';

  @override
  String get notificationsEmptyFiltered =>
      'No notifications match the selected filters.\nModify or reset filters to see more results.';

  @override
  String get notificationsEmptyGeneral =>
      'You will be notified here about important updates.\nBook tickets or create events to receive notifications.';

  @override
  String get notificationsResetFilters => 'Reset filters';

  @override
  String get pageNotFoundTitle => 'Page not found';

  @override
  String get pageNotFoundHome => 'Home';

  @override
  String get widgetsErrorRetry => 'Retry';

  @override
  String get widgetsSeatPickerRow => 'Row';

  @override
  String get widgetsCrudConfirm => 'Confirm';

  @override
  String get widgetsCrudDeleteConfirm => 'Delete this item?';

  @override
  String get widgetsCrudCancel => 'Cancel';

  @override
  String get widgetsCrudDelete => 'Delete';

  @override
  String get widgetsCrudBulkDeleteTitle => 'Bulk delete';

  @override
  String widgetsCrudBulkDeleteConfirm(Object n) {
    return 'Delete $n item(s)?';
  }

  @override
  String get widgetsCrudDeleteAll => 'Delete all';

  @override
  String get widgetsCrudEdit => 'Edit';

  @override
  String get widgetsCrudAdd => 'Add';

  @override
  String get widgetsCrudSave => 'Save';

  @override
  String get widgetsCrudRequired => 'Required';

  @override
  String get widgetsCrudSelectDate => 'Select a date';

  @override
  String get widgetsCrudSelectAll => 'Select all';

  @override
  String get widgetsCrudDeleteSelection => 'Delete selection';

  @override
  String get widgetsCrudExitSelectMode => 'Exit select mode';

  @override
  String get widgetsCrudSelectMode => 'Select mode';

  @override
  String get widgetsCrudSearch => 'Search...';

  @override
  String get widgetsCrudAll => 'All';

  @override
  String get widgetsCrudRetry => 'Retry';

  @override
  String get widgetsCrudEmpty => 'No items';

  @override
  String get widgetsCodePromoLabel => 'Promo code';

  @override
  String get widgetsCodePromoHint => 'Enter your promo code';

  @override
  String get widgetsCodePromoApply => 'Apply';

  @override
  String get widgetsCodePromoApplied => 'Promo code applied!';

  @override
  String get widgetsCarteBancaireTitle => 'Bank card information';

  @override
  String get widgetsCarteBancaireCardNumber => 'Card number';

  @override
  String get widgetsCarteBancaireCardNumberHint => '1234 5678 9012 3456';

  @override
  String get widgetsCarteBancaireExpiry => 'Expiry date';

  @override
  String get widgetsCarteBancaireExpiryHint => 'MM/YY';

  @override
  String get widgetsCarteBancaireCvv => 'CVV';

  @override
  String get widgetsCarteBancaireCvvHint => '123';

  @override
  String get widgetsCarteBancaireCardholderName => 'Cardholder name';

  @override
  String get widgetsCarteBancaireCardholderNameHint => 'JOHN DOE';

  @override
  String get widgetsPaymentMethodTitle => 'Payment method';

  @override
  String get widgetsTwoFactorDisable2fa => 'Disable 2FA';

  @override
  String get widgetsTwoFactorDisable2faConfirm =>
      'Are you sure you want to disable two-factor authentication?';

  @override
  String get widgetsTwoFactorCancel => 'Cancel';

  @override
  String get widgetsTwoFactorDisable => 'Disable';

  @override
  String get widgetsTwoFactorPassword2fa => 'Password & 2FA';

  @override
  String get widgetsTwoFactor2faLabel => 'Two-factor authentication';

  @override
  String get widgetsTwoFactor2faEnabledDesc => '6-digit code sent by email';

  @override
  String get widgetsTwoFactor2faDisabledDesc => 'Enable to secure your account';

  @override
  String get widgetsTwoFactorChangePasswordTitle => 'Change password';

  @override
  String get widgetsTwoFactorCurrentPassword => 'Current password';

  @override
  String get widgetsTwoFactorNewPassword => 'New password';

  @override
  String get widgetsTwoFactorConfirmPassword => 'Confirm';

  @override
  String get widgetsTwoFactorPasswordLengthError =>
      'Password must be at least 6 characters';

  @override
  String get widgetsTwoFactorPasswordMismatchError => 'Passwords do not match';

  @override
  String get widgetsTwoFactorPasswordChanged => 'Password changed';

  @override
  String get widgetsTwoFactorChangePassword => 'Change password';

  @override
  String get widgetsTwoFactorActivate2fa => 'Enable 2FA';

  @override
  String get widgetsTwoFactor2faEmailDesc =>
      'A 6-digit code will be sent to your email address.';

  @override
  String get widgetsTwoFactorSending => 'Sending...';

  @override
  String get widgetsTwoFactorSendCode => 'Send code';

  @override
  String get widgetsTwoFactorCodeHint => '000000';

  @override
  String get widgetsTwoFactor2faActivated => '2FA enabled';

  @override
  String get widgetsTwoFactorIncorrectCode => 'Incorrect code';

  @override
  String get widgetsTwoFactorVerifyActivate => 'Verify & activate';

  @override
  String get widgetsNotificationBellTooltip => 'Notifications';

  @override
  String get widgetsProfileLogout => 'Logout';

  @override
  String get adminUsersCode => 'Code';

  @override
  String get adminUsersTel => 'Phone';

  @override
  String get adminEventsReason => 'Reason';

  @override
  String get adminEventsReserved => 'reserved';

  @override
  String get adminEventsTo => 'to';

  @override
  String get commonNone => 'None';

  @override
  String get commonDetails => 'Details';

  @override
  String get commonNoData => 'No data';

  @override
  String get adminActionHistoryRetry => 'Retry';

  @override
  String get adminActionHistoryActions => 'actions';

  @override
  String get adminActionHistoryNo => 'No';

  @override
  String get adminActionHistoryOn => 'on';

  @override
  String get adminActionHistoryUndoConfirm => 'Undo';

  @override
  String get adminActionHistoryUndoTitle => 'Undo action';

  @override
  String get adminActionHistoryUndone => 'Action undone';

  @override
  String get adminPaymentsReservation => 'Reservation';

  @override
  String get adminPaymentsAmount => 'Amount';

  @override
  String get adminPaymentsMethod => 'Method';

  @override
  String get adminPaymentsDate => 'Date';

  @override
  String get adminPaymentsStatus => 'Status';

  @override
  String get adminTicketsPlace => 'Place';

  @override
  String get adminTicketsEvent => 'Event';

  @override
  String get adminReservationsItem => 'Item';

  @override
  String get adminReservationsClient => 'Client';

  @override
  String get adminReservationsTickets => 'Tickets';

  @override
  String get adminProfileEmail => 'Email';

  @override
  String get adminProfileLogout => 'Logout';

  @override
  String get adminProfileAdmin => 'Admin';

  @override
  String get adminProfileBadge => 'Badge';

  @override
  String get adminProfileAccount => 'Compte';

  @override
  String get adminCategoriesFeatureName => 'Feature name';

  @override
  String get adminCategoriesTypeLabel => 'Type';

  @override
  String get adminCategoriesOrderLabel => 'Order';

  @override
  String get adminCategoriesFeaturesTitle => 'Features';

  @override
  String get adminCategoriesConfigFor => 'Config for';

  @override
  String get adminCategoriesZone => 'Zone';

  @override
  String get adminCategoriesSelectRooms => 'Select rooms';

  @override
  String get adminCategoriesCapacity => 'Capacity';

  @override
  String get adminCategoriesEditZone => 'Edit zone';

  @override
  String get adminCategoriesEditBlock => 'Edit block';

  @override
  String get adminCategoriesBlock => 'Block';

  @override
  String get adminVenuesRoomType => 'Room type';

  @override
  String get adminActionHistory => 'Historique';

  @override
  String get commonAdd => 'Add';
}
