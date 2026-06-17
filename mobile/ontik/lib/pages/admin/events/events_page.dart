import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ontik/core/services/evenement_service.dart';
import 'package:ontik/models/evenement_model.dart';
import 'package:ontik/core/assets/app_colors.dart';
import 'package:ontik/core/utils/error_helper.dart';
import 'package:ontik/widgets/admin/admin_search_field.dart';
import 'package:ontik/widgets/admin/admin_empty_state.dart';
import 'package:ontik/widgets/admin/admin_error_state.dart';
import 'event_details_sheet.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final _service = EvenementService();
  final _searchCtrl = TextEditingController();
  bool _loading = true;
  String? _error;
  List<Evenement> _events = [];
  List<Evenement> _filteredEvents = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _service.getEvents();
      if (!mounted) return;
      final events = data.map((e) => Evenement.fromJson(e as Map<String, dynamic>)).toList();
      events.sort((a, b) => (b.dateEvenement ?? DateTime(2000)).compareTo(a.dateEvenement ?? DateTime(2000)));
      setState(() { _events = events; _filteredEvents = events; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = apiErrorString(e); _loading = false; });
    }
  }

  void _filter(String query) {
    _searchQuery = query.toLowerCase();
    setState(() {
      _filteredEvents = _events.where((e) =>
        e.titre.toLowerCase().contains(_searchQuery) ||
        (e.organisateurNom?.toLowerCase().contains(_searchQuery) ?? false) ||
        (e.statut?.toLowerCase().contains(_searchQuery) ?? false)
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              const Text('Événements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.refresh, size: 20), onPressed: _load),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: AdminSearchField(
            hintText: 'Rechercher par titre, organisateur, statut...',
            controller: _searchCtrl,
            onChanged: _filter,
          ),
        ),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return AdminErrorState(message: _error!, onRetry: _load);
    if (_filteredEvents.isEmpty) {
      return AdminEmptyState(
        icon: Icons.event_busy,
        message: _searchQuery.isNotEmpty ? 'Aucun événement trouvé' : 'Aucun événement',
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredEvents.length,
        itemBuilder: (ctx, i) => _buildEventCard(_filteredEvents[i]),
      ),
    );
  }

  Widget _buildEventCard(Evenement event) {
    final statusColor = AppConstants.statutColors[event.statut] ?? AppColors.textMuted;
    final dateStr = event.dateEvenement != null ? DateFormat('dd/MM/yyyy').format(event.dateEvenement!) : '';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.2),
          child: Icon(AppConstants.statutIcons[event.statut] ?? Icons.event, color: statusColor, size: 20),
        ),
        title: Text(event.titre, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text('$dateStr  •  ${event.organisateurNom ?? "Inconnu"}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
              child: Text(event.statut ?? '', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.info_outline, size: 20),
              tooltip: 'Détails',
              onPressed: () => EventDetailsSheet.show(context, event: event),
            ),
          ],
        ),
      ),
    );
  }
}
