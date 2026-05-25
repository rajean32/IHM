import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/auth_controller.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/auth/first_login_view.dart';
import '../views/client/home_view.dart';
import '../views/client/event_detail_view.dart';
import '../views/client/reservation_view.dart';
import '../views/client/payment_view.dart';
import '../views/client/ticket_view.dart';
import '../views/client/my_reservations_view.dart';
import '../views/organizer/dashboard_view.dart' as org;
import '../views/organizer/create_event_view.dart';
import '../views/organizer/scan_view.dart';
import '../views/admin/dashboard_view.dart' as admin;
import '../views/admin/manage_lieux_view.dart';
import '../views/admin/manage_salles_view.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: AuthRefreshNotifier(ref),
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterView(),
      ),
      GoRoute(
        path: '/first-login',
        builder: (context, state) => const FirstLoginView(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeView(),
      ),
      GoRoute(
        path: '/event/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return EventDetailView(eventId: id);
        },
      ),
      GoRoute(
        path: '/reservation/:eventId',
        builder: (context, state) {
          final eventId = int.parse(state.pathParameters['eventId']!);
          return ReservationView(eventId: eventId);
        },
      ),
      GoRoute(
        path: '/payment/:reservationId',
        builder: (context, state) {
          final reservationId = int.parse(state.pathParameters['reservationId']!);
          final amount = double.tryParse(state.uri.queryParameters['amount'] ?? '0') ?? 0;
          return PaymentView(reservationId: reservationId, amount: amount);
        },
      ),
      GoRoute(
        path: '/ticket/:ticketCode',
        builder: (context, state) {
          final ticketCode = state.pathParameters['ticketCode']!;
          return TicketView(ticketCode: ticketCode);
        },
      ),
      GoRoute(
        path: '/my-reservations',
        builder: (context, state) => const MyReservationsView(),
      ),
      GoRoute(
        path: '/organizer',
        builder: (context, state) => const org.OrganizerDashboardView(),
      ),
      GoRoute(
        path: '/organizer/create-event',
        builder: (context, state) => const CreateEventView(),
      ),
      GoRoute(
        path: '/organizer/scan',
        builder: (context, state) => const ScanView(),
      ),
      GoRoute(
        path: '/organizer/scan/:eventId',
        builder: (context, state) {
          final eventId = int.tryParse(state.pathParameters['eventId'] ?? '');
          return ScanView(eventId: eventId);
        },
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const admin.AdminDashboardView(),
      ),
      GoRoute(
        path: '/admin/lieux',
        builder: (context, state) => const ManageLieuxView(),
      ),
      GoRoute(
        path: '/admin/salles',
        builder: (context, state) => const ManageSallesView(),
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final isAuth = authState.isAuthenticated;
      final isLogin = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final isFirstLogin = state.matchedLocation == '/first-login';

      if (!isAuth && !isLogin) return '/login';
      if (isAuth && authState.needsFirstLogin && !isFirstLogin) {
        return '/first-login';
      }
      if (isAuth && isLogin) {
        final role = authState.user?.role;
        if (role == 'ADMINISTRATEUR') return '/admin';
        if (role == 'ORGANISATEUR') return '/organizer';
        return '/home';
      }
      return null;
    },
  );
});

class AuthRefreshNotifier extends ChangeNotifier {
  final Ref _ref;

  AuthRefreshNotifier(this._ref) {
    _ref.listen(authControllerProvider, (prev, next) {
      notifyListeners();
    });
  }
}
