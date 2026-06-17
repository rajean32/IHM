import 'package:flutter/material.dart';

class SeatMapPlace {
  final int id;
  final String rang;
  final String numero;
  final String typePlace;
  final bool disponible;
  final bool reservee;

  const SeatMapPlace({
    required this.id,
    required this.rang,
    required this.numero,
    this.typePlace = 'STANDARD',
    this.disponible = true,
    this.reservee = false,
  });
}

enum _SeatState { available, selected, occupied }

Color _seatColor(_SeatState state, String typePlace) {
  if (state == _SeatState.selected) return const Color(0xFF1565C0);
  if (state == _SeatState.occupied) return const Color(0xFFBDBDBD);
  switch (typePlace.toUpperCase()) {
    case 'VIP':
      return const Color(0xFFFFD700);
    case 'PREMIUM':
      return const Color(0xFF9C27B0);
    case 'PMR':
      return const Color(0xFF009688);
    default:
      return const Color(0xFFC8E6C9);
  }
}

IconData _seatIcon(_SeatState state, String typePlace) {
  if (state == _SeatState.occupied) return Icons.lock;
  if (state == _SeatState.selected) return Icons.check;
  if (typePlace.toUpperCase() == 'PMR') return Icons.accessible;
  if (typePlace.toUpperCase() == 'VIP') return Icons.star;
  return Icons.event_seat;
}

Color _seatIconColor(_SeatState state, String typePlace) {
  if (state == _SeatState.selected) return Colors.white;
  if (state == _SeatState.occupied) return const Color(0xFF757575);
  switch (typePlace.toUpperCase()) {
    case 'PMR':
      return Colors.white;
    case 'VIP':
      return const Color(0xFF5D4037);
    default:
      return const Color(0xFF2E7D32);
  }
}

String? _seatBadge(String typePlace) {
  switch (typePlace.toUpperCase()) {
    case 'VIP':
      return 'VIP';
    case 'PREMIUM':
      return 'PREM';
    default:
      return null;
  }
}

String _semanticsLabel(SeatMapPlace place, _SeatState state) {
  final status = switch (state) {
    _SeatState.selected => 'sélectionnée',
    _SeatState.occupied => 'occupée',
    _SeatState.available => 'disponible',
  };
  return 'Place ${place.numero} $status';
}

class SeatMapWidget extends StatelessWidget {
  final List<SeatMapPlace> places;
  final Set<int> selectedPlaceIds;
  final ValueChanged<int> onPlaceTapped;

  const SeatMapWidget({
    super.key,
    required this.places,
    required this.selectedPlaceIds,
    required this.onPlaceTapped,
  });

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<SeatMapPlace>>{};
    for (final p in places) {
      grouped.putIfAbsent(p.rang, () => []);
      grouped[p.rang]!.add(p);
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) {
      final an = int.tryParse(a.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      final bn = int.tryParse(b.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      if (an != bn) return an.compareTo(bn);
      return a.compareTo(b);
    });
    for (final key in sortedKeys) {
      final seats = grouped[key]!;
      seats.sort((a, b) {
        final an = int.tryParse(a.numero.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final bn = int.tryParse(b.numero.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return an.compareTo(bn);
      });
    }

    return Column(
      children: [
        _buildLegend(context),
        const SizedBox(height: 12),
        Expanded(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            panEnabled: true,
            scaleEnabled: true,
            boundaryMargin: const EdgeInsets.all(40),
            constrained: false,
            child: _buildSeatGrid(context, sortedKeys, grouped),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _legendItem(context, _seatColor(_SeatState.available, 'STANDARD'), 'Disponible'),
          const SizedBox(width: 10),
          _legendItem(context, _seatColor(_SeatState.selected, ''), 'Sélectionnée'),
          const SizedBox(width: 10),
          _legendItem(context, _seatColor(_SeatState.occupied, ''), 'Occupée'),
          const SizedBox(width: 10),
          _legendItem(context, _seatColor(_SeatState.available, 'VIP'), 'VIP'),
          const SizedBox(width: 10),
          _legendItem(context, _seatColor(_SeatState.available, 'PREMIUM'), 'Premium'),
          const SizedBox(width: 10),
          _legendItem(context, _seatColor(_SeatState.available, 'PMR'), 'PMR'),
        ],
      ),
    );
  }

  Widget _legendItem(BuildContext context, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildSeatGrid(
    BuildContext context,
    List<String> sortedKeys,
    Map<String, List<SeatMapPlace>> grouped,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStage(context),
        const SizedBox(height: 20),
        ...sortedKeys.map((row) => _buildRow(context, row, grouped[row]!)),
      ],
    );
  }

  Widget _buildStage(BuildContext context) {
    return Center(
      child: Container(
        height: 50,
        width: 240,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: const Text(
          'SCÈNE',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
          ),
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, String rowLabel, List<SeatMapPlace> rowSeats) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            child: Text(
              rowLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 4),
          ...rowSeats.map((place) => _buildSeat(context, place)),
        ],
      ),
    );
  }

  Widget _buildSeat(BuildContext context, SeatMapPlace place) {
    final isSelected = selectedPlaceIds.contains(place.id);
    final isOccupied = place.reservee || !place.disponible;
    final state = isSelected
        ? _SeatState.selected
        : isOccupied
            ? _SeatState.occupied
            : _SeatState.available;
    final color = _seatColor(state, place.typePlace);
    final icon = _seatIcon(state, place.typePlace);
    final badge = _seatBadge(place.typePlace);

    return Padding(
      padding: const EdgeInsets.all(2),
      key: ValueKey('seat_${place.id}'),
      child: Semantics(
        label: _semanticsLabel(place, state),
        button: true,
        enabled: !isOccupied,
        child: GestureDetector(
          onTap: isOccupied ? null : () => onPlaceTapped(place.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
              border: isSelected
                  ? Border.all(color: const Color(0xFF1565C0), width: 2)
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (icon != null)
                  Icon(icon, size: 18, color: _seatIconColor(state, place.typePlace)),
                if (badge != null)
                  Positioned(
                    top: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
