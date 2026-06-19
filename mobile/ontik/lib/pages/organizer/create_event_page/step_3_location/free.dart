import 'package:flutter/material.dart';
import '../../../../models/lieu_model.dart';
import '../../../../core/assets/app_colors.dart';
import '../../../../generated/app_localizations.dart';

Widget buildStep3Free({
  required BuildContext context,
  required String? selectedLieu,
  required List<Lieu> lieux,
  required String? selectedSalle,
  required List<Map<String, dynamic>> salles,
  required bool loadingSalles,
  required bool salleOptionnelle,
  required bool capaciteIllimitee,
  required TextEditingController capaciteLibreCtrl,
  required List<String> placeTypes,
  required TextEditingController newPlaceTypeCtrl,
  required ValueChanged<String?> onLieuChanged,
  required ValueChanged<String> onSalleChanged,
  required ValueChanged<bool> onSalleOptionnelleChanged,
  required ValueChanged<bool> onCapaciteIllimiteeChanged,
  required VoidCallback onAddPlaceType,
  required ValueChanged<String> onRemovePlaceType,
  required VoidCallback onRefresh,
}) {
  final l10n = AppLocalizations.of(context)!;
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(l10n.locationConfig, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 16),
    DropdownButtonFormField<String>(
      value: selectedLieu, isExpanded: true,
      decoration: InputDecoration(labelText: l10n.venueDropdown, border: const OutlineInputBorder()),
      items: lieux.map((l) => DropdownMenuItem(value: l.code, child: Text(l.nomLieu))).toList(),
      onChanged: onLieuChanged,
    ),
    const SizedBox(height: 12),
    SwitchListTile(
      title: Text(l10n.withoutRoom, style: const TextStyle(fontSize: 14)),
      value: salleOptionnelle, onChanged: onSalleOptionnelleChanged,
      contentPadding: EdgeInsets.zero,
    ),
    if (!salleOptionnelle && selectedLieu != null) ...[
      if (loadingSalles) const Center(child: CircularProgressIndicator(strokeWidth: 2))
      else if (salles.isEmpty) Text(l10n.noRoomsAvailable, style: TextStyle(color: AppTheme.textSecondary))
      else ...[
        Text(l10n.roomLabel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        ...salles.map((s) => _salleTile(context, s, selectedSalle, onSalleChanged)),
      ],
    ],
    const SizedBox(height: 16),
    Text(l10n.capacityLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    SwitchListTile(
      title: Text(l10n.unlimitedCapacity, style: const TextStyle(fontSize: 14)),
      value: capaciteIllimitee, onChanged: onCapaciteIllimiteeChanged,
      contentPadding: EdgeInsets.zero,
    ),
    if (!capaciteIllimitee)
      TextFormField(
        controller: capaciteLibreCtrl,
        decoration: InputDecoration(
          labelText: l10n.maxPeopleLabel,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
      ),
    const SizedBox(height: 16),
    _placeTypeManager(context, placeTypes, newPlaceTypeCtrl, onAddPlaceType, onRemovePlaceType, onRefresh, l10n),
  ]);
}

Widget _salleTile(BuildContext context, Map<String, dynamic> s, String? selectedSalle, ValueChanged<String> onSalleChanged) {
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
        Expanded(child: Text(nom, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
        if (capacite != null) Text(AppLocalizations.of(context)!.capacityPlaces('$capacite'), style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
      ]),
    ),
  );
}

Widget _placeTypeManager(BuildContext context, List<String> placeTypes, TextEditingController newPlaceTypeCtrl,
    VoidCallback onAddPlaceType, ValueChanged<String> onRemovePlaceType, VoidCallback onRefresh, AppLocalizations l10n) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(l10n.seatTypesLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
    const SizedBox(height: 4),
    Text(l10n.seatTypesDesc, style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
    const SizedBox(height: 8),
    Wrap(spacing: 8, runSpacing: 8, children: placeTypes.map((type) {
      return Container(
        padding: const EdgeInsets.only(left: 12, right: 4),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(type, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => onRemovePlaceType(type),
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.close, size: 14, color: AppTheme.textSecondary),
            ),
          ),
        ]),
      );
    }).toList()),
    const SizedBox(height: 8),
    Row(children: [
      Expanded(
        child: TextField(
          controller: newPlaceTypeCtrl,
          decoration: InputDecoration(hintText: l10n.newTypeHint, border: const OutlineInputBorder(), isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
          style: const TextStyle(fontSize: 13),
        ),
      ),
      const SizedBox(width: 8),
      IconButton.filled(onPressed: onAddPlaceType, icon: const Icon(Icons.add, size: 20)),
    ]),
  ]);
}