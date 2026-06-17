import 'package:flutter/material.dart';
import '../../../models/lieu_model.dart';
import '../../../models/event_place_config_model.dart';
import '../../../core/assets/app_colors.dart';
import '../../../generated/app_localizations.dart';

Widget buildStep3({
  required BuildContext context,
  required String? selectedLieu,
  required List<Lieu> lieux,
  required String? selectedSalle,
  required List<Map<String, dynamic>> salles,
  required bool loadingSalles,
  required String typePlacement,
  required bool salleOptionnelle,
  required bool capaciteIllimitee,
  required TextEditingController capaciteLibreCtrl,
  required List<String> placeTypes,
  required Map<String, TextEditingController> typePriceCtrls,
  required List<Map<String, dynamic>> standingZones,
  required TextEditingController zoneNomCtrl,
  required TextEditingController zoneCapaciteCtrl,
  required TextEditingController zonePrixCtrl,
  required bool zoneCapaciteIllimitee,
  required TextEditingController newPlaceTypeCtrl,
  required List<EventPlaceConfig> places,
  required ValueChanged<String?> onLieuChanged,
  required ValueChanged<String> onSalleChanged,
  required ValueChanged<bool> onSalleOptionnelleChanged,
  required ValueChanged<bool> onCapaciteIllimiteeChanged,
  required VoidCallback onAddPlaceType,
  required ValueChanged<String> onRemovePlaceType,
  required VoidCallback onAddStandingZone,
  required ValueChanged<int> onRemoveStandingZone,
  required ValueChanged<bool> onToggleCapaciteIllimitee,
  required VoidCallback onRefresh,
}) {
  final lieuxFiltres = lieux;
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(AppLocalizations.of(context)!.locationConfig, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 16),
    DropdownButtonFormField<String>(
      value: selectedLieu,
      isExpanded: true,
      decoration: InputDecoration(labelText: AppLocalizations.of(context)!.venueDropdown, border: OutlineInputBorder()),
      items: lieuxFiltres.map((l) => DropdownMenuItem(value: l.code, child: Text(l.nomLieu))).toList(),
      onChanged: onLieuChanged,
    ),
    const SizedBox(height: 12),
    if (typePlacement == 'LIBRE') _buildLibreSection(context, selectedLieu, selectedSalle, salles, loadingSalles,
        salleOptionnelle, capaciteIllimitee, capaciteLibreCtrl, placeTypes, newPlaceTypeCtrl, typePriceCtrls,
        onSalleChanged, onSalleOptionnelleChanged, onCapaciteIllimiteeChanged,
        onAddPlaceType, onRemovePlaceType, onRefresh),
    if (typePlacement == 'NUMEROTE') _buildNumeroteSection(context, selectedLieu, salles, loadingSalles, selectedSalle,
        placeTypes, newPlaceTypeCtrl, onSalleChanged, onAddPlaceType, onRemovePlaceType, onRefresh),
    if (typePlacement == 'MIXTE') _buildMixteSection(context, selectedLieu, salles, loadingSalles, selectedSalle,
        placeTypes, newPlaceTypeCtrl, standingZones, zoneNomCtrl, zoneCapaciteCtrl, zonePrixCtrl, zoneCapaciteIllimitee,
        onSalleChanged, onAddPlaceType, onRemovePlaceType, onAddStandingZone, onRemoveStandingZone, onToggleCapaciteIllimitee, onRefresh),
  ]);
}

Widget _buildLibreSection(
    BuildContext context, String? selectedLieu, String? selectedSalle, List<Map<String, dynamic>> salles, bool loadingSalles,
    bool salleOptionnelle, bool capaciteIllimitee, TextEditingController capaciteLibreCtrl,
    List<String> placeTypes, TextEditingController newPlaceTypeCtrl, Map<String, TextEditingController> typePriceCtrls,
    ValueChanged<String> onSalleChanged, ValueChanged<bool> onSalleOptionnelleChanged,
    ValueChanged<bool> onCapaciteIllimiteeChanged,
    VoidCallback onAddPlaceType, ValueChanged<String> onRemovePlaceType, VoidCallback onRefresh) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    SwitchListTile(
      title: Text(AppLocalizations.of(context)!.withoutRoom, style: TextStyle(fontSize: 14)),
      value: salleOptionnelle,
      onChanged: onSalleOptionnelleChanged,
      contentPadding: EdgeInsets.zero,
    ),
    if (!salleOptionnelle && selectedLieu != null) ...[
      if (loadingSalles)
        const Center(child: CircularProgressIndicator(strokeWidth: 2))
      else if (salles.isEmpty)
        Text(AppLocalizations.of(context)!.noRoomsAvailable, style: TextStyle(color: AppTheme.textSecondary))
      else ...[
        Text(AppLocalizations.of(context)!.roomLabel, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        ...salles.map((s) => _buildSalleTile(context, s, selectedSalle, onSalleChanged)),
      ],
    ],
    const SizedBox(height: 16),
    Text(AppLocalizations.of(context)!.capacityLabel, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    SwitchListTile(
      title: Text(AppLocalizations.of(context)!.unlimitedCapacity, style: TextStyle(fontSize: 14)),
      value: capaciteIllimitee,
      onChanged: onCapaciteIllimiteeChanged,
      contentPadding: EdgeInsets.zero,
    ),
    if (!capaciteIllimitee)
      TextFormField(
        controller: capaciteLibreCtrl,
        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.maxPeopleLabel, border: OutlineInputBorder(),
            helperText: AppLocalizations.of(context)!.unlimitedHint),
        keyboardType: TextInputType.number,
      ),
    const SizedBox(height: 8),
    const Divider(),
    Text(AppLocalizations.of(context)!.seatTypesPricingLabel, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    ...placeTypes.map((type) {
      typePriceCtrls.putIfAbsent(type, () => TextEditingController());
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(child: Text(type, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
            SizedBox(
              width: 100,
              child: TextField(
                controller: typePriceCtrls[type]!,
                decoration: InputDecoration(hintText: AppLocalizations.of(context)!.priceField, border: OutlineInputBorder(), isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8), prefixText: AppLocalizations.of(context)!.pricePrefix),
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ]),
        ),
      );
    }),
    _buildPlaceTypeManager(context, placeTypes, newPlaceTypeCtrl, onAddPlaceType, onRemovePlaceType, onRefresh),
  ]);
}

Widget _buildNumeroteSection(
    BuildContext context, String? selectedLieu, List<Map<String, dynamic>> salles, bool loadingSalles, String? selectedSalle,
    List<String> placeTypes, TextEditingController newPlaceTypeCtrl,
    ValueChanged<String> onSalleChanged,
    VoidCallback onAddPlaceType, ValueChanged<String> onRemovePlaceType, VoidCallback onRefresh) {
  if (selectedLieu == null) return const SizedBox.shrink();
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    if (loadingSalles)
      const Center(child: CircularProgressIndicator(strokeWidth: 2))
    else if (salles.isEmpty)
      Text(AppLocalizations.of(context)!.noRoomsAvailable, style: TextStyle(color: AppTheme.textSecondary))
    else ...[
      Text(AppLocalizations.of(context)!.roomRequiredLabel, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      ...salles.map((s) => _buildSalleTile(context, s, selectedSalle, onSalleChanged)),
    ],
    _buildPlaceTypeManager(context, placeTypes, newPlaceTypeCtrl, onAddPlaceType, onRemovePlaceType, onRefresh),
  ]);
}

Widget _buildMixteSection(
    BuildContext context, String? selectedLieu, List<Map<String, dynamic>> salles, bool loadingSalles, String? selectedSalle,
    List<String> placeTypes, TextEditingController newPlaceTypeCtrl, List<Map<String, dynamic>> standingZones,
    TextEditingController zoneNomCtrl, TextEditingController zoneCapaciteCtrl,
    TextEditingController zonePrixCtrl, bool zoneCapaciteIllimitee,
    ValueChanged<String> onSalleChanged,
    VoidCallback onAddPlaceType, ValueChanged<String> onRemovePlaceType,
    VoidCallback onAddStandingZone, ValueChanged<int> onRemoveStandingZone, ValueChanged<bool> onToggleCapaciteIllimitee, VoidCallback onRefresh) {
  if (selectedLieu == null) return const SizedBox.shrink();
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    if (loadingSalles)
      const Center(child: CircularProgressIndicator(strokeWidth: 2))
    else if (salles.isEmpty)
      Text(AppLocalizations.of(context)!.noRoomsAvailable, style: TextStyle(color: AppTheme.textSecondary))
    else ...[
      Text(AppLocalizations.of(context)!.roomRequiredLabel, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      ...salles.map((s) => _buildSalleTile(context, s, selectedSalle, onSalleChanged)),
    ],
    _buildPlaceTypeManager(context, placeTypes, newPlaceTypeCtrl, onAddPlaceType, onRemovePlaceType, onRefresh),
    const SizedBox(height: 16),
    const Divider(),
    Text(AppLocalizations.of(context)!.standingZonesLabel, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    ...standingZones.asMap().entries.map((entry) {
      final i = entry.key;
      final z = entry.value;
      return Card(
        margin: const EdgeInsets.only(bottom: 6),
        child: ListTile(
          dense: true,
          title: Text(z['nom'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(
            '${z['capacite'] != null ? AppLocalizations.of(context)!.zoneCapacityInfo('${z['capacite']}') : AppLocalizations.of(context)!.zoneCapacityUnlimited}'
            ' — ${AppLocalizations.of(context)!.zonePricePrefix((z['prix'] as num).toStringAsFixed(2))}',
            style: const TextStyle(fontSize: 12),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            onPressed: () => onRemoveStandingZone(i),
          ),
        ),
      );
    }),
    _buildAddZoneForm(context, zoneNomCtrl, zoneCapaciteCtrl, zonePrixCtrl, zoneCapaciteIllimitee, onAddStandingZone, onToggleCapaciteIllimitee, onRefresh),
  ]);
}

Widget _buildAddZoneForm(
    BuildContext context, TextEditingController zoneNomCtrl, TextEditingController zoneCapaciteCtrl,
    TextEditingController zonePrixCtrl, bool zoneCapaciteIllimitee,
    VoidCallback onAddStandingZone, ValueChanged<bool> onToggleCapaciteIllimitee,
    VoidCallback onRefresh) {
  return Card(
    margin: const EdgeInsets.only(top: 8),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(AppLocalizations.of(context)!.addStandingZoneTitle, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: zoneNomCtrl,
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.zoneNameLabel, border: OutlineInputBorder(), isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10), hintText: AppLocalizations.of(context)!.zoneNameHint),
          style: const TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: TextField(
              controller: zoneCapaciteCtrl,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.zoneCapacityLabel, border: OutlineInputBorder(), isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
              keyboardType: TextInputType.number,
              enabled: !zoneCapaciteIllimitee,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => onToggleCapaciteIllimitee(!zoneCapaciteIllimitee),
            child: Text(zoneCapaciteIllimitee ? AppLocalizations.of(context)!.unlimitedToggle : AppLocalizations.of(context)!.limitedToggle, style: TextStyle(fontSize: 12)),
          ),
        ]),
        const SizedBox(height: 8),
        TextField(
          controller: zonePrixCtrl,
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.zonePriceLabel, border: OutlineInputBorder(), isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: zoneNomCtrl.text.trim().isEmpty ? null : onAddStandingZone,
            icon: const Icon(Icons.add, size: 18),
            label: Text(AppLocalizations.of(context)!.addZoneButton, style: TextStyle(fontSize: 12)),
          ),
        ),
      ]),
    ),
  );
}

Widget _buildSalleTile(BuildContext context, Map<String, dynamic> s, String? selectedSalle, ValueChanged<String> onSalleChanged) {
  final id = s['numeroSalle'] as String? ?? '';
  final nom = s['nomSalle'] as String? ?? id;
  final capacite = s['capacite'];
  final selected = selectedSalle == id;
  return GestureDetector(
    onTap: () => onSalleChanged(id),
    child: Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: selected ? AppTheme.primaryColor.withValues(alpha: 0.08) : AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: selected ? AppTheme.primaryColor : AppTheme.dividerColor),
      ),
      child: Row(children: [
        Icon(Icons.meeting_room, size: 20, color: selected ? AppTheme.primaryColor : AppTheme.textSecondary),
        const SizedBox(width: 10),
        Expanded(child: Text(nom, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
        if (capacite != null) Text(AppLocalizations.of(context)!.capacityPlaces('$capacite'), style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
      ]),
    ),
  );
}

Widget _buildPlaceTypeManager(BuildContext context, List<String> placeTypes, TextEditingController newPlaceTypeCtrl,
    VoidCallback onAddPlaceType, ValueChanged<String> onRemovePlaceType, VoidCallback onRefresh) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SizedBox(height: 16),
    Text(AppLocalizations.of(context)!.seatTypesLabel, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
    const SizedBox(height: 4),
    Text(AppLocalizations.of(context)!.seatTypesDesc,
        style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
    const SizedBox(height: 8),
    Wrap(spacing: 8, runSpacing: 8, children: placeTypes.map((type) {
      final isDefault = type == 'Standard' || type == 'VIP';
      return Chip(
        label: Text(type, style: TextStyle(fontSize: 12, color: isDefault ? Colors.white : null)),
        backgroundColor: isDefault ? AppTheme.primaryColor : AppTheme.surfaceColor,
        deleteIcon: isDefault ? null : const Icon(Icons.close, size: 16),
        onDeleted: isDefault ? null : () => onRemovePlaceType(type),
      );
    }).toList()),
    const SizedBox(height: 8),
    Row(children: [
      Expanded(
        child: TextField(
          controller: newPlaceTypeCtrl,
          decoration: InputDecoration(hintText: AppLocalizations.of(context)!.newTypeHint, border: OutlineInputBorder(), isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
          style: const TextStyle(fontSize: 13),
        ),
      ),
      const SizedBox(width: 8),
      IconButton.filled(
        onPressed: onAddPlaceType,
        icon: const Icon(Icons.add, size: 20),
      ),
    ]),
  ]);
}
