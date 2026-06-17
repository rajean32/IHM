import 'package:flutter/material.dart';
import '../../pages/auth/login_page.dart';
import '../../pages/splash_page.dart';
import '../../pages/auth/register_page.dart';
import '../../pages/auth/forgot_password_page.dart';
import '../../pages/client/home_page.dart';
import '../../pages/client/home_detail_page.dart';
import '../../pages/client/reservation_page.dart';
import '../../pages/client/payment_page.dart';
import '../../pages/client/ticket_page.dart';
import '../../pages/client/profile_page.dart';
import '../../pages/client/client_layout.dart';
import '../../pages/organizer/organizer_layout.dart';
import '../../pages/organizer/create_event_page.dart';
import '../../pages/organizer/pricing_page.dart';
import '../../pages/organizer/scan_page.dart';
import '../../pages/organizer/tickets_page.dart';
import '../../pages/organizer/reservations_page.dart';
import '../../pages/organizer/reservation_detail_page.dart';
import '../../pages/admin/admin_layout.dart';
import '../../pages/shared/notifications_page.dart';
import '../../pages/shared/settings_page.dart';
import '../../pages/ticket/ticket_list_page.dart';
import '../../pages/ticket/free_seating_ticket_page.dart';
import '../../pages/ticket/numbered_seating_ticket_page.dart';
import '../../pages/ticket/mixed_seating_ticket_page.dart';
import 'auth_routes.dart';
import 'client_routes.dart';
import 'organizer_routes.dart';
import 'admin_routes.dart';
import 'shared_routes.dart';
import '../api/dio_config.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    if (_isProtectedRoute(settings.name)) {
      if (!isLoggedInSync) {
        return MaterialPageRoute(builder: (_) => const SplashPage());
      }
    }
    switch (settings.name) {
      case AuthRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case AuthRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case AuthRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case AuthRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());
      case ClientRoutes.home:
        return MaterialPageRoute(builder: (_) => const ClientLayout());
      case ClientRoutes.homeDetail:
        final a = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => HomeDetailPage(eventId: a['id'] as int));
      case ClientRoutes.reservation:
        final a = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => ReservationPage(eventId: a['eventId'] as int));
      case ClientRoutes.payment:
        final a = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => PaymentPage(
          eventId: a['eventId'] as int,
          eventTitle: a['eventTitle'] as String? ?? '',
          amount: (a['amount'] as num).toDouble(),
          tickets: (a['tickets'] as List).cast<Map<String, dynamic>>(),
        ));
      case ClientRoutes.ticket:
        final a = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => TicketPage(ticketCode: a['code'] as String));
      case ClientRoutes.ticketList:
        return MaterialPageRoute(builder: (_) => const TicketListPage());
      case ClientRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case OrganizerRoutes.layout:
        return MaterialPageRoute(builder: (_) => const OrganizerLayout());
      case OrganizerRoutes.createEvent:
        final a = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(builder: (_) => CreateEventPage(event: a?['event']));
      case OrganizerRoutes.scan:
        return MaterialPageRoute(builder: (_) => const ScanPage());
      case OrganizerRoutes.pricing:
        final a = settings.arguments as Map<String, dynamic>?;
        if (a == null) return MaterialPageRoute(builder: (_) => const LoginPage());
        return MaterialPageRoute(builder: (_) => PricingPage(eventId: a['eventId'] as int));
      case OrganizerRoutes.tickets:
        return MaterialPageRoute(builder: (_) => const TicketsPage());
      case OrganizerRoutes.ticketFreeSeating:
        return MaterialPageRoute(builder: (_) => const TicketListPage(placementType: 'LIBRE'));
      case OrganizerRoutes.ticketNumbered:
        return MaterialPageRoute(builder: (_) => const TicketListPage(placementType: 'NUMEROTE'));
      case OrganizerRoutes.ticketMixed:
        return MaterialPageRoute(builder: (_) => const TicketListPage(placementType: 'MIXTE'));
      case OrganizerRoutes.reservations:
        return MaterialPageRoute(builder: (_) => const ReservationsPage());
      case OrganizerRoutes.reservationDetail:
        final a = settings.arguments as Map<String, dynamic>?;
        if (a == null) return MaterialPageRoute(builder: (_) => const LoginPage());
        return MaterialPageRoute(builder: (_) => ReservationDetailPage(id: a['id'] as int));
      case AdminRoutes.layout:
        return MaterialPageRoute(builder: (_) => const AdminLayout());
      case SharedRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case SharedRoutes.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsPage());
      default:
        return MaterialPageRoute(builder: (_) => const LoginPage());
    }
  }

  static bool _isProtectedRoute(String? name) {
    const protected = [
      ClientRoutes.home,
      ClientRoutes.homeDetail,
      ClientRoutes.reservation,
      ClientRoutes.payment,
      ClientRoutes.ticket,
      ClientRoutes.ticketList,
      ClientRoutes.profile,
      OrganizerRoutes.layout,
      OrganizerRoutes.createEvent,
      OrganizerRoutes.scan,
      OrganizerRoutes.pricing,
      OrganizerRoutes.tickets,
      OrganizerRoutes.ticketFreeSeating,
      OrganizerRoutes.ticketNumbered,
      OrganizerRoutes.ticketMixed,
      OrganizerRoutes.reservations,
      OrganizerRoutes.reservationDetail,
      AdminRoutes.layout,
      SharedRoutes.notifications,
      SharedRoutes.settings,
    ];
    return protected.contains(name);
  }
}
