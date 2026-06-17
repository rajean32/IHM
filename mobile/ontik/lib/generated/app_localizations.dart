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
