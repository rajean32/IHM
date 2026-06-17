import 'package:flutter/material.dart';
import '../../../../core/assets/app_colors.dart';
import '../../../../generated/app_localizations.dart';

Widget buildStep4PricingFree({
  required BuildContext context,
  required List<String> placeTypes,
  required Map<String, TextEditingController> typePriceCtrls,
  required List<Map<String, dynamic>> standingZones,
  required VoidCallback onRefresh,
}) {
  final l10n = AppLocalizations.of(context)!;
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(l10n.stepPricing, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 4),
    Text(l10n.pricingDesc, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
    const SizedBox(height: 16),
    ...placeTypes.map((t) => _priceCard(t, typePriceCtrls, l10n)),
    if (standingZones.isNotEmpty) ...[
      const Divider(),
      Text(l10n.standingZonesLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      ...standingZones.map((z) => Card(
        margin: const EdgeInsets.only(bottom: 6),
        child: ListTile(
          dense: true,
          title: Text(z['nom'] as String),
          trailing: Text('Ar ${(z['prix'] as num).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      )),
    ],
  ]);
}

Color _typeColor(String type) {
  return AppConstants.placeTypeColors[type] ?? Colors.grey;
}

Widget _priceCard(String type, Map<String, TextEditingController> typePriceCtrls, AppLocalizations l10n) {
  typePriceCtrls.putIfAbsent(type, () => TextEditingController());
  final color = _typeColor(type);
  return Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        Container(width: 4, height: 32, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Expanded(child: Text(type, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
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
