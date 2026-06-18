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
  String get commonAll => 'All';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonDelete => 'Delete';

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
  String get accountDeleted => 'Account deleted';

  @override
  String get errorOccurred => 'An error occurred';

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

  @override
  String get appTitle => 'Ontik';

  @override
  String get appLoading => 'Loading...';

  @override
  String get splashTitle => 'Ontik';

  @override
  String get authLoginTitle => 'Login';

  @override
  String get authLoginEmail => 'Email';

  @override
  String get authLoginPassword => 'Password';

  @override
  String get authLoginSubmit => 'Sign in';

  @override
  String get authLoginForgotPassword => 'Forgot password?';

  @override
  String get authLoginNoAccount => 'Don\'t have an account?';

  @override
  String get authLoginRegister => 'Register';

  @override
  String get authLoginWelcome => 'Welcome back';

  @override
  String get authRegisterTitle => 'Register';

  @override
  String get authRegisterSubmit => 'Sign up';

  @override
  String get authRegisterHaveAccount => 'Already have an account?';

  @override
  String get authRegisterLogin => 'Sign in';

  @override
  String get authForgotPasswordTitle => 'Forgot password';

  @override
  String get authRegisterSuccess => 'Registration successful. Please log in.';

  @override
  String get clientHome => 'Events';

  @override
  String get clientTickets => 'My Tickets';

  @override
  String get clientAccount => 'Account';

  @override
  String get clientProfileTitle => 'My Profile';

  @override
  String get clientLayoutTitle => 'Ontik';

  @override
  String get clientHomeFilters => 'Filters';

  @override
  String get clientHomeReset => 'Reset';

  @override
  String get clientHomeStatus => 'Status';

  @override
  String get clientHomeVenue => 'Venue';

  @override
  String get clientHomeAllVenues => 'All venues';

  @override
  String get clientHomeSelectDateRange => 'Select a range';

  @override
  String get clientHomeApply => 'Apply';

  @override
  String get clientHomeSearchHint => 'Search events...';

  @override
  String get clientHomeNewEvents => 'New Events';

  @override
  String get clientHomeNewBadge => 'NEW';

  @override
  String get clientHomeFeatured => 'Featured events';

  @override
  String get clientHomeNoEvents => 'No events found';

  @override
  String get clientHomeVenueNotSpecified => 'Venue not specified';

  @override
  String get clientHomePriceUnavailable => 'Price unavailable';

  @override
  String get clientHomeStandard => 'Standard';

  @override
  String get clientHomePromoTitle => '-20% on your first ticket';

  @override
  String get clientHomePromoSubtitle => 'Use code SECURE20 at checkout.';

  @override
  String get clientHomeRetry => 'Retry';

  @override
  String get clientHomeDetailShare => 'Share';

  @override
  String get clientHomeDetailRetry => 'Retry';

  @override
  String get clientHomeDetailEventNotFound => 'Event not found';

  @override
  String get clientHomeDetailEvent => 'EVENT';

  @override
  String get clientHomeDetailDate => 'Date';

  @override
  String get clientHomeDetailTime => 'Time';

  @override
  String get clientHomeDetailVenueNotSpecified => 'Venue not specified';

  @override
  String get clientHomeDetailAbout => 'About the event';

  @override
  String get clientHomeDetailNoDescription => 'No description available.';

  @override
  String get clientHomeDetailCharacteristic => 'Characteristic';

  @override
  String get clientHomeDetailAvailableZones => 'Available zones';

  @override
  String get clientHomeDetailUnlimitedSeats => 'Unlimited seats';

  @override
  String get clientHomeDetailPlacesAvailable => 'seats available';

  @override
  String get clientHomeDetailPriceUnavailable => 'Price unavailable';

  @override
  String get clientHomeDetailFrom => 'From';

  @override
  String get clientHomeDetailBook => 'BOOK MY SEAT';

  @override
  String get clientProfileMyReservations => 'My Reservations';

  @override
  String get clientProfileReservationsTab => 'Reservations';

  @override
  String get clientProfileTicketsTab => 'Tickets';

  @override
  String get clientProfileReferenceCodes => 'Reference codes';

  @override
  String get clientProfileNoReservations => 'No reservations';

  @override
  String get clientProfileReservationsWillAppear =>
      'Your reservations will appear here.';

  @override
  String get clientProfileUnknownDate => 'Unknown date';

  @override
  String get clientProfileReservationReference => 'Reservation reference';

  @override
  String get clientProfileNoTickets => 'No tickets';

  @override
  String get clientProfileTicketsWillAppear =>
      'Your tickets will appear here after booking.';

  @override
  String get clientProfileEvent => 'Event';

  @override
  String get clientProfileRoom => 'Room';

  @override
  String get clientProfileRow => 'Row';

  @override
  String get clientProfileSeat => 'Seat';

  @override
  String get clientProfileReference => 'Reference';

  @override
  String get clientProfileExpired => 'EXPIRED';

  @override
  String get clientProfileReservation => 'Reservation';

  @override
  String get clientProfileTicketsCount => 'ticket(s)';

  @override
  String get clientProfilePersonalInfo => 'Personal information';

  @override
  String get clientProfileLastName => 'Last name';

  @override
  String get clientProfileFirstName => 'First name';

  @override
  String get clientProfilePhone => 'Phone';

  @override
  String get clientProfileConfirm => 'Confirm';

  @override
  String get clientProfileConfirmSave => 'Do you want to save the changes?';

  @override
  String get clientProfileUpdated => 'Information updated';

  @override
  String get clientProfilePaymentMethods => 'Payment methods';

  @override
  String get clientProfilePaymentHistoryComing =>
      'Payment history — coming soon.';

  @override
  String get clientProfileClose => 'Close';

  @override
  String get clientProfileConfirmLogout => 'Do you really want to log out?';

  @override
  String get clientProfileUser => 'User';

  @override
  String get clientProfileFavorites => 'Favorites';

  @override
  String get clientProfileAlerts => 'Alerts';

  @override
  String get clientProfileAccountGroup => 'Account';

  @override
  String get clientProfileSecurityGroup => 'Security';

  @override
  String get clientProfilePassword2FA => 'Password & 2FA';

  @override
  String get clientProfileSecure => 'Secured';

  @override
  String get clientProfileConnectedDevices => 'Connected devices';

  @override
  String get clientReservationShare => 'Share';

  @override
  String get clientReservationEventNotFound => 'Event not found';

  @override
  String get clientReservationNoSeatsAvailable => 'No seats available';

  @override
  String get clientReservationStage => 'STAGE';

  @override
  String get clientReservationSelectBlock =>
      'Select a block to see available seats';

  @override
  String get clientReservationNoSeatsInBlock =>
      'No seats available in this block';

  @override
  String get clientReservationBlockView => 'View from block';

  @override
  String get clientReservationNoStandingZones => 'No standing zones available';

  @override
  String get clientReservationStandingZones => 'Standing zones';

  @override
  String get clientReservationUnlimitedSeats => 'Unlimited seats';

  @override
  String get clientReservationSelectedSeats => 'SELECTED SEATS';

  @override
  String get clientReservationConfirmSelection => 'Confirm selection';

  @override
  String get clientReservationSelectInBlock => 'Select your seats in the block';

  @override
  String get clientReservationPlaces => 'seats';

  @override
  String get clientReservationRemainingSeats => 'seat(s) remaining out of';

  @override
  String get clientReservationTickets => 'ticket(s)';

  @override
  String get clientReservationEstimatedTotal => 'ESTIMATED TOTAL';

  @override
  String get clientPaymentProcessing => 'Processing payment...';

  @override
  String get clientPaymentPaymentMethod => 'Payment method';

  @override
  String get clientPaymentSummary => 'Summary';

  @override
  String get clientPaymentVenue => 'VENUE';

  @override
  String get clientPaymentEvent => 'Event';

  @override
  String get clientPaymentPrice => 'PRICE';

  @override
  String get clientPaymentRow => 'ROW';

  @override
  String get clientPaymentSeat => 'SEAT';

  @override
  String get clientPaymentTickets => 'TICKETS';

  @override
  String get clientPaymentOrderVerified => 'Order verified';

  @override
  String get clientPaymentCard => 'Bank Card';

  @override
  String get clientPaymentCardSubtitle => 'Visa, Mastercard, AMEX';

  @override
  String get clientPaymentMvolaSubtitle => 'MVola mobile payment';

  @override
  String get clientPaymentOrangeSubtitle => 'Orange mobile payment';

  @override
  String get clientPaymentAirtelSubtitle => 'Airtel mobile payment';

  @override
  String get clientPaymentTransactionRef => 'Transaction reference';

  @override
  String get clientPaymentPhoneNumber => 'Phone number';

  @override
  String get clientPaymentFullName => 'Full name';

  @override
  String get clientPaymentSecurityDisclaimer =>
      'Your payment data is end-to-end encrypted. We are PCI-DSS Level 1 certified.';

  @override
  String get clientPaymentErrorTransactionRef =>
      'Transaction reference is required';

  @override
  String get clientPaymentErrorPhoneNumber => 'Phone number is required';

  @override
  String get clientPaymentErrorCardInfo => 'Card information is required';

  @override
  String get clientPaymentErrorNotLoggedIn => 'User not logged in';

  @override
  String get clientPaymentSuccess => 'Booking successful!';

  @override
  String get clientPaymentErrorTimeout =>
      'Server not responding. Check your connection.';

  @override
  String get clientPaymentErrorSeatTaken =>
      'Seat already booked or unavailable. Please try again.';

  @override
  String get clientPaymentErrorInsufficientFunds =>
      'Insufficient funds for this transaction.';

  @override
  String get clientPaymentErrorPromoCode => 'Invalid or expired promo code.';

  @override
  String get clientPaymentSuccessReduction =>
      'Booking successful! Reduction of';

  @override
  String get clientPaymentPay => 'Pay';

  @override
  String get clientTicketTitle => 'Ticket';

  @override
  String get clientTicketNotFound => 'Ticket not found';

  @override
  String get clientTicketValid => 'VALID';

  @override
  String get clientTicketInvalid => 'INVALID';

  @override
  String get clientTicketDownloadPDF => 'Download PDF';

  @override
  String get clientTicketEvent => 'Event';

  @override
  String get clientTicketSeat => 'Seat';

  @override
  String get clientTicketRow => 'Row';

  @override
  String get clientTicketType => 'Type';

  @override
  String get clientTicketZone => 'Zone';

  @override
  String get clientTicketPrice => 'Price';

  @override
  String get clientTicketHolder => 'Holder';

  @override
  String get clientTicketNoTickets => 'No tickets';

  @override
  String get clientTicketAfterPurchase =>
      'Your tickets will appear here after purchase.';

  @override
  String get clientTicketMyTickets => 'My Tickets';

  @override
  String get clientTicketManageTickets => 'Manage your access and reservations';

  @override
  String get clientTicketRoom => 'Room';

  @override
  String get clientTicketPdfSaved => 'PDF saved to';

  @override
  String get clientTicketDownloadFailed => 'Download failed:';

  @override
  String get clientTicketReference => 'Reference';

  @override
  String get clientTicketExpired => 'EXPIRED';

  @override
  String get adminDashboard => 'Dashboard';

  @override
  String get adminUsers => 'Users';

  @override
  String get adminEvents => 'Events';

  @override
  String get adminCategories => 'Categories';

  @override
  String get adminVenues => 'Venues';

  @override
  String get adminPlaces => 'Seats';

  @override
  String get adminTickets => 'Tickets';

  @override
  String get adminReservations => 'Reservations';

  @override
  String get adminPayments => 'Payments';

  @override
  String get adminAccount => 'Account';

  @override
  String get adminLayoutTitle => 'Admin Panel';

  @override
  String get adminConfig => 'Configuration';

  @override
  String get adminMore => 'More';

  @override
  String get adminMoreOptions => 'More options';

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
  String get adminProfilePersonalInfo => 'Personal information';

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
  String get adminProfileAccount => 'Account';

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
  String get adminActionHistory => 'History';

  @override
  String get commonAdd => 'Add';

  @override
  String get clientHomeDateRange => 'Date Range';

  @override
  String get clientHomePriceRange => 'Price Range';

  @override
  String get clientHomeMin => 'Min';

  @override
  String get clientHomeMax => 'Max';

  @override
  String get clientHomeDetailTitle => 'Event Details';

  @override
  String get clientSavedEventsEmpty => 'No saved events';

  @override
  String get clientFavoriteAdded => 'Event added to favorites';

  @override
  String get clientFavoriteRemoved => 'Event removed from favorites';

  @override
  String get clientShareCopied => 'Details copied to clipboard';

  @override
  String get clientPaymentShareText => 'Current order on Ontik';

  @override
  String get clientPaymentOrderCopied => 'Order information copied';

  @override
  String get clientPaymentEventName => 'Event';

  @override
  String get clientHomeSubscribedSection => 'Followed Organizers';

  @override
  String get clientHomeSubscribe => 'Subscribe';

  @override
  String get clientHomeUnsubscribe => 'Unsubscribe';

  @override
  String get clientHomeNoSubscriptions =>
      'Follow organizers to see their events here';
}
