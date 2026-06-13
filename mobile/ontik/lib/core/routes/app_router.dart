import 'package:flutter/material.dart';
import '../../pages/auth/login_page.dart';
import '../../pages/splash_page.dart';
import '../assets/app_colors.dart';
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
import 'auth_routes.dart';
import 'client_routes.dart';
import 'organizer_routes.dart';
import 'admin_routes.dart';
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
      case OrganizerRoutes.createEvent:
        final a = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(builder: (_) => CreateEventPage(event: a?['event']));
      case OrganizerRoutes.scan:
        return MaterialPageRoute(builder: (_) => const ScanPage());
      case OrganizerRoutes.pricing:
        final a = settings.arguments as Map<String, dynamic>?;
        if (a == null) return _notFound();
        return MaterialPageRoute(builder: (_) => PricingPage(eventId: a['eventId'] as int));
      case OrganizerRoutes.tickets:
        return MaterialPageRoute(builder: (_) => const TicketsPage());
      case OrganizerRoutes.reservations:
        return MaterialPageRoute(builder: (_) => const ReservationsPage());
      case OrganizerRoutes.reservationDetail:
        final a = settings.arguments as Map<String, dynamic>?;
        if (a == null) return _notFound();
        return MaterialPageRoute(builder: (_) => ReservationDetailPage(id: a['id'] as int));
      case AdminRoutes.layout:
        return MaterialPageRoute(builder: (_) => const AdminLayout());
      default:
        return _notFound();
    }
  }

  static bool _isProtectedRoute(String? name) {
    const protected = [
      ClientRoutes.home,
      ClientRoutes.homeDetail,
      ClientRoutes.reservation,
      ClientRoutes.payment,
      ClientRoutes.ticket,
      ClientRoutes.profile,
      OrganizerRoutes.layout,
      OrganizerRoutes.createEvent,
      OrganizerRoutes.scan,
      OrganizerRoutes.pricing,
      OrganizerRoutes.tickets,
      OrganizerRoutes.reservations,
      OrganizerRoutes.reservationDetail,
      AdminRoutes.layout,
    ];
    return protected.contains(name);
  }

  static Route<dynamic> _notFound() {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Page introuvable')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off, size: 64, color: AppColors.textSecondary),
              const SizedBox(height: 16),
              const Text('Page introuvable', style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(AuthRoutes.splash, (route) => false),
                icon: const Icon(Icons.home),
                label: const Text('Accueil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
