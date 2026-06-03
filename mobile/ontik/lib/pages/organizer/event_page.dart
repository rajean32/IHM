import 'package:flutter/material.dart';
import '../../core/services/evenement_service.dart';
import '../../core/api/dio_config.dart';
import '../../models/evenement_model.dart';
import '../../core/assets/app_colors.dart';
import '../../widgets/error_state.dart';
import 'create_event_page.dart';
import 'pricing_page.dart';
import '../../core/utils/error_helper.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  bool _loading = true;
  String? _error;
  List<Evenement> _events = [];
  String _filter = '';
  String _periodFilter = 'all';

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    final orgCode = userCode ?? '';
    if (orgCode.isEmpty) return;

    setState(() => _loading = true);
    try {
      final eventService = EvenementService();
      final data = await eventService.getEvents(orgCode: orgCode);
      final events = data.map((e) => Evenement.fromJson(e as Map<String, dynamic>)).toList();
      if (!mounted) return;
      setState(() { _events = events; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = apiErrorString(e); _loading = false; });
    }
  }

  void _showPricingModal(Evenement event) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => PricingPage(eventId: event.idEvenement!)));
  }

  Future<void> _deleteEvent(Evenement event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer l\'événement'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${event.titre}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await EvenementService().deleteEvent(event.idEvenement!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Événement supprimé')),
      );
      _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(apiErrorString(e)), backgroundColor: AppTheme.errorColor),
      );
    }
  }

  void _showEventInfo(Evenement event) {
    final sc = AppConstants.statutColors[event.statut] ?? AppTheme.textSecondary;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(children: [
          Icon(AppConstants.statutIcons[event.statut] ?? Icons.event, color: sc, size: 24),
          const SizedBox(width: 8),
          Expanded(child: Text(event.titre, style: const TextStyle(fontSize: 16))),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Statut', event.statut ?? '-', sc),
            _infoRow('Date', event.dateEvenement?.toIso8601String().split('T').first ?? '-'),
            _infoRow('Heure', event.heureEvenement ?? '-'),
            if (event.description != null) _infoRow('Description', event.description!),
            _infoRow('Catégorie', event.categorieNom ?? '-'),
            _infoRow('Lieu', event.lieuNom ?? '-'),
            _infoRow('Organisateur', event.organisateurNom ?? '-'),
            if (event.idEvenement != null) _infoRow('ID', event.idEvenement.toString()),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fermer'))],
      ),
    );
  }

  Widget _infoRow(String label, String value, [Color? color]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text('$label :', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final filtered = _events.where((e) {
      if (_filter.isNotEmpty && !e.titre.toLowerCase().contains(_filter.toLowerCase())) return false;
      if (_periodFilter == 'upcoming' && e.dateEvenement != null && e.dateEvenement!.isBefore(now)) return false;
      if (_periodFilter == 'past' && e.dateEvenement != null && !e.dateEvenement!.isBefore(now)) return false;
      if (_periodFilter == 'today' && e.dateEvenement != null &&
          (e.dateEvenement!.year != now.year || e.dateEvenement!.month != now.month || e.dateEvenement!.day != now.day)) return false;
      return true;
    }).toList();

    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorState(message: _error!, onRetry: _loadData)
              : Column(children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: Row(children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(hintText: 'Rechercher...', prefixIcon: Icon(Icons.search), border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 8)),
                          onChanged: (v) => setState(() => _filter = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 110,
                        child: DropdownButtonFormField<String>(
                          value: _periodFilter,
                          isExpanded: true,
                          decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('Tous', style: TextStyle(fontSize: 11))),
                            DropdownMenuItem(value: 'upcoming', child: Text('À venir', style: TextStyle(fontSize: 11))),
                            DropdownMenuItem(value: 'today', child: Text('Aujourd\'hui', style: TextStyle(fontSize: 11))),
                            DropdownMenuItem(value: 'past', child: Text('Passés', style: TextStyle(fontSize: 11))),
                          ],
                          onChanged: (v) => setState(() => _periodFilter = v!),
                        ),
                      ),
                    ]),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.event_busy, size: 48, color: AppTheme.textSecondary.withValues(alpha: 0.4)),
                                const SizedBox(height: 12),
                                const Text('Aucun événement', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateEventPage())),
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('Créer un événement'),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: filtered.length,
                            itemBuilder: (ctx, i) {
                              final event = filtered[i];
                              final sc = AppConstants.statutColors[event.statut] ?? AppTheme.textSecondary;
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: sc.withValues(alpha: 0.2),
                                    child: Icon(AppConstants.statutIcons[event.statut] ?? Icons.event, color: sc, size: 20),
                                  ),
                                  title: Text(event.titre, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                  subtitle: Text(
                                    '${event.dateEvenement?.toIso8601String().split('T').first ?? ''} • ${event.statut}',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: sc.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: sc.withValues(alpha: 0.4)),
                                        ),
                                        child: Text(event.statut ?? '', style: TextStyle(fontSize: 10, color: sc, fontWeight: FontWeight.w600)),
                                      ),
                                      PopupMenuButton<String>(
                                        onSelected: (v) {
                                          if (v == 'info') _showEventInfo(event);
                                          if (v == 'edit') Navigator.push(context, MaterialPageRoute(builder: (_) => CreateEventPage(event: event)));
                                          if (v == 'pricing') _showPricingModal(event);
                                          if (v == 'delete') _deleteEvent(event);
                                        },
                                        itemBuilder: (ctx) => [
                                          const PopupMenuItem(value: 'info', child: ListTile(leading: Icon(Icons.info_outline, size: 18), title: Text('Info', style: TextStyle(fontSize: 13)))),
                                          const PopupMenuItem(value: 'pricing', child: ListTile(leading: Icon(Icons.attach_money, size: 18), title: Text('Prix', style: TextStyle(fontSize: 13)))),
                                          const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit, size: 18), title: Text('Modifier', style: TextStyle(fontSize: 13)))),
                                          const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete, size: 18, color: AppTheme.errorColor), title: Text('Supprimer', style: TextStyle(fontSize: 13, color: AppTheme.errorColor)))),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateEventPage())),
        child: const Icon(Icons.add),
      ),
    );
  }
}
