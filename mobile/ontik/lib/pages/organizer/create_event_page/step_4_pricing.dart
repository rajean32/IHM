import 'package:flutter/material.dart';
import '../../../models/event_place_config_model.dart';
import '../../../generated/app_localizations.dart';

import 'step_4_pricing/free.dart';
import 'step_4_pricing/numbered.dart';
import 'step_4_pricing/mixed.dart';

Widget buildStep4({
  required BuildContext context,
  required String typePlacement,
  required List<String> placeTypes,
  required Map<String, TextEditingController> typePriceCtrls,
  required List<Map<String, dynamic>> standingZones,
  required List<TextEditingController> zonePriceCtrls,
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
  switch (typePlacement) {
    case 'LIBRE':
      return buildStep4PricingFree(
        context: context,
        placeTypes: placeTypes,
        typePriceCtrls: typePriceCtrls,
        standingZones: standingZones,
        onRefresh: onRefresh,
      );
    case 'NUMEROTE':
      return buildStep4PricingNumbered(
        context: context,
        placeTypes: placeTypes,
        typePriceCtrls: typePriceCtrls,
        selectedSalle: selectedSalle,
        places: places,
        loadingPlaces: loadingPlaces,
        selectedRows: selectedRows,
        selectedPlaceIds: selectedPlaceIds,
        assignType: assignType,
        availableTypes: availableTypes,
        gridExpanded: gridExpanded,
        pendingRowAssignments: pendingRowAssignments,
        pendingPlaceAssignments: pendingPlaceAssignments,
        onAssignTypeChanged: onAssignTypeChanged,
        onAddPendingAssignment: onAddPendingAssignment,
        onClearPendingAssignments: onClearPendingAssignments,
        onToggleRow: onToggleRow,
        onTogglePlace: onTogglePlace,
        onToggleGridExpanded: onToggleGridExpanded,
        onRefresh: onRefresh,
      );
    case 'MIXTE':
      return buildStep4PricingMixed(
        context: context,
        placeTypes: placeTypes,
        typePriceCtrls: typePriceCtrls,
        selectedSalle: selectedSalle,
        places: places,
        loadingPlaces: loadingPlaces,
        selectedRows: selectedRows,
        selectedPlaceIds: selectedPlaceIds,
        assignType: assignType,
        availableTypes: availableTypes,
        gridExpanded: gridExpanded,
        pendingRowAssignments: pendingRowAssignments,
        pendingPlaceAssignments: pendingPlaceAssignments,
        standingZones: standingZones,
        zonePriceCtrls: zonePriceCtrls,
        onAssignTypeChanged: onAssignTypeChanged,
        onAddPendingAssignment: onAddPendingAssignment,
        onClearPendingAssignments: onClearPendingAssignments,
        onToggleRow: onToggleRow,
        onTogglePlace: onTogglePlace,
        onToggleGridExpanded: onToggleGridExpanded,
        onRemoveStandingZone: onRemoveStandingZone,
        onRefresh: onRefresh,
      );
    default:
      return const SizedBox.shrink();
  }
}