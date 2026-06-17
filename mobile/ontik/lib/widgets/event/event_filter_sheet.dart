import 'package:flutter/material.dart';
import '../../models/lieu_model.dart';
import '../../core/assets/app_colors.dart';
import '../../generated/app_localizations.dart';

class EventFilterResult {
  final String? statut;
  final String? lieu;
  final DateTimeRange? dateRange;
  final double? prixMin;
  final double? prixMax;

  const EventFilterResult({this.statut, this.lieu, this.dateRange, this.prixMin, this.prixMax});

  bool get hasActiveFilters => statut != null || lieu != null || dateRange != null || prixMin != null || prixMax != null;
}

class EventFilterSheet extends StatefulWidget {
  final String? currentStatut;
  final String? currentLieu;
  final DateTimeRange? currentDateRange;
  final double? currentPrixMin;
  final double? currentPrixMax;
  final List<Lieu> lieux;
  final ValueChanged<EventFilterResult> onApply;

  const EventFilterSheet({
    super.key,
    this.currentStatut,
    this.currentLieu,
    this.currentDateRange,
    this.currentPrixMin,
    this.currentPrixMax,
    required this.lieux,
    required this.onApply,
  });

  static Future<void> show(BuildContext context, {
    required String? statut,
    required String? lieu,
    required DateTimeRange? dateRange,
    required double? prixMin,
    required double? prixMax,
    required List<Lieu> lieux,
    required ValueChanged<EventFilterResult> onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => EventFilterSheet(
        currentStatut: statut,
        currentLieu: lieu,
        currentDateRange: dateRange,
        currentPrixMin: prixMin,
        currentPrixMax: prixMax,
        lieux: lieux,
        onApply: onApply,
      ),
    );
  }

  @override
  State<EventFilterSheet> createState() => _EventFilterSheetState();
}

class _EventFilterSheetState extends State<EventFilterSheet> {
  String? _statut;
  String? _lieu;
  DateTimeRange? _dateRange;
  double? _prixMin;
  double? _prixMax;

  static const _statusOptions = ['Tous', 'planifie', 'en_cours', 'termine', 'annule'];

  @override
  void initState() {
    super.initState();
    _statut = widget.currentStatut;
    _lieu = widget.currentLieu;
    _dateRange = widget.currentDateRange;
    _prixMin = widget.currentPrixMin;
    _prixMax = widget.currentPrixMax;
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (ctx, setSheetState) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(AppLocalizations.of(context)!.clientHomeFilters, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => setSheetState(() { _statut = null; _lieu = null; _dateRange = null; _prixMin = null; _prixMax = null; }),
                child: Text(AppLocalizations.of(context)!.clientHomeReset),
              ),
            ]),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.clientHomeStatus, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _statut,
              decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
              items: _statusOptions.map((s) => DropdownMenuItem(value: s == 'Tous' ? null : s, child: Text(s))).toList(),
              onChanged: (v) => setSheetState(() => _statut = v),
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.clientHomeVenue, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _lieu,
              decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
              items: [
                DropdownMenuItem<String>(value: null, child: Text(AppLocalizations.of(context)!.clientHomeAllVenues)),
                ...widget.lieux.map((l) => DropdownMenuItem(value: l.code, child: Text(l.nomLieu))),
              ],
              onChanged: (v) => setSheetState(() => _lieu = v),
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.clientHomeDateRange, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final range = await showDateRangePicker(
                  context: ctx, firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  initialDateRange: _dateRange,
                );
                if (range != null) setSheetState(() => _dateRange = range);
              },
              child: InputDecorator(
                decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                child: Text(
                  _dateRange != null
                      ? '${_dateRange!.start.toIso8601String().split('T').first} \u2014 ${_dateRange!.end.toIso8601String().split('T').first}'
                      : AppLocalizations.of(context)!.clientHomeSelectDateRange,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.clientHomePriceRange, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.clientHomeMin, border: const OutlineInputBorder(), isDense: true),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => _prixMin = double.tryParse(v),
                ),
              ),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('\u2014')),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.clientHomeMax, border: const OutlineInputBorder(), isDense: true),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => _prixMax = double.tryParse(v),
                ),
              ),
            ]),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                widget.onApply(EventFilterResult(
                  statut: _statut, lieu: _lieu, dateRange: _dateRange,
                  prixMin: _prixMin, prixMax: _prixMax,
                ));
              },
              child: Text(AppLocalizations.of(context)!.clientHomeApply),
            ),
          ]),
        ),
      ),
    );
  }
}
