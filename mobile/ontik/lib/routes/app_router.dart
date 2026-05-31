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
import '../views/organizer/organizer_dashboard_view.dart';
import '../views/organizer/organizer_events_view.dart';
import '../views/organizer/organizer_account_view.dart';
import '../views/organizer/organizer_layout.dart';
import '../views/organizer/create_event_view.dart';
import '../views/organizer/scan_view.dart';
import '../views/admin/admin_layout.dart';
import '../views/admin/dashboard_view.dart' as admin;
import '../views/admin/manage_lieux_view.dart';
import '../views/admin/manage_users_view.dart';
import '../views/admin/manage_categories_view.dart';
import '../views/admin/manage_events_view.dart';
import '../views/admin/manage_salle_places_view.dart';
import '../views/admin/manage_tickets_view.dart';
import '../views/admin/manage_reservations_view.dart';
import '../views/admin/manage_payments_view.dart';

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
        path: '/payment/:eventId',
        builder: (context, state) {
          final eventId = int.parse(state.pathParameters['eventId']!);
          final extra = state.extra as Map<String, dynamic>?;
          final amount = extra?['amount'] as double? ?? 0;
          final tickets = extra?['tickets'] as List<dynamic>? ?? [];
          return PaymentView(eventId: eventId, amount: amount, tickets: tickets.cast<Map<String, dynamic>>());
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
      ShellRoute(
        builder: (context, state, child) => OrganizerLayout(child: child),
        routes: [
          GoRoute(
            path: '/organizer',
            builder: (context, state) => const OrganizerDashboardView(),
          ),
          GoRoute(
            path: '/organizer/events',
            builder: (context, state) => const OrganizerEventsView(),
          ),
          GoRoute(
            path: '/organizer/account',
            builder: (context, state) => const OrganizerAccountView(),
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
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => AdminLayout(child: child),
        routes: [
          GoRoute(
            path: '/admin',
            builder: (context, state) => const admin.AdminDashboardView(),
          ),
          GoRoute(
            path: '/admin/users',
            builder: (context, state) => const ManageUsersView(),
          ),
          GoRoute(
            path: '/admin/events',
            builder: (context, state) => const ManageEventsView(),
          ),
          GoRoute(
            path: '/admin/categories',
            builder: (context, state) => const ManageCategoriesView(),
          ),
          GoRoute(
            path: '/admin/lieux',
            builder: (context, state) => const ManageLieuxView(),
          ),
          GoRoute(
            path: '/admin/salle-places',
            builder: (context, state) {
              final salleFilter = state.extra as String?;
              return ManageSallePlacesView(initialSalleFilter: salleFilter);
            },
          ),
          GoRoute(
            path: '/admin/tickets',
            builder: (context, state) => const ManageTicketsView(),
          ),
          GoRoute(
            path: '/admin/reservations',
            builder: (context, state) => const ManageReservationsView(),
          ),
          GoRoute(
            path: '/admin/payments',
            builder: (context, state) => const ManagePaymentsView(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final isAuth = authState.isAuthenticated;
      final isLogin = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final isFirstLogin = state.matchedLocation == '/first-login';
      final isAdmin = state.matchedLocation.startsWith('/admin');

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
      if (isAuth && isAdmin && authState.user?.role != 'ADMINISTRATEUR') {
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
