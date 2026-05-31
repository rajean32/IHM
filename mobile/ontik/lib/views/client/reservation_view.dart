import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

  void _proceedToPayment() {
    if (_selectedSeats.isEmpty) return;
    if (!mounted) return;
    context.push(
      '/payment/${widget.eventId}',
      extra: {
        'tickets': _selectedSeats,
        'amount': _totalAmount,
      },
    );
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
                onPressed: (_selectedSeats.isEmpty)
                    ? null
                    : _proceedToPayment,
                                child: Text(
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
