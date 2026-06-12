import 'package:flutter/material.dart';
import '../../models/evenement_model.dart';
import '../../models/lieu_model.dart';
import '../../core/services/evenement_service.dart';
import '../../core/services/reservation_service.dart';
import '../../core/assets/app_colors.dart';
import '../../core/routes/client_routes.dart';
import '../../widgets/seat_picker.dart';
import '../../widgets/error_state.dart';
import '../../core/utils/error_helper.dart';
import '../../models/paiement_request_model.dart';

class ReservationPage extends StatefulWidget {
  final int eventId;
  const ReservationPage({super.key, required this.eventId});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  EventDetail? _event;
  List<SeatingPlace> _availableSeats = [];
  bool _isLoading = true;
  String? _error;
  final List<Map<String, dynamic>> _selectedSeats = [];

  double get _totalAmount {
    return _selectedSeats.fold(0.0, (sum, s) => sum + ((s['prix'] as num?)?.toDouble() ?? 0.0));
  }

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() => _isLoading = true);
    try {
      final _eventService = EvenementService();
      final _reservationService = ReservationService();
      final eventData = await _eventService.getEventDetail(widget.eventId);
      final seatsData = await _reservationService.getAvailablePlaces(widget.eventId);
      if (!mounted) return;
      setState(() {
        _event = EventDetail.fromJson(eventData);
        _availableSeats = seatsData.map((e) => SeatingPlace.fromJson(e as Map<String, dynamic>)).toList();
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = apiErrorString(e);
        _isLoading = false;
      });
    }
  }

  void _onSeatsSelected(List<SeatingPlace> seats) {
    setState(() {
      _selectedSeats.clear();
      for (final seat in seats) {
        _selectedSeats.add({
          'prix': seat.prix ?? 0.0,
          'numeroPlace': seat.numeroPlace,
          'typePlace': seat.typePlace,
        });
      }
    });
  }

  void _proceedToPayment() {
    if (_selectedSeats.isEmpty) return;
    if (!mounted) return;
    Navigator.pushNamed(
      context,
      ClientRoutes.payment,
      arguments: {
        'eventId': widget.eventId,
        'tickets': _selectedSeats,
        'amount': _totalAmount,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choisir les places')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorState(message: _error!, onRetry: _loadDetail)
              : _event == null
                  ? const Center(child: Text('Événement non trouvé'))
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _event!.titre,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.event_seat, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_selectedSeats.length} place(s) sélectionnée(s)',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Ar ${_totalAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.secondary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        Expanded(
                          child: _availableSeats.isEmpty
                              ? const Center(child: Text('Aucune place disponible'))
                              : Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: SeatPicker(
                                    seats: _availableSeats,
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
                                onPressed: (_selectedSeats.isEmpty) ? null : _proceedToPayment,
                                child: Text('Payer (Ar ${_totalAmount.toStringAsFixed(2)})'),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }
}
