// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get dashboard => 'Dashboard';

  @override
  String get events => 'Events';

  @override
  String get tickets => 'Tickets';

  @override
  String get reservations => 'Reservations';

  @override
  String get account => 'Account';

  @override
  String get layoutTitle => 'Ontik — Organizer';

  @override
  String get profileTitle => 'Profile';

  @override
  String get overview => 'Overview';

  @override
  String eventsActive(Object count) {
    return '$count active events';
  }

  @override
  String get manage => 'Manage';

  @override
  String get revenue => 'Revenue';

  @override
  String get fillRate => 'Fill rate';

  @override
  String get ticketsSold => 'Tickets sold';

  @override
  String get seatsAvailable => 'Seats avail.';

  @override
  String get myEvents => 'My events';

  @override
  String get seeAll => 'See all';

  @override
  String get salesEvolution => 'Sales evolution';

  @override
  String get topEvents => 'Top events';

  @override
  String get suspendEventTitle => 'Suspend event';

  @override
  String suspendConfirm(Object event) {
    return 'Suspend \"$event\"? Existing reservations will be kept.';
  }

  @override
  String get suspend => 'Suspend';

  @override
  String get eventSuspended => 'Event suspended';

  @override
  String get eventResumed => 'Event reactivated';

  @override
  String get cancelEventTitle => 'Cancel event';

  @override
  String cancelConfirm(Object event) {
    return 'Are you sure you want to cancel \"$event\"?';
  }

  @override
  String get cancelNotify => 'Booked customers will be notified.';

  @override
  String get cancelReason => 'Cancellation reason';

  @override
  String get cancelEvent => 'Cancel event';

  @override
  String get eventCancelled => 'Event cancelled';

  @override
  String get info => 'Info';

  @override
  String get reactivate => 'Reactivate';

  @override
  String get noEvents => 'No events';

  @override
  String get createEvent => 'Create Event';

  @override
  String get statusLabel => 'Status';

  @override
  String get dateLabel => 'Date';

  @override
  String get timeLabel => 'Time';

  @override
  String get countdownLabel => 'Countdown';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get categoryLabel => 'Category';

  @override
  String get locationLabel => 'Venue';

  @override
  String get organizerLabel => 'Organizer';

  @override
  String get featuresLabel => 'Features';

  @override
  String get feature => 'Feature';

  @override
  String endedMin(Object count) {
    return 'Ended $count min ago';
  }

  @override
  String endedH(Object count) {
    return 'Ended ${count}h ago';
  }

  @override
  String endedD(Object count) {
    return 'Ended ${count}d ago';
  }

  @override
  String endedMonths(Object count) {
    return 'Ended $count months ago';
  }

  @override
  String endedYears(Object count) {
    return 'Ended $count year(s) ago';
  }

  @override
  String startsMin(Object count) {
    return 'Starts in $count min';
  }

  @override
  String startsH(Object count) {
    return 'Starts in ${count}h';
  }

  @override
  String startsD(Object count) {
    return 'Starts in ${count}d';
  }

  @override
  String get personalInfo => 'Personal information';

  @override
  String get lastName => 'Last name';

  @override
  String get firstName => 'First name';

  @override
  String get phone => 'Phone';

  @override
  String get saveChangesConfirm => 'Do you want to save the changes?';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get totalRevenue => 'Total revenue';

  @override
  String get loadError => 'Load error';

  @override
  String get latestSales => 'Latest sales';

  @override
  String get logoutConfirm => 'Do you really want to log out?';

  @override
  String get orgCodeMissing => 'Organizer code not found. Please reconnect.';

  @override
  String get today => 'Today';

  @override
  String get last7Days => '7 days';

  @override
  String get last30Days => '30 days';

  @override
  String get searchClient => 'Search client...';

  @override
  String get paid => 'Paid';

  @override
  String get pending => 'Pending';

  @override
  String get cancelled => 'Cancelled';

  @override
  String reservationCount(Object count) {
    return '$count reservation(s)';
  }

  @override
  String get noReservationsForEvent => 'No reservations for this event';

  @override
  String get selectEvent => 'Select an event';

  @override
  String get noReservations => 'No reservations';

  @override
  String ticketCount(Object count) {
    return '$count ticket(s)';
  }

  @override
  String get fullDetail => 'Full detail';

  @override
  String get viewEvent => 'View event';

  @override
  String get available => 'Available';

  @override
  String get scanned => 'Scanned';

  @override
  String get pendingShort => 'Pending';

  @override
  String pricingTitle(Object title) {
    return 'Pricing — $title';
  }

  @override
  String get roomLabel => 'Room:';

  @override
  String get priceByType => 'Price by seat type';

  @override
  String get priceByTypeDesc =>
      'Set the price for each seat type. All seats of this type will be updated.';

  @override
  String get price => 'Price';

  @override
  String get apply => 'Apply';

  @override
  String get typeAssignment => 'Type assignment';

  @override
  String get typeAssignmentDesc =>
      'Select rows or seats and assign them a type.';

  @override
  String get typeToAssign => 'Type to assign';

  @override
  String get newType => '+ New type...';

  @override
  String get assign => 'Assign';

  @override
  String selectionCount(Object rows, Object seats) {
    return '$rows row(s) • $seats seat(s) selected';
  }

  @override
  String get noRows => 'No rows available';

  @override
  String get clickSeatToSelect => 'Click a seat in the grid below to select it';

  @override
  String get rowPricing => 'Pricing by row';

  @override
  String get rowPricingDesc => 'Configure type and price for each row.';

  @override
  String get seatGrid => 'Individual grid';

  @override
  String get searchSeat => 'Search seat...';

  @override
  String get type => 'Type';

  @override
  String seatCountLabel(Object configured, Object total) {
    return '$total seats • $configured configured';
  }

  @override
  String get configured => 'configured';

  @override
  String priceWithCurrency(Object currency) {
    return 'Price ($currency)';
  }

  @override
  String get newTypeName => 'New type';

  @override
  String get confirmRefund => 'Confirm refund';

  @override
  String get refundsTitle => 'Refunds and cancellations';

  @override
  String get cancelledBadge => 'CANCELLED';

  @override
  String get refundAction => 'Refund';

  @override
  String get dataExport => 'Data export';

  @override
  String get selectEventExport => 'Select an event to export data';

  @override
  String get ticketsCsv => 'Tickets CSV';

  @override
  String get reservationsCsv => 'Reserv. CSV';

  @override
  String get scanTicket => 'Scan a ticket';

  @override
  String get scanNext => 'Scan next';

  @override
  String get alignQr => 'Align the QR code within the frame';

  @override
  String get ticketValid => 'Valid ticket';

  @override
  String get ticketInvalid => 'Invalid ticket';

  @override
  String get stepInfos => 'Info';

  @override
  String get stepDateTime => 'Date & Time';

  @override
  String get stepLocation => 'Venue & Seats';

  @override
  String get stepSummary => 'Summary';

  @override
  String get editEvent => 'Edit event';

  @override
  String get cancelEdit => 'Cancel changes?';

  @override
  String get cancelCreate => 'Cancel creation?';

  @override
  String get unsavedChanges => 'Unsaved changes will be lost.';

  @override
  String get eventUpdated => 'Event updated';

  @override
  String get eventCreated => 'Event created';

  @override
  String get publishEvent => 'Publish event';

  @override
  String get statusSuspended => 'Suspended';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusUpcoming => 'Upcoming';

  @override
  String get statusInProgress => 'In progress';

  @override
  String get statusEnded => 'Ended';

  @override
  String get eventLabel => 'Event';

  @override
  String get periodToday => 'Today';

  @override
  String get period7days => '7 days';

  @override
  String get period30days => '30 days';

  @override
  String get searchClientHint => 'Search client...';

  @override
  String get statusPaid => 'Paid';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusCancelledShort => 'Cancelled';

  @override
  String get retryButton => 'Retry';

  @override
  String get unknownClient => 'Unknown';

  @override
  String ticketsCount(Object count) {
    return '$count ticket(s)';
  }

  @override
  String seatPlace(Object seat) {
    return 'Seat $seat';
  }

  @override
  String get fullDetailButton => 'Full detail';

  @override
  String get viewEventButton => 'View event';

  @override
  String reservationHeader(Object id) {
    return 'Reservation #$id';
  }

  @override
  String get clientSection => 'Client';

  @override
  String get nameField => 'Name';

  @override
  String get codeField => 'Code';

  @override
  String get emailField => 'Email';

  @override
  String get phoneField => 'Phone';

  @override
  String get paymentSection => 'Payment';

  @override
  String get amountField => 'Amount';

  @override
  String get modeField => 'Method';

  @override
  String get paymentDateField => 'Date';

  @override
  String get statusField => 'Status';

  @override
  String get ticketsSection => 'Tickets';

  @override
  String get noTicketsText => 'No tickets';

  @override
  String seatPlaceDetail(Object seat) {
    return 'Seat $seat';
  }

  @override
  String rowDetail(Object row) {
    return 'Row $row';
  }

  @override
  String get orgCodeMissingReconnect =>
      'Organizer code not found. Please reconnect.';

  @override
  String get paidStatus => 'Paid';

  @override
  String get pendingStatus => 'Pending';

  @override
  String get availableStatus => 'Available';

  @override
  String get scannedStatus => 'Scanned';

  @override
  String get unknownStatus => 'Unknown';

  @override
  String get eventDropdown => 'Event';

  @override
  String get allFilter => 'All';

  @override
  String get paidFilter => 'Paid';

  @override
  String get pendingFilter => 'Pending';

  @override
  String pricingAppliedRow(Object row) {
    return 'Pricing applied to row $row';
  }

  @override
  String pricingAppliedType(Object type) {
    return 'Price applied to type $type';
  }

  @override
  String get selectMinRowOrSeat => 'Select at least one row or seat';

  @override
  String typeAssignedMsg(Object type) {
    return 'Type $type assigned';
  }

  @override
  String seatUpdatedMsg(Object seat) {
    return 'Seat $seat updated';
  }

  @override
  String pricingHeader(Object title) {
    return 'Pricing — $title';
  }

  @override
  String get roomSelector => 'Room:';

  @override
  String get priceByTypeTitle => 'Price by seat type';

  @override
  String get priceField => 'Price';

  @override
  String get applyButton => 'Apply';

  @override
  String get typeAssignmentTitle => 'Type assignment';

  @override
  String get newTypeOption => '+ New type...';

  @override
  String get namePlaceholder => 'Name';

  @override
  String get assignButton => 'Assign';

  @override
  String get noRowsAvailable => 'No rows available';

  @override
  String get rowPricingTitle => 'Pricing by row';

  @override
  String get seatGridTitle => 'Individual grid';

  @override
  String get searchSeatHint => 'Search seat...';

  @override
  String get typeDropdown => 'Type';

  @override
  String get allOption => 'All';

  @override
  String seatCountConfigured(Object configured, Object total) {
    return '$total seats • $configured configured';
  }

  @override
  String seatDialogTitle(Object seat) {
    return 'Seat $seat';
  }

  @override
  String get newTypeLabel => 'New type';

  @override
  String priceCurrency(Object currency) {
    return 'Price ($currency)';
  }

  @override
  String get cancelButton => 'Cancel';

  @override
  String get saveButton => 'Save';

  @override
  String rowTitle(Object count, Object row) {
    return 'Row $row  ($count seats)';
  }

  @override
  String get configuredBadge => 'configured';

  @override
  String get typeField => 'Type';

  @override
  String get confirmRefundTitle => 'Confirm refund';

  @override
  String confirmRefundText(Object id) {
    return 'Do you want to cancel and refund reservation #$id?';
  }

  @override
  String get cancelRefundButton => 'Cancel';

  @override
  String get confirmRefundButton => 'Confirm';

  @override
  String refundResultMessage(Object amount, Object currency, Object id) {
    return 'Reservation #$id cancelled. Refund: $amount $currency';
  }

  @override
  String get cancelledBadgeLabel => 'CANCELLED';

  @override
  String get refundActionButton => 'Refund';

  @override
  String get exportTitle => 'Data export';

  @override
  String get exportSubtitle => 'Select an event to export data';

  @override
  String get noEventsExport => 'No events';

  @override
  String get exportTicketsCsv => 'Tickets CSV';

  @override
  String get exportReservationsCsv => 'Reserv. CSV';

  @override
  String get exportAllButton => 'All';

  @override
  String exportSavedMessage(Object filename) {
    return 'File saved: $filename';
  }

  @override
  String exportErrorPrefix(Object message) {
    return 'Error: $message';
  }

  @override
  String get scanTitle => 'Scan a ticket';

  @override
  String get scanAlignQr => 'Align the QR code within the frame';

  @override
  String get scanValid => 'Valid ticket';

  @override
  String get scanInvalid => 'Invalid ticket';

  @override
  String scanCodeLabel(Object code) {
    return 'Code: $code';
  }

  @override
  String scanEventLabel(Object event) {
    return 'Event: $event';
  }

  @override
  String scanPlaceLabel(Object place) {
    return 'Seat: $place';
  }

  @override
  String scanClientLabel(Object client) {
    return 'Client: $client';
  }

  @override
  String get stepLocationSeats => 'Venue & Seats';

  @override
  String get stepPricing => 'Pricing';

  @override
  String get editEventTitle => 'Edit event';

  @override
  String createEventTitle(Object name, Object step) {
    return 'Create event — Step $step/5: $name';
  }

  @override
  String get cancelEditTitle => 'Cancel changes?';

  @override
  String get cancelCreateTitle => 'Cancel creation?';

  @override
  String get unsavedWarning => 'Unsaved changes will be lost.';

  @override
  String get continueButton => 'Continue';

  @override
  String get cancelButton2 => 'Cancel';

  @override
  String get backButton => 'Back';

  @override
  String get nextButton => 'Next';

  @override
  String get eventUpdatedMsg => 'Event updated';

  @override
  String get eventCreatedMsg => 'Event created';

  @override
  String get publishButton => 'Publish event';

  @override
  String get editButton => 'Edit event';

  @override
  String get generalInfo => 'General information';

  @override
  String get titleRequired => 'Title *';

  @override
  String get requiredMarker => 'Required';

  @override
  String get addPoster => 'Add poster';

  @override
  String get genreRequired => 'Genre *';

  @override
  String get placementType => 'Placement type';

  @override
  String get placementFree => 'Free\nSeating';

  @override
  String get placementNumbered => 'Numbered\nSeating';

  @override
  String get placementMixed => 'Mixed\nSeating';

  @override
  String featuresCategory(Object category) {
    return 'Features $category';
  }

  @override
  String get selectDatePlaceholder => 'Select a date';

  @override
  String get dateTimeTitle => 'Date & Time';

  @override
  String get dateRequired => 'Date *';

  @override
  String get selectDateHint => 'Select date';

  @override
  String get numDaysRequired => 'Number of days *';

  @override
  String get dayUnit => 'day';

  @override
  String get daysUnit => 'days';

  @override
  String get startTimeRequired => 'Start time *';

  @override
  String get selectTimeHint => 'Select time';

  @override
  String get durationHours => 'Duration (hours)';

  @override
  String get durationMinutes => 'Duration (minutes)';

  @override
  String totalDurationLabel(Object duration) {
    return 'Total duration: $duration';
  }

  @override
  String dateRangeLabel(Object days, Object end, Object start) {
    return 'From $start to $end ($days day(s))';
  }

  @override
  String get locationConfig => 'Venue & Configuration';

  @override
  String get venueDropdown => 'Venue / Building';

  @override
  String get withoutRoom => 'Without specific room';

  @override
  String get noRoomsAvailable => 'No rooms available';

  @override
  String get capacityLabel => 'Capacity';

  @override
  String get unlimitedCapacity => 'Unlimited people';

  @override
  String get maxPeopleLabel => 'Max people';

  @override
  String get unlimitedHint => 'Leave empty for unlimited';

  @override
  String get seatTypesPricingLabel => 'Seat types & prices';

  @override
  String get pricePrefix => '';

  @override
  String get addStandingZoneTitle => 'Add a standing zone';

  @override
  String get zoneNameLabel => 'Zone name';

  @override
  String get zoneNameHint => 'Pit, Balcony...';

  @override
  String get zoneCapacityLabel => 'Max capacity';

  @override
  String get unlimitedToggle => 'Unlimited';

  @override
  String get limitedToggle => 'Limited';

  @override
  String get zonePriceLabel => 'Unit price';

  @override
  String get addZoneButton => 'Add zone';

  @override
  String capacityPlaces(Object capacity) {
    return '$capacity seats';
  }

  @override
  String get seatTypesLabel => 'Seat types';

  @override
  String get seatTypesDesc =>
      'Create seat categories (Standard, VIP, Pit, Balcony...)';

  @override
  String get newTypeHint => 'New type...';

  @override
  String get roomRequiredLabel => 'Room *';

  @override
  String get standingZonesLabel => 'Standing zones';

  @override
  String zoneCapacityInfo(Object capacity) {
    return '$capacity people max';
  }

  @override
  String get zoneCapacityUnlimited => 'Unlimited';

  @override
  String zonePricePrefix(Object price) {
    return '$price';
  }

  @override
  String get pricingDesc => 'Set the price for each seat type.';

  @override
  String get selectRoomFirstHint =>
      'Please select a room in the previous step first.';

  @override
  String get seatPlanConfig => 'Configure seating plan';

  @override
  String get individualSeats => 'Individual seats';

  @override
  String seatsSelectedCount(Object count) {
    return '$count selected';
  }

  @override
  String get assignTariff => 'Assign a tariff type';

  @override
  String pendingAssignments(Object count) {
    return 'Assignments ($count)';
  }

  @override
  String get clearAll => 'Clear all';

  @override
  String rowAssignmentText(Object row, Object type) {
    return 'Row $row → $type';
  }

  @override
  String seatAssignmentText(Object seat, Object type) {
    return 'Seat $seat → $type';
  }

  @override
  String placesCountSuffix(Object count) {
    return '$count seat(s)';
  }

  @override
  String get tariffTypeTitle => 'Tariff type';

  @override
  String get noTypesWithPrice => 'No seat types with a defined price.';

  @override
  String get applyTariff => 'Apply';

  @override
  String get summaryTitle => 'Summary';

  @override
  String get dateTimeSection => 'Date & Time';

  @override
  String untilDate(Object date, Object days) {
    return 'Until $date ($days days)';
  }

  @override
  String timeDisplay(Object time) {
    return '$time';
  }

  @override
  String durationDisplay(Object duration) {
    return 'Duration: $duration';
  }

  @override
  String get locationSection => 'Venue';

  @override
  String capacityDisplay(Object capacity) {
    return 'Capacity: $capacity people';
  }

  @override
  String get placementPricingSection => 'Placement & Pricing';

  @override
  String get placementFreeDisplay => 'Free seating';

  @override
  String get placementMixedDisplay => 'Mixed';

  @override
  String get placementNumberedDisplay => 'Numbered';

  @override
  String typesDisplay(Object types) {
    return '$types';
  }

  @override
  String standingZonesCount(Object count) {
    return '$count standing zone(s)';
  }

  @override
  String priceDisplay(Object price, Object type) {
    return '$type: $price';
  }

  @override
  String get featuresSection => 'Features';

  @override
  String featureDisplay(Object name, Object value) {
    return '$name: $value';
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
  String get commonCancel => 'Cancel';

  @override
  String get commonBack => 'Back';

  @override
  String get commonClose => 'Close';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonSave => 'Save';

  @override
  String get commonLogout => 'Logout';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsPreferences => 'Preferences';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageFr => 'Français';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsSecurity => 'Security';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsPassword2fa => 'Password & 2FA';

  @override
  String get settingsSecured => 'Secured';

  @override
  String get settingsConnectedDevices => 'Connected devices';

  @override
  String get settingsCurrentDevice => 'Current device';

  @override
  String get settingsActive => 'Active';

  @override
  String get settingsOthersDisconnected =>
      'All other devices have been disconnected';

  @override
  String get settingsDisconnectOthers => 'Disconnect other devices';

  @override
  String get settingsLogoutConfirm => 'Do you want to log out?';

  @override
  String get settingsDeleteAccount => 'Delete account';

  @override
  String get settingsIrreversible => 'This action is irreversible';

  @override
  String get settingsDeleteConfirm =>
      'Do you really want to delete your account? This action is irreversible.';

  @override
  String get settingsNotImplemented => 'Feature not yet implemented';

  @override
  String get settingsConfirm => 'Confirm';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAppVersion => 'App version';
}
