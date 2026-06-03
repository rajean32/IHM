import 'package:flutter/material.dart';
import '../../core/services/evenement_service.dart';
import '../../core/api/dio_config.dart';
import '../../core/api/endpoints.dart';
import '../../core/assets/app_colors.dart';
import '../../core/utils/error_helper.dart';
import '../../models/evenement_model.dart';
import '../../widgets/error_state.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});
  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  bool _loading = true;
  String? _error;
  List<Evenement> _events = [];
  String _filter = '';
  final _api = EvenementService();

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final eventsData = await _api.getEvents();
      if (!mounted) return;
      setState(() {
        _events = eventsData.map((e) => Evenement.fromJson(e as Map<String, dynamic>)).toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = apiErrorString(e); _loading = false; });
    }
  }

  Future<void> _showInfoModal(Evenement event) async {
    final e = event;
    Evenement detail = e;
    if (e.idEvenement != null) {
      try {
        final resp = await dio.get(Endpoints.eventById(e.idEvenement!));
        final data = resp.data['data'] as Map<String, dynamic>;
        detail = Evenement.fromJson(data);
      } catch (_) {}
    }
    if (!mounted) return;
    final statusColor = AppConstants.statutColors[detail.statut] ?? AppColors.textSecondary;
    final seatsReserved = (detail.placesTotal ?? 0) - (detail.placesDisponibles ?? 0);
    final placesPct = (detail.placesTotal != null && detail.placesTotal! > 0)
        ? (seatsReserved / detail.placesTotal!) * 100
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
                Expanded(child: Text(detail.titre, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
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
                    Icon(AppConstants.statutIcons[detail.statut] ?? Icons.help, size: 16, color: statusColor),
                    const SizedBox(width: 6),
                    Text(detail.statut ?? '', style: TextStyle(color: statusColor, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const Divider(height: 24),

              if (detail.motifAnnulation != null && detail.statut == 'annule') ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber, color: AppColors.error, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Motif: ${detail.motifAnnulation}', style: const TextStyle(color: AppColors.error))),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              _sectionTitle('Informations'),
              _infoRow(Icons.description, 'Description', detail.description ?? 'Aucune'),
              _infoRow(Icons.category, 'Catégorie', detail.categorieNom ?? detail.codeCategorie ?? '-'),
              _infoRow(Icons.person, 'Organisateur', detail.organisateurNom ?? detail.codeOrganisateur),
              const SizedBox(height: 12),

              _sectionTitle('Logistique'),
              _infoRow(Icons.location_on, 'Lieu', detail.lieuNom ?? '-'),
              _infoRow(Icons.calendar_today, 'Date', detail.dateEvenement?.toIso8601String().split('T').first ?? '-'),
              _infoRow(Icons.access_time, 'Heure', detail.heureEvenement ?? '-'),
              const SizedBox(height: 12),

              _sectionTitle('Jauge'),
              const SizedBox(height: 4),
              if (detail.placesTotal != null && detail.placesTotal! > 0) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: placesPct / 100,
                    minHeight: 12,
                    backgroundColor: AppColors.textSecondary.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      placesPct > 80 ? AppColors.error : placesPct > 50 ? AppColors.accent : AppColors.secondary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$seatsReserved / ${detail.placesTotal} réservées',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ] else
                const Text('Aucune place configurée', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 20),

              _sectionTitle('Actions'),
              const SizedBox(height: 8),
              _adminActionButton(
                icon: Icons.verified,
                label: 'Valider / Approuver',
                color: AppColors.secondary,
                enabled: detail.statut == 'planifie',
                onTap: () async {
                  Navigator.pop(ctx);
                  await _performAction(() => _api.validateEvent(detail.idEvenement!), 'Événement validé');
                },
              ),
              if (detail.statut == 'suspendu')
                _adminActionButton(
                  icon: Icons.play_arrow,
                  label: 'Réactiver',
                  color: AppColors.primary,
                  enabled: true,
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _performAction(
                      () => dio.put('${Endpoints.events}/${detail.idEvenement}/resume'),
                      'Événement réactivé',
                    );
                  },
                )
              else
                _adminActionButton(
                  icon: Icons.pause_circle,
                  label: 'Suspendre',
                  color: AppColors.accent,
                  enabled: detail.statut == 'valide' || detail.statut == 'planifie' || detail.statut == 'en_cours',
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _performAction(
                      () => dio.put('${Endpoints.events}/${detail.idEvenement}/suspend'),
                      'Événement suspendu',
                    );
                  },
                ),
              _adminActionButton(
                icon: Icons.cancel,
                label: 'Annuler l\'événement',
                color: AppColors.error,
                enabled: detail.statut != 'annule' && detail.statut != 'termine',
                onTap: () async {
                  Navigator.pop(ctx);
                  final motif = await _showCancelDialog();
                  if (motif != null) {
                    await _performAction(
                      () => dio.put('${Endpoints.events}/${detail.idEvenement}/cancel', data: {'motifAnnulation': motif}),
                      'Événement annulé',
                    );
                  }
                },
              ),
              _adminActionButton(
                icon: Icons.email,
                label: 'Contacter l\'Organisateur',
                color: AppColors.primary,
                enabled: true,
                onTap: () {
                  Navigator.pop(ctx);
                  _showContactDialog(detail);
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
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        SizedBox(width: 100, child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
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
            foregroundColor: enabled ? color : AppColors.textSecondary,
            side: BorderSide(color: enabled ? color.withValues(alpha: 0.5) : AppColors.textSecondary.withValues(alpha: 0.3)),
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
            child: const Text('Confirmer', style: TextStyle(color: AppColors.error)),
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
              leading: const Icon(Icons.email, color: AppColors.primary),
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
              leading: const Icon(Icons.chat, color: AppColors.primary),
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

  Future<void> _performAction(Future<dynamic> Function() action, String successMsg) async {
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(successMsg), backgroundColor: AppColors.secondary));
      _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(apiErrorString(e)), backgroundColor: AppColors.error));
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
                                  Icon(Icons.event_busy, size: 48, color: AppColors.textSecondary.withValues(alpha: 0.4)),
                                  const SizedBox(height: 12),
                                  const Text('Aucun événement trouvé', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: filtered.length,
                              itemBuilder: (ctx, i) {
                                final event = filtered[i];
                                final statusColor = AppConstants.statutColors[event.statut] ?? AppColors.textSecondary;
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
