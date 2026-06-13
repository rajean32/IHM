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

class ReservationPage extends StatefulWidget {
  final int eventId;
  const ReservationPage({super.key, required this.eventId});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  EventDetail? _event;
  List<SeatingPlace> _availableSeats = [];
  List<StandingZone> _standingZones = [];
  bool _isLoading = true;
  String? _error;
  final List<Map<String, dynamic>> _selectedSeats = [];
  final Map<int, int> _zoneQuantities = {};

  double get _totalAmount {
    final seatTotal = _selectedSeats.fold(0.0, (sum, s) => sum + ((s['prix'] as num?)?.toDouble() ?? 0.0));
    final zoneTotal = _standingZones.fold(0.0, (sum, z) {
      final qty = _zoneQuantities[z.idZone] ?? 0;
      return sum + (z.prix * qty);
    });
    return seatTotal + zoneTotal;
  }

  bool get _isStandingOnly => _event?.typeAgencement == 'DEBOUT_AVEC_LIMITE' || _event?.typeAgencement == 'DEBOUT_SANS_LIMITE';
  bool get _isMixed => _event?.typeAgencement == 'ASSIS_DEBOUT';
  bool get _isSeated => _event?.typeAgencement == null || _event?.typeAgencement == 'UNIQUEMENT_ASSIS' || _event?.typeAgencement == 'TABLE_ASSIS';

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
      final event = EventDetail.fromJson(eventData);

      List<SeatingPlace> seats = [];
      List<StandingZone> zones = [];

      if (event.typeAgencement != 'DEBOUT_AVEC_LIMITE' && event.typeAgencement != 'DEBOUT_SANS_LIMITE') {
        final seatsData = await _reservationService.getAvailablePlaces(widget.eventId);
        seats = seatsData.map((e) => SeatingPlace.fromJson(e as Map<String, dynamic>)).toList();
      }

      if (event.typeAgencement == 'ASSIS_DEBOUT' || event.typeAgencement == 'DEBOUT_AVEC_LIMITE' || event.typeAgencement == 'DEBOUT_SANS_LIMITE') {
        final zonesData = await _eventService.getStandingZones(widget.eventId);
        zones = zonesData.map((e) => StandingZone.fromJson(e as Map<String, dynamic>)).toList();
      }

      if (!mounted) return;
      setState(() {
        _event = event;
        _availableSeats = seats;
        _standingZones = zones;
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

  void _onZoneQuantityChanged(int zoneId, int delta) {
    setState(() {
      final current = _zoneQuantities[zoneId] ?? 0;
      final next = current + delta;
      if (next < 0) return;
      final zone = _standingZones.firstWhere((z) => z.idZone == zoneId);
      if (zone.capacite != null && next > (zone.placesDisponibles ?? 0)) return;
      if (next == 0) {
        _zoneQuantities.remove(zoneId);
      } else {
        _zoneQuantities[zoneId] = next;
      }
    });
  }

  bool get _hasSelection {
    if (_isSeated) return _selectedSeats.isNotEmpty;
    if (_isStandingOnly) return _zoneQuantities.values.any((q) => q > 0);
    return _selectedSeats.isNotEmpty || _zoneQuantities.values.any((q) => q > 0);
  }

  int get _totalItems {
    int count = _selectedSeats.length;
    for (final qty in _zoneQuantities.values) {
      count += qty;
    }
    return count;
  }

  void _proceedToPayment() {
    if (!_hasSelection) return;
    if (!mounted) return;

    final ticketItems = <Map<String, dynamic>>[];
    for (final seat in _selectedSeats) {
      ticketItems.add({
        'prix': seat['prix'],
        'numeroPlace': seat['numeroPlace'],
        'typePlace': seat['typePlace'],
      });
    }
    for (final entry in _zoneQuantities.entries) {
      final zone = _standingZones.firstWhere((z) => z.idZone == entry.key);
      for (int i = 0; i < entry.value; i++) {
        ticketItems.add({
          'prix': zone.prix,
          'numeroPlace': zone.nom,
          'idZone': zone.idZone,
        });
      }
    }

    Navigator.pushNamed(
      context,
      ClientRoutes.payment,
      arguments: {
        'eventId': widget.eventId,
        'tickets': ticketItems,
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
                                    '$_totalItems place(s) sélectionnée(s)',
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
                          child: _isStandingOnly
                              ? _buildStandingZones()
                              : _isMixed
                                  ? _buildMixedLayout()
                                  : _buildSeatPicker(),
                        ),
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _hasSelection ? _proceedToPayment : null,
                                child: Text('Payer (Ar ${_totalAmount.toStringAsFixed(2)})'),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildSeatPicker() {
    if (_availableSeats.isEmpty) {
      return const Center(child: Text('Aucune place assise disponible'));
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SeatPicker(
        seats: _availableSeats,
        onSeatsSelected: _onSeatsSelected,
      ),
    );
  }

  Widget _buildStandingZones() {
    if (_standingZones.isEmpty) {
      return const Center(child: Text('Aucune zone debout disponible'));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _standingZones.map((zone) => _buildZoneCard(zone)).toList(),
    );
  }

  Widget _buildMixedLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_availableSeats.isNotEmpty) ...[
            const Text('Places assises', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: SeatPicker(
                seats: _availableSeats,
                onSeatsSelected: _onSeatsSelected,
              ),
            ),
            const Divider(height: 24),
          ],
          if (_standingZones.isNotEmpty) ...[
            const Text('Zones debout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._standingZones.map((zone) => _buildZoneCard(zone)),
          ],
        ],
      ),
    );
  }

  Widget _buildZoneCard(StandingZone zone) {
    final qty = _zoneQuantities[zone.idZone] ?? 0;
    final remaining = zone.capacite != null ? (zone.placesDisponibles ?? 0) - qty : null;
    final progress = zone.capacite != null && zone.capacite! > 0
        ? ((zone.capacite! - (remaining ?? 0)) / zone.capacite!)
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.accessibility_new, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(zone.nom, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                Text('Ar ${zone.prix.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.secondary)),
              ],
            ),
            if (zone.capacite != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.surface,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress > 0.8 ? AppColors.error : AppColors.secondary,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$remaining place(s) restante(s) sur ${zone.capacite}',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ] else ...[
              const SizedBox(height: 4),
              Text('Places illimitées', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: qty > 0 ? () => _onZoneQuantityChanged(zone.idZone!, -1) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  color: AppColors.primary,
                ),
                Container(
                  width: 36,
                  alignment: Alignment.center,
                  child: Text('$qty', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  onPressed: () => _onZoneQuantityChanged(zone.idZone!, 1),
                  icon: const Icon(Icons.add_circle_outline),
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
