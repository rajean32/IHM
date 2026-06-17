import 'package:flutter/material.dart';
import '../../../models/event_place_config_model.dart';
import '../../../core/assets/app_colors.dart';
import '../../../generated/app_localizations.dart';

Widget buildStep4({
  required BuildContext context,
  required String typePlacement,
  required List<String> placeTypes,
  required Map<String, TextEditingController> typePriceCtrls,
  required List<Map<String, dynamic>> standingZones,
  required String? selectedSalle,
  required List<EventPlaceConfig> places,
  required Set<String> selectedRows,
  required Set<String> selectedPlaceIds,
  required String assignType,
  required List<String> availableTypes,
  required bool gridExpanded,
  required Map<String, String> pendingRowAssignments,
  required Map<String, String> pendingPlaceAssignments,
  required ValueChanged<String> onAssignTypeChanged,
  required VoidCallback onAddPendingAssignment,
  required VoidCallback onClearPendingAssignments,
  required ValueChanged<String> onToggleRow,
  required ValueChanged<String> onTogglePlace,
  required ValueChanged<bool> onToggleGridExpanded,
  required ValueChanged<int> onRemoveStandingZone,
  required VoidCallback onRefresh,
}) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(AppLocalizations.of(context)!.stepPricing, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 4),
    Text(AppLocalizations.of(context)!.pricingDesc,
        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
    const SizedBox(height: 16),
    if (typePlacement == 'LIBRE') ...[
      ...placeTypes.map((t) => _buildPriceCard(context, t, typePlacement, typePriceCtrls, places)),
      if (standingZones.isNotEmpty) ...[
        const Divider(),
        Text(AppLocalizations.of(context)!.standingZonesLabel, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...standingZones.map((z) => Card(
          margin: const EdgeInsets.only(bottom: 6),
          child: ListTile(
            dense: true,
            title: Text(z['nom'] as String),
            trailing: Text('Ar ${(z['prix'] as num).toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        )),
      ],
    ],
    if (typePlacement == 'NUMEROTE' || typePlacement == 'MIXTE') ...[
      if (selectedSalle == null)
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(AppLocalizations.of(context)!.selectRoomFirstHint,
              style: TextStyle(color: AppTheme.textSecondary)),
        )
      else ...[
        ...placeTypes.map((t) => _buildPriceCard(context, t, typePlacement, typePriceCtrls, places)),
        const SizedBox(height: 8),
        if (places.isNotEmpty) ...[
          Text(AppLocalizations.of(context)!.seatPlanConfig, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          _buildRowSelector(context, places, selectedRows, onToggleRow),
          const SizedBox(height: 4),
          InkWell(
            onTap: () => onToggleGridExpanded(!gridExpanded),
            child: Row(children: [
              Icon(gridExpanded ? Icons.expand_less : Icons.expand_more, size: 18),
              Text(AppLocalizations.of(context)!.individualSeats, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.primaryColor)),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.seatsSelectedCount('${selectedPlaceIds.length}'), style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
            ]),
          ),
          if (gridExpanded) ...[const SizedBox(height: 4), _buildSeatGrid(context, places, selectedPlaceIds, onTogglePlace)],
          const SizedBox(height: 8),
          Builder(builder: (context) {
            return SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: selectedRows.isEmpty && selectedPlaceIds.isEmpty
                    ? null
                    : () => _showAssignBottomSheet(context, availableTypes, assignType, onAssignTypeChanged, onAddPendingAssignment),
                icon: const Icon(Icons.sell_outlined, size: 18),
                label: Text(AppLocalizations.of(context)!.assignTariff),
              ),
            );
          }),
          if (pendingRowAssignments.isNotEmpty || pendingPlaceAssignments.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.pending, size: 16, color: AppTheme.primaryColor),
                    const SizedBox(width: 6),
                    Text(AppLocalizations.of(context)!.pendingAssignments('${pendingRowAssignments.length + pendingPlaceAssignments.length}'),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
                    const Spacer(),
                    GestureDetector(
                      onTap: onClearPendingAssignments,
                      child: Text(AppLocalizations.of(context)!.clearAll, style: TextStyle(fontSize: 11, color: AppTheme.errorColor)),
                    ),
                  ]),
                  const SizedBox(height: 6),
                  ...pendingRowAssignments.entries.map((e) => Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(AppLocalizations.of(context)!.rowAssignmentText(e.key, e.value), style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                  )),
                  ...pendingPlaceAssignments.entries.map((e) => Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(AppLocalizations.of(context)!.seatAssignmentText(e.key, e.value), style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                  )),
                ],
              ),
            ),
          ],
        ],
      ],
    ],
    if (typePlacement == 'MIXTE') ...[
      const Divider(),
      Text(AppLocalizations.of(context)!.standingZonesLabel, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      ...standingZones.asMap().entries.map((entry) {
        final i = entry.key;
        final z = entry.value;
        return Card(
          margin: const EdgeInsets.only(bottom: 6),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(z['nom'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(z['capacite'] != null ? AppLocalizations.of(context)!.zoneCapacityInfo('${z['capacite']}') : AppLocalizations.of(context)!.zoneCapacityUnlimited,
                      style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                ]),
              ),
            Text(AppLocalizations.of(context)!.zonePricePrefix((z['prix'] as num).toStringAsFixed(2)),
                style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                onPressed: () => onRemoveStandingZone(i),
              ),
            ]),
          ),
        );
      }),
    ],
  ]);
}

Widget _buildPriceCard(BuildContext context, String type, String typePlacement,
    Map<String, TextEditingController> typePriceCtrls, List<EventPlaceConfig> places) {
  typePriceCtrls.putIfAbsent(type, () => TextEditingController());
  final count = places.where((p) => (p.typePlace ?? 'Standard') == type).length;
  return Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(type, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            if (typePlacement != 'LIBRE')
              Text(AppLocalizations.of(context)!.placesCountSuffix('$count'), style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ]),
        ),
        SizedBox(
          width: 100,
          child: TextField(
            controller: typePriceCtrls[type]!,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.priceField, border: OutlineInputBorder(), isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                prefixText: AppLocalizations.of(context)!.pricePrefix,
              ),
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ]),
    ),
  );
}

Widget _buildRowSelector(BuildContext context, List<EventPlaceConfig> places, Set<String> selectedRows,
    ValueChanged<String> onToggleRow) {
  final rangs = places.map((p) => p.range).whereType<String>().toSet().toList()..sort();
  if (rangs.isEmpty) return Text(AppLocalizations.of(context)!.noRowLabel, style: TextStyle(color: AppTheme.textSecondary));
  return Wrap(spacing: 6, runSpacing: 4, children: rangs.map((rang) {
    final selected = selectedRows.contains(rang);
    final count = places.where((p) => p.range == rang).length;
    return FilterChip(
      label: Text('$rang ($count)', style: TextStyle(fontSize: 11, color: selected ? Colors.white : null)),
      selected: selected,
      onSelected: (v) => onToggleRow(rang),
    );
  }).toList());
}

Widget _buildSeatGrid(BuildContext context, List<EventPlaceConfig> places, Set<String> selectedPlaceIds,
    ValueChanged<String> onTogglePlace) {
  final rangs = places.map((p) => p.range).whereType<String>().toSet().toList()..sort();
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rangs.map((rang) {
    final rowPlaces = places.where((p) => p.range == rang).toList()
      ..sort((a, b) => a.numeroPlace.compareTo(b.numeroPlace));
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${AppLocalizations.of(context)!.rowPrefix} $rang', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
        const SizedBox(height: 2),
        Wrap(spacing: 3, runSpacing: 3, children: rowPlaces.map((p) {
          final selected = selectedPlaceIds.contains(p.numeroPlace);
          return GestureDetector(
            onTap: () => onTogglePlace(p.numeroPlace),
            child: Container(
              width: 34, height: 26,
              decoration: BoxDecoration(
                color: selected ? AppTheme.primaryColor.withValues(alpha: 0.3) : AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: selected ? AppTheme.primaryColor : AppTheme.dividerColor, width: selected ? 2 : 0.5),
              ),
              child: Center(child: Text(p.numeroPlace.replaceAll(rang, ''),
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: selected ? AppTheme.primaryColor : AppTheme.textSecondary))),
            ),
          );
        }).toList()),
      ]),
    );
  }).toList());
}

void _showAssignBottomSheet(BuildContext context, List<String> availableTypes,
    String currentAssignType, ValueChanged<String> onAssignTypeChanged, VoidCallback onAddPendingAssignment) {
  String selectedType = availableTypes.contains(currentAssignType) ? currentAssignType : (availableTypes.firstOrNull ?? '');
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) {
      return StatefulBuilder(builder: (context, setSheetState) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                const Icon(Icons.sell_outlined, size: 20),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.tariffTypeTitle, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                  visualDensity: VisualDensity.compact,
                ),
              ]),
              const SizedBox(height: 16),
              if (availableTypes.isEmpty)
                Text(AppLocalizations.of(context)!.noTypesWithPrice, style: TextStyle(fontSize: 14, color: AppTheme.textSecondary))
              else
                ...availableTypes.map((t) => RadioListTile<String>(
                  title: Text(t),
                  value: t,
                  groupValue: selectedType,
                  onChanged: (v) => setSheetState(() => selectedType = v!),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  activeColor: Theme.of(context).colorScheme.primary,
                )),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: availableTypes.isEmpty ? null : () {
                  onAssignTypeChanged(selectedType);
                  onAddPendingAssignment();
                  Navigator.pop(ctx);
                },
                child: Text(AppLocalizations.of(context)!.applyTariff),
              ),
            ],
          ),
        );
      });
    },
  );
}
