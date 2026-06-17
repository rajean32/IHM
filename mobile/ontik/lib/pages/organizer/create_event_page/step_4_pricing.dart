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
  required bool loadingPlaces,
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
  final l10n = AppLocalizations.of(context)!;
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(l10n.stepPricing, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 4),
    Text(l10n.pricingDesc, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
    const SizedBox(height: 16),
    if (typePlacement == 'LIBRE') ...[
      ...placeTypes.map((t) => _buildPriceCard(t, typePlacement, typePriceCtrls, places, l10n)),
      if (standingZones.isNotEmpty) ...[
        const Divider(),
        Text(l10n.standingZonesLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
          child: Text(l10n.selectRoomFirstHint,
              style: TextStyle(color: AppTheme.textSecondary)),
        )
      else if (loadingPlaces)
        const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(strokeWidth: 2)))
      else if (places.isEmpty)
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Aucune place disponible dans cette salle', style: TextStyle(color: AppTheme.textSecondary)),
        )
      else ...[
        ...placeTypes.map((t) => _buildPriceCard(t, typePlacement, typePriceCtrls, places, l10n)),
        const SizedBox(height: 8),
        Text(l10n.seatPlanConfig, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        _buildRowSelector(places, selectedRows, onToggleRow, l10n),
        const SizedBox(height: 4),
        InkWell(
          onTap: () => onToggleGridExpanded(!gridExpanded),
          child: Row(children: [
            Icon(gridExpanded ? Icons.expand_less : Icons.expand_more, size: 18),
            Text(l10n.individualSeats, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.primaryColor)),
            const SizedBox(width: 8),
            Text(l10n.seatsSelectedCount('${selectedPlaceIds.length}'), style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
          ]),
        ),
        if (gridExpanded) ...[const SizedBox(height: 4), _buildSeatGrid(places, selectedPlaceIds, onTogglePlace, l10n)],
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: DropdownButtonFormField<String>(
            value: availableTypes.contains(assignType) ? assignType : null,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder(), isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
            items: availableTypes.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12)))).toList(),
            onChanged: (v) => onAssignTypeChanged(v!),
          )),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: selectedRows.isEmpty && selectedPlaceIds.isEmpty ? null : onAddPendingAssignment,
            child: Text(l10n.applyButton, style: const TextStyle(fontSize: 12)),
          ),
        ]),
        if (pendingRowAssignments.isNotEmpty || pendingPlaceAssignments.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.pending, size: 14, color: AppTheme.primaryColor),
                  const SizedBox(width: 4),
                  Text(l10n.pendingAssignments('${pendingRowAssignments.length + pendingPlaceAssignments.length}'),
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
                  const Spacer(),
                  GestureDetector(
                    onTap: onClearPendingAssignments,
                    child: Text(l10n.clearAll, style: TextStyle(fontSize: 10, color: AppTheme.errorColor)),
                  ),
                ]),
                ...pendingRowAssignments.entries.map((e) => Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(l10n.rowAssignmentText(e.key, e.value), style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                )),
                ...pendingPlaceAssignments.entries.map((e) => Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(l10n.seatAssignmentText(e.key, e.value), style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                )),
              ],
            ),
          ),
        ],
      ],
    ],
    if (typePlacement == 'MIXTE') ...[
      const Divider(),
      Text(l10n.standingZonesLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
                  Text(z['capacite'] != null ? l10n.zoneCapacityInfo('${z['capacite']}') : l10n.zoneCapacityUnlimited,
                      style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                ]),
              ),
              Text(l10n.zonePricePrefix((z['prix'] as num).toStringAsFixed(2)),
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(Icons.delete_outline, size: 18, color: AppTheme.errorColor),
                onPressed: () => onRemoveStandingZone(i),
              ),
            ]),
          ),
        );
      }),
    ],
  ]);
}

Widget _buildPriceCard(String type, String typePlacement,
    Map<String, TextEditingController> typePriceCtrls, List<EventPlaceConfig> places,
    AppLocalizations l10n) {
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
              Text(l10n.placesCountSuffix('$count'), style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ]),
        ),
        SizedBox(
          width: 100,
          child: TextField(
            controller: typePriceCtrls[type]!,
            decoration: InputDecoration(
              hintText: l10n.priceField, border: const OutlineInputBorder(), isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              prefixText: l10n.pricePrefix,
            ),
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ]),
    ),
  );
}

Widget _buildRowSelector(List<EventPlaceConfig> places, Set<String> selectedRows,
    ValueChanged<String> onToggleRow, AppLocalizations l10n) {
  final rangs = places.map((p) => p.range).whereType<String>().toSet().toList()..sort();
  if (rangs.isEmpty) return Text(l10n.noRowLabel, style: TextStyle(color: AppTheme.textSecondary));
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

Widget _buildSeatGrid(List<EventPlaceConfig> places, Set<String> selectedPlaceIds,
    ValueChanged<String> onTogglePlace, AppLocalizations l10n) {
  final rangs = places.map((p) => p.range).whereType<String>().toSet().toList()..sort();
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rangs.map((rang) {
    final rowPlaces = places.where((p) => p.range == rang).toList()
      ..sort((a, b) => a.numeroPlace.compareTo(b.numeroPlace));
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${l10n.rowPrefix} $rang', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
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
