import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  String? _selectedBlockType;

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

  Set<String> get _blockTypes {
    return _availableSeats.map((s) => s.typePlace ?? 'STANDARD').toSet();
  }

  Color _blockColor(String type) {
    return AppConstants.placeTypeColors[type] ?? AppColors.textMuted;
  }

  String _blockLabel(String type) {
    return type.toUpperCase();
  }

  double _blockPrice(String type) {
    final seatsOfType = _availableSeats.where((s) => s.typePlace == type).toList();
    if (seatsOfType.isEmpty) return 0;
    final prices = seatsOfType.map((s) => s.prix ?? 0.0).toSet().toList()..sort();
    return prices.isNotEmpty ? prices.first : 0;
  }

  int _blockCount(String type) {
    return _availableSeats.where((s) => s.typePlace == type).length;
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

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    try {
      return DateFormat('d MMMM yyyy', 'fr').format(date).toUpperCase();
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Partager',
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorState(message: _error!, onRetry: _loadDetail)
              : _event == null
                  ? const Center(child: Text('Événement non trouvé'))
                  : Column(
                      children: [
                        _buildEventSummary(),
                        Expanded(child: _buildContent()),
                        _buildFooter(),
                      ],
                    ),
    );
  }

  Widget _buildEventSummary() {
    final event = _event!;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.titre,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  [event.lieuNom, event.lieuVille].where((s) => s != null && s.isNotEmpty).join(', '),
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _formatDate(event.dateEvenement),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isStandingOnly) return _buildStandingZones();
    if (_isMixed) return _buildMixedLayout();
    return _buildSeatedLayout();
  }

  Widget _buildSeatedLayout() {
    if (_availableSeats.isEmpty) {
      return const Center(child: Text('Aucune place disponible'));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        children: [
          _buildMapArea(),
          const SizedBox(height: 16),
          _buildLegend(),
          const SizedBox(height: 16),
          if (_selectedBlockType != null) _buildSeatPickerForBlock(),
        ],
      ),
    );
  }

  Widget _buildMapArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Stage indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.theater_comedy, size: 16, color: Colors.white70),
                SizedBox(width: 8),
                Text(
                  'SCÈNE / STAGE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Blocks grid
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: _blockTypes.map((type) => _buildBlock(type)).toList(),
          ),
          const SizedBox(height: 16),
          // Instruction
          Text(
            _selectedBlockType != null
                ? 'Sélectionnez vos places dans le bloc ${_blockLabel(_selectedBlockType!)}'
                : 'Sélectionnez un bloc pour voir les places disponibles',
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBlock(String type) {
    final isActive = _selectedBlockType == type;
    final color = _blockColor(type);
    final price = _blockPrice(type);
    final count = _blockCount(type);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBlockType = _selectedBlockType == type ? null : type;
          _selectedSeats.clear();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? color : AppColors.ticketBorder,
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: isActive
              ? [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2))]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              Icons.event_seat,
              size: 22,
              color: isActive ? Colors.white : color,
            ),
            const SizedBox(height: 4),
            Text(
              _blockLabel(type),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : color,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${count} places',
              style: TextStyle(
                fontSize: 9,
                color: isActive ? Colors.white70 : AppColors.textMuted,
              ),
            ),
            if (price > 0)
              Text(
                '${AppConstants.currency}${price.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : AppColors.textPrimary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _blockTypes.map((type) {
        final color = _blockColor(type);
        final price = _blockPrice(type);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 4),
              Text(
                '${_blockLabel(type)} (${AppConstants.currency}${price.toStringAsFixed(0)})',
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSeatPickerForBlock() {
    if (_availableSeats.isEmpty) {
      return const Center(child: Text('Aucune place disponible dans ce bloc'));
    }

    final filteredSeats = _selectedBlockType != null
        ? _availableSeats.where((s) => s.typePlace == _selectedBlockType).toList()
        : _availableSeats;

    if (filteredSeats.isEmpty) {
      return const Center(child: Text('Aucune place disponible dans ce bloc'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.visibility, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            const Text(
              'Vue depuis le bloc',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.ticketBorder),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: SeatPicker(
              seats: filteredSeats,
              onSeatsSelected: _onSeatsSelected,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStandingZones() {
    if (_standingZones.isEmpty) {
      return const Center(child: Text('Aucune zone debout disponible'));
    }
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ..._standingZones.map((zone) => _buildZoneCard(zone)),
      ],
    );
  }

  Widget _buildMixedLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_availableSeats.isNotEmpty) ...[
            _buildMapArea(),
            const SizedBox(height: 16),
            _buildLegend(),
            const SizedBox(height: 16),
            if (_selectedBlockType != null) _buildSeatPickerForBlock(),
            const Divider(height: 32),
          ],
          if (_standingZones.isNotEmpty) ...[
            const Text('Zones debout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            ..._standingZones.map((zone) => _buildZoneCard(zone)).toList(),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.ticketBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.accessibility_new, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(zone.nom, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    if (zone.capacite != null)
                      Text(
                        '$remaining place(s) restante(s) sur ${zone.capacite}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      )
                    else
                      const Text('Places illimitées', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Text(
                '${AppConstants.currency}${zone.prix.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ],
          ),
          if (zone.capacite != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: AppColors.surface,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress > 0.8 ? AppColors.error : AppColors.secondary,
                ),
              ),
            ),
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
                child: Text('$qty', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('PLACES SÉLECTIONNÉES', style: TextStyle(fontSize: 10, color: AppColors.textMuted, letterSpacing: 0.5)),
                  const SizedBox(height: 2),
                  Text(
                    '$_totalItems billet(s)',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'TOTAL ESTIMÉ  ${AppConstants.currency}${_totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: _hasSelection ? _proceedToPayment : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                child: Text(
                  'Confirmer la sélection',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _hasSelection ? Colors.white : Colors.white38,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
