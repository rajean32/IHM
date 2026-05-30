import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/api_client.dart';
import '../../core/api_endpoints.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/event_controller.dart';
import '../../widgets/seat_picker.dart';
import '../../widgets/error_state.dart';

class ReservationView extends ConsumerStatefulWidget {
  final int eventId;
  const ReservationView({super.key, required this.eventId});

  @override
  ConsumerState<ReservationView> createState() => _ReservationViewState();
}

class _ReservationViewState extends ConsumerState<ReservationView> {
  final List<Map<String, dynamic>> _selectedSeats = [];
  bool _isProcessing = false;

  double get _totalAmount {
    return _selectedSeats.fold(0, (sum, s) => sum + (s['prix'] as double? ?? 0));
  }

  void _onSeatsSelected(List<dynamic> seats) {
    setState(() {
      _selectedSeats.clear();
      for (final seat in seats) {
        final seatData = seat is Map<String, dynamic>
            ? seat
            : {'numeroPlace': seat.numeroPlace, 'prix': seat.prix ?? 0, 'typePlace': seat.typePlace};
        _selectedSeats.add({
          'prix': seatData['prix'] ?? 0,
          'numeroPlace': seatData['numeroPlace'],
          'typePlace': seatData['typePlace'],
        });
      }
    });
  }

  Future<void> _proceedToPayment() async {
    if (_selectedSeats.isEmpty) return;
    setState(() => _isProcessing = true);
    try {
      final authState = ref.read(authControllerProvider);
      final clientCode = authState.user?.codeUtilisateur;
      final apiClient = ApiClient();

      final List<String> ticketCodes = [];

      for (final seat in _selectedSeats) {
        final codeTicket = 'TKT-${widget.eventId}-${seat['numeroPlace']}-${DateTime.now().millisecondsSinceEpoch}';
        final ticketPayload = {
          'codeTicket': codeTicket,
          'prix': (seat['prix'] as num).toDouble(),
          'idEvenement': widget.eventId,
          'numeroPlace': seat['numeroPlace'],
        };
        await apiClient.post(ApiEndpoints.tickets.all, data: ticketPayload);
        ticketCodes.add(codeTicket);
      }

      final reservationPayload = {
        'dateReservation': DateTime.now().toIso8601String().substring(0, 19),
        'codeClient': clientCode,
        'codeTickets': ticketCodes,
      };
      final resResponse = await apiClient.post(ApiEndpoints.reservations.all, data: reservationPayload);
      final reservationId = resResponse['data']['idReservation'] as int;

      if (!mounted) return;
      context.pushReplacement(
        '/payment/$reservationId',
        extra: {
          'eventId': widget.eventId,
          'clientCode': clientCode,
          'tickets': _selectedSeats,
          'amount': _totalAmount,
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reservation failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(eventDetailProvider(widget.eventId));

    return Scaffold(
      appBar: AppBar(title: const Text('Select Seats')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? ErrorState(message: state.error!, onRetry: () => ref.read(eventDetailProvider(widget.eventId).notifier).loadDetail())
              : state.event == null
                  ? const Center(child: Text('Event not found'))
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.event!.titre,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.event_seat, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_selectedSeats.length} seat(s) selected',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '\$${_totalAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        Expanded(
                          child: state.availableSeats.isEmpty
                              ? const Center(child: Text('No seats available'))
                              : SingleChildScrollView(
                                  padding: const EdgeInsets.all(16),
                                  child: SeatPicker(
                                    seats: state.availableSeats,
                                    onSeatsSelected: _onSeatsSelected,
                                  ),
                                ),
                        ),
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: (_selectedSeats.isEmpty || _isProcessing)
                                    ? null
                                    : _proceedToPayment,
                                child: _isProcessing
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : Text(
                                        'Proceed to Payment (\$${_totalAmount.toStringAsFixed(2)})',
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
  );
}
}
