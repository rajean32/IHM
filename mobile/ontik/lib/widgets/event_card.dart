import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/evenement_model.dart';
import '../core/assets/app_colors.dart';
import 'event_image_widget.dart';
import '../core/services/app_config.dart';

class EventCard extends StatelessWidget {
  final Evenement event;
  final VoidCallback onTap;

  const EventCard({super.key, required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: _buildContent(context)),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (event.image != null)
          eventImageWidget(event.image!, height: 160)
        else
          _buildPlaceholder(),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event.titre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (event.statut != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppConstants.statutColors[event.statut]
                            ?.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        event.statut!,
                        style: TextStyle(
                          color: AppConstants.statutColors[event.statut],
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (event.dateEvenement != null)
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                        DateFormat('d MMM yyyy', appLanguage).format(event.dateEvenement!),
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              if (event.description != null) ...[
                const SizedBox(height: 6),
                Text(
                  event.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
              ],
              if (event.caracteristiqueValeurs != null && event.caracteristiqueValeurs!.length <= 3)
                ...event.caracteristiqueValeurs!.map((c) => Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    '${c.nomCaracteristique ?? ""} : ${c.valeur}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return eventImageWidget(null, height: 160);
  }
}
