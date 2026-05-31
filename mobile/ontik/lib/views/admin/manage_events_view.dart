import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/event_controller.dart';
import '../../models/evenement.dart';
import '../../core/constants.dart';
import '../../widgets/error_state.dart';

class ManageEventsView extends ConsumerStatefulWidget {
  const ManageEventsView({super.key});
  @override
  ConsumerState<ManageEventsView> createState() => _ManageEventsViewState();
}

class _ManageEventsViewState extends ConsumerState<ManageEventsView> {
  bool _loading = true;
  String? _error;
  List<Evenement> _events = [];
  String _filter = '';

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(eventRepositoryProvider);
      final events = await repo.getAll();
      if (!mounted) return;
      setState(() { _events = events; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _showInfoModal(Evenement event) async {
    final repo = ref.read(eventRepositoryProvider);
    Evenement d = event;
    if (event.idEvenement != null) {
      try {
        d = await repo.getDetail(event.idEvenement!);
      } catch (_) {}
    }
    if (!mounted) return;
    final e = d;
    final statusColor = AppConstants.statutColors[e.statut] ?? Colors.grey;
    final seatsReserved = (e.placesTotal ?? 0) - (e.placesDisponibles ?? 0);
    final placesPct = (e.placesTotal != null && e.placesTotal! > 0)
        ? (seatsReserved / e.placesTotal!) * 100
        : 0.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                Expanded(child: Text(e.titre, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
                IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
              ]),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(AppConstants.statutIcons[e.statut] ?? Icons.help, size: 16, color: statusColor),
                    const SizedBox(width: 6),
                    Text(e.statut ?? '', style: TextStyle(color: statusColor, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const Divider(height: 24),

              if (e.motifAnnulation != null && e.statut == 'annule') ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Motif: ${e.motifAnnulation}', style: const TextStyle(color: Colors.red))),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              _sectionTitle('Informations'),
              _infoRow(Icons.description, 'Description', e.description ?? 'Aucune'),
              _infoRow(Icons.category, 'Catégorie', e.categorieNom ?? e.codeCategorie ?? '-'),
              _infoRow(Icons.person, 'Organisateur', e.organisateurNom ?? e.codeOrganisateur),
              const SizedBox(height: 12),

              _sectionTitle('Logistique'),
              _infoRow(Icons.location_on, 'Lieu', e.lieuNom ?? '-'),
              _infoRow(Icons.calendar_today, 'Date', e.dateEvenement?.toIso8601String().split('T').first ?? '-'),
              _infoRow(Icons.access_time, 'Heure', e.heureEvenement ?? '-'),
              const SizedBox(height: 12),

              _sectionTitle('Jauge'),
              const SizedBox(height: 4),
              if (e.placesTotal != null && e.placesTotal! > 0) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: placesPct / 100,
                    minHeight: 12,
                    backgroundColor: Colors.grey.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      placesPct > 80 ? Colors.red : placesPct > 50 ? Colors.orange : Colors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$seatsReserved / ${e.placesTotal} réservées',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ] else
                const Text('Aucune place configurée', style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 20),

              _sectionTitle('Actions'),
              const SizedBox(height: 8),
              _adminActionButton(
                icon: Icons.verified,
                label: 'Valider / Approuver',
                color: Colors.green,
                enabled: e.statut == 'planifie',
                onTap: () async {
                  Navigator.pop(ctx);
                  await _performAction(() => repo.validate(e.idEvenement!), 'Événement validé');
                },
              ),
              if (e.statut == 'suspendu')
                _adminActionButton(
                  icon: Icons.play_arrow,
                  label: 'Réactiver',
                  color: Colors.blue,
                  enabled: true,
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _performAction(() => repo.resume(e.idEvenement!), 'Événement réactivé');
                  },
                )
              else
                _adminActionButton(
                  icon: Icons.pause_circle,
                  label: 'Suspendre',
                  color: Colors.orange,
                  enabled: e.statut == 'valide' || e.statut == 'planifie' || e.statut == 'en_cours',
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _performAction(() => repo.suspend(e.idEvenement!), 'Événement suspendu');
                  },
                ),
              _adminActionButton(
                icon: Icons.cancel,
                label: 'Annuler l\'événement',
                color: Colors.red,
                enabled: e.statut != 'annule' && e.statut != 'termine',
                onTap: () async {
                  Navigator.pop(ctx);
                  final motif = await _showCancelDialog();
                  if (motif != null) {
                    await _performAction(
                      () => repo.cancel(e.idEvenement!, motif),
                      'Événement annulé',
                    );
                  }
                },
              ),
              _adminActionButton(
                icon: Icons.email,
                label: 'Contacter l\'Organisateur',
                color: Colors.indigo,
                enabled: true,
                onTap: () {
                  Navigator.pop(ctx);
                  _showContactDialog(e);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 10),
        SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
      ]),
    );
  }

  Widget _adminActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: enabled ? onTap : null,
          icon: Icon(icon, size: 18),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            foregroundColor: enabled ? color : Colors.grey,
            side: BorderSide(color: enabled ? color.withValues(alpha: 0.5) : Colors.grey.withValues(alpha: 0.3)),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }

  Future<String?> _showCancelDialog() async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Annuler l\'événement'),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Motif d\'annulation *',
            hintText: 'Raison obligatoire',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          TextButton(
            onPressed: () => ctrl.text.isNotEmpty ? Navigator.pop(ctx, ctrl.text) : null,
            child: const Text('Confirmer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return result;
  }

  void _showContactDialog(Evenement event) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Contacter l\'Organisateur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow(Icons.person, 'Nom', event.organisateurNom ?? event.codeOrganisateur),
            _infoRow(Icons.badge, 'Code', event.codeOrganisateur),
            const SizedBox(height: 12),
            const Text('Options de contact :', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.indigo),
              title: const Text('Envoyer un email'),
              subtitle: Text('À ${event.codeOrganisateur}'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fonctionnalité email à implémenter')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.teal),
              title: const Text('Discussion interne'),
              subtitle: const Text('Ouvrir un chat'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fonctionnalité chat à implémenter')),
                );
              },
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fermer'))],
      ),
    );
  }

  Future<void> _performAction(Future<Evenement> Function() action, String successMsg) async {
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(successMsg), backgroundColor: Colors.green));
      _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filter.isEmpty ? _events : _events.where((e) =>
      e.titre.toLowerCase().contains(_filter.toLowerCase())
    ).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Événements')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorState(message: _error!, onRetry: _loadData)
              : Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Rechercher...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (v) => setState(() => _filter = v),
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadData,
                      child: filtered.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.event_busy, size: 48, color: Colors.grey.withValues(alpha: 0.4)),
                                  const SizedBox(height: 12),
                                  const Text('Aucun événement trouvé', style: TextStyle(color: Colors.grey, fontSize: 16)),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: filtered.length,
                              itemBuilder: (ctx, i) {
                                final event = filtered[i];
                                final statusColor = AppConstants.statutColors[event.statut] ?? Colors.grey;
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: statusColor.withValues(alpha: 0.2),
                                      child: Icon(AppConstants.statutIcons[event.statut] ?? Icons.event, color: statusColor),
                                    ),
                                    title: Text(event.titre, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    subtitle: Text(
                                      '${event.dateEvenement?.toIso8601String().split('T').first ?? ''}  •  ${event.organisateurNom ?? event.codeOrganisateur}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: statusColor.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(event.statut ?? '', style: TextStyle(fontSize: 11, color: statusColor)),
                                        ),
                                        const SizedBox(width: 4),
                                        IconButton(
                                          icon: const Icon(Icons.info_outline, size: 20),
                                          tooltip: 'Détails',
                                          onPressed: () => _showInfoModal(event),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ]),
    );
  }
}
