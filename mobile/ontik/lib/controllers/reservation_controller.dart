import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/reservation_repository.dart';
import '../repositories/paiement_repository.dart';
import '../repositories/ticket_repository.dart';
import '../models/reservation.dart';
import '../models/ticket.dart';
import 'auth_controller.dart';

final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  return ReservationRepository(ref.watch(apiClientProvider));
});

final paiementRepositoryProvider = Provider<PaiementRepository>((ref) {
  return PaiementRepository(ref.watch(apiClientProvider));
});

final ticketRepositoryProvider = Provider<TicketRepository>((ref) {
  return TicketRepository(ref.watch(apiClientProvider));
});

class ReservationState {
  final Reservation? reservation;
  final PaiementStatus? paymentStatus;
  final TicketQRResponse? ticketQR;
  final bool isLoading;
  final String? error;

  ReservationState({
    this.reservation,
    this.paymentStatus,
    this.ticketQR,
    this.isLoading = false,
    this.error,
  });

  ReservationState copyWith({
    Reservation? reservation,
    PaiementStatus? paymentStatus,
    TicketQRResponse? ticketQR,
    bool? isLoading,
    String? error,
  }) {
    return ReservationState(
      reservation: reservation ?? this.reservation,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      ticketQR: ticketQR ?? this.ticketQR,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final reservationControllerProvider = StateNotifierProvider.family<
    ReservationController, ReservationState, String>((ref, clientCode) {
  return ReservationController(
    ref.watch(reservationRepositoryProvider),
    ref.watch(paiementRepositoryProvider),
    ref.watch(ticketRepositoryProvider),
    clientCode,
  );
});

class ReservationController extends StateNotifier<ReservationState> {
  final ReservationRepository _reservationRepo;
  final PaiementRepository _paiementRepo;
  final TicketRepository _ticketRepo;
  final String clientCode;

  ReservationController(
    this._reservationRepo,
    this._paiementRepo,
    this._ticketRepo,
    this.clientCode,
  ) : super(ReservationState());

  Future<void> createReservation({
    required String codeClient,
    required DateTime dateReservation,
    required List<String> codeTickets,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final reservation = Reservation(
        codeClient: codeClient,
        dateReservation: dateReservation,
        codeTickets: codeTickets,
      );
      final created = await _reservationRepo.create(reservation);
      state = state.copyWith(isLoading: false, reservation: created);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> processPayment({
    required int reservationId,
    required double amount,
    required String modePaiement,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final paiement = Paiement(
        montant: amount,
        datePaiement: DateTime.now(),
        modePaiement: modePaiement,
        idReservation: reservationId,
      );
      await _paiementRepo.create(paiement);
      final status = await _paiementRepo.getPaymentStatus(reservationId);
      state = state.copyWith(isLoading: false, paymentStatus: status);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> getTicketQR(String ticketCode) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final qr = await _ticketRepo.generateQRCode(ticketCode);
      state = state.copyWith(isLoading: false, ticketQR: qr);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<List<Reservation>> getClientReservations() async {
    return await _reservationRepo.getByClient(clientCode);
  }

  Future<List<Ticket>> getClientTickets() async {
    return await _ticketRepo.getByClient(clientCode);
  }
}
