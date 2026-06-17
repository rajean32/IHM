import 'dart:io';
import 'package:flutter/material.dart';
import '../../../models/categorie_model.dart';
import '../../../models/lieu_model.dart';
import '../../../models/caracteristique_model.dart';
import '../../../core/assets/app_colors.dart';
import '../../../generated/app_localizations.dart';

Widget buildStep5({
  required BuildContext context,
  required TextEditingController titreCtrl,
  required String? selectedImagePath,
  required bool hasNewImage,
  required String? selectedCategorie,
  required List<Categorie> categories,
  required DateTime? selectedDate,
  required int nombreJours,
  required TimeOfDay? selectedHeureDebut,
  required Duration dureeCalculee,
  required String? selectedLieu,
  required List<Lieu> lieux,
  required String? selectedSalle,
  required List<Map<String, dynamic>> salles,
  required String typePlacement,
  required bool salleOptionnelle,
  required bool capaciteIllimitee,
  required TextEditingController capaciteLibreCtrl,
  required List<String> placeTypes,
  required Map<String, TextEditingController> typePriceCtrls,
  required List<Map<String, dynamic>> standingZones,
  required List<Caracteristique> caracteristiques,
  required Map<int, String> caracDropdownValues,
  required Map<int, TextEditingController> caracControllers,
  required Map<int, bool> caracBooleanValues,
}) {
  final duree = dureeCalculee;
  final cat = categories.where((c) => c.codeCategorie == selectedCategorie).firstOrNull;
  final salle = salles.where((s) => (s['numeroSalle'] as String?) == selectedSalle).firstOrNull;
  final lieu = lieux.where((l) => l.code == selectedLieu).firstOrNull;
  final dateFin = selectedDate?.add(Duration(days: nombreJours - 1));
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(AppLocalizations.of(context)!.summaryTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 16),

    // Carte : Informations générales
    _sectionCard(title: titreCtrl.text, children: [
      if (hasNewImage) ...[
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(File(selectedImagePath!), height: 140, width: double.infinity, fit: BoxFit.cover),
        ),
        const SizedBox(height: 12),
      ],
      Text(titreCtrl.text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      if (cat != null) ...[
        const SizedBox(height: 4),
        Text(cat.nomCategorie, style: const TextStyle(color: AppTheme.textSecondary)),
      ],
    ]),
    const SizedBox(height: 8),

    // Carte : Date & Heure
    if (selectedDate != null || selectedHeureDebut != null)
      _sectionCard(icon: Icons.calendar_today, title: AppLocalizations.of(context)!.dateTimeSection, children: [
        if (selectedDate != null)
          _recapRow(Icons.calendar_today, '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'),
        if (dateFin != null && nombreJours > 1)
          _recapRow(Icons.date_range, AppLocalizations.of(context)!.untilDate('${dateFin.day}/${dateFin.month}/${dateFin.year}', '$nombreJours')),
        if (selectedHeureDebut != null)
          _recapRow(Icons.access_time, AppLocalizations.of(context)!.timeDisplay('${selectedHeureDebut!.hour.toString().padLeft(2, '0')}:${selectedHeureDebut!.minute.toString().padLeft(2, '0')}')),
        _recapRow(Icons.timer, AppLocalizations.of(context)!.durationDisplay('${duree.inHours > 0 ? '${duree.inHours}h ' : ''}${duree.inMinutes.remainder(60)}m')),
      ]),
    if ((selectedDate != null || selectedHeureDebut != null)) const SizedBox(height: 8),

    // Carte : Lieu
    if (lieu != null)
      _sectionCard(icon: Icons.location_on, title: AppLocalizations.of(context)!.locationSection, children: [
        _recapRow(Icons.location_on, lieu!.nomLieu),
        if (salle != null || (typePlacement == 'LIBRE' && !salleOptionnelle && selectedSalle != null))
          _recapRow(Icons.meeting_room, salle?['nomSalle'] as String? ?? selectedSalle ?? ''),
        if (typePlacement == 'LIBRE' && !capaciteIllimitee && capaciteLibreCtrl.text.isNotEmpty)
          _recapRow(Icons.people, AppLocalizations.of(context)!.capacityDisplay('${capaciteLibreCtrl.text}')),
      ]),
    if (lieu != null) const SizedBox(height: 8),

    // Carte : Placement & Tarifs
    _sectionCard(icon: Icons.sell, title: AppLocalizations.of(context)!.placementPricingSection, children: [
      _recapRow(Icons.people, typePlacement == 'LIBRE' ? AppLocalizations.of(context)!.placementFreeDisplay : (typePlacement == 'MIXTE' ? AppLocalizations.of(context)!.placementMixedDisplay : AppLocalizations.of(context)!.placementNumberedDisplay)),
      _recapRow(Icons.category, AppLocalizations.of(context)!.typesDisplay(placeTypes.join(', '))),
      if (typePlacement == 'MIXTE' && standingZones.isNotEmpty)
        _recapRow(Icons.accessibility_new, AppLocalizations.of(context)!.standingZonesCount('${standingZones.length}')),
      if (typePriceCtrls.entries.any((e) => e.value.text.isNotEmpty)) ...[
        const SizedBox(height: 4),
        ...typePriceCtrls.entries.where((e) => e.value.text.isNotEmpty).map((e) =>
          _recapRow(Icons.monetization_on, AppLocalizations.of(context)!.priceDisplay(e.key, double.tryParse(e.value.text)?.toStringAsFixed(2) ?? e.value.text))),
      ],
      if (standingZones.isNotEmpty) ...[
        ...standingZones.map((z) =>
          _recapRow(Icons.accessibility_new, AppLocalizations.of(context)!.priceDisplay('${z['nom']}', (z['prix'] as num).toStringAsFixed(2)))),
      ],
    ]),
    const SizedBox(height: 8),

    // Carte : Caractéristiques
    if (caracteristiques.isNotEmpty)
      _sectionCard(icon: Icons.info_outline, title: AppLocalizations.of(context)!.featuresSection, children: [
        ..._buildCaracteristiqueValeurs(caracteristiques, caracDropdownValues,
            caracControllers, caracBooleanValues).map((v) {
          final nom = caracteristiques
              .where((c) => c.idCaracteristique == v['idCaracteristique'])
              .firstOrNull?.nom ?? '';
          return _recapRow(Icons.check_circle_outline, AppLocalizations.of(context)!.featureDisplay(nom, '${v['valeur']}'));
        }),
      ]),
  ]);
}

List<Map<String, dynamic>> _buildCaracteristiqueValeurs(
    List<Caracteristique> caracteristiques,
    Map<int, String> caracDropdownValues,
    Map<int, TextEditingController> caracControllers,
    Map<int, bool> caracBooleanValues) {
  final values = <Map<String, dynamic>>[];
  for (final c in caracteristiques) {
    if (c.idCaracteristique == null) continue;
    String valeur;
    switch (c.typeDonnee) {
      case 'boolean': valeur = caracBooleanValues[c.idCaracteristique!]?.toString() ?? 'false'; break;
      case 'select': valeur = caracDropdownValues[c.idCaracteristique!] ?? ''; break;
      default: valeur = caracControllers[c.idCaracteristique!]?.text ?? '';
    }
    if (valeur.isNotEmpty) values.add({'idCaracteristique': c.idCaracteristique, 'valeur': valeur});
  }
  return values;
}

Widget _sectionCard({
  IconData? icon,
  required String title,
  required List<Widget> children,
}) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (icon != null) ...[
          Row(children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 12),
        ] else ...[
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
        ],
        ...children,
      ]),
    ),
  );
}

Widget _recapRow(IconData icon, String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Icon(icon, size: 16, color: AppTheme.textSecondary),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
    ]),
  );
}
