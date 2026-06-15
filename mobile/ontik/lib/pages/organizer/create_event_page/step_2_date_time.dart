import 'package:flutter/material.dart';
import '../../../core/assets/app_colors.dart';

Widget buildStep2({
  required DateTime? selectedDate,
  required int nombreJours,
  required TimeOfDay? selectedHeureDebut,
  required int dureeHeures,
  required int dureeMinutes,
  required bool isEditing,
  required ValueChanged<DateTime?> onDateChanged,
  required ValueChanged<int> onNombreJoursChanged,
  required ValueChanged<TimeOfDay?> onHeureChanged,
  required ValueChanged<int> onDureeHeuresChanged,
  required ValueChanged<int> onDureeMinutesChanged,
}) {
  final duree = Duration(hours: dureeHeures, minutes: dureeMinutes);
  final dateFin = selectedDate != null ? selectedDate.add(Duration(days: nombreJours - 1)) : null;
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Date & Heure', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 16),
    Builder(builder: (context) {
      return InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context, initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 1)),
            firstDate: isEditing ? DateTime(2020) : DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (picked != null) onDateChanged(picked);
        },
        child: InputDecorator(
          decoration: const InputDecoration(labelText: 'Date *', border: OutlineInputBorder()),
          child: Text(selectedDate != null
              ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
              : 'Sélectionner la date'),
        ),
      );
    }),
    const SizedBox(height: 12),
    TextFormField(
      initialValue: nombreJours.toString(),
      decoration: const InputDecoration(labelText: 'Nombre de jours *', border: OutlineInputBorder(),
          helperText: '1 = un seul jour'),
      keyboardType: TextInputType.number,
      onChanged: (v) => onNombreJoursChanged(int.tryParse(v) ?? 1),
      validator: (v) {
        final n = int.tryParse(v ?? '');
        if (n == null || n < 1) return 'Minimum 1 jour';
        return null;
      },
    ),
    const SizedBox(height: 12),
    Builder(builder: (context) {
      return InkWell(
        onTap: () async {
          final picked = await showTimePicker(context: context, initialTime: selectedHeureDebut ?? TimeOfDay.now());
          if (picked != null) onHeureChanged(picked);
        },
        child: InputDecorator(
          decoration: const InputDecoration(labelText: 'Heure début *', border: OutlineInputBorder()),
          child: Text(selectedHeureDebut != null
              ? '${selectedHeureDebut!.hour.toString().padLeft(2, '0')}:${selectedHeureDebut!.minute.toString().padLeft(2, '0')}'
              : 'Sélectionner l\'heure'),
        ),
      );
    }),
    const SizedBox(height: 12),
    Row(children: [
      Expanded(
        child: TextFormField(
          initialValue: dureeHeures.toString(),
          decoration: const InputDecoration(labelText: 'Durée (heures)', border: OutlineInputBorder(), isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12)),
          keyboardType: TextInputType.number,
          onChanged: (v) => onDureeHeuresChanged(int.tryParse(v) ?? 0),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: TextFormField(
          initialValue: dureeMinutes.toString(),
          decoration: const InputDecoration(labelText: 'Durée (minutes)', border: OutlineInputBorder(), isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12)),
          keyboardType: TextInputType.number,
          onChanged: (v) => onDureeMinutesChanged(int.tryParse(v) ?? 0),
        ),
      ),
    ]),
    const SizedBox(height: 8),
    Card(
      color: AppTheme.primaryColor.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.timer, size: 20, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text('Durée : ${duree.inHours}h ${duree.inMinutes.remainder(60)}min',
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ]),
          if (dateFin != null) ...[
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.date_range, size: 20, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text('Du ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} '
                  'au ${dateFin.day}/${dateFin.month}/${dateFin.year} ($nombreJours jour${nombreJours > 1 ? 's' : ''})',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ]),
          ],
        ]),
      ),
    ),
  ]);
}
