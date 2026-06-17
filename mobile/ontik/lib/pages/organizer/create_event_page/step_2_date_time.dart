import 'package:flutter/material.dart';
import '../../../core/assets/app_colors.dart';
import '../../../generated/app_localizations.dart';

Widget buildStep2({
  required BuildContext context,
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
    Text(AppLocalizations.of(context)!.dateTimeTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.dateRequired, border: OutlineInputBorder()),
          child: Text(selectedDate != null
              ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
              : AppLocalizations.of(context)!.selectDateHint),
        ),
      );
    }),
    const SizedBox(height: 12),
    DropdownButtonFormField<int>(
      value: nombreJours,
      isExpanded: true,
      decoration: InputDecoration(labelText: AppLocalizations.of(context)!.numDaysRequired, border: OutlineInputBorder()),
      items: List.generate(7, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1} ${i + 1 > 1 ? AppLocalizations.of(context)!.daysUnit : AppLocalizations.of(context)!.dayUnit}'))),
      onChanged: (v) => onNombreJoursChanged(v ?? 1),
    ),
    const SizedBox(height: 12),
    Builder(builder: (context) {
      return InkWell(
        onTap: () async {
          final picked = await showTimePicker(context: context, initialTime: selectedHeureDebut ?? TimeOfDay.now());
          if (picked != null) onHeureChanged(picked);
        },
        child: InputDecorator(
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.startTimeRequired, border: OutlineInputBorder()),
          child: Text(selectedHeureDebut != null
              ? '${selectedHeureDebut!.hour.toString().padLeft(2, '0')}:${selectedHeureDebut!.minute.toString().padLeft(2, '0')}'
              : AppLocalizations.of(context)!.selectTimeHint),
        ),
      );
    }),
    const SizedBox(height: 12),
    Row(children: [
      Expanded(
        child: TextFormField(
          initialValue: dureeHeures.toString(),
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.durationHours, border: OutlineInputBorder(), isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12)),
          keyboardType: TextInputType.number,
          onChanged: (v) => onDureeHeuresChanged(int.tryParse(v) ?? 0),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: TextFormField(
          initialValue: dureeMinutes.toString(),
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.durationMinutes, border: OutlineInputBorder(), isDense: true,
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
            Icon(Icons.timer, size: 20, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.totalDurationLabel('${duree.inHours > 0 ? '${duree.inHours}h ' : ''}${duree.inMinutes.remainder(60)}m'),
                style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
          ]),
          if (dateFin != null) ...[
            const SizedBox(height: 6),
            Row(children: [
              Icon(Icons.date_range, size: 20, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(AppLocalizations.of(context)!.dateRangeLabel('${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}', '${dateFin.day}/${dateFin.month}/${dateFin.year}', '$nombreJours'),
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.primaryColor)),
              ),
            ]),
          ],
        ]),
      ),
    ),
  ]);
}
