import 'package:flutter/material.dart';
import '../../../models/lieu_model.dart';
import '../../../generated/app_localizations.dart';

import 'step_3_location/free.dart';
import 'step_3_location/numbered.dart';
import 'step_3_location/mixed.dart';

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
  required List<Map<String, dynamic>> standingZones,
  required TextEditingController zoneNomCtrl,
  required TextEditingController zoneCapaciteCtrl,
  required bool zoneCapaciteIllimitee,
  required TextEditingController newPlaceTypeCtrl,
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
  switch (typePlacement) {
    case 'LIBRE':
      return buildStep3Free(
        context: context,
        selectedLieu: selectedLieu,
        lieux: lieux,
        selectedSalle: selectedSalle,
        salles: salles,
        loadingSalles: loadingSalles,
        salleOptionnelle: salleOptionnelle,
        capaciteIllimitee: capaciteIllimitee,
        capaciteLibreCtrl: capaciteLibreCtrl,
        placeTypes: placeTypes,
        newPlaceTypeCtrl: newPlaceTypeCtrl,
        onLieuChanged: onLieuChanged,
        onSalleChanged: onSalleChanged,
        onSalleOptionnelleChanged: onSalleOptionnelleChanged,
        onCapaciteIllimiteeChanged: onCapaciteIllimiteeChanged,
        onAddPlaceType: onAddPlaceType,
        onRemovePlaceType: onRemovePlaceType,
        onRefresh: onRefresh,
      );
    case 'NUMEROTE':
      return buildStep3Numbered(
        context: context,
        selectedLieu: selectedLieu,
        lieux: lieux,
        selectedSalle: selectedSalle,
        salles: salles,
        loadingSalles: loadingSalles,
        placeTypes: placeTypes,
        newPlaceTypeCtrl: newPlaceTypeCtrl,
        onLieuChanged: onLieuChanged,
        onSalleChanged: onSalleChanged,
        onAddPlaceType: onAddPlaceType,
        onRemovePlaceType: onRemovePlaceType,
        onRefresh: onRefresh,
      );
    case 'MIXTE':
      return buildStep3Mixed(
        context: context,
        selectedLieu: selectedLieu,
        lieux: lieux,
        selectedSalle: selectedSalle,
        salles: salles,
        loadingSalles: loadingSalles,
        placeTypes: placeTypes,
        newPlaceTypeCtrl: newPlaceTypeCtrl,
        standingZones: standingZones,
        zoneNomCtrl: zoneNomCtrl,
        zoneCapaciteCtrl: zoneCapaciteCtrl,
        zoneCapaciteIllimitee: zoneCapaciteIllimitee,
        onLieuChanged: onLieuChanged,
        onSalleChanged: onSalleChanged,
        onAddPlaceType: onAddPlaceType,
        onRemovePlaceType: onRemovePlaceType,
        onAddStandingZone: onAddStandingZone,
        onRemoveStandingZone: onRemoveStandingZone,
        onToggleCapaciteIllimitee: onToggleCapaciteIllimitee,
        onRefresh: onRefresh,
      );
    default:
      return const SizedBox.shrink();
  }
}