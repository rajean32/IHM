import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/evenement_model.dart';
import '../../models/lieu_model.dart';
import '../../core/services/evenement_service.dart';
import '../../core/assets/app_colors.dart';
import '../../core/routes/client_routes.dart';
import '../../core/utils/error_helper.dart';
import '../../widgets/event_image_widget.dart';

class HomeDetailPage extends StatefulWidget {
  final int eventId;
  const HomeDetailPage({super.key, required this.eventId});

  @override
  State<HomeDetailPage> createState() => _HomeDetailPageState();
}

class _HomeDetailPageState extends State<HomeDetailPage> {
  EventDetail? _event;
  List<SeatingPlace> _availableSeats = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() => _isLoading = true);
    try {
      final _eventService = EvenementService();
      final eventData = await _eventService.getEventDetail(widget.eventId);
      final seatsData = await _eventService.getAvailablePlaces(widget.eventId);
      if (!mounted) return;
      setState(() {
        _event = EventDetail.fromJson(eventData);
        _availableSeats = seatsData.map((e) => SeatingPlace.fromJson(e as Map<String, dynamic>)).toList();
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = apiErrorString(e);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détails')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _event == null
                  ? const Center(child: Text('Événement non trouvé'))
                  : _buildContent(),
    );
  }

  Widget _buildContent() {
    final event = _event!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (event.image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: eventImageWidget(event.image, height: 200),
            ),
          const SizedBox(height: 16),
          Text(event.titre, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              if (event.statut != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppConstants.statutColors[event.statut]?.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(event.statut!, style: TextStyle(color: AppConstants.statutColors[event.statut], fontSize: 12)),
                ),
              if (event.typeAgencement != null)
                Container(
                  margin: const EdgeInsets.only(left: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(_typeAgencementLabel(event.typeAgencement!), style: TextStyle(color: AppColors.primary, fontSize: 11)),
                ),
              const Spacer(),
              Text(event.categorieNom ?? '', style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 16),
          if (event.dateEvenement != null)
            _buildInfoRow(Icons.calendar_today, DateFormat('EEEE d MMMM yyyy', 'fr').format(event.dateEvenement!)),
          if (event.heureEvenement != null) _buildInfoRow(Icons.access_time, event.heureEvenement!),
          if (event.lieuNom != null) _buildInfoRow(Icons.location_on, event.lieuNom!),
          if (event.lieuAdresse != null) _buildInfoRow(Icons.map, event.lieuAdresse!),
          if (event.organisateurNom != null) _buildInfoRow(Icons.person, event.organisateurNom!),
          const SizedBox(height: 16),
          if (event.description != null) ...[
            const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(event.description!),
          ],
          if (event.caracteristiqueValeurs != null && event.caracteristiqueValeurs!.isNotEmpty) ...[
            const Text('Caractéristiques', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...event.caracteristiqueValeurs!.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Text('${c.nomCaracteristique ?? "Caractéristique"} : ',
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                  Expanded(child: Text(c.valeur)),
                ],
              ),
            )),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 16),
          if (_availableSeats.isNotEmpty) ...[
            Text('Places assises disponibles : ${_availableSeats.where((s) => s.disponible).length}/${_availableSeats.length}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (event.prixMin != null && event.prixMax != null)
              Text('Prix : ${AppConstants.currency}${event.prixMin} - ${AppConstants.currency}${event.prixMax}', style: const TextStyle(fontSize: 16, color: AppColors.secondary)),
            const SizedBox(height: 8),
          ],
          if (event.standingZones != null && event.standingZones!.isNotEmpty) ...[
            const Divider(),
            const Text('Zones debout', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...event.standingZones!.map((zone) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.accessibility_new, size: 24, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(zone.nom, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 2),
                            Text(
                              '${zone.capacite != null ? '${zone.placesDisponibles ?? 0}/${zone.capacite} places - ' : 'Places illimitées - '}${AppConstants.currency} ${zone.prix.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: event.idEvenement != null
                  ? () => Navigator.pushNamed(context, ClientRoutes.reservation, arguments: {'eventId': event.idEvenement})
                  : null,
              icon: const Icon(Icons.confirmation_number),
              label: const Text('Réserver', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  String _typeAgencementLabel(String? type) {
    switch (type) {
      case 'UNIQUEMENT_ASSIS': return 'Assis';
      case 'TABLE_ASSIS': return 'Table assis';
      case 'ASSIS_DEBOUT': return 'Assis & Debout';
      case 'DEBOUT_AVEC_LIMITE': return 'Debout (jaugé)';
      case 'DEBOUT_SANS_LIMITE': return 'Debout (libre)';
      default: return type ?? '';
    }
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
