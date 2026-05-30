import 'package:flutter/material.dart';
import '../models/venue.dart';

const _seatAvailableStatuses = {'DISPONIBLE', null};

class SeatPicker extends StatefulWidget {
  final List<SeatingPlace> seats;
  final Function(List<SeatingPlace>) onSeatsSelected;
  final Map<String, double>? categoryPrices;

  const SeatPicker({
    super.key,
    required this.seats,
    required this.onSeatsSelected,
    this.categoryPrices,
  });

  @override
  State<SeatPicker> createState() => _SeatPickerState();
}

class _SeatPickerState extends State<SeatPicker> {
  final Set<String> _selectedSeats = {};
  String? _selectedCategory;

  List<SeatingPlace> get _filteredSeats {
    if (_selectedCategory == null) return widget.seats;
    return widget.seats.where((s) => s.typePlace == _selectedCategory).toList();
  }

  Set<String> get _availableCategories {
    return widget.seats.where((s) => s.typePlace != null).map((s) => s.typePlace!).toSet();
  }

  bool _isSeatAvailable(SeatingPlace seat) {
    return seat.disponible && _seatAvailableStatuses.contains(seat.statut);
  }

  void _toggleSeat(SeatingPlace seat) {
    if (!_isSeatAvailable(seat)) return;
    setState(() {
      if (_selectedSeats.contains(seat.numeroPlace)) {
        _selectedSeats.remove(seat.numeroPlace);
      } else {
        _selectedSeats.add(seat.numeroPlace);
      }
    });
    widget.onSeatsSelected(
      widget.seats
          .where((s) => _selectedSeats.contains(s.numeroPlace))
          .toList(),
    );
  }

  Map<String, List<SeatingPlace>> _groupByRang(List<SeatingPlace> seats) {
    final Map<String, List<SeatingPlace>> groups = {};
    for (final seat in seats) {
      final rang = seat.rang ?? 'Unknown';
      groups.putIfAbsent(rang, () => []).add(seat);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final categories = _availableCategories;
    final groups = _groupByRang(_filteredSeats);
    return Column(
      children: [
        _buildLegend(),
        if (categories.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildCategoryFilter(categories),
        ],
        const SizedBox(height: 16),
        _buildSeatCountAndTotal(),
        const SizedBox(height: 12),
        if (groups.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('No seats available for this category',
                style: TextStyle(color: Colors.grey)),
          )
        else
          ...groups.entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    alignment: Alignment.center,
                    child: Text(
                      e.key,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: e.value.map((s) => _buildSeatTile(s)).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryFilter(Set<String> categories) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('All'),
              selected: _selectedCategory == null,
              onSelected: (_) => setState(() => _selectedCategory = null),
            ),
          ),
          ...categories.map((cat) {
            final price = widget.categoryPrices?[cat];
            final label = price != null ? '$cat (\$${price.toStringAsFixed(0)})' : cat;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(label, style: const TextStyle(fontSize: 12)),
                selected: _selectedCategory == cat,
                onSelected: (_) => setState(() => _selectedCategory = cat),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSeatCountAndTotal() {
    if (_selectedSeats.isEmpty) return const SizedBox.shrink();
    double total = 0;
    for (final seat in widget.seats) {
      if (_selectedSeats.contains(seat.numeroPlace) && seat.prix != null) {
        total += seat.prix!;
      }
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.confirmation_number, size: 20, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            '${_selectedSeats.length} seat(s) selected',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          if (total > 0) ...[
            const SizedBox(width: 16),
            Text(
              'Total: \$${total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                fontSize: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSeatTile(SeatingPlace seat) {
    final isSelected = _selectedSeats.contains(seat.numeroPlace);
    final isAvailable = _isSeatAvailable(seat);
    final isPending = seat.statut == 'EN_ATTENTE';
    return GestureDetector(
      onTap: () => _toggleSeat(seat),
      child: Tooltip(
        message:
            '${seat.numeroPlace}${seat.prix != null ? ' - \$${seat.prix!.toStringAsFixed(0)}' : ''}${seat.typePlace != null ? ' (${seat.typePlace})' : ''}${seat.statut != null ? ' [${seat.statut}]' : ''}',
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.blue
                : isAvailable
                    ? Colors.green.shade200
                    : isPending
                        ? Colors.orange.shade200
                        : Colors.red.shade200,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected ? Colors.blue.shade700 : Colors.grey,
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            seat.numeroPlace.replaceAll(RegExp(r'[^0-9]'), ''),
            style: TextStyle(
              color: isAvailable || isSelected ? Colors.white : Colors.grey,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(Colors.green.shade200, 'Available'),
        const SizedBox(width: 12),
        _legendItem(Colors.blue, 'Selected'),
        const SizedBox(width: 12),
        _legendItem(Colors.orange.shade200, 'Pending'),
        const SizedBox(width: 12),
        _legendItem(Colors.red.shade200, 'Taken'),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: Colors.grey, width: 1),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
