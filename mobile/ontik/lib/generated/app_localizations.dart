import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// No description provided for @tickets.
  ///
  /// In en, this message translates to:
  /// **'Tickets'**
  String get tickets;

  /// No description provided for @reservations.
  ///
  /// In en, this message translates to:
  /// **'Reservations'**
  String get reservations;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @layoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Ontik — Organizer'**
  String get layoutTitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @eventsActive.
  ///
  /// In en, this message translates to:
  /// **'{count} active events'**
  String eventsActive(Object count);

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @fillRate.
  ///
  /// In en, this message translates to:
  /// **'Fill rate'**
  String get fillRate;

  /// No description provided for @ticketsSold.
  ///
  /// In en, this message translates to:
  /// **'Tickets sold'**
  String get ticketsSold;

  /// No description provided for @seatsAvailable.
  ///
  /// In en, this message translates to:
  /// **'Seats avail.'**
  String get seatsAvailable;

  /// No description provided for @myEvents.
  ///
  /// In en, this message translates to:
  /// **'My events'**
  String get myEvents;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @salesEvolution.
  ///
  /// In en, this message translates to:
  /// **'Sales evolution'**
  String get salesEvolution;

  /// No description provided for @topEvents.
  ///
  /// In en, this message translates to:
  /// **'Top events'**
  String get topEvents;

  /// No description provided for @suspendEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Suspend event'**
  String get suspendEventTitle;

  /// No description provided for @suspendConfirm.
  ///
  /// In en, this message translates to:
  /// **'Suspend \"{event}\"? Existing reservations will be kept.'**
  String suspendConfirm(Object event);

  /// No description provided for @suspend.
  ///
  /// In en, this message translates to:
  /// **'Suspend'**
  String get suspend;

  /// No description provided for @eventSuspended.
  ///
  /// In en, this message translates to:
  /// **'Event suspended'**
  String get eventSuspended;

  /// No description provided for @eventResumed.
  ///
  /// In en, this message translates to:
  /// **'Event reactivated'**
  String get eventResumed;

  /// No description provided for @cancelEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel event'**
  String get cancelEventTitle;

  /// No description provided for @cancelConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel \"{event}\"?'**
  String cancelConfirm(Object event);

  /// No description provided for @cancelNotify.
  ///
  /// In en, this message translates to:
  /// **'Booked customers will be notified.'**
  String get cancelNotify;

  /// No description provided for @cancelReason.
  ///
  /// In en, this message translates to:
  /// **'Cancellation reason'**
  String get cancelReason;

  /// No description provided for @cancelEvent.
  ///
  /// In en, this message translates to:
  /// **'Cancel event'**
  String get cancelEvent;

  /// No description provided for @eventCancelled.
  ///
  /// In en, this message translates to:
  /// **'Event cancelled'**
  String get eventCancelled;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @reactivate.
  ///
  /// In en, this message translates to:
  /// **'Reactivate'**
  String get reactivate;

  /// No description provided for @noEvents.
  ///
  /// In en, this message translates to:
  /// **'No events'**
  String get noEvents;

  /// No description provided for @createEvent.
  ///
  /// In en, this message translates to:
  /// **'Create Event'**
  String get createEvent;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @countdownLabel.
  ///
  /// In en, this message translates to:
  /// **'Countdown'**
  String get countdownLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Venue'**
  String get locationLabel;

  /// No description provided for @organizerLabel.
  ///
  /// In en, this message translates to:
  /// **'Organizer'**
  String get organizerLabel;

  /// No description provided for @featuresLabel.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get featuresLabel;

  /// No description provided for @feature.
  ///
  /// In en, this message translates to:
  /// **'Feature'**
  String get feature;

  /// No description provided for @endedMin.
  ///
  /// In en, this message translates to:
  /// **'Ended {count} min ago'**
  String endedMin(Object count);

  /// No description provided for @endedH.
  ///
  /// In en, this message translates to:
  /// **'Ended {count}h ago'**
  String endedH(Object count);

  /// No description provided for @endedD.
  ///
  /// In en, this message translates to:
  /// **'Ended {count}d ago'**
  String endedD(Object count);

  /// No description provided for @endedMonths.
  ///
  /// In en, this message translates to:
  /// **'Ended {count} months ago'**
  String endedMonths(Object count);

  /// No description provided for @endedYears.
  ///
  /// In en, this message translates to:
  /// **'Ended {count} year(s) ago'**
  String endedYears(Object count);

  /// No description provided for @startsMin.
  ///
  /// In en, this message translates to:
  /// **'Starts in {count} min'**
  String startsMin(Object count);

  /// No description provided for @startsH.
  ///
  /// In en, this message translates to:
  /// **'Starts in {count}h'**
  String startsH(Object count);

  /// No description provided for @startsD.
  ///
  /// In en, this message translates to:
  /// **'Starts in {count}d'**
  String startsD(Object count);

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get personalInfo;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @saveChangesConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to save the changes?'**
  String get saveChangesConfirm;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total revenue'**
  String get totalRevenue;

  /// No description provided for @loadError.
  ///
  /// In en, this message translates to:
  /// **'Load error'**
  String get loadError;

  /// No description provided for @latestSales.
  ///
  /// In en, this message translates to:
  /// **'Latest sales'**
  String get latestSales;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to log out?'**
  String get logoutConfirm;

  /// No description provided for @orgCodeMissing.
  ///
  /// In en, this message translates to:
  /// **'Organizer code not found. Please reconnect.'**
  String get orgCodeMissing;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get last7Days;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get last30Days;

  /// No description provided for @searchClient.
  ///
  /// In en, this message translates to:
  /// **'Search client...'**
  String get searchClient;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @reservationCount.
  ///
  /// In en, this message translates to:
  /// **'{count} reservation(s)'**
  String reservationCount(Object count);

  /// No description provided for @noReservationsForEvent.
  ///
  /// In en, this message translates to:
  /// **'No reservations for this event'**
  String get noReservationsForEvent;

  /// No description provided for @selectEvent.
  ///
  /// In en, this message translates to:
  /// **'Select an event'**
  String get selectEvent;

  /// No description provided for @noReservations.
  ///
  /// In en, this message translates to:
  /// **'No reservations'**
  String get noReservations;

  /// No description provided for @ticketCount.
  ///
  /// In en, this message translates to:
  /// **'{count} ticket(s)'**
  String ticketCount(Object count);

  /// No description provided for @fullDetail.
  ///
  /// In en, this message translates to:
  /// **'Full detail'**
  String get fullDetail;

  /// No description provided for @viewEvent.
  ///
  /// In en, this message translates to:
  /// **'View event'**
  String get viewEvent;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @scanned.
  ///
  /// In en, this message translates to:
  /// **'Scanned'**
  String get scanned;

  /// No description provided for @pendingShort.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingShort;

  /// No description provided for @pricingTitle.
  ///
  /// In en, this message translates to:
  /// **'Pricing — {title}'**
  String pricingTitle(Object title);

  /// No description provided for @roomLabel.
  ///
  /// In en, this message translates to:
  /// **'Room:'**
  String get roomLabel;

  /// No description provided for @priceByType.
  ///
  /// In en, this message translates to:
  /// **'Price by seat type'**
  String get priceByType;

  /// No description provided for @priceByTypeDesc.
  ///
  /// In en, this message translates to:
  /// **'Set the price for each seat type. All seats of this type will be updated.'**
  String get priceByTypeDesc;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @typeAssignment.
  ///
  /// In en, this message translates to:
  /// **'Type assignment'**
  String get typeAssignment;

  /// No description provided for @typeAssignmentDesc.
  ///
  /// In en, this message translates to:
  /// **'Select rows or seats and assign them a type.'**
  String get typeAssignmentDesc;

  /// No description provided for @typeToAssign.
  ///
  /// In en, this message translates to:
  /// **'Type to assign'**
  String get typeToAssign;

  /// No description provided for @newType.
  ///
  /// In en, this message translates to:
  /// **'+ New type...'**
  String get newType;

  /// No description provided for @assign.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get assign;

  /// No description provided for @selectionCount.
  ///
  /// In en, this message translates to:
  /// **'{rows} row(s) • {seats} seat(s) selected'**
  String selectionCount(Object rows, Object seats);

  /// No description provided for @noRows.
  ///
  /// In en, this message translates to:
  /// **'No rows available'**
  String get noRows;

  /// No description provided for @clickSeatToSelect.
  ///
  /// In en, this message translates to:
  /// **'Click a seat in the grid below to select it'**
  String get clickSeatToSelect;

  /// No description provided for @rowPricing.
  ///
  /// In en, this message translates to:
  /// **'Pricing by row'**
  String get rowPricing;

  /// No description provided for @rowPricingDesc.
  ///
  /// In en, this message translates to:
  /// **'Configure type and price for each row.'**
  String get rowPricingDesc;

  /// No description provided for @seatGrid.
  ///
  /// In en, this message translates to:
  /// **'Individual grid'**
  String get seatGrid;

  /// No description provided for @searchSeat.
  ///
  /// In en, this message translates to:
  /// **'Search seat...'**
  String get searchSeat;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @seatCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{total} seats • {configured} configured'**
  String seatCountLabel(Object configured, Object total);

  /// No description provided for @configured.
  ///
  /// In en, this message translates to:
  /// **'configured'**
  String get configured;

  /// No description provided for @priceWithCurrency.
  ///
  /// In en, this message translates to:
  /// **'Price ({currency})'**
  String priceWithCurrency(Object currency);

  /// No description provided for @newTypeName.
  ///
  /// In en, this message translates to:
  /// **'New type'**
  String get newTypeName;

  /// No description provided for @confirmRefund.
  ///
  /// In en, this message translates to:
  /// **'Confirm refund'**
  String get confirmRefund;

  /// No description provided for @refundsTitle.
  ///
  /// In en, this message translates to:
  /// **'Refunds and cancellations'**
  String get refundsTitle;

  /// No description provided for @cancelledBadge.
  ///
  /// In en, this message translates to:
  /// **'CANCELLED'**
  String get cancelledBadge;

  /// No description provided for @refundAction.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get refundAction;

  /// No description provided for @dataExport.
  ///
  /// In en, this message translates to:
  /// **'Data export'**
  String get dataExport;

  /// No description provided for @selectEventExport.
  ///
  /// In en, this message translates to:
  /// **'Select an event to export data'**
  String get selectEventExport;

  /// No description provided for @ticketsCsv.
  ///
  /// In en, this message translates to:
  /// **'Tickets CSV'**
  String get ticketsCsv;

  /// No description provided for @reservationsCsv.
  ///
  /// In en, this message translates to:
  /// **'Reserv. CSV'**
  String get reservationsCsv;

  /// No description provided for @scanTicket.
  ///
  /// In en, this message translates to:
  /// **'Scan a ticket'**
  String get scanTicket;

  /// No description provided for @scanNext.
  ///
  /// In en, this message translates to:
  /// **'Scan next'**
  String get scanNext;

  /// No description provided for @alignQr.
  ///
  /// In en, this message translates to:
  /// **'Align the QR code within the frame'**
  String get alignQr;

  /// No description provided for @ticketValid.
  ///
  /// In en, this message translates to:
  /// **'Valid ticket'**
  String get ticketValid;

  /// No description provided for @ticketInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid ticket'**
  String get ticketInvalid;

  /// No description provided for @stepInfos.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get stepInfos;

  /// No description provided for @stepDateTime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get stepDateTime;

  /// No description provided for @stepLocation.
  ///
  /// In en, this message translates to:
  /// **'Venue & Seats'**
  String get stepLocation;

  /// No description provided for @stepSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get stepSummary;

  /// No description provided for @editEvent.
  ///
  /// In en, this message translates to:
  /// **'Edit event'**
  String get editEvent;

  /// No description provided for @cancelEdit.
  ///
  /// In en, this message translates to:
  /// **'Cancel changes?'**
  String get cancelEdit;

  /// No description provided for @cancelCreate.
  ///
  /// In en, this message translates to:
  /// **'Cancel creation?'**
  String get cancelCreate;

  /// No description provided for @unsavedChanges.
  ///
  /// In en, this message translates to:
  /// **'Unsaved changes will be lost.'**
  String get unsavedChanges;

  /// No description provided for @eventUpdated.
  ///
  /// In en, this message translates to:
  /// **'Event updated'**
  String get eventUpdated;

  /// No description provided for @eventCreated.
  ///
  /// In en, this message translates to:
  /// **'Event created'**
  String get eventCreated;

  /// No description provided for @publishEvent.
  ///
  /// In en, this message translates to:
  /// **'Publish event'**
  String get publishEvent;

  /// No description provided for @statusSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get statusSuspended;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get statusUpcoming;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get statusInProgress;

  /// No description provided for @statusEnded.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get statusEnded;

  /// No description provided for @eventLabel.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get eventLabel;

  /// No description provided for @periodToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get periodToday;

  /// No description provided for @period7days.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get period7days;

  /// No description provided for @period30days.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get period30days;

  /// No description provided for @searchClientHint.
  ///
  /// In en, this message translates to:
  /// **'Search client...'**
  String get searchClientHint;

  /// No description provided for @statusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statusPaid;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusCancelledShort.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelledShort;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @unknownClient.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownClient;

  /// No description provided for @ticketsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} ticket(s)'**
  String ticketsCount(Object count);

  /// No description provided for @seatPlace.
  ///
  /// In en, this message translates to:
  /// **'Seat {seat}'**
  String seatPlace(Object seat);

  /// No description provided for @fullDetailButton.
  ///
  /// In en, this message translates to:
  /// **'Full detail'**
  String get fullDetailButton;

  /// No description provided for @viewEventButton.
  ///
  /// In en, this message translates to:
  /// **'View event'**
  String get viewEventButton;

  /// No description provided for @reservationHeader.
  ///
  /// In en, this message translates to:
  /// **'Reservation #{id}'**
  String reservationHeader(Object id);

  /// No description provided for @clientSection.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get clientSection;

  /// No description provided for @nameField.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameField;

  /// No description provided for @codeField.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get codeField;

  /// No description provided for @emailField.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailField;

  /// No description provided for @phoneField.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneField;

  /// No description provided for @paymentSection.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentSection;

  /// No description provided for @amountField.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountField;

  /// No description provided for @modeField.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get modeField;

  /// No description provided for @paymentDateField.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get paymentDateField;

  /// No description provided for @statusField.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusField;

  /// No description provided for @ticketsSection.
  ///
  /// In en, this message translates to:
  /// **'Tickets'**
  String get ticketsSection;

  /// No description provided for @noTicketsText.
  ///
  /// In en, this message translates to:
  /// **'No tickets'**
  String get noTicketsText;

  /// No description provided for @seatPlaceDetail.
  ///
  /// In en, this message translates to:
  /// **'Seat {seat}'**
  String seatPlaceDetail(Object seat);

  /// No description provided for @rowDetail.
  ///
  /// In en, this message translates to:
  /// **'Row {row}'**
  String rowDetail(Object row);

  /// No description provided for @orgCodeMissingReconnect.
  ///
  /// In en, this message translates to:
  /// **'Organizer code not found. Please reconnect.'**
  String get orgCodeMissingReconnect;

  /// No description provided for @paidStatus.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paidStatus;

  /// No description provided for @pendingStatus.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingStatus;

  /// No description provided for @availableStatus.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get availableStatus;

  /// No description provided for @scannedStatus.
  ///
  /// In en, this message translates to:
  /// **'Scanned'**
  String get scannedStatus;

  /// No description provided for @unknownStatus.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownStatus;

  /// No description provided for @eventDropdown.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get eventDropdown;

  /// No description provided for @allFilter.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allFilter;

  /// No description provided for @paidFilter.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paidFilter;

  /// No description provided for @pendingFilter.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingFilter;

  /// No description provided for @pricingAppliedRow.
  ///
  /// In en, this message translates to:
  /// **'Pricing applied to row {row}'**
  String pricingAppliedRow(Object row);

  /// No description provided for @pricingAppliedType.
  ///
  /// In en, this message translates to:
  /// **'Price applied to type {type}'**
  String pricingAppliedType(Object type);

  /// No description provided for @selectMinRowOrSeat.
  ///
  /// In en, this message translates to:
  /// **'Select at least one row or seat'**
  String get selectMinRowOrSeat;

  /// No description provided for @typeAssignedMsg.
  ///
  /// In en, this message translates to:
  /// **'Type {type} assigned'**
  String typeAssignedMsg(Object type);

  /// No description provided for @seatUpdatedMsg.
  ///
  /// In en, this message translates to:
  /// **'Seat {seat} updated'**
  String seatUpdatedMsg(Object seat);

  /// No description provided for @pricingHeader.
  ///
  /// In en, this message translates to:
  /// **'Pricing — {title}'**
  String pricingHeader(Object title);

  /// No description provided for @roomSelector.
  ///
  /// In en, this message translates to:
  /// **'Room:'**
  String get roomSelector;

  /// No description provided for @priceByTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Price by seat type'**
  String get priceByTypeTitle;

  /// No description provided for @priceField.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceField;

  /// No description provided for @applyButton.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyButton;

  /// No description provided for @typeAssignmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Type assignment'**
  String get typeAssignmentTitle;

  /// No description provided for @newTypeOption.
  ///
  /// In en, this message translates to:
  /// **'+ New type...'**
  String get newTypeOption;

  /// No description provided for @namePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get namePlaceholder;

  /// No description provided for @assignButton.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get assignButton;

  /// No description provided for @noRowsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No rows available'**
  String get noRowsAvailable;

  /// No description provided for @rowPricingTitle.
  ///
  /// In en, this message translates to:
  /// **'Pricing by row'**
  String get rowPricingTitle;

  /// No description provided for @seatGridTitle.
  ///
  /// In en, this message translates to:
  /// **'Individual grid'**
  String get seatGridTitle;

  /// No description provided for @searchSeatHint.
  ///
  /// In en, this message translates to:
  /// **'Search seat...'**
  String get searchSeatHint;

  /// No description provided for @typeDropdown.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeDropdown;

  /// No description provided for @allOption.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allOption;

  /// No description provided for @seatCountConfigured.
  ///
  /// In en, this message translates to:
  /// **'{total} seats • {configured} configured'**
  String seatCountConfigured(Object configured, Object total);

  /// No description provided for @seatDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Seat {seat}'**
  String seatDialogTitle(Object seat);

  /// No description provided for @newTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'New type'**
  String get newTypeLabel;

  /// No description provided for @priceCurrency.
  ///
  /// In en, this message translates to:
  /// **'Price ({currency})'**
  String priceCurrency(Object currency);

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @rowTitle.
  ///
  /// In en, this message translates to:
  /// **'Row {row}  ({count} seats)'**
  String rowTitle(Object count, Object row);

  /// No description provided for @configuredBadge.
  ///
  /// In en, this message translates to:
  /// **'configured'**
  String get configuredBadge;

  /// No description provided for @typeField.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeField;

  /// No description provided for @confirmRefundTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm refund'**
  String get confirmRefundTitle;

  /// No description provided for @confirmRefundText.
  ///
  /// In en, this message translates to:
  /// **'Do you want to cancel and refund reservation #{id}?'**
  String confirmRefundText(Object id);

  /// No description provided for @cancelRefundButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelRefundButton;

  /// No description provided for @confirmRefundButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmRefundButton;

  /// No description provided for @refundResultMessage.
  ///
  /// In en, this message translates to:
  /// **'Reservation #{id} cancelled. Refund: {amount} {currency}'**
  String refundResultMessage(Object amount, Object currency, Object id);

  /// No description provided for @cancelledBadgeLabel.
  ///
  /// In en, this message translates to:
  /// **'CANCELLED'**
  String get cancelledBadgeLabel;

  /// No description provided for @refundActionButton.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get refundActionButton;

  /// No description provided for @exportTitle.
  ///
  /// In en, this message translates to:
  /// **'Data export'**
  String get exportTitle;

  /// No description provided for @exportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select an event to export data'**
  String get exportSubtitle;

  /// No description provided for @noEventsExport.
  ///
  /// In en, this message translates to:
  /// **'No events'**
  String get noEventsExport;

  /// No description provided for @exportTicketsCsv.
  ///
  /// In en, this message translates to:
  /// **'Tickets CSV'**
  String get exportTicketsCsv;

  /// No description provided for @exportReservationsCsv.
  ///
  /// In en, this message translates to:
  /// **'Reserv. CSV'**
  String get exportReservationsCsv;

  /// No description provided for @exportAllButton.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get exportAllButton;

  /// No description provided for @exportSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'File saved: {filename}'**
  String exportSavedMessage(Object filename);

  /// No description provided for @exportErrorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String exportErrorPrefix(Object message);

  /// No description provided for @scanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan a ticket'**
  String get scanTitle;

  /// No description provided for @scanAlignQr.
  ///
  /// In en, this message translates to:
  /// **'Align the QR code within the frame'**
  String get scanAlignQr;

  /// No description provided for @scanValid.
  ///
  /// In en, this message translates to:
  /// **'Valid ticket'**
  String get scanValid;

  /// No description provided for @scanInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid ticket'**
  String get scanInvalid;

  /// No description provided for @scanCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Code: {code}'**
  String scanCodeLabel(Object code);

  /// No description provided for @scanEventLabel.
  ///
  /// In en, this message translates to:
  /// **'Event: {event}'**
  String scanEventLabel(Object event);

  /// No description provided for @scanPlaceLabel.
  ///
  /// In en, this message translates to:
  /// **'Seat: {place}'**
  String scanPlaceLabel(Object place);

  /// No description provided for @scanClientLabel.
  ///
  /// In en, this message translates to:
  /// **'Client: {client}'**
  String scanClientLabel(Object client);

  /// No description provided for @stepLocationSeats.
  ///
  /// In en, this message translates to:
  /// **'Venue & Seats'**
  String get stepLocationSeats;

  /// No description provided for @stepPricing.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get stepPricing;

  /// No description provided for @editEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit event'**
  String get editEventTitle;

  /// No description provided for @createEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Create event — Step {step}/5: {name}'**
  String createEventTitle(Object name, Object step);

  /// No description provided for @cancelEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel changes?'**
  String get cancelEditTitle;

  /// No description provided for @cancelCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel creation?'**
  String get cancelCreateTitle;

  /// No description provided for @unsavedWarning.
  ///
  /// In en, this message translates to:
  /// **'Unsaved changes will be lost.'**
  String get unsavedWarning;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @cancelButton2.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton2;

  /// No description provided for @backButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// No description provided for @nextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextButton;

  /// No description provided for @eventUpdatedMsg.
  ///
  /// In en, this message translates to:
  /// **'Event updated'**
  String get eventUpdatedMsg;

  /// No description provided for @eventCreatedMsg.
  ///
  /// In en, this message translates to:
  /// **'Event created'**
  String get eventCreatedMsg;

  /// No description provided for @publishButton.
  ///
  /// In en, this message translates to:
  /// **'Publish event'**
  String get publishButton;

  /// No description provided for @editButton.
  ///
  /// In en, this message translates to:
  /// **'Edit event'**
  String get editButton;

  /// No description provided for @generalInfo.
  ///
  /// In en, this message translates to:
  /// **'General information'**
  String get generalInfo;

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title *'**
  String get titleRequired;

  /// No description provided for @requiredMarker.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredMarker;

  /// No description provided for @addPoster.
  ///
  /// In en, this message translates to:
  /// **'Add poster'**
  String get addPoster;

  /// No description provided for @genreRequired.
  ///
  /// In en, this message translates to:
  /// **'Genre *'**
  String get genreRequired;

  /// No description provided for @placementType.
  ///
  /// In en, this message translates to:
  /// **'Placement type'**
  String get placementType;

  /// No description provided for @placementFree.
  ///
  /// In en, this message translates to:
  /// **'Free\nSeating'**
  String get placementFree;

  /// No description provided for @placementNumbered.
  ///
  /// In en, this message translates to:
  /// **'Numbered\nSeating'**
  String get placementNumbered;

  /// No description provided for @placementMixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed\nSeating'**
  String get placementMixed;

  /// No description provided for @featuresCategory.
  ///
  /// In en, this message translates to:
  /// **'Features {category}'**
  String featuresCategory(Object category);

  /// No description provided for @selectDatePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select a date'**
  String get selectDatePlaceholder;

  /// No description provided for @dateTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get dateTimeTitle;

  /// No description provided for @dateRequired.
  ///
  /// In en, this message translates to:
  /// **'Date *'**
  String get dateRequired;

  /// No description provided for @selectDateHint.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDateHint;

  /// No description provided for @numDaysRequired.
  ///
  /// In en, this message translates to:
  /// **'Number of days *'**
  String get numDaysRequired;

  /// No description provided for @dayUnit.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get dayUnit;

  /// No description provided for @daysUnit.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get daysUnit;

  /// No description provided for @startTimeRequired.
  ///
  /// In en, this message translates to:
  /// **'Start time *'**
  String get startTimeRequired;

  /// No description provided for @selectTimeHint.
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get selectTimeHint;

  /// No description provided for @durationHours.
  ///
  /// In en, this message translates to:
  /// **'Duration (hours)'**
  String get durationHours;

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'Duration (minutes)'**
  String get durationMinutes;

  /// No description provided for @totalDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Total duration: {duration}'**
  String totalDurationLabel(Object duration);

  /// No description provided for @dateRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'From {start} to {end} ({days} day(s))'**
  String dateRangeLabel(Object days, Object end, Object start);

  /// No description provided for @locationConfig.
  ///
  /// In en, this message translates to:
  /// **'Venue & Configuration'**
  String get locationConfig;

  /// No description provided for @venueDropdown.
  ///
  /// In en, this message translates to:
  /// **'Venue / Building'**
  String get venueDropdown;

  /// No description provided for @withoutRoom.
  ///
  /// In en, this message translates to:
  /// **'Without specific room'**
  String get withoutRoom;

  /// No description provided for @noRoomsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No rooms available'**
  String get noRoomsAvailable;

  /// No description provided for @capacityLabel.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get capacityLabel;

  /// No description provided for @unlimitedCapacity.
  ///
  /// In en, this message translates to:
  /// **'Unlimited people'**
  String get unlimitedCapacity;

  /// No description provided for @maxPeopleLabel.
  ///
  /// In en, this message translates to:
  /// **'Max people'**
  String get maxPeopleLabel;

  /// No description provided for @unlimitedHint.
  ///
  /// In en, this message translates to:
  /// **'Leave empty for unlimited'**
  String get unlimitedHint;

  /// No description provided for @seatTypesPricingLabel.
  ///
  /// In en, this message translates to:
  /// **'Seat types & prices'**
  String get seatTypesPricingLabel;

  /// No description provided for @pricePrefix.
  ///
  /// In en, this message translates to:
  /// **''**
  String get pricePrefix;

  /// No description provided for @addStandingZoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a standing zone'**
  String get addStandingZoneTitle;

  /// No description provided for @zoneNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Zone name'**
  String get zoneNameLabel;

  /// No description provided for @zoneNameHint.
  ///
  /// In en, this message translates to:
  /// **'Pit, Balcony...'**
  String get zoneNameHint;

  /// No description provided for @zoneCapacityLabel.
  ///
  /// In en, this message translates to:
  /// **'Max capacity'**
  String get zoneCapacityLabel;

  /// No description provided for @unlimitedToggle.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get unlimitedToggle;

  /// No description provided for @limitedToggle.
  ///
  /// In en, this message translates to:
  /// **'Limited'**
  String get limitedToggle;

  /// No description provided for @zonePriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit price'**
  String get zonePriceLabel;

  /// No description provided for @addZoneButton.
  ///
  /// In en, this message translates to:
  /// **'Add zone'**
  String get addZoneButton;

  /// No description provided for @capacityPlaces.
  ///
  /// In en, this message translates to:
  /// **'{capacity} seats'**
  String capacityPlaces(Object capacity);

  /// No description provided for @seatTypesLabel.
  ///
  /// In en, this message translates to:
  /// **'Seat types'**
  String get seatTypesLabel;

  /// No description provided for @seatTypesDesc.
  ///
  /// In en, this message translates to:
  /// **'Create seat categories (Standard, VIP, Pit, Balcony...)'**
  String get seatTypesDesc;

  /// No description provided for @newTypeHint.
  ///
  /// In en, this message translates to:
  /// **'New type...'**
  String get newTypeHint;

  /// No description provided for @roomRequiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Room *'**
  String get roomRequiredLabel;

  /// No description provided for @standingZonesLabel.
  ///
  /// In en, this message translates to:
  /// **'Standing zones'**
  String get standingZonesLabel;

  /// No description provided for @zoneCapacityInfo.
  ///
  /// In en, this message translates to:
  /// **'{capacity} people max'**
  String zoneCapacityInfo(Object capacity);

  /// No description provided for @zoneCapacityUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get zoneCapacityUnlimited;

  /// No description provided for @zonePricePrefix.
  ///
  /// In en, this message translates to:
  /// **'{price}'**
  String zonePricePrefix(Object price);

  /// No description provided for @pricingDesc.
  ///
  /// In en, this message translates to:
  /// **'Set the price for each seat type.'**
  String get pricingDesc;

  /// No description provided for @selectRoomFirstHint.
  ///
  /// In en, this message translates to:
  /// **'Please select a room in the previous step first.'**
  String get selectRoomFirstHint;

  /// No description provided for @seatPlanConfig.
  ///
  /// In en, this message translates to:
  /// **'Configure seating plan'**
  String get seatPlanConfig;

  /// No description provided for @individualSeats.
  ///
  /// In en, this message translates to:
  /// **'Individual seats'**
  String get individualSeats;

  /// No description provided for @seatsSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String seatsSelectedCount(Object count);

  /// No description provided for @assignTariff.
  ///
  /// In en, this message translates to:
  /// **'Assign a tariff type'**
  String get assignTariff;

  /// No description provided for @pendingAssignments.
  ///
  /// In en, this message translates to:
  /// **'Assignments ({count})'**
  String pendingAssignments(Object count);

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @rowAssignmentText.
  ///
  /// In en, this message translates to:
  /// **'Row {row} → {type}'**
  String rowAssignmentText(Object row, Object type);

  /// No description provided for @seatAssignmentText.
  ///
  /// In en, this message translates to:
  /// **'Seat {seat} → {type}'**
  String seatAssignmentText(Object seat, Object type);

  /// No description provided for @placesCountSuffix.
  ///
  /// In en, this message translates to:
  /// **'{count} seat(s)'**
  String placesCountSuffix(Object count);

  /// No description provided for @tariffTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Tariff type'**
  String get tariffTypeTitle;

  /// No description provided for @noTypesWithPrice.
  ///
  /// In en, this message translates to:
  /// **'No seat types with a defined price.'**
  String get noTypesWithPrice;

  /// No description provided for @applyTariff.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyTariff;

  /// No description provided for @summaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summaryTitle;

  /// No description provided for @dateTimeSection.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get dateTimeSection;

  /// No description provided for @untilDate.
  ///
  /// In en, this message translates to:
  /// **'Until {date} ({days} days)'**
  String untilDate(Object date, Object days);

  /// No description provided for @timeDisplay.
  ///
  /// In en, this message translates to:
  /// **'{time}'**
  String timeDisplay(Object time);

  /// No description provided for @durationDisplay.
  ///
  /// In en, this message translates to:
  /// **'Duration: {duration}'**
  String durationDisplay(Object duration);

  /// No description provided for @locationSection.
  ///
  /// In en, this message translates to:
  /// **'Venue'**
  String get locationSection;

  /// No description provided for @capacityDisplay.
  ///
  /// In en, this message translates to:
  /// **'Capacity: {capacity} people'**
  String capacityDisplay(Object capacity);

  /// No description provided for @placementPricingSection.
  ///
  /// In en, this message translates to:
  /// **'Placement & Pricing'**
  String get placementPricingSection;

  /// No description provided for @placementFreeDisplay.
  ///
  /// In en, this message translates to:
  /// **'Free seating'**
  String get placementFreeDisplay;

  /// No description provided for @placementMixedDisplay.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get placementMixedDisplay;

  /// No description provided for @placementNumberedDisplay.
  ///
  /// In en, this message translates to:
  /// **'Numbered'**
  String get placementNumberedDisplay;

  /// No description provided for @typesDisplay.
  ///
  /// In en, this message translates to:
  /// **'{types}'**
  String typesDisplay(Object types);

  /// No description provided for @standingZonesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} standing zone(s)'**
  String standingZonesCount(Object count);

  /// No description provided for @priceDisplay.
  ///
  /// In en, this message translates to:
  /// **'{type}: {price}'**
  String priceDisplay(Object price, Object type);

  /// No description provided for @featuresSection.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get featuresSection;

  /// No description provided for @featureDisplay.
  ///
  /// In en, this message translates to:
  /// **'{name}: {value}'**
  String featureDisplay(Object name, Object value);

  /// No description provided for @rowPrefix.
  ///
  /// In en, this message translates to:
  /// **'Row'**
  String get rowPrefix;

  /// No description provided for @noRowLabel.
  ///
  /// In en, this message translates to:
  /// **'No rows'**
  String get noRowLabel;

  /// No description provided for @reservationCountPlain.
  ///
  /// In en, this message translates to:
  /// **'{count} reservation(s)'**
  String reservationCountPlain(Object count);

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get commonLogout;

  /// No description provided for @commonAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get commonAll;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsPreferences;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageFr.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get settingsLanguageFr;

  /// No description provided for @settingsLanguageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEn;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSecurity;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsPassword2fa.
  ///
  /// In en, this message translates to:
  /// **'Password & 2FA'**
  String get settingsPassword2fa;

  /// No description provided for @settingsSecured.
  ///
  /// In en, this message translates to:
  /// **'Secured'**
  String get settingsSecured;

  /// No description provided for @settingsConnectedDevices.
  ///
  /// In en, this message translates to:
  /// **'Connected devices'**
  String get settingsConnectedDevices;

  /// No description provided for @settingsCurrentDevice.
  ///
  /// In en, this message translates to:
  /// **'Current device'**
  String get settingsCurrentDevice;

  /// No description provided for @settingsActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get settingsActive;

  /// No description provided for @settingsOthersDisconnected.
  ///
  /// In en, this message translates to:
  /// **'All other devices have been disconnected'**
  String get settingsOthersDisconnected;

  /// No description provided for @settingsDisconnectOthers.
  ///
  /// In en, this message translates to:
  /// **'Disconnect other devices'**
  String get settingsDisconnectOthers;

  /// No description provided for @settingsLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to log out?'**
  String get settingsLogoutConfirm;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsIrreversible.
  ///
  /// In en, this message translates to:
  /// **'This action is irreversible'**
  String get settingsIrreversible;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get accountDeleted;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @settingsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete your account? This action is irreversible.'**
  String get settingsDeleteConfirm;

  /// No description provided for @settingsNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Feature not yet implemented'**
  String get settingsNotImplemented;

  /// No description provided for @settingsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get settingsConfirm;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsAppVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get settingsAppVersion;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Ontik'**
  String get appTitle;

  /// No description provided for @appLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get appLoading;

  /// No description provided for @splashTitle.
  ///
  /// In en, this message translates to:
  /// **'Ontik'**
  String get splashTitle;

  /// No description provided for @authLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authLoginTitle;

  /// No description provided for @authLoginEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authLoginEmail;

  /// No description provided for @authLoginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authLoginPassword;

  /// No description provided for @authLoginSubmit.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authLoginSubmit;

  /// No description provided for @authLoginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authLoginForgotPassword;

  /// No description provided for @authLoginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get authLoginNoAccount;

  /// No description provided for @authLoginRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authLoginRegister;

  /// No description provided for @authLoginWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authLoginWelcome;

  /// No description provided for @authRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegisterTitle;

  /// No description provided for @authRegisterSubmit.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authRegisterSubmit;

  /// No description provided for @authRegisterHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authRegisterHaveAccount;

  /// No description provided for @authRegisterLogin.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authRegisterLogin;

  /// No description provided for @authForgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get authForgotPasswordTitle;

  /// No description provided for @authRegisterSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful. Please log in.'**
  String get authRegisterSuccess;

  /// No description provided for @clientHome.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get clientHome;

  /// No description provided for @clientTickets.
  ///
  /// In en, this message translates to:
  /// **'My Tickets'**
  String get clientTickets;

  /// No description provided for @clientAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get clientAccount;

  /// No description provided for @clientProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get clientProfileTitle;

  /// No description provided for @clientLayoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Ontik'**
  String get clientLayoutTitle;

  /// No description provided for @clientHomeFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get clientHomeFilters;

  /// No description provided for @clientHomeReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get clientHomeReset;

  /// No description provided for @clientHomeStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get clientHomeStatus;

  /// No description provided for @clientHomeVenue.
  ///
  /// In en, this message translates to:
  /// **'Venue'**
  String get clientHomeVenue;

  /// No description provided for @clientHomeAllVenues.
  ///
  /// In en, this message translates to:
  /// **'All venues'**
  String get clientHomeAllVenues;

  /// No description provided for @clientHomeSelectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Select a range'**
  String get clientHomeSelectDateRange;

  /// No description provided for @clientHomeApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get clientHomeApply;

  /// No description provided for @clientHomeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search events...'**
  String get clientHomeSearchHint;

  /// No description provided for @clientHomeFeatured.
  ///
  /// In en, this message translates to:
  /// **'Featured events'**
  String get clientHomeFeatured;

  /// No description provided for @clientHomeNoEvents.
  ///
  /// In en, this message translates to:
  /// **'No events found'**
  String get clientHomeNoEvents;

  /// No description provided for @clientHomeVenueNotSpecified.
  ///
  /// In en, this message translates to:
  /// **'Venue not specified'**
  String get clientHomeVenueNotSpecified;

  /// No description provided for @clientHomePriceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Price unavailable'**
  String get clientHomePriceUnavailable;

  /// No description provided for @clientHomeStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get clientHomeStandard;

  /// No description provided for @clientHomePromoTitle.
  ///
  /// In en, this message translates to:
  /// **'-20% on your first ticket'**
  String get clientHomePromoTitle;

  /// No description provided for @clientHomePromoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use code SECURE20 at checkout.'**
  String get clientHomePromoSubtitle;

  /// No description provided for @clientHomeRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get clientHomeRetry;

  /// No description provided for @clientHomeDetailShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get clientHomeDetailShare;

  /// No description provided for @clientHomeDetailRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get clientHomeDetailRetry;

  /// No description provided for @clientHomeDetailEventNotFound.
  ///
  /// In en, this message translates to:
  /// **'Event not found'**
  String get clientHomeDetailEventNotFound;

  /// No description provided for @clientHomeDetailEvent.
  ///
  /// In en, this message translates to:
  /// **'EVENT'**
  String get clientHomeDetailEvent;

  /// No description provided for @clientHomeDetailDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get clientHomeDetailDate;

  /// No description provided for @clientHomeDetailTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get clientHomeDetailTime;

  /// No description provided for @clientHomeDetailVenueNotSpecified.
  ///
  /// In en, this message translates to:
  /// **'Venue not specified'**
  String get clientHomeDetailVenueNotSpecified;

  /// No description provided for @clientHomeDetailAbout.
  ///
  /// In en, this message translates to:
  /// **'About the event'**
  String get clientHomeDetailAbout;

  /// No description provided for @clientHomeDetailNoDescription.
  ///
  /// In en, this message translates to:
  /// **'No description available.'**
  String get clientHomeDetailNoDescription;

  /// No description provided for @clientHomeDetailCharacteristic.
  ///
  /// In en, this message translates to:
  /// **'Characteristic'**
  String get clientHomeDetailCharacteristic;

  /// No description provided for @clientHomeDetailAvailableZones.
  ///
  /// In en, this message translates to:
  /// **'Available zones'**
  String get clientHomeDetailAvailableZones;

  /// No description provided for @clientHomeDetailUnlimitedSeats.
  ///
  /// In en, this message translates to:
  /// **'Unlimited seats'**
  String get clientHomeDetailUnlimitedSeats;

  /// No description provided for @clientHomeDetailPlacesAvailable.
  ///
  /// In en, this message translates to:
  /// **'seats available'**
  String get clientHomeDetailPlacesAvailable;

  /// No description provided for @clientHomeDetailPriceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Price unavailable'**
  String get clientHomeDetailPriceUnavailable;

  /// No description provided for @clientHomeDetailFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get clientHomeDetailFrom;

  /// No description provided for @clientHomeDetailBook.
  ///
  /// In en, this message translates to:
  /// **'BOOK MY SEAT'**
  String get clientHomeDetailBook;

  /// No description provided for @clientProfileMyReservations.
  ///
  /// In en, this message translates to:
  /// **'My Reservations'**
  String get clientProfileMyReservations;

  /// No description provided for @clientProfileReservationsTab.
  ///
  /// In en, this message translates to:
  /// **'Reservations'**
  String get clientProfileReservationsTab;

  /// No description provided for @clientProfileTicketsTab.
  ///
  /// In en, this message translates to:
  /// **'Tickets'**
  String get clientProfileTicketsTab;

  /// No description provided for @clientProfileReferenceCodes.
  ///
  /// In en, this message translates to:
  /// **'Reference codes'**
  String get clientProfileReferenceCodes;

  /// No description provided for @clientProfileNoReservations.
  ///
  /// In en, this message translates to:
  /// **'No reservations'**
  String get clientProfileNoReservations;

  /// No description provided for @clientProfileReservationsWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Your reservations will appear here.'**
  String get clientProfileReservationsWillAppear;

  /// No description provided for @clientProfileUnknownDate.
  ///
  /// In en, this message translates to:
  /// **'Unknown date'**
  String get clientProfileUnknownDate;

  /// No description provided for @clientProfileReservationReference.
  ///
  /// In en, this message translates to:
  /// **'Reservation reference'**
  String get clientProfileReservationReference;

  /// No description provided for @clientProfileNoTickets.
  ///
  /// In en, this message translates to:
  /// **'No tickets'**
  String get clientProfileNoTickets;

  /// No description provided for @clientProfileTicketsWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Your tickets will appear here after booking.'**
  String get clientProfileTicketsWillAppear;

  /// No description provided for @clientProfileEvent.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get clientProfileEvent;

  /// No description provided for @clientProfileRoom.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get clientProfileRoom;

  /// No description provided for @clientProfileRow.
  ///
  /// In en, this message translates to:
  /// **'Row'**
  String get clientProfileRow;

  /// No description provided for @clientProfileSeat.
  ///
  /// In en, this message translates to:
  /// **'Seat'**
  String get clientProfileSeat;

  /// No description provided for @clientProfileReference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get clientProfileReference;

  /// No description provided for @clientProfileExpired.
  ///
  /// In en, this message translates to:
  /// **'EXPIRED'**
  String get clientProfileExpired;

  /// No description provided for @clientProfileReservation.
  ///
  /// In en, this message translates to:
  /// **'Reservation'**
  String get clientProfileReservation;

  /// No description provided for @clientProfileTicketsCount.
  ///
  /// In en, this message translates to:
  /// **'ticket(s)'**
  String get clientProfileTicketsCount;

  /// No description provided for @clientProfilePersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get clientProfilePersonalInfo;

  /// No description provided for @clientProfileLastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get clientProfileLastName;

  /// No description provided for @clientProfileFirstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get clientProfileFirstName;

  /// No description provided for @clientProfilePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get clientProfilePhone;

  /// No description provided for @clientProfileConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get clientProfileConfirm;

  /// No description provided for @clientProfileConfirmSave.
  ///
  /// In en, this message translates to:
  /// **'Do you want to save the changes?'**
  String get clientProfileConfirmSave;

  /// No description provided for @clientProfileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Information updated'**
  String get clientProfileUpdated;

  /// No description provided for @clientProfilePaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment methods'**
  String get clientProfilePaymentMethods;

  /// No description provided for @clientProfilePaymentHistoryComing.
  ///
  /// In en, this message translates to:
  /// **'Payment history — coming soon.'**
  String get clientProfilePaymentHistoryComing;

  /// No description provided for @clientProfileClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get clientProfileClose;

  /// No description provided for @clientProfileConfirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to log out?'**
  String get clientProfileConfirmLogout;

  /// No description provided for @clientProfileUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get clientProfileUser;

  /// No description provided for @clientProfileFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get clientProfileFavorites;

  /// No description provided for @clientProfileAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get clientProfileAlerts;

  /// No description provided for @clientProfileAccountGroup.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get clientProfileAccountGroup;

  /// No description provided for @clientProfileSecurityGroup.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get clientProfileSecurityGroup;

  /// No description provided for @clientProfilePassword2FA.
  ///
  /// In en, this message translates to:
  /// **'Password & 2FA'**
  String get clientProfilePassword2FA;

  /// No description provided for @clientProfileSecure.
  ///
  /// In en, this message translates to:
  /// **'Secured'**
  String get clientProfileSecure;

  /// No description provided for @clientProfileConnectedDevices.
  ///
  /// In en, this message translates to:
  /// **'Connected devices'**
  String get clientProfileConnectedDevices;

  /// No description provided for @clientReservationShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get clientReservationShare;

  /// No description provided for @clientReservationEventNotFound.
  ///
  /// In en, this message translates to:
  /// **'Event not found'**
  String get clientReservationEventNotFound;

  /// No description provided for @clientReservationNoSeatsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No seats available'**
  String get clientReservationNoSeatsAvailable;

  /// No description provided for @clientReservationStage.
  ///
  /// In en, this message translates to:
  /// **'STAGE'**
  String get clientReservationStage;

  /// No description provided for @clientReservationSelectBlock.
  ///
  /// In en, this message translates to:
  /// **'Select a block to see available seats'**
  String get clientReservationSelectBlock;

  /// No description provided for @clientReservationNoSeatsInBlock.
  ///
  /// In en, this message translates to:
  /// **'No seats available in this block'**
  String get clientReservationNoSeatsInBlock;

  /// No description provided for @clientReservationBlockView.
  ///
  /// In en, this message translates to:
  /// **'View from block'**
  String get clientReservationBlockView;

  /// No description provided for @clientReservationNoStandingZones.
  ///
  /// In en, this message translates to:
  /// **'No standing zones available'**
  String get clientReservationNoStandingZones;

  /// No description provided for @clientReservationStandingZones.
  ///
  /// In en, this message translates to:
  /// **'Standing zones'**
  String get clientReservationStandingZones;

  /// No description provided for @clientReservationUnlimitedSeats.
  ///
  /// In en, this message translates to:
  /// **'Unlimited seats'**
  String get clientReservationUnlimitedSeats;

  /// No description provided for @clientReservationSelectedSeats.
  ///
  /// In en, this message translates to:
  /// **'SELECTED SEATS'**
  String get clientReservationSelectedSeats;

  /// No description provided for @clientReservationConfirmSelection.
  ///
  /// In en, this message translates to:
  /// **'Confirm selection'**
  String get clientReservationConfirmSelection;

  /// No description provided for @clientReservationSelectInBlock.
  ///
  /// In en, this message translates to:
  /// **'Select your seats in the block'**
  String get clientReservationSelectInBlock;

  /// No description provided for @clientReservationPlaces.
  ///
  /// In en, this message translates to:
  /// **'seats'**
  String get clientReservationPlaces;

  /// No description provided for @clientReservationRemainingSeats.
  ///
  /// In en, this message translates to:
  /// **'seat(s) remaining out of'**
  String get clientReservationRemainingSeats;

  /// No description provided for @clientReservationTickets.
  ///
  /// In en, this message translates to:
  /// **'ticket(s)'**
  String get clientReservationTickets;

  /// No description provided for @clientReservationEstimatedTotal.
  ///
  /// In en, this message translates to:
  /// **'ESTIMATED TOTAL'**
  String get clientReservationEstimatedTotal;

  /// No description provided for @clientPaymentProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing payment...'**
  String get clientPaymentProcessing;

  /// No description provided for @clientPaymentPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get clientPaymentPaymentMethod;

  /// No description provided for @clientPaymentSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get clientPaymentSummary;

  /// No description provided for @clientPaymentVenue.
  ///
  /// In en, this message translates to:
  /// **'VENUE'**
  String get clientPaymentVenue;

  /// No description provided for @clientPaymentEvent.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get clientPaymentEvent;

  /// No description provided for @clientPaymentPrice.
  ///
  /// In en, this message translates to:
  /// **'PRICE'**
  String get clientPaymentPrice;

  /// No description provided for @clientPaymentRow.
  ///
  /// In en, this message translates to:
  /// **'ROW'**
  String get clientPaymentRow;

  /// No description provided for @clientPaymentSeat.
  ///
  /// In en, this message translates to:
  /// **'SEAT'**
  String get clientPaymentSeat;

  /// No description provided for @clientPaymentTickets.
  ///
  /// In en, this message translates to:
  /// **'TICKETS'**
  String get clientPaymentTickets;

  /// No description provided for @clientPaymentOrderVerified.
  ///
  /// In en, this message translates to:
  /// **'Order verified'**
  String get clientPaymentOrderVerified;

  /// No description provided for @clientPaymentCard.
  ///
  /// In en, this message translates to:
  /// **'Bank Card'**
  String get clientPaymentCard;

  /// No description provided for @clientPaymentCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Visa, Mastercard, AMEX'**
  String get clientPaymentCardSubtitle;

  /// No description provided for @clientPaymentMvolaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'MVola mobile payment'**
  String get clientPaymentMvolaSubtitle;

  /// No description provided for @clientPaymentOrangeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Orange mobile payment'**
  String get clientPaymentOrangeSubtitle;

  /// No description provided for @clientPaymentAirtelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Airtel mobile payment'**
  String get clientPaymentAirtelSubtitle;

  /// No description provided for @clientPaymentTransactionRef.
  ///
  /// In en, this message translates to:
  /// **'Transaction reference'**
  String get clientPaymentTransactionRef;

  /// No description provided for @clientPaymentPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get clientPaymentPhoneNumber;

  /// No description provided for @clientPaymentFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get clientPaymentFullName;

  /// No description provided for @clientPaymentSecurityDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Your payment data is end-to-end encrypted. We are PCI-DSS Level 1 certified.'**
  String get clientPaymentSecurityDisclaimer;

  /// No description provided for @clientPaymentErrorTransactionRef.
  ///
  /// In en, this message translates to:
  /// **'Transaction reference is required'**
  String get clientPaymentErrorTransactionRef;

  /// No description provided for @clientPaymentErrorPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get clientPaymentErrorPhoneNumber;

  /// No description provided for @clientPaymentErrorCardInfo.
  ///
  /// In en, this message translates to:
  /// **'Card information is required'**
  String get clientPaymentErrorCardInfo;

  /// No description provided for @clientPaymentErrorNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'User not logged in'**
  String get clientPaymentErrorNotLoggedIn;

  /// No description provided for @clientPaymentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Booking successful!'**
  String get clientPaymentSuccess;

  /// No description provided for @clientPaymentErrorTimeout.
  ///
  /// In en, this message translates to:
  /// **'Server not responding. Check your connection.'**
  String get clientPaymentErrorTimeout;

  /// No description provided for @clientPaymentErrorSeatTaken.
  ///
  /// In en, this message translates to:
  /// **'Seat already booked or unavailable. Please try again.'**
  String get clientPaymentErrorSeatTaken;

  /// No description provided for @clientPaymentErrorInsufficientFunds.
  ///
  /// In en, this message translates to:
  /// **'Insufficient funds for this transaction.'**
  String get clientPaymentErrorInsufficientFunds;

  /// No description provided for @clientPaymentErrorPromoCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired promo code.'**
  String get clientPaymentErrorPromoCode;

  /// No description provided for @clientPaymentSuccessReduction.
  ///
  /// In en, this message translates to:
  /// **'Booking successful! Reduction of'**
  String get clientPaymentSuccessReduction;

  /// No description provided for @clientPaymentPay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get clientPaymentPay;

  /// No description provided for @clientTicketTitle.
  ///
  /// In en, this message translates to:
  /// **'Ticket'**
  String get clientTicketTitle;

  /// No description provided for @clientTicketNotFound.
  ///
  /// In en, this message translates to:
  /// **'Ticket not found'**
  String get clientTicketNotFound;

  /// No description provided for @clientTicketValid.
  ///
  /// In en, this message translates to:
  /// **'VALID'**
  String get clientTicketValid;

  /// No description provided for @clientTicketInvalid.
  ///
  /// In en, this message translates to:
  /// **'INVALID'**
  String get clientTicketInvalid;

  /// No description provided for @clientTicketDownloadPDF.
  ///
  /// In en, this message translates to:
  /// **'Download PDF'**
  String get clientTicketDownloadPDF;

  /// No description provided for @clientTicketEvent.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get clientTicketEvent;

  /// No description provided for @clientTicketSeat.
  ///
  /// In en, this message translates to:
  /// **'Seat'**
  String get clientTicketSeat;

  /// No description provided for @clientTicketRow.
  ///
  /// In en, this message translates to:
  /// **'Row'**
  String get clientTicketRow;

  /// No description provided for @clientTicketType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get clientTicketType;

  /// No description provided for @clientTicketZone.
  ///
  /// In en, this message translates to:
  /// **'Zone'**
  String get clientTicketZone;

  /// No description provided for @clientTicketPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get clientTicketPrice;

  /// No description provided for @clientTicketHolder.
  ///
  /// In en, this message translates to:
  /// **'Holder'**
  String get clientTicketHolder;

  /// No description provided for @clientTicketNoTickets.
  ///
  /// In en, this message translates to:
  /// **'No tickets'**
  String get clientTicketNoTickets;

  /// No description provided for @clientTicketAfterPurchase.
  ///
  /// In en, this message translates to:
  /// **'Your tickets will appear here after purchase.'**
  String get clientTicketAfterPurchase;

  /// No description provided for @clientTicketMyTickets.
  ///
  /// In en, this message translates to:
  /// **'My Tickets'**
  String get clientTicketMyTickets;

  /// No description provided for @clientTicketManageTickets.
  ///
  /// In en, this message translates to:
  /// **'Manage your access and reservations'**
  String get clientTicketManageTickets;

  /// No description provided for @clientTicketRoom.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get clientTicketRoom;

  /// No description provided for @clientTicketPdfSaved.
  ///
  /// In en, this message translates to:
  /// **'PDF saved to'**
  String get clientTicketPdfSaved;

  /// No description provided for @clientTicketDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed:'**
  String get clientTicketDownloadFailed;

  /// No description provided for @clientTicketReference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get clientTicketReference;

  /// No description provided for @clientTicketExpired.
  ///
  /// In en, this message translates to:
  /// **'EXPIRED'**
  String get clientTicketExpired;

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get adminDashboard;

  /// No description provided for @adminUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get adminUsers;

  /// No description provided for @adminEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get adminEvents;

  /// No description provided for @adminCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get adminCategories;

  /// No description provided for @adminVenues.
  ///
  /// In en, this message translates to:
  /// **'Venues'**
  String get adminVenues;

  /// No description provided for @adminPlaces.
  ///
  /// In en, this message translates to:
  /// **'Seats'**
  String get adminPlaces;

  /// No description provided for @adminTickets.
  ///
  /// In en, this message translates to:
  /// **'Tickets'**
  String get adminTickets;

  /// No description provided for @adminReservations.
  ///
  /// In en, this message translates to:
  /// **'Reservations'**
  String get adminReservations;

  /// No description provided for @adminPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get adminPayments;

  /// No description provided for @adminAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get adminAccount;

  /// No description provided for @adminLayoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get adminLayoutTitle;

  /// No description provided for @adminConfig.
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get adminConfig;

  /// No description provided for @adminMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get adminMore;

  /// No description provided for @adminMoreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get adminMoreOptions;

  /// No description provided for @adminDashboardRecentEvents.
  ///
  /// In en, this message translates to:
  /// **'Recent Events'**
  String get adminDashboardRecentEvents;

  /// No description provided for @adminDashboardAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get adminDashboardAnalytics;

  /// No description provided for @adminDashboardByStatus.
  ///
  /// In en, this message translates to:
  /// **'By status'**
  String get adminDashboardByStatus;

  /// No description provided for @adminDashboardByCategory.
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get adminDashboardByCategory;

  /// No description provided for @adminDashboardStatEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get adminDashboardStatEvents;

  /// No description provided for @adminDashboardStatClients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get adminDashboardStatClients;

  /// No description provided for @adminDashboardStatOrganizers.
  ///
  /// In en, this message translates to:
  /// **'Organizers'**
  String get adminDashboardStatOrganizers;

  /// No description provided for @adminDashboardStatRevenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get adminDashboardStatRevenue;

  /// No description provided for @adminDashboardStatVenues.
  ///
  /// In en, this message translates to:
  /// **'Venues'**
  String get adminDashboardStatVenues;

  /// No description provided for @adminDashboardStatRooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get adminDashboardStatRooms;

  /// No description provided for @adminEventsInfo.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get adminEventsInfo;

  /// No description provided for @adminEventsLogistics.
  ///
  /// In en, this message translates to:
  /// **'Logistics'**
  String get adminEventsLogistics;

  /// No description provided for @adminEventsCapacity.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get adminEventsCapacity;

  /// No description provided for @adminEventsVenue.
  ///
  /// In en, this message translates to:
  /// **'Venue'**
  String get adminEventsVenue;

  /// No description provided for @adminEventsDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get adminEventsDate;

  /// No description provided for @adminEventsTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get adminEventsTime;

  /// No description provided for @adminEventsNoSeatsConfigured.
  ///
  /// In en, this message translates to:
  /// **'No seats configured'**
  String get adminEventsNoSeatsConfigured;

  /// No description provided for @adminEventsFeatures.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get adminEventsFeatures;

  /// No description provided for @adminEventsActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get adminEventsActions;

  /// No description provided for @adminEventsValidate.
  ///
  /// In en, this message translates to:
  /// **'Validate / Approve'**
  String get adminEventsValidate;

  /// No description provided for @adminEventsValidated.
  ///
  /// In en, this message translates to:
  /// **'Event validated'**
  String get adminEventsValidated;

  /// No description provided for @adminEventsReactivate.
  ///
  /// In en, this message translates to:
  /// **'Reactivate'**
  String get adminEventsReactivate;

  /// No description provided for @adminEventsReactivated.
  ///
  /// In en, this message translates to:
  /// **'Event reactivated'**
  String get adminEventsReactivated;

  /// No description provided for @adminEventsSuspend.
  ///
  /// In en, this message translates to:
  /// **'Suspend'**
  String get adminEventsSuspend;

  /// No description provided for @adminEventsSuspended.
  ///
  /// In en, this message translates to:
  /// **'Event suspended'**
  String get adminEventsSuspended;

  /// No description provided for @adminEventsCancelEvent.
  ///
  /// In en, this message translates to:
  /// **'Cancel Event'**
  String get adminEventsCancelEvent;

  /// No description provided for @adminEventsCancelled.
  ///
  /// In en, this message translates to:
  /// **'Event cancelled'**
  String get adminEventsCancelled;

  /// No description provided for @adminEventsContactOrganizer.
  ///
  /// In en, this message translates to:
  /// **'Contact Organizer'**
  String get adminEventsContactOrganizer;

  /// No description provided for @adminEventsCancelReason.
  ///
  /// In en, this message translates to:
  /// **'Cancellation reason *'**
  String get adminEventsCancelReason;

  /// No description provided for @adminEventsCancelReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Mandatory reason'**
  String get adminEventsCancelReasonHint;

  /// No description provided for @adminEventsContactOptions.
  ///
  /// In en, this message translates to:
  /// **'Contact options:'**
  String get adminEventsContactOptions;

  /// No description provided for @adminEventsSendEmail.
  ///
  /// In en, this message translates to:
  /// **'Send an email'**
  String get adminEventsSendEmail;

  /// No description provided for @adminEventsEmailNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Email feature not implemented'**
  String get adminEventsEmailNotImplemented;

  /// No description provided for @adminEventsInternalChat.
  ///
  /// In en, this message translates to:
  /// **'Internal chat'**
  String get adminEventsInternalChat;

  /// No description provided for @adminEventsOpenChat.
  ///
  /// In en, this message translates to:
  /// **'Open chat'**
  String get adminEventsOpenChat;

  /// No description provided for @adminEventsChatNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Chat feature not implemented'**
  String get adminEventsChatNotImplemented;

  /// No description provided for @adminEventsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No events found'**
  String get adminEventsEmpty;

  /// No description provided for @adminUsersChangeRole.
  ///
  /// In en, this message translates to:
  /// **'Change role'**
  String get adminUsersChangeRole;

  /// No description provided for @adminUsersRoleOrganizer.
  ///
  /// In en, this message translates to:
  /// **'Organizer'**
  String get adminUsersRoleOrganizer;

  /// No description provided for @adminUsersRoleClient.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get adminUsersRoleClient;

  /// No description provided for @adminUsersResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get adminUsersResetPassword;

  /// No description provided for @adminUsersNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get adminUsersNewPassword;

  /// No description provided for @adminUsersNewPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a new password'**
  String get adminUsersNewPasswordHint;

  /// No description provided for @adminUsersPasswordReset.
  ///
  /// In en, this message translates to:
  /// **'Password reset'**
  String get adminUsersPasswordReset;

  /// No description provided for @adminUsersDeleteUser.
  ///
  /// In en, this message translates to:
  /// **'Delete user'**
  String get adminUsersDeleteUser;

  /// No description provided for @adminUsersManagement.
  ///
  /// In en, this message translates to:
  /// **'User management'**
  String get adminUsersManagement;

  /// No description provided for @adminUsersAudit.
  ///
  /// In en, this message translates to:
  /// **'Audit'**
  String get adminUsersAudit;

  /// No description provided for @adminUsersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get adminUsersEmpty;

  /// No description provided for @adminUsersActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get adminUsersActive;

  /// No description provided for @adminUsersInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get adminUsersInactive;

  /// No description provided for @adminUsersNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get adminUsersNew;

  /// No description provided for @adminUsersRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get adminUsersRole;

  /// No description provided for @adminUsersDeactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get adminUsersDeactivate;

  /// No description provided for @adminUsersActivate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get adminUsersActivate;

  /// No description provided for @adminUsersResetPwd.
  ///
  /// In en, this message translates to:
  /// **'Reset PWD'**
  String get adminUsersResetPwd;

  /// No description provided for @adminUsersNoActivity.
  ///
  /// In en, this message translates to:
  /// **'No activity'**
  String get adminUsersNoActivity;

  /// No description provided for @adminCategoriesAdd.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get adminCategoriesAdd;

  /// No description provided for @adminCategoriesCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get adminCategoriesCode;

  /// No description provided for @adminCategoriesCodeHint.
  ///
  /// In en, this message translates to:
  /// **'CAT01'**
  String get adminCategoriesCodeHint;

  /// No description provided for @adminCategoriesName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get adminCategoriesName;

  /// No description provided for @adminCategoriesDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get adminCategoriesDescription;

  /// No description provided for @adminCategoriesEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get adminCategoriesEdit;

  /// No description provided for @adminCategoriesDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get adminCategoriesDeleteTitle;

  /// No description provided for @adminCategoriesDeleted.
  ///
  /// In en, this message translates to:
  /// **'Category deleted'**
  String get adminCategoriesDeleted;

  /// No description provided for @adminCategoriesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No categories found'**
  String get adminCategoriesEmpty;

  /// No description provided for @adminCategoriesFeatures.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get adminCategoriesFeatures;

  /// No description provided for @adminCategoriesRooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get adminCategoriesRooms;

  /// No description provided for @adminCategoriesConfig.
  ///
  /// In en, this message translates to:
  /// **'Config'**
  String get adminCategoriesConfig;

  /// No description provided for @adminCategoriesAddFeature.
  ///
  /// In en, this message translates to:
  /// **'Add a feature'**
  String get adminCategoriesAddFeature;

  /// No description provided for @adminCategoriesEditFeature.
  ///
  /// In en, this message translates to:
  /// **'Edit feature'**
  String get adminCategoriesEditFeature;

  /// No description provided for @adminCategoriesDataType.
  ///
  /// In en, this message translates to:
  /// **'Data type'**
  String get adminCategoriesDataType;

  /// No description provided for @adminCategoriesDataTypeText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get adminCategoriesDataTypeText;

  /// No description provided for @adminCategoriesDataTypeNumber.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get adminCategoriesDataTypeNumber;

  /// No description provided for @adminCategoriesDataTypeDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get adminCategoriesDataTypeDate;

  /// No description provided for @adminCategoriesDataTypeSelect.
  ///
  /// In en, this message translates to:
  /// **'Dropdown list'**
  String get adminCategoriesDataTypeSelect;

  /// No description provided for @adminCategoriesDataTypeBoolean.
  ///
  /// In en, this message translates to:
  /// **'Yes/No'**
  String get adminCategoriesDataTypeBoolean;

  /// No description provided for @adminCategoriesDisplayOrder.
  ///
  /// In en, this message translates to:
  /// **'Display order'**
  String get adminCategoriesDisplayOrder;

  /// No description provided for @adminCategoriesOptions.
  ///
  /// In en, this message translates to:
  /// **'Options (comma separated)'**
  String get adminCategoriesOptions;

  /// No description provided for @adminCategoriesRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get adminCategoriesRequired;

  /// No description provided for @adminCategoriesNoFeatures.
  ///
  /// In en, this message translates to:
  /// **'No features'**
  String get adminCategoriesNoFeatures;

  /// No description provided for @adminCategoriesCompatibleRoomTypes.
  ///
  /// In en, this message translates to:
  /// **'Compatible room types'**
  String get adminCategoriesCompatibleRoomTypes;

  /// No description provided for @adminCategoriesConfigSaved.
  ///
  /// In en, this message translates to:
  /// **'Specific configuration saved'**
  String get adminCategoriesConfigSaved;

  /// No description provided for @adminCategoriesCinemaConfig.
  ///
  /// In en, this message translates to:
  /// **'Cinema room configuration'**
  String get adminCategoriesCinemaConfig;

  /// No description provided for @adminCategoriesNumRows.
  ///
  /// In en, this message translates to:
  /// **'Number of rows'**
  String get adminCategoriesNumRows;

  /// No description provided for @adminCategoriesSeatsPerRow.
  ///
  /// In en, this message translates to:
  /// **'Seats per row'**
  String get adminCategoriesSeatsPerRow;

  /// No description provided for @adminCategoriesAisles.
  ///
  /// In en, this message translates to:
  /// **'Aisles (ex: B,D)'**
  String get adminCategoriesAisles;

  /// No description provided for @adminCategoriesAisleWidth.
  ///
  /// In en, this message translates to:
  /// **'Aisle width'**
  String get adminCategoriesAisleWidth;

  /// No description provided for @adminCategoriesFreeSeatingZones.
  ///
  /// In en, this message translates to:
  /// **'Free seating zones'**
  String get adminCategoriesFreeSeatingZones;

  /// No description provided for @adminCategoriesNoZones.
  ///
  /// In en, this message translates to:
  /// **'No zones configured'**
  String get adminCategoriesNoZones;

  /// No description provided for @adminCategoriesAddZone.
  ///
  /// In en, this message translates to:
  /// **'Add a zone'**
  String get adminCategoriesAddZone;

  /// No description provided for @adminCategoriesMaxCapacity.
  ///
  /// In en, this message translates to:
  /// **'Max capacity'**
  String get adminCategoriesMaxCapacity;

  /// No description provided for @adminCategoriesTicketPrice.
  ///
  /// In en, this message translates to:
  /// **'Ticket price'**
  String get adminCategoriesTicketPrice;

  /// No description provided for @adminCategoriesStandsBlocks.
  ///
  /// In en, this message translates to:
  /// **'Stand blocks'**
  String get adminCategoriesStandsBlocks;

  /// No description provided for @adminCategoriesNoBlocks.
  ///
  /// In en, this message translates to:
  /// **'No blocks configured'**
  String get adminCategoriesNoBlocks;

  /// No description provided for @adminCategoriesAddBlock.
  ///
  /// In en, this message translates to:
  /// **'Add a block'**
  String get adminCategoriesAddBlock;

  /// No description provided for @adminCategoriesBlockType.
  ///
  /// In en, this message translates to:
  /// **'Type (ex: Stand A)'**
  String get adminCategoriesBlockType;

  /// No description provided for @adminCategoriesNumSeats.
  ///
  /// In en, this message translates to:
  /// **'Number of seats'**
  String get adminCategoriesNumSeats;

  /// No description provided for @adminCategoriesPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get adminCategoriesPrice;

  /// No description provided for @adminCategoriesType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get adminCategoriesType;

  /// No description provided for @adminCategoriesNoSpecificConfig.
  ///
  /// In en, this message translates to:
  /// **'No specific configuration available for this category'**
  String get adminCategoriesNoSpecificConfig;

  /// No description provided for @adminVenuesRoomsFor.
  ///
  /// In en, this message translates to:
  /// **'Rooms —'**
  String get adminVenuesRoomsFor;

  /// No description provided for @adminVenuesNoRooms.
  ///
  /// In en, this message translates to:
  /// **'No rooms for this venue'**
  String get adminVenuesNoRooms;

  /// No description provided for @adminVenuesAddRoom.
  ///
  /// In en, this message translates to:
  /// **'Add a room'**
  String get adminVenuesAddRoom;

  /// No description provided for @adminVenuesManageSeats.
  ///
  /// In en, this message translates to:
  /// **'Manage seats'**
  String get adminVenuesManageSeats;

  /// No description provided for @adminVenuesRoomName.
  ///
  /// In en, this message translates to:
  /// **'Room name'**
  String get adminVenuesRoomName;

  /// No description provided for @adminVenuesVenueCode.
  ///
  /// In en, this message translates to:
  /// **'Venue code'**
  String get adminVenuesVenueCode;

  /// No description provided for @adminVenuesName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get adminVenuesName;

  /// No description provided for @adminVenuesAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get adminVenuesAddress;

  /// No description provided for @adminVenuesCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get adminVenuesCity;

  /// No description provided for @adminVenuesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No venues found'**
  String get adminVenuesEmpty;

  /// No description provided for @adminVenuesSelectRoomType.
  ///
  /// In en, this message translates to:
  /// **'Select rooms compatible with'**
  String get adminVenuesSelectRoomType;

  /// No description provided for @adminPlacesRoomDeleted.
  ///
  /// In en, this message translates to:
  /// **'Room deleted'**
  String get adminPlacesRoomDeleted;

  /// No description provided for @adminPlacesSeatDeleted.
  ///
  /// In en, this message translates to:
  /// **'Seat deleted'**
  String get adminPlacesSeatDeleted;

  /// No description provided for @adminPlacesEditSeat.
  ///
  /// In en, this message translates to:
  /// **'Edit seat'**
  String get adminPlacesEditSeat;

  /// No description provided for @adminPlacesSeatNumber.
  ///
  /// In en, this message translates to:
  /// **'Seat number'**
  String get adminPlacesSeatNumber;

  /// No description provided for @adminPlacesRow.
  ///
  /// In en, this message translates to:
  /// **'Row'**
  String get adminPlacesRow;

  /// No description provided for @adminPlacesEditRoom.
  ///
  /// In en, this message translates to:
  /// **'Edit room'**
  String get adminPlacesEditRoom;

  /// No description provided for @adminPlacesAddRoom.
  ///
  /// In en, this message translates to:
  /// **'Add a room'**
  String get adminPlacesAddRoom;

  /// No description provided for @adminPlacesParentVenue.
  ///
  /// In en, this message translates to:
  /// **'Parent venue'**
  String get adminPlacesParentVenue;

  /// No description provided for @adminPlacesRoomsAndSeats.
  ///
  /// In en, this message translates to:
  /// **'Rooms & Seats'**
  String get adminPlacesRoomsAndSeats;

  /// No description provided for @adminPlacesSearchRoom.
  ///
  /// In en, this message translates to:
  /// **'Search a room...'**
  String get adminPlacesSearchRoom;

  /// No description provided for @adminPlacesFilterByVenue.
  ///
  /// In en, this message translates to:
  /// **'Filter by venue'**
  String get adminPlacesFilterByVenue;

  /// No description provided for @adminPlacesAllVenues.
  ///
  /// In en, this message translates to:
  /// **'All venues'**
  String get adminPlacesAllVenues;

  /// No description provided for @adminPlacesNoRooms.
  ///
  /// In en, this message translates to:
  /// **'No rooms found'**
  String get adminPlacesNoRooms;

  /// No description provided for @adminPlacesManageSeats.
  ///
  /// In en, this message translates to:
  /// **'Manage seats'**
  String get adminPlacesManageSeats;

  /// No description provided for @adminPlacesMultiSelect.
  ///
  /// In en, this message translates to:
  /// **'Multi select'**
  String get adminPlacesMultiSelect;

  /// No description provided for @adminPlacesBatchGeneration.
  ///
  /// In en, this message translates to:
  /// **'Batch generation'**
  String get adminPlacesBatchGeneration;

  /// No description provided for @adminPlacesRowHint.
  ///
  /// In en, this message translates to:
  /// **'B'**
  String get adminPlacesRowHint;

  /// No description provided for @adminPlacesStartNum.
  ///
  /// In en, this message translates to:
  /// **'Start #'**
  String get adminPlacesStartNum;

  /// No description provided for @adminPlacesEndNum.
  ///
  /// In en, this message translates to:
  /// **'End #'**
  String get adminPlacesEndNum;

  /// No description provided for @adminPlacesGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get adminPlacesGenerate;

  /// No description provided for @adminPlacesSearchSeat.
  ///
  /// In en, this message translates to:
  /// **'Search a seat...'**
  String get adminPlacesSearchSeat;

  /// No description provided for @adminPlacesNoSeats.
  ///
  /// In en, this message translates to:
  /// **'No seats for this room'**
  String get adminPlacesNoSeats;

  /// No description provided for @adminPlacesNoSeatsMatch.
  ///
  /// In en, this message translates to:
  /// **'No seats match your search'**
  String get adminPlacesNoSeatsMatch;

  /// No description provided for @adminPlacesDeselect.
  ///
  /// In en, this message translates to:
  /// **'Deselect'**
  String get adminPlacesDeselect;

  /// No description provided for @adminPlacesSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get adminPlacesSelect;

  /// No description provided for @adminPlacesBulkDelete.
  ///
  /// In en, this message translates to:
  /// **'Bulk delete'**
  String get adminPlacesBulkDelete;

  /// No description provided for @adminTicketsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tickets found'**
  String get adminTicketsEmpty;

  /// No description provided for @adminReservationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No reservations found'**
  String get adminReservationsEmpty;

  /// No description provided for @adminPaymentsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No payments found'**
  String get adminPaymentsEmpty;

  /// No description provided for @adminProfilePersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get adminProfilePersonalInfo;

  /// No description provided for @adminProfileLastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get adminProfileLastName;

  /// No description provided for @adminProfileFirstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get adminProfileFirstName;

  /// No description provided for @adminProfileSaveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to save the changes?'**
  String get adminProfileSaveConfirm;

  /// No description provided for @adminProfileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Information updated'**
  String get adminProfileUpdated;

  /// No description provided for @adminProfileActionHistory.
  ///
  /// In en, this message translates to:
  /// **'Action history'**
  String get adminProfileActionHistory;

  /// No description provided for @adminProfileLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to log out?'**
  String get adminProfileLogoutConfirm;

  /// No description provided for @adminActionHistoryUndoAction.
  ///
  /// In en, this message translates to:
  /// **'Undo action'**
  String get adminActionHistoryUndoAction;

  /// No description provided for @adminActionHistoryYesUndo.
  ///
  /// In en, this message translates to:
  /// **'Yes, undo'**
  String get adminActionHistoryYesUndo;

  /// No description provided for @adminActionHistoryActionUndone.
  ///
  /// In en, this message translates to:
  /// **'Action undone'**
  String get adminActionHistoryActionUndone;

  /// No description provided for @adminActionHistoryCreateUser.
  ///
  /// In en, this message translates to:
  /// **'User creation'**
  String get adminActionHistoryCreateUser;

  /// No description provided for @adminActionHistoryUpdateUser.
  ///
  /// In en, this message translates to:
  /// **'User update'**
  String get adminActionHistoryUpdateUser;

  /// No description provided for @adminActionHistoryChangeRole.
  ///
  /// In en, this message translates to:
  /// **'Role change'**
  String get adminActionHistoryChangeRole;

  /// No description provided for @adminActionHistoryDeactivateUser.
  ///
  /// In en, this message translates to:
  /// **'User deactivation'**
  String get adminActionHistoryDeactivateUser;

  /// No description provided for @adminActionHistoryActivateUser.
  ///
  /// In en, this message translates to:
  /// **'User activation'**
  String get adminActionHistoryActivateUser;

  /// No description provided for @adminActionHistoryResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Password reset'**
  String get adminActionHistoryResetPassword;

  /// No description provided for @adminActionHistoryDeleteUser.
  ///
  /// In en, this message translates to:
  /// **'User deletion'**
  String get adminActionHistoryDeleteUser;

  /// No description provided for @adminActionHistoryPaymentMade.
  ///
  /// In en, this message translates to:
  /// **'Payment made'**
  String get adminActionHistoryPaymentMade;

  /// No description provided for @adminActionHistoryRefund.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get adminActionHistoryRefund;

  /// No description provided for @adminActionHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Action history'**
  String get adminActionHistoryTitle;

  /// No description provided for @adminActionHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No actions recorded'**
  String get adminActionHistoryEmpty;

  /// No description provided for @adminActionHistoryReverted.
  ///
  /// In en, this message translates to:
  /// **'Reverted'**
  String get adminActionHistoryReverted;

  /// No description provided for @adminActionHistoryUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get adminActionHistoryUndo;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get notificationsEmpty;

  /// No description provided for @notificationsNotConnected.
  ///
  /// In en, this message translates to:
  /// **'User not connected'**
  String get notificationsNotConnected;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsMarkAllReadShort.
  ///
  /// In en, this message translates to:
  /// **'Read all'**
  String get notificationsMarkAllReadShort;

  /// No description provided for @notificationsFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get notificationsFilterAll;

  /// No description provided for @notificationsFilterPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get notificationsFilterPayments;

  /// No description provided for @notificationsFilterFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get notificationsFilterFailed;

  /// No description provided for @notificationsFilterReservations.
  ///
  /// In en, this message translates to:
  /// **'Reservations'**
  String get notificationsFilterReservations;

  /// No description provided for @notificationsFilterCancellations.
  ///
  /// In en, this message translates to:
  /// **'Cancellations'**
  String get notificationsFilterCancellations;

  /// No description provided for @notificationsFilterCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get notificationsFilterCancelled;

  /// No description provided for @notificationsFilterApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get notificationsFilterApproved;

  /// No description provided for @notificationsFilterUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get notificationsFilterUpdated;

  /// No description provided for @notificationsFilterSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get notificationsFilterSuspended;

  /// No description provided for @notificationsFilterScanned.
  ///
  /// In en, this message translates to:
  /// **'Scanned'**
  String get notificationsFilterScanned;

  /// No description provided for @notificationsFilterReused.
  ///
  /// In en, this message translates to:
  /// **'Reused'**
  String get notificationsFilterReused;

  /// No description provided for @notificationsFilterRefunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get notificationsFilterRefunded;

  /// No description provided for @notificationsAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get notificationsAll;

  /// No description provided for @notificationsUnread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get notificationsUnread;

  /// No description provided for @notificationsRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get notificationsRead;

  /// No description provided for @notificationsNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get notificationsNoResults;

  /// No description provided for @notificationsEmptyFiltered.
  ///
  /// In en, this message translates to:
  /// **'No notifications match the selected filters.\nModify or reset filters to see more results.'**
  String get notificationsEmptyFiltered;

  /// No description provided for @notificationsEmptyGeneral.
  ///
  /// In en, this message translates to:
  /// **'You will be notified here about important updates.\nBook tickets or create events to receive notifications.'**
  String get notificationsEmptyGeneral;

  /// No description provided for @notificationsResetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset filters'**
  String get notificationsResetFilters;

  /// No description provided for @pageNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get pageNotFoundTitle;

  /// No description provided for @pageNotFoundHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get pageNotFoundHome;

  /// No description provided for @widgetsErrorRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get widgetsErrorRetry;

  /// No description provided for @widgetsSeatPickerRow.
  ///
  /// In en, this message translates to:
  /// **'Row'**
  String get widgetsSeatPickerRow;

  /// No description provided for @widgetsCrudConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get widgetsCrudConfirm;

  /// No description provided for @widgetsCrudDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this item?'**
  String get widgetsCrudDeleteConfirm;

  /// No description provided for @widgetsCrudCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get widgetsCrudCancel;

  /// No description provided for @widgetsCrudDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get widgetsCrudDelete;

  /// No description provided for @widgetsCrudBulkDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Bulk delete'**
  String get widgetsCrudBulkDeleteTitle;

  /// No description provided for @widgetsCrudBulkDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete {n} item(s)?'**
  String widgetsCrudBulkDeleteConfirm(Object n);

  /// No description provided for @widgetsCrudDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get widgetsCrudDeleteAll;

  /// No description provided for @widgetsCrudEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get widgetsCrudEdit;

  /// No description provided for @widgetsCrudAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get widgetsCrudAdd;

  /// No description provided for @widgetsCrudSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get widgetsCrudSave;

  /// No description provided for @widgetsCrudRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get widgetsCrudRequired;

  /// No description provided for @widgetsCrudSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Select a date'**
  String get widgetsCrudSelectDate;

  /// No description provided for @widgetsCrudSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get widgetsCrudSelectAll;

  /// No description provided for @widgetsCrudDeleteSelection.
  ///
  /// In en, this message translates to:
  /// **'Delete selection'**
  String get widgetsCrudDeleteSelection;

  /// No description provided for @widgetsCrudExitSelectMode.
  ///
  /// In en, this message translates to:
  /// **'Exit select mode'**
  String get widgetsCrudExitSelectMode;

  /// No description provided for @widgetsCrudSelectMode.
  ///
  /// In en, this message translates to:
  /// **'Select mode'**
  String get widgetsCrudSelectMode;

  /// No description provided for @widgetsCrudSearch.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get widgetsCrudSearch;

  /// No description provided for @widgetsCrudAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get widgetsCrudAll;

  /// No description provided for @widgetsCrudRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get widgetsCrudRetry;

  /// No description provided for @widgetsCrudEmpty.
  ///
  /// In en, this message translates to:
  /// **'No items'**
  String get widgetsCrudEmpty;

  /// No description provided for @widgetsCodePromoLabel.
  ///
  /// In en, this message translates to:
  /// **'Promo code'**
  String get widgetsCodePromoLabel;

  /// No description provided for @widgetsCodePromoHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your promo code'**
  String get widgetsCodePromoHint;

  /// No description provided for @widgetsCodePromoApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get widgetsCodePromoApply;

  /// No description provided for @widgetsCodePromoApplied.
  ///
  /// In en, this message translates to:
  /// **'Promo code applied!'**
  String get widgetsCodePromoApplied;

  /// No description provided for @widgetsCarteBancaireTitle.
  ///
  /// In en, this message translates to:
  /// **'Bank card information'**
  String get widgetsCarteBancaireTitle;

  /// No description provided for @widgetsCarteBancaireCardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card number'**
  String get widgetsCarteBancaireCardNumber;

  /// No description provided for @widgetsCarteBancaireCardNumberHint.
  ///
  /// In en, this message translates to:
  /// **'1234 5678 9012 3456'**
  String get widgetsCarteBancaireCardNumberHint;

  /// No description provided for @widgetsCarteBancaireExpiry.
  ///
  /// In en, this message translates to:
  /// **'Expiry date'**
  String get widgetsCarteBancaireExpiry;

  /// No description provided for @widgetsCarteBancaireExpiryHint.
  ///
  /// In en, this message translates to:
  /// **'MM/YY'**
  String get widgetsCarteBancaireExpiryHint;

  /// No description provided for @widgetsCarteBancaireCvv.
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get widgetsCarteBancaireCvv;

  /// No description provided for @widgetsCarteBancaireCvvHint.
  ///
  /// In en, this message translates to:
  /// **'123'**
  String get widgetsCarteBancaireCvvHint;

  /// No description provided for @widgetsCarteBancaireCardholderName.
  ///
  /// In en, this message translates to:
  /// **'Cardholder name'**
  String get widgetsCarteBancaireCardholderName;

  /// No description provided for @widgetsCarteBancaireCardholderNameHint.
  ///
  /// In en, this message translates to:
  /// **'JOHN DOE'**
  String get widgetsCarteBancaireCardholderNameHint;

  /// No description provided for @widgetsPaymentMethodTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get widgetsPaymentMethodTitle;

  /// No description provided for @widgetsTwoFactorDisable2fa.
  ///
  /// In en, this message translates to:
  /// **'Disable 2FA'**
  String get widgetsTwoFactorDisable2fa;

  /// No description provided for @widgetsTwoFactorDisable2faConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to disable two-factor authentication?'**
  String get widgetsTwoFactorDisable2faConfirm;

  /// No description provided for @widgetsTwoFactorCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get widgetsTwoFactorCancel;

  /// No description provided for @widgetsTwoFactorDisable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get widgetsTwoFactorDisable;

  /// No description provided for @widgetsTwoFactorPassword2fa.
  ///
  /// In en, this message translates to:
  /// **'Password & 2FA'**
  String get widgetsTwoFactorPassword2fa;

  /// No description provided for @widgetsTwoFactor2faLabel.
  ///
  /// In en, this message translates to:
  /// **'Two-factor authentication'**
  String get widgetsTwoFactor2faLabel;

  /// No description provided for @widgetsTwoFactor2faEnabledDesc.
  ///
  /// In en, this message translates to:
  /// **'6-digit code sent by email'**
  String get widgetsTwoFactor2faEnabledDesc;

  /// No description provided for @widgetsTwoFactor2faDisabledDesc.
  ///
  /// In en, this message translates to:
  /// **'Enable to secure your account'**
  String get widgetsTwoFactor2faDisabledDesc;

  /// No description provided for @widgetsTwoFactorChangePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get widgetsTwoFactorChangePasswordTitle;

  /// No description provided for @widgetsTwoFactorCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get widgetsTwoFactorCurrentPassword;

  /// No description provided for @widgetsTwoFactorNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get widgetsTwoFactorNewPassword;

  /// No description provided for @widgetsTwoFactorConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get widgetsTwoFactorConfirmPassword;

  /// No description provided for @widgetsTwoFactorPasswordLengthError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get widgetsTwoFactorPasswordLengthError;

  /// No description provided for @widgetsTwoFactorPasswordMismatchError.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get widgetsTwoFactorPasswordMismatchError;

  /// No description provided for @widgetsTwoFactorPasswordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get widgetsTwoFactorPasswordChanged;

  /// No description provided for @widgetsTwoFactorChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get widgetsTwoFactorChangePassword;

  /// No description provided for @widgetsTwoFactorActivate2fa.
  ///
  /// In en, this message translates to:
  /// **'Enable 2FA'**
  String get widgetsTwoFactorActivate2fa;

  /// No description provided for @widgetsTwoFactor2faEmailDesc.
  ///
  /// In en, this message translates to:
  /// **'A 6-digit code will be sent to your email address.'**
  String get widgetsTwoFactor2faEmailDesc;

  /// No description provided for @widgetsTwoFactorSending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get widgetsTwoFactorSending;

  /// No description provided for @widgetsTwoFactorSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get widgetsTwoFactorSendCode;

  /// No description provided for @widgetsTwoFactorCodeHint.
  ///
  /// In en, this message translates to:
  /// **'000000'**
  String get widgetsTwoFactorCodeHint;

  /// No description provided for @widgetsTwoFactor2faActivated.
  ///
  /// In en, this message translates to:
  /// **'2FA enabled'**
  String get widgetsTwoFactor2faActivated;

  /// No description provided for @widgetsTwoFactorIncorrectCode.
  ///
  /// In en, this message translates to:
  /// **'Incorrect code'**
  String get widgetsTwoFactorIncorrectCode;

  /// No description provided for @widgetsTwoFactorVerifyActivate.
  ///
  /// In en, this message translates to:
  /// **'Verify & activate'**
  String get widgetsTwoFactorVerifyActivate;

  /// No description provided for @widgetsNotificationBellTooltip.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get widgetsNotificationBellTooltip;

  /// No description provided for @widgetsProfileLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get widgetsProfileLogout;

  /// No description provided for @adminUsersCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get adminUsersCode;

  /// No description provided for @adminUsersTel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get adminUsersTel;

  /// No description provided for @adminEventsReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get adminEventsReason;

  /// No description provided for @adminEventsReserved.
  ///
  /// In en, this message translates to:
  /// **'reserved'**
  String get adminEventsReserved;

  /// No description provided for @adminEventsTo.
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get adminEventsTo;

  /// No description provided for @commonNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get commonNone;

  /// No description provided for @commonDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get commonDetails;

  /// No description provided for @commonNoData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get commonNoData;

  /// No description provided for @adminActionHistoryRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get adminActionHistoryRetry;

  /// No description provided for @adminActionHistoryActions.
  ///
  /// In en, this message translates to:
  /// **'actions'**
  String get adminActionHistoryActions;

  /// No description provided for @adminActionHistoryNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get adminActionHistoryNo;

  /// No description provided for @adminActionHistoryOn.
  ///
  /// In en, this message translates to:
  /// **'on'**
  String get adminActionHistoryOn;

  /// No description provided for @adminActionHistoryUndoConfirm.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get adminActionHistoryUndoConfirm;

  /// No description provided for @adminActionHistoryUndoTitle.
  ///
  /// In en, this message translates to:
  /// **'Undo action'**
  String get adminActionHistoryUndoTitle;

  /// No description provided for @adminActionHistoryUndone.
  ///
  /// In en, this message translates to:
  /// **'Action undone'**
  String get adminActionHistoryUndone;

  /// No description provided for @adminPaymentsReservation.
  ///
  /// In en, this message translates to:
  /// **'Reservation'**
  String get adminPaymentsReservation;

  /// No description provided for @adminPaymentsAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get adminPaymentsAmount;

  /// No description provided for @adminPaymentsMethod.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get adminPaymentsMethod;

  /// No description provided for @adminPaymentsDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get adminPaymentsDate;

  /// No description provided for @adminPaymentsStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get adminPaymentsStatus;

  /// No description provided for @adminTicketsPlace.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get adminTicketsPlace;

  /// No description provided for @adminTicketsEvent.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get adminTicketsEvent;

  /// No description provided for @adminReservationsItem.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get adminReservationsItem;

  /// No description provided for @adminReservationsClient.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get adminReservationsClient;

  /// No description provided for @adminReservationsTickets.
  ///
  /// In en, this message translates to:
  /// **'Tickets'**
  String get adminReservationsTickets;

  /// No description provided for @adminProfileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get adminProfileEmail;

  /// No description provided for @adminProfileLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get adminProfileLogout;

  /// No description provided for @adminProfileAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get adminProfileAdmin;

  /// No description provided for @adminProfileBadge.
  ///
  /// In en, this message translates to:
  /// **'Badge'**
  String get adminProfileBadge;

  /// No description provided for @adminProfileAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get adminProfileAccount;

  /// No description provided for @adminCategoriesFeatureName.
  ///
  /// In en, this message translates to:
  /// **'Feature name'**
  String get adminCategoriesFeatureName;

  /// No description provided for @adminCategoriesTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get adminCategoriesTypeLabel;

  /// No description provided for @adminCategoriesOrderLabel.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get adminCategoriesOrderLabel;

  /// No description provided for @adminCategoriesFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get adminCategoriesFeaturesTitle;

  /// No description provided for @adminCategoriesConfigFor.
  ///
  /// In en, this message translates to:
  /// **'Config for'**
  String get adminCategoriesConfigFor;

  /// No description provided for @adminCategoriesZone.
  ///
  /// In en, this message translates to:
  /// **'Zone'**
  String get adminCategoriesZone;

  /// No description provided for @adminCategoriesSelectRooms.
  ///
  /// In en, this message translates to:
  /// **'Select rooms'**
  String get adminCategoriesSelectRooms;

  /// No description provided for @adminCategoriesCapacity.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get adminCategoriesCapacity;

  /// No description provided for @adminCategoriesEditZone.
  ///
  /// In en, this message translates to:
  /// **'Edit zone'**
  String get adminCategoriesEditZone;

  /// No description provided for @adminCategoriesEditBlock.
  ///
  /// In en, this message translates to:
  /// **'Edit block'**
  String get adminCategoriesEditBlock;

  /// No description provided for @adminCategoriesBlock.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get adminCategoriesBlock;

  /// No description provided for @adminVenuesRoomType.
  ///
  /// In en, this message translates to:
  /// **'Room type'**
  String get adminVenuesRoomType;

  /// No description provided for @adminActionHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get adminActionHistory;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @clientHomeDateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get clientHomeDateRange;

  /// No description provided for @clientHomePriceRange.
  ///
  /// In en, this message translates to:
  /// **'Price Range'**
  String get clientHomePriceRange;

  /// No description provided for @clientHomeMin.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get clientHomeMin;

  /// No description provided for @clientHomeMax.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get clientHomeMax;

  /// No description provided for @clientHomeDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Event Details'**
  String get clientHomeDetailTitle;

  /// No description provided for @clientSavedEventsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No saved events'**
  String get clientSavedEventsEmpty;

  /// No description provided for @clientFavoriteAdded.
  ///
  /// In en, this message translates to:
  /// **'Event added to favorites'**
  String get clientFavoriteAdded;

  /// No description provided for @clientFavoriteRemoved.
  ///
  /// In en, this message translates to:
  /// **'Event removed from favorites'**
  String get clientFavoriteRemoved;

  /// No description provided for @clientShareCopied.
  ///
  /// In en, this message translates to:
  /// **'Details copied to clipboard'**
  String get clientShareCopied;

  /// No description provided for @clientPaymentShareText.
  ///
  /// In en, this message translates to:
  /// **'Current order on Ontik'**
  String get clientPaymentShareText;

  /// No description provided for @clientPaymentOrderCopied.
  ///
  /// In en, this message translates to:
  /// **'Order information copied'**
  String get clientPaymentOrderCopied;

  /// No description provided for @clientPaymentEventName.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get clientPaymentEventName;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
