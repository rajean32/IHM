import 'package:flutter/material.dart';
import '../models/lieu_model.dart';
import '../core/assets/app_colors.dart';
import '../localization/app_localizations.dart';

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

  Set<String> get _categories {
    return widget.seats.map((s) => s.typePlace ?? 'Standard').toSet();
  }

  @override
  void initState() {
    super.initState();
    final cats = _categories.toList()..sort();
    if (cats.isNotEmpty) _selectedCategory = cats.first;
  }

  void _toggleSeat(SeatingPlace seat) {
    if (!_seatAvailableStatuses.contains(seat.statut)) return;
    setState(() {
      if (_selectedSeats.contains(seat.numeroPlace)) {
        _selectedSeats.remove(seat.numeroPlace);
      } else {
        _selectedSeats.add(seat.numeroPlace);
      }
      widget.onSeatsSelected(
        widget.seats.where((s) => _selectedSeats.contains(s.numeroPlace)).toList(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final cats = _categories.toList()..sort();
    final grouped = <String, List<SeatingPlace>>{};
    for (final s in _filteredSeats) {
      final key = s.rang ?? '?';
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(s);
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) {
      final an = int.tryParse(a.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      final bn = int.tryParse(b.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return an.compareTo(bn);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (cats.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                ...cats.map((cat) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(cat, style: TextStyle(fontSize: 11, color: _selectedCategory == cat ? Colors.white : null)),
                    selected: _selectedCategory == cat,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                    visualDensity: VisualDensity.compact,
                  ),
                )),
              ]),
            ),
          ),
        Expanded(
          child: ListView(
            children: sortedKeys.map((row) {
              final seats = grouped[row]!;
              seats.sort((a, b) => a.numeroPlace.compareTo(b.numeroPlace));
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${tr('widgets.seat_picker.row')} $row', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Wrap(spacing: 4, runSpacing: 4, children: seats.map((seat) {
                      final avail = _seatAvailableStatuses.contains(seat.statut);
                      final sel = _selectedSeats.contains(seat.numeroPlace);
                      final color = AppConstants.placeTypeColors[seat.typePlace] ?? AppColors.primary;
                      return GestureDetector(
                        onTap: avail ? () => _toggleSeat(seat) : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 34,
                          height: 28,
                          decoration: BoxDecoration(
                            color: sel ? color : (avail ? color.withValues(alpha: 0.12) : AppColors.textSecondary.withValues(alpha: 0.12)),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: sel ? color : (avail ? color.withValues(alpha: 0.3) : AppColors.textSecondary.withValues(alpha: 0.25)),
                              width: sel ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              seat.numeroPlace.replaceAll(RegExp(r'^[A-Z]*'), ''),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: sel ? Colors.white : (avail ? color : AppColors.textSecondary),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList()),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
