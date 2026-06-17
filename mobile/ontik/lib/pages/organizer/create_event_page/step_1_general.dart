import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/assets/app_colors.dart';
import '../../../models/categorie_model.dart';
import '../../../models/caracteristique_model.dart';
import '../../../generated/app_localizations.dart';

Widget buildStep1({
  required BuildContext context,
  required TextEditingController titreCtrl,
  required TextEditingController descriptionCtrl,
  required String? selectedCategorie,
  required List<Categorie> categories,
  required String? selectedImagePath,
  required bool hasNewImage,
  required String typePlacement,
  required List<Caracteristique> caracteristiques,
  required Map<int, TextEditingController> caracControllers,
  required Map<int, String> caracDropdownValues,
  required Map<int, bool> caracBooleanValues,
  required bool loadingCaracteristiques,
  required ImagePicker imagePicker,
  required ValueChanged<String?> onCategorieChanged,
  required ValueChanged<String> onPlacementChanged,
  required ValueChanged<String> onImagePicked,
  required VoidCallback onImageRemove,
  required VoidCallback onRefresh,
}) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(AppLocalizations.of(context)!.generalInfo, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 16),
    TextFormField(
      controller: titreCtrl,
      decoration: InputDecoration(labelText: AppLocalizations.of(context)!.titleRequired, border: OutlineInputBorder()),
      validator: (v) => v == null || v.isEmpty ? AppLocalizations.of(context)!.requiredMarker : null,
    ),
    const SizedBox(height: 12),
    TextFormField(
      controller: descriptionCtrl,
      decoration: InputDecoration(labelText: AppLocalizations.of(context)!.descriptionLabel, border: OutlineInputBorder()),
      maxLines: 3,
    ),
    const SizedBox(height: 12),
    InkWell(
      onTap: () async {
        final picked = await imagePicker.pickImage(source: ImageSource.gallery, maxWidth: 1920, maxHeight: 1080);
        if (picked != null) onImagePicked(picked.path);
      },
      child: Container(
        height: 120, width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.textSecondary.withValues(alpha: 0.3)),
        ),
        child: hasNewImage
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(File(selectedImagePath!), height: 120, width: double.infinity, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 4, right: 4,
                    child: GestureDetector(
                      onTap: onImageRemove,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.textPrimary.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              )
            : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.add_photo_alternate, size: 40, color: AppTheme.textSecondary),
                Text(AppLocalizations.of(context)!.addPoster, style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              ]),
      ),
    ),
    const SizedBox(height: 12),
    DropdownButtonFormField<String>(
      value: selectedCategorie,
      isExpanded: true,
      decoration: InputDecoration(labelText: AppLocalizations.of(context)!.genreRequired, border: OutlineInputBorder()),
      items: categories.map((c) => DropdownMenuItem(value: c.codeCategorie, child: Text(c.nomCategorie))).toList(),
      onChanged: onCategorieChanged,
      validator: (v) => v == null ? AppLocalizations.of(context)!.requiredMarker : null,
    ),
    const SizedBox(height: 12),
    Text(AppLocalizations.of(context)!.placementType, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    Row(children: [
      _buildPlacementChip('LIBRE', AppLocalizations.of(context)!.placementFree, Icons.people, typePlacement, onPlacementChanged),
      const SizedBox(width: 8),
      _buildPlacementChip('NUMEROTE', AppLocalizations.of(context)!.placementNumbered, Icons.event_seat, typePlacement, onPlacementChanged),
      const SizedBox(width: 8),
      _buildPlacementChip('MIXTE', AppLocalizations.of(context)!.placementMixed, Icons.swap_horiz, typePlacement, onPlacementChanged),
    ]),
    if (loadingCaracteristiques)
      const Padding(padding: EdgeInsets.only(top: 12), child: LinearProgressIndicator())
    else
      _buildCaracteristiquesInputs(context, caracteristiques, categories, selectedCategorie,
          caracControllers, caracDropdownValues, caracBooleanValues, onRefresh),
  ]);
}

Widget _buildPlacementChip(String value, String label, IconData icon, String typePlacement, ValueChanged<String> onChanged) {
  final selected = typePlacement == value;
  return Expanded(
    child: GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryColor.withValues(alpha: 0.1) : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppTheme.primaryColor : AppTheme.dividerColor, width: selected ? 2 : 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? AppTheme.primaryColor : AppTheme.textSecondary, size: 24),
            const SizedBox(height: 6),
            Text(label, textAlign: TextAlign.center, style: TextStyle(
              fontSize: 11, fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              color: selected ? AppTheme.primaryColor : AppTheme.textSecondary,
            )),
          ],
        ),
      ),
    ),
  );
}

Widget _buildCaracteristiquesInputs(
    BuildContext context,
    List<Caracteristique> caracteristiques,
    List<Categorie> categories,
    String? selectedCategorie,
    Map<int, TextEditingController> caracControllers,
    Map<int, String> caracDropdownValues,
    Map<int, bool> caracBooleanValues,
    VoidCallback onRefresh) {
  if (caracteristiques.isEmpty) return const SizedBox.shrink();
  final cat = categories.where((c) => c.codeCategorie == selectedCategorie).firstOrNull;
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Divider(),
    Text(AppLocalizations.of(context)!.featuresCategory(cat != null ? '- ${cat.nomCategorie}' : ''),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    ...caracteristiques.map((c) {
      final id = c.idCaracteristique!;
      final label = '${c.nom}${c.obligatoire ? ' *' : ''}';
      switch (c.typeDonnee) {
        case 'boolean':
          return SwitchListTile(
            title: Text(label, style: const TextStyle(fontSize: 14)),
            value: caracBooleanValues[id] ?? false,
            onChanged: (v) { caracBooleanValues[id] = v; onRefresh(); },
          );
        case 'select':
          final options = (c.options ?? '').split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ),
            Wrap(
              spacing: 8, runSpacing: 4,
              children: options.map((o) => FilterChip(
                label: Text(o, style: const TextStyle(fontSize: 13)),
                selected: caracDropdownValues[id] == o,
                selectedColor: AppTheme.secondaryColor.withValues(alpha: 0.2),
                checkmarkColor: AppTheme.secondaryColor,
                onSelected: (selected) { caracDropdownValues[id] = selected ? o : ''; onRefresh(); },
              )).toList(),
            ),
          ]);
        case 'number':
          return TextFormField(
            controller: caracControllers[id]!,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
            onChanged: (_) => onRefresh(),
          );
        case 'date':
          return Builder(builder: (context) {
            return InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context, initialDate: DateTime.now(),
                  firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) { caracControllers[id]!.text = picked.toIso8601String().split('T').first; onRefresh(); }
              },
              child: InputDecorator(
                decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
                child: Text(caracControllers[id]!.text.isEmpty ? AppLocalizations.of(context)!.selectDatePlaceholder : caracControllers[id]!.text),
              ),
            );
          });
        default:
          final isMissing = c.obligatoire && (caracControllers[id]?.text.trim().isEmpty ?? true);
          return TextFormField(
            controller: caracControllers[id]!,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: isMissing ? Colors.red : null),
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) => onRefresh(),
          );
      }
    }).toList(),
  ]);
}
