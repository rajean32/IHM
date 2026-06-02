import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/evenement_model.dart';
import '../../models/lieu_model.dart';
import '../../core/services/evenement_service.dart';
import '../../core/assets/app_colors.dart';
import '../../core/routes/client_routes.dart';

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
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Details')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _event == null
                  ? const Center(child: Text('Event not found'))
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
              child: Image.network(event.image!, height: 200, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox(height: 200, child: Center(child: Icon(Icons.image, size: 64)))),
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
              const Spacer(),
              Text(event.categorieNom ?? '', style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 16),
          if (event.dateEvenement != null)
            _buildInfoRow(Icons.calendar_today, DateFormat('EEEE, MMMM d, yyyy').format(event.dateEvenement!)),
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
          const SizedBox(height: 16),
          if (_availableSeats.isNotEmpty) ...[
            Text('Available Seats: ${_availableSeats.where((s) => s.disponible).length}/${_availableSeats.length}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (event.prixMin != null && event.prixMax != null)
              Text('Price: ${AppConstants.currency}${event.prixMin} - ${AppConstants.currency}${event.prixMax}', style: const TextStyle(fontSize: 16, color: AppColors.secondary)),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: event.idEvenement != null
                  ? () => Navigator.pushNamed(context, ClientRoutes.reservation, arguments: event.idEvenement)
                  : null,
              icon: const Icon(Icons.confirmation_number),
              label: const Text('Reserve Tickets', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
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
