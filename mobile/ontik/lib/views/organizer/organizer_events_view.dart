import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/event_controller.dart';
import '../../repositories/event_repository.dart';
import '../../models/evenement.dart';
import '../../core/api_client.dart';
import '../../core/api_endpoints.dart';
import '../../core/constants.dart';
import '../../models/api_wrapper.dart';
import '../../widgets/error_state.dart';

class OrganizerEventsView extends ConsumerStatefulWidget {
  const OrganizerEventsView({super.key});

  @override
  ConsumerState<OrganizerEventsView> createState() => _OrganizerEventsViewState();
}

class _OrganizerEventsViewState extends ConsumerState<OrganizerEventsView> {
  bool _loading = true;
  String? _error;
  List<Evenement> _events = [];
  String _filter = '';
  String _periodFilter = 'all';
  Evenement? _selectedEvent;
  List<dynamic> _places = [];
  bool _placesLoading = false;

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    final authState = ref.read(authControllerProvider);
    final orgCode = authState.user?.codeUtilisateur ?? '';
    if (orgCode.isEmpty) return;

    setState(() => _loading = true);
    try {
      final repo = EventRepository(ApiClient());
      final events = await repo.getByOrganisateur(orgCode);
      if (!mounted) return;
      setState(() { _events = events; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _showPricingModal(Evenement event) {
    setState(() { _selectedEvent = event; _places = []; _placesLoading = true; });
    final client = ApiClient();
    client.get('/organisateur/evenements/${event.idEvenement}/places').then((resp) {
      final wrapper = ApiWrapper.fromJson(resp);
      final places = wrapper.getDataList((e) => e);
      if (!mounted) return;
      setState(() { _places = places; _placesLoading = false; });
    }).catchError((e) {
      if (!mounted) return;
      setState(() { _placesLoading = false; });
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Text('Prix & Types - ${event.titre}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
              ]),
              const Divider(),
              _buildRowPricingForm(event, ctx),
              const SizedBox(height: 16),
              const Text('Places', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (_placesLoading)
                const Center(child: CircularProgressIndicator())
              else if (_places.isEmpty)
                const Text('Aucune place trouvée', style: TextStyle(color: Colors.grey))
              else
                ...(_places as List).map((p) => _buildPlaceTile(p, ctx)),
            ],
          ),
        ),
      ),
    );
  }

  void _showEventInfo(Evenement event) {
    final sc = AppConstants.statutColors[event.statut] ?? Colors.grey;
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
            child: Text('$label :', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color)),
          ),
        ],
      ),
    );
  }

  Widget _buildRowPricingForm(Evenement event, BuildContext ctx) {
    final rangCtrl = TextEditingController();
    final prixCtrl = TextEditingController();
    String typePlace = 'VIP';

    return StatefulBuilder(builder: (ctx, setSheetState) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Configuration par Rang', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: rangCtrl,
          decoration: const InputDecoration(labelText: 'Rang (ex: A, B, C)', border: OutlineInputBorder(), isDense: true),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: typePlace,
          decoration: const InputDecoration(labelText: 'Type de place', border: OutlineInputBorder(), isDense: true),
          items: AppConstants.placeTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
          onChanged: (v) => setSheetState(() => typePlace = v!),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: prixCtrl,
          decoration: const InputDecoration(labelText: 'Prix (€)', border: OutlineInputBorder(), isDense: true),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () async {
            if (rangCtrl.text.isEmpty) return;
            final client = ApiClient();
            try {
              await client.put('/organisateur/evenements/${event.idEvenement}/places/rang/pricing', data: {
                'rang': rangCtrl.text,
                'typePlace': typePlace,
                'prix': double.tryParse(prixCtrl.text) ?? 0,
              });
              if (!ctx.mounted) return;
              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Tarification appliquée'), backgroundColor: Colors.green));
              setSheetState(() { _placesLoading = true; });
              client.get('/organisateur/evenements/${event.idEvenement}/places').then((resp) {
                final wrapper = ApiWrapper.fromJson(resp);
                if (mounted) setState(() { _places = wrapper.getDataList((e) => e); _placesLoading = false; });
              });
            } catch (e) {
              if (!ctx.mounted) return;
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
            }
          },
          icon: const Icon(Icons.check, size: 18),
          label: const Text('Appliquer au rang'),
        ),
      ],
    ));
  }

  Widget _buildPlaceTile(dynamic p, BuildContext ctx) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        dense: true,
        title: Text('${p['numeroPlace']} (${p['range'] ?? ''})'),
        subtitle: Text('${p['typePlace'] ?? 'Standard'} - ${p['prix'] != null ? '${p['prix']}€' : 'N/A'}'),
        trailing: IconButton(
          icon: const Icon(Icons.edit, size: 18),
          onPressed: () => _showPlaceEditDialog(p, ctx),
        ),
      ),
    );
  }

  void _showPlaceEditDialog(dynamic place, BuildContext ctx) {
    final typeCtrl = TextEditingController(text: place['typePlace'] ?? '');
    final prixCtrl = TextEditingController(text: place['prix']?.toString() ?? '');
    showDialog(context: ctx, builder: (dCtx) => AlertDialog(
      title: Text('Place ${place['numeroPlace']}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: place['typePlace'] ?? 'Standard',
            decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder(), isDense: true),
            items: AppConstants.placeTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) => typeCtrl.text = v!,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: prixCtrl,
            decoration: const InputDecoration(labelText: 'Prix (€)', border: OutlineInputBorder(), isDense: true),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('Annuler')),
        ElevatedButton(onPressed: () async {
          try {
            final client = ApiClient();
            await client.put('/organisateur/places/${place['numeroPlace']}/pricing?typePlace=${typeCtrl.text}&prix=${double.tryParse(prixCtrl.text) ?? 0}');
            if (!dCtx.mounted) return;
            Navigator.pop(dCtx);
            if (!ctx.mounted) return;
            Navigator.pop(ctx);
            _showPricingModal(_selectedEvent!);
          } catch (e) {
            if (!dCtx.mounted) return;
            ScaffoldMessenger.of(dCtx).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: Colors.red));
          }
        }, child: const Text('Enregistrer')),
      ],
    ));
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
                                Icon(Icons.event_busy, size: 48, color: Colors.grey.withValues(alpha: 0.4)),
                                const SizedBox(height: 12),
                                const Text('Aucun événement', style: TextStyle(color: Colors.grey, fontSize: 16)),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () => context.push('/organizer/create-event'),
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
                              final sc = AppConstants.statutColors[event.statut] ?? Colors.grey;
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
                                          if (v == 'edit') context.push('/organizer/create-event', extra: event);
                                        },
                                        itemBuilder: (ctx) => [
                                          const PopupMenuItem(value: 'info', child: ListTile(leading: Icon(Icons.info_outline, size: 18), title: Text('Info', style: TextStyle(fontSize: 13)))),
                                          const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit, size: 18), title: Text('Modifier', style: TextStyle(fontSize: 13)))),
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
        onPressed: () => context.push('/organizer/create-event'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
