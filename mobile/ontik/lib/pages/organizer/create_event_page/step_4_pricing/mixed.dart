import 'package:flutter/material.dart';
import '../../../../models/event_place_config_model.dart';
import '../../../../core/assets/app_colors.dart';
import '../../../../generated/app_localizations.dart';
import '../../../../core/utils/place_utils.dart';

Widget buildStep4PricingMixed({
  required BuildContext context,
  required List<String> placeTypes,
  required Map<String, TextEditingController> typePriceCtrls,
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
  required List<Map<String, dynamic>> standingZones,
  required List<TextEditingController> zonePriceCtrls,
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
    if (selectedSalle == null)
      Padding(padding: const EdgeInsets.all(16), child: Text(l10n.selectRoomFirstHint, style: TextStyle(color: AppTheme.textSecondary)))
    else if (loadingPlaces)
      const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(strokeWidth: 2)))
    else if (places.isEmpty && standingZones.isEmpty)
      Padding(padding: const EdgeInsets.all(16), child: Text('Aucune place disponible dans cette salle', style: TextStyle(color: AppTheme.textSecondary)))
    else ...[
      Text('Section assise', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      _typePricingSection(placeTypes, typePriceCtrls, places, l10n),
      const SizedBox(height: 12),
      if (places.isNotEmpty) ...[
        _seatPreview(places, typePriceCtrls, pendingRowAssignments, pendingPlaceAssignments, l10n),
        const SizedBox(height: 12),
        Text(l10n.seatPlanConfig, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        _rowSelector(places, selectedRows, onToggleRow, l10n),
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
        if (gridExpanded) ...[const SizedBox(height: 4), _seatGrid(places, selectedPlaceIds, pendingRowAssignments, pendingPlaceAssignments, onTogglePlace, l10n)],
        const SizedBox(height: 8),
        _assignmentControls(
          availableTypes, assignType, selectedRows, selectedPlaceIds,
          pendingRowAssignments, pendingPlaceAssignments,
          onAssignTypeChanged, onAddPendingAssignment, onClearPendingAssignments, l10n,
        ),
      ],
      const Divider(),
      Text(l10n.standingZonesLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text(l10n.pricingDesc, style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      const SizedBox(height: 8),
      ...standingZones.asMap().entries.map((entry) {
        final i = entry.key;
        final z = entry.value;
        final ctrl = i < zonePriceCtrls.length ? zonePriceCtrls[i] : null;
        return Card(
          margin: const EdgeInsets.only(bottom: 6),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Container(
                width: 4, height: 40,
                decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(z['nom'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(z['capacite'] != null ? l10n.zoneCapacityInfo('${z['capacite']}') : l10n.zoneCapacityUnlimited,
                    style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              ])),
              SizedBox(
                width: 90,
                child: TextField(
                  controller: ctrl,
                  decoration: InputDecoration(
                    hintText: l10n.priceField, border: const OutlineInputBorder(), isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    prefixText: l10n.pricePrefix,
                  ),
                  keyboardType: TextInputType.number, style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(icon: Icon(Icons.delete_outline, size: 18, color: AppTheme.errorColor), onPressed: () => onRemoveStandingZone(i)),
            ]),
          ),
        );
      }),
    ],
  ]);
}

Widget _typePricingSection(List<String> placeTypes, Map<String, TextEditingController> typePriceCtrls,
    List<EventPlaceConfig> places, AppLocalizations l10n) {
  return Column(children: placeTypes.map((t) => _priceCard(t, typePriceCtrls, places, l10n)).toList());
}

Widget _priceCard(String type, Map<String, TextEditingController> typePriceCtrls,
    List<EventPlaceConfig> places, AppLocalizations l10n) {
  typePriceCtrls.putIfAbsent(type, () => TextEditingController());
  final count = places.where((p) => (p.typePlace ?? 'Standard') == type).length;
  final color = _typeColor(type);
  return Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        Container(width: 4, height: 32, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(type, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          Text(l10n.placesCountSuffix('$count'), style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        ])),
        SizedBox(
          width: 100,
          child: TextField(
            controller: typePriceCtrls[type]!,
            decoration: InputDecoration(hintText: l10n.priceField, border: const OutlineInputBorder(), isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), prefixText: l10n.pricePrefix),
            keyboardType: TextInputType.number, style: const TextStyle(fontSize: 13),
          ),
        ),
      ]),
    ),
  );
}

Color _typeColor(String type) {
  return AppConstants.placeTypeColors[type] ?? Colors.grey;
}

String _assignedTypeForPlace(EventPlaceConfig place, Map<String, String> pendingRowAssignments,
    Map<String, String> pendingPlaceAssignments) {
  if (pendingPlaceAssignments.containsKey(place.numeroPlace)) {
    return pendingPlaceAssignments[place.numeroPlace]!;
  }
  if (place.range != null && pendingRowAssignments.containsKey(place.range)) {
    return pendingRowAssignments[place.range]!;
  }
  return place.effectiveType;
}

Widget _seatPreview(List<EventPlaceConfig> places, Map<String, TextEditingController> typePriceCtrls,
    Map<String, String> pendingRowAssignments, Map<String, String> pendingPlaceAssignments, AppLocalizations l10n) {
  final rangs = places.map((p) => p.range).whereType<String>().where((r) => r != '?').toSet().toList()..sort();
  if (rangs.isEmpty) return const SizedBox.shrink();

  final typesWithPrices = typePriceCtrls.entries
      .where((e) => e.value.text.trim().isNotEmpty && double.tryParse(e.value.text.trim()) != null)
      .map((e) => e.key)
      .toSet();

  return Container(
    decoration: BoxDecoration(
      color: AppTheme.surfaceColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.dividerColor),
    ),
    padding: const EdgeInsets.all(12),
    child: Column(children: [
      Text('Aperçu du plan', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
      const SizedBox(height: 8),
      _stageWidget(),
      const SizedBox(height: 4),
      ...rangs.map((rang) {
        final rowPlaces = places.where((p) => p.range == rang).toList()
          ..sort((a, b) => a.numeroPlace.compareTo(b.numeroPlace));
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Row(children: [
            SizedBox(width: 24, child: Text(rang, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: AppTheme.textSecondary))),
            const SizedBox(width: 4),
            Expanded(
              child: Wrap(spacing: 2, runSpacing: 2, children: rowPlaces.map((p) {
                final assignedType = _assignedTypeForPlace(p, pendingRowAssignments, pendingPlaceAssignments);
                final hasPrice = typesWithPrices.contains(assignedType);
                return Container(
                  width: 20, height: 16,
                  decoration: BoxDecoration(
                    color: hasPrice ? _typeColor(assignedType).withValues(alpha: 0.6) : AppTheme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: pendingPlaceAssignments.containsKey(p.numeroPlace) || 
                             (p.range != null && pendingRowAssignments.containsKey(p.range))
                          ? _typeColor(assignedType) : AppTheme.dividerColor,
                      width: pendingPlaceAssignments.containsKey(p.numeroPlace) || 
                             (p.range != null && pendingRowAssignments.containsKey(p.range)) ? 1.5 : 0.5,
                    ),
                  ),
                );
              }).toList()),
            ),
          ]),
        );
      }),
      if (typesWithPrices.isNotEmpty) ...[
        const SizedBox(height: 6),
        _legend(typesWithPrices),
      ],
    ]),
  );
}

Widget _stageWidget() {
  return Center(
    child: Container(
      width: 120, height: 20,
      decoration: BoxDecoration(
        color: AppTheme.textSecondary.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Center(child: Text('SCENE', style: TextStyle(fontSize: 8, color: AppColors.textMuted, letterSpacing: 2))),
    ),
  );
}

Widget _legend(Set<String> types) {
  return Wrap(spacing: 8, alignment: WrapAlignment.center, children: types.map((t) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(
        color: _typeColor(t).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(2),
      )),
      const SizedBox(width: 3),
      Text(t, style: TextStyle(fontSize: 9, color: AppTheme.textSecondary)),
    ]);
  }).toList());
}

Widget _rowSelector(List<EventPlaceConfig> places, Set<String> selectedRows,
    ValueChanged<String> onToggleRow, AppLocalizations l10n) {
  final rangs = places.map((p) => p.range).whereType<String>().where((r) => r != '?').toSet().toList()..sort();
  if (rangs.isEmpty) return Text(l10n.noRowLabel, style: TextStyle(color: AppTheme.textSecondary));
  return Wrap(spacing: 6, runSpacing: 4, children: rangs.map((rang) {
    final selected = selectedRows.contains(rang);
    final count = places.where((p) => p.range == rang).length;
    return FilterChip(
      label: Text('$rang ($count)', style: TextStyle(fontSize: 11, color: selected ? Colors.white : null)),
      selected: selected, onSelected: (v) => onToggleRow(rang),
    );
  }).toList());
}

Widget _seatGrid(List<EventPlaceConfig> places, Set<String> selectedPlaceIds,
    Map<String, String> pendingRowAssignments, Map<String, String> pendingPlaceAssignments,
    ValueChanged<String> onTogglePlace, AppLocalizations l10n) {
  final rangs = places.map((p) => p.range).whereType<String>().where((r) => r != '?').toSet().toList()..sort();
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rangs.map((rang) {
    final rowPlaces = places.where((p) => p.range == rang).toList()..sort((a, b) => a.numeroPlace.compareTo(b.numeroPlace));
    final rowAssigned = pendingRowAssignments.containsKey(rang);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${l10n.rowPrefix} $rang${rowAssigned ? ' (${pendingRowAssignments[rang]})' : ''}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11,
                color: rowAssigned ? AppTheme.textSecondary : null)),
        const SizedBox(height: 2),
        Wrap(spacing: 3, runSpacing: 3, children: rowPlaces.map((p) {
          final assigned = pendingPlaceAssignments.containsKey(p.numeroPlace) || rowAssigned;
          final selected = selectedPlaceIds.contains(p.numeroPlace);
          return GestureDetector(
            onTap: assigned ? null : () => onTogglePlace(p.numeroPlace),
            child: Container(
              width: 34, height: 26,
              decoration: BoxDecoration(
                color: assigned ? AppTheme.dividerColor.withValues(alpha: 0.3)
                    : selected ? AppTheme.primaryColor.withValues(alpha: 0.3) : AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: assigned ? AppTheme.dividerColor
                      : selected ? AppTheme.primaryColor : AppTheme.dividerColor,
                  width: assigned ? 0.5 : (selected ? 2 : 0.5),
                ),
              ),
              child: Center(child: Text(extractSeatNumber(p.numeroPlace),
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600,
                      color: assigned ? AppColors.textMuted : (selected ? AppTheme.primaryColor : AppTheme.textSecondary)))),
            ),
          );
        }).toList()),
      ]),
    );
  }).toList());
}

Widget _assignmentControls(
    List<String> availableTypes, String assignType, Set<String> selectedRows, Set<String> selectedPlaceIds,
    Map<String, String> pendingRowAssignments, Map<String, String> pendingPlaceAssignments,
    ValueChanged<String> onAssignTypeChanged, VoidCallback onAddPendingAssignment,
    VoidCallback onClearPendingAssignments, AppLocalizations l10n) {
  return Column(children: [
    Row(children: [
      Expanded(
        child: DropdownButtonFormField<String>(
          value: availableTypes.contains(assignType) ? assignType : null, isExpanded: true,
          decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder(), isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
          items: availableTypes.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12)))).toList(),
          onChanged: (v) => onAssignTypeChanged(v!),
        ),
      ),
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.pending, size: 14, color: AppTheme.primaryColor),
            const SizedBox(width: 4),
            Text(l10n.pendingAssignments('${pendingRowAssignments.length + pendingPlaceAssignments.length}'),
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
            const Spacer(),
            GestureDetector(onTap: onClearPendingAssignments, child: Text(l10n.clearAll, style: TextStyle(fontSize: 10, color: AppTheme.errorColor))),
          ]),
          ...pendingRowAssignments.entries.map((e) => Padding(padding: const EdgeInsets.only(top: 2),
              child: Text(l10n.rowAssignmentText(e.key, e.value), style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)))),
          ...pendingPlaceAssignments.entries.map((e) => Padding(padding: const EdgeInsets.only(top: 2),
              child: Text(l10n.seatAssignmentText(e.key, e.value), style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)))),
        ]),
      ),
    ],
  ]);
}