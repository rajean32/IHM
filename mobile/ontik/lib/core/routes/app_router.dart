import 'package:flutter/material.dart';
import '../../pages/auth/login_page.dart';
import '../../pages/auth/register_page.dart';
import '../../pages/auth/forgot_password_page.dart';
import '../../pages/client/home_page.dart';
import '../../pages/client/home_detail_page.dart';
import '../../pages/client/reservation_page.dart';
import '../../pages/client/payment_page.dart';
import '../../pages/client/ticket_page.dart';
import '../../pages/client/profile_page.dart';
import '../../pages/organizer/organizer_layout.dart';
import '../../pages/admin/admin_layout.dart';
import 'auth_routes.dart';
import 'client_routes.dart';
import 'organizer_routes.dart';
import 'admin_routes.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AuthRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case AuthRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case AuthRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());
      case ClientRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomePage());
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
          amount: (a['amount'] as num).toDouble(),
          tickets: (a['tickets'] as List).cast<Map<String, dynamic>>(),
        ));
      case ClientRoutes.ticket:
        final a = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => TicketPage(ticketCode: a['code'] as String));
      case ClientRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case OrganizerRoutes.layout:
        return MaterialPageRoute(builder: (_) => const OrganizerLayout());
      case AdminRoutes.layout:
        return MaterialPageRoute(builder: (_) => const AdminLayout());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text('Page introuvable'))),
        );
    }
  }
}
