import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/evenement_model.dart';
import '../../core/assets/app_colors.dart';
import '../../core/services/app_config.dart';
import '../../generated/app_localizations.dart';
import '../event_image_widget.dart';

class EventCard extends StatelessWidget {
  final Evenement event;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool compact;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.trailing,
    this.compact = false,
  });

  String _formatDate(DateTime? date, String? time) {
    if (date == null) return '';
    final formatted = DateFormat('d MMMM yyyy', appLanguage).format(date);
    if (time != null && time.length >= 5) return '$formatted \u2022 ${time.substring(0, 5)}';
    return formatted;
  }

  String _placementLabel(String? type) {
    switch (type) {
      case 'LIBRE': case 'DEBOUT_SANS_LIMITE': case 'DEBOUT_AVEC_LIMITE': return 'Libre';
      case 'NUMEROTE': case 'UNIQUEMENT_ASSIS': return 'Numéroté';
      case 'MIXTE': case 'ASSIS_DEBOUT': return 'Mixte';
      default: return type ?? '—';
    }
  }

  IconData _placementIcon(String? type) {
    switch (type) {
      case 'LIBRE': case 'DEBOUT_SANS_LIMITE': case 'DEBOUT_AVEC_LIMITE': return Icons.people;
      case 'NUMEROTE': case 'UNIQUEMENT_ASSIS': return Icons.event_seat;
      case 'MIXTE': case 'ASSIS_DEBOUT': return Icons.swap_horiz;
      default: return Icons.event;
    }
  }

  String _formatPrice(Evenement event, BuildContext context) {
    final price = event.prixMin ?? event.prix;
    if (price != null && price > 0) {
      return 'À partir de ${price.toStringAsFixed(0)} ${AppConstants.currency}';
    }
    return AppLocalizations.of(context)!.clientHomePriceUnavailable;
  }

  Color _badgeColor(String? label) {
    switch (label?.toUpperCase()) {
      case 'VIP': return AppColors.placeVIP;
      case 'PREMIUM': return const Color(0xFFFF6F00);
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (compact) return _buildCompact(context);
    return _buildFull(context);
  }

  Widget _buildCompact(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(11)),
            child: SizedBox(
              width: 100, height: 100,
              child: Stack(fit: StackFit.expand, children: [
                event.image != null
                    ? eventImageWidget(event.image!, fit: BoxFit.cover)
                    : Container(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        child: Icon(Icons.event, color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                if (event.isNew == true)
                  Positioned(
                    top: 4, left: 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [const Color(0xFFFF6B35).withValues(alpha: 0.85), const Color(0xFFFF2E63).withValues(alpha: 0.85)],
                                begin: Alignment.topLeft, end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.clientHomeNewBadge,
                            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
              ]),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(event.titre, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                if (event.lieuNom != null) Text(event.lieuNom!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                if (event.dateEvenement != null) Text(DateFormat('d MMM yyyy', appLanguage).format(event.dateEvenement!), style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ]),
            ),
          ),
          if (trailing != null) trailing!,
        ]),
      ),
    );
  }

  Widget _buildFull(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(fit: StackFit.expand, children: [
              event.image != null
                  ? eventImageWidget(event.image!, fit: BoxFit.cover, width: double.infinity)
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary.withValues(alpha: 0.7), AppColors.primary.withValues(alpha: 0.3)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(child: Icon(Icons.event, size: 48, color: Colors.white.withValues(alpha: 0.4))),
                    ),
              if (event.isNew == true)
                Positioned(
                  top: 8, right: 8,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [const Color(0xFFFF6B35).withValues(alpha: 0.85), const Color(0xFFFF2E63).withValues(alpha: 0.85)],
                            begin: Alignment.topLeft, end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [BoxShadow(color: const Color(0xFFFF2E63).withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.clientHomeNewBadge,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1),
                        ),
                      ),
                    ),
                  ),
                ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Text(event.titre, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 8),
                _buildPlacementBadge(event.typeAgencement),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Icon(Icons.calendar_today, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Flexible(child: Text(_formatDate(event.dateEvenement, event.heureEvenement), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                Icon(Icons.location_on, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Flexible(child: Text(event.lieuNom ?? AppLocalizations.of(context)!.clientHomeVenueNotSpecified, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
              const SizedBox(height: 10),
              Text(_formatPrice(event, context), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildPlacementBadge(String? typeAgencement) {
    final label = _placementLabel(typeAgencement);
    final color = AppColors.primary;
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(_placementIcon(typeAgencement), size: 12, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
          ]),
        ),
      ),
    );
  }
}
