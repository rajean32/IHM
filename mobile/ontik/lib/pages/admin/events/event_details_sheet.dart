import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ontik/models/evenement_model.dart';
import 'package:ontik/core/assets/app_colors.dart';
import 'package:ontik/widgets/admin/admin_section_header.dart';

class EventDetailsSheet extends StatelessWidget {
  final Evenement event;

  const EventDetailsSheet({super.key, required this.event});

  static void show(BuildContext context, {required Evenement event}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          child: EventDetailsSheet(event: event),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = AppConstants.statutColors[event.statut] ?? AppColors.textMuted;
    final statusIcon = AppConstants.statutIcons[event.statut] ?? Icons.event;
    final dateStr = event.dateEvenement != null ? DateFormat('dd/MM/yyyy').format(event.dateEvenement!) : '';
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 32, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Text(event.titre, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(statusIcon, size: 14, color: statusColor),
                  const SizedBox(width: 4),
                  Text(event.statut ?? '', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor)),
                ]),
              ),
            ],
          ),
          if (event.statut == 'annule' && event.motifAnnulation != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.error.withValues(alpha: 0.3))),
              child: Row(children: [
                const Icon(Icons.warning_amber, color: AppColors.error, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('Motif: ${event.motifAnnulation}', style: const TextStyle(color: AppColors.error, fontSize: 13))),
              ]),
            ),
          ],
          AdminSectionHeader(icon: Icons.info, title: 'Informations'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _infoRow(Icons.description, 'Description', event.description ?? 'Non spécifiée'),
                  _infoRow(Icons.category, 'Catégorie', event.categorieNom ?? event.codeCategorie ?? 'Non spécifiée'),
                  _infoRow(Icons.person, 'Organisateur', event.organisateurNom ?? event.codeOrganisateur),
                ],
              ),
            ),
          ),
          AdminSectionHeader(icon: Icons.map, title: 'Logistique'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _infoRow(Icons.location_on, 'Lieu', event.lieuNom ?? event.codeLieu ?? 'Non spécifié'),
                  _infoRow(Icons.calendar_today, 'Date', dateStr),
                  _infoRow(Icons.access_time, 'Heure', event.heureEvenement ?? 'Non spécifiée'),
                ],
              ),
            ),
          ),
          if (event.placesTotal != null) ...[
            AdminSectionHeader(icon: Icons.event_seat, title: 'Jauge'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: event.placesTotal! > 0 ? ((event.placesTotal! - (event.placesDisponibles ?? 0)) / event.placesTotal!) : 0,
                        minHeight: 12,
                        backgroundColor: AppColors.fieldFill,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          event.placesDisponibles != null && event.placesTotal! > 0
                              ? (event.placesDisponibles! < event.placesTotal! * 0.2 ? AppColors.error
                                  : event.placesDisponibles! < event.placesTotal! * 0.5 ? AppColors.accent
                                  : AppColors.secondary)
                              : AppColors.secondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('${event.placesTotal! - (event.placesDisponibles ?? 0)} / ${event.placesTotal} réservées',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
          ],
          if (event.caracteristiqueValeurs != null && event.caracteristiqueValeurs!.isNotEmpty) ...[
            AdminSectionHeader(icon: Icons.list, title: 'Caractéristiques'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: event.caracteristiqueValeurs!.map((c) =>
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(children: [
                        SizedBox(width: 120, child: Text(c.nomCaracteristique ?? '', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
                        Expanded(child: Text(c.valeur, style: const TextStyle(fontSize: 13))),
                      ]),
                    )
                  ).toList(),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
