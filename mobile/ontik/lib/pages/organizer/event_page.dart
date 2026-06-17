import 'package:flutter/material.dart';
import '../../core/services/evenement_service.dart';
import '../../core/api/dio_config.dart';
import '../../models/evenement_model.dart';
import '../../core/assets/app_colors.dart';
import '../../widgets/error_state.dart';
import '../../widgets/event_image_widget.dart';
import 'create_event_page.dart';
import '../../core/utils/error_helper.dart';
import '../../generated/app_localizations.dart';

class EventPage extends StatefulWidget {
  final Function(int eventId)? onViewReservations;

  const EventPage({super.key, this.onViewReservations});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  bool _loading = true;
  String? _error;
  List<Evenement> _events = [];


  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData({bool showLoader = true}) async {
    final orgCode = userCode ?? '';
    if (orgCode.isEmpty) return;

    if (showLoader) setState(() => _loading = true);
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

  Future<void> _suspendEvent(Evenement event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.suspendEventTitle),
        content: Text(AppLocalizations.of(context)!.suspendConfirm(event.titre)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppLocalizations.of(ctx)!.commonCancel)),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            child: Text(AppLocalizations.of(context)!.suspend, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await EvenementService().suspendEvent(event.idEvenement!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.eventSuspended), backgroundColor: AppColors.accent),
      );
      _loadData(showLoader: false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(apiErrorString(e)), backgroundColor: AppTheme.errorColor),
      );
    }
  }

  Future<void> _resumeEvent(Evenement event) async {
    try {
      await EvenementService().resumeEvent(event.idEvenement!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.eventResumed), backgroundColor: AppColors.secondary),
      );
      _loadData(showLoader: false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(apiErrorString(e)), backgroundColor: AppTheme.errorColor),
      );
    }
  }

  Future<void> _cancelEvent(Evenement event) async {
    final motifCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.cancelEventTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.cancelConfirm(event.titre)),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context)!.cancelNotify, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 12),
            TextField(
              controller: motifCtrl,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.cancelReason,
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppLocalizations.of(ctx)!.commonBack)),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: Text(AppLocalizations.of(context)!.cancelEvent, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await EvenementService().cancelEvent(event.idEvenement!, motifCtrl.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.eventCancelled), backgroundColor: AppTheme.errorColor),
      );
      _loadData(showLoader: false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(apiErrorString(e)), backgroundColor: AppTheme.errorColor),
      );
    }
  }

  String _eventStatusKey(Evenement event) {
    final statut = event.statut;
    if (statut == 'suspendu') return 'suspended';
    if (statut == 'annule') return 'cancelled';
    if (event.dateEvenement == null) return 'upcoming';
    final now = DateTime.now();
    final diff = event.dateEvenement!.difference(now);
    if (diff.isNegative && diff.inDays > -1) return 'in_progress';
    if (diff.isNegative) return 'ended';
    return 'upcoming';
  }

  String _eventStatusLabel(Evenement event) {
    switch (_eventStatusKey(event)) {
      case 'suspended': return AppLocalizations.of(context)!.statusSuspended;
      case 'cancelled': return AppLocalizations.of(context)!.statusCancelled;
      case 'in_progress': return AppLocalizations.of(context)!.statusInProgress;
      case 'ended': return AppLocalizations.of(context)!.statusEnded;
      default: return AppLocalizations.of(context)!.statusUpcoming;
    }
  }

  String _eventCountdown(Evenement event) {
    if (event.dateEvenement == null) return '';
    final now = DateTime.now();
    final diff = event.dateEvenement!.difference(now);
    if (diff.isNegative) {
      final past = -diff;
      if (past.inMinutes < 60) return AppLocalizations.of(context)!.endedMin('${past.inMinutes}');
      if (past.inHours < 24) return AppLocalizations.of(context)!.endedH('${past.inHours}');
      if (past.inDays < 30) return AppLocalizations.of(context)!.endedD('${past.inDays}');
      if (past.inDays < 365) return AppLocalizations.of(context)!.endedMonths('${(past.inDays / 30).round()}');
      return AppLocalizations.of(context)!.endedYears('${(past.inDays / 365).round()}');
    }
    if (diff.inMinutes < 60) return AppLocalizations.of(context)!.startsMin('${diff.inMinutes}');
    if (diff.inHours < 24) return AppLocalizations.of(context)!.startsH('${diff.inHours}');
    return AppLocalizations.of(context)!.startsD('${diff.inDays}');
  }

  Color _eventStatusColor(String key) {
    switch (key) {
      case 'upcoming': return AppColors.statusPlanned;
      case 'in_progress': return AppColors.statusInProgress;
      case 'ended': return AppColors.statusDone;
      case 'suspended': return AppColors.statusSuspended;
      case 'cancelled': return AppColors.statusCancelled;
      default: return AppTheme.textSecondary;
    }
  }

  Color _eventBadgeBg(String key) {
    return _eventStatusColor(key).withValues(alpha: 0.15);
  }

  IconData _eventStatusIcon(String key) {
    switch (key) {
      case 'upcoming': return Icons.schedule;
      case 'in_progress': return Icons.play_circle;
      case 'ended': return Icons.check_circle_outline;
      case 'suspended': return Icons.pause_circle;
      case 'cancelled': return Icons.cancel;
      default: return Icons.event;
    }
  }

  void _showEventInfo(Evenement event) {
    final sk = _eventStatusKey(event);
    final sc = _eventStatusColor(sk);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(children: [
          Icon(_eventStatusIcon(sk), color: sc, size: 24),
          const SizedBox(width: 8),
          Expanded(child: Text(event.titre, style: const TextStyle(fontSize: 16))),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow(AppLocalizations.of(context)!.statusLabel, _eventStatusLabel(event), sc),
            _infoRow(AppLocalizations.of(context)!.dateLabel, event.dateEvenement?.toIso8601String().split('T').first ?? '-'),
            _infoRow(AppLocalizations.of(context)!.timeLabel, event.heureEvenement ?? '-'),
            _infoRow(AppLocalizations.of(context)!.countdownLabel, _eventCountdown(event)),
            if (event.description != null) _infoRow(AppLocalizations.of(context)!.descriptionLabel, event.description!),
            _infoRow(AppLocalizations.of(context)!.categoryLabel, event.categorieNom ?? '-'),
            _infoRow(AppLocalizations.of(context)!.locationLabel, event.lieuNom ?? '-'),
            _infoRow(AppLocalizations.of(context)!.organizerLabel, event.organisateurNom ?? '-'),
            if (event.idEvenement != null) _infoRow('ID', event.idEvenement.toString()),
            if (event.caracteristiqueValeurs != null && event.caracteristiqueValeurs!.isNotEmpty) ...[
              const Divider(height: 16),
              Text(AppLocalizations.of(context)!.featuresLabel, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ...event.caracteristiqueValeurs!.map((c) =>
                _infoRow(c.nomCaracteristique ?? AppLocalizations.of(context)!.feature, c.valeur)),
            ],
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppLocalizations.of(ctx)!.commonClose))],
      ),
    );
  }

  Widget _infoRow(String label, String value, [Color? color]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text('$label :', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary))),
          Expanded(child: Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorState(message: _error!, onRetry: _loadData)
              : Column(children: [
                  Expanded(
                    child: _events.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.event_busy, size: 48, color: AppTheme.textSecondary.withValues(alpha: 0.4)),
                                const SizedBox(height: 12),
                                Text(AppLocalizations.of(context)!.noEvents, style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    await Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateEventPage()));
                                    _loadData(showLoader: false);
                                  },
                                  icon: const Icon(Icons.add, size: 18),
                                  label: Text(AppLocalizations.of(context)!.createEvent),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: _events.length,
                            itemBuilder: (ctx, i) {
                              final event = _events[i];
                              final sk = _eventStatusKey(event);
                              final status = _eventStatusLabel(event);
                              final sc = _eventStatusColor(sk);
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    eventImageWidget(event.image, height: 140),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(                                          children: [
                                            CircleAvatar(
                                              backgroundColor: _eventBadgeBg(sk),
                                              child: Icon(_eventStatusIcon(sk), color: sc, size: 20),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(event.titre, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    '${event.dateEvenement?.toIso8601String().split('T').first ?? ''}',
                                                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: _eventBadgeBg(status),
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(color: sc.withValues(alpha: 0.4)),
                                              ),
                                              child: Text(status, style: TextStyle(fontSize: 9, color: sc, fontWeight: FontWeight.w700)),
                                            ),
                                            const SizedBox(width: 4),
                                            PopupMenuButton<String>(
                                              onSelected: (v) async {
                                                if (v == 'info') _showEventInfo(event);
                                                if (v == 'suspend') _suspendEvent(event);
                                                if (v == 'resume') _resumeEvent(event);
                                                if (v == 'cancel') _cancelEvent(event);
                                              },
                                              itemBuilder: (ctx) => [
                                                PopupMenuItem(value: 'info', child: ListTile(leading: Icon(Icons.info_outline, size: 18), title: Text(AppLocalizations.of(context)!.info, style: TextStyle(fontSize: 13)))),
                                                if (sk != 'suspended' && sk != 'cancelled')
                                                  PopupMenuItem(value: 'suspend', child: ListTile(leading: Icon(Icons.pause_circle, size: 18, color: AppColors.accent), title: Text(AppLocalizations.of(context)!.suspend, style: TextStyle(fontSize: 13, color: AppColors.accent)))),
                                                if (sk == 'suspended')
                                                  PopupMenuItem(value: 'resume', child: ListTile(leading: Icon(Icons.play_arrow, size: 18, color: AppColors.primary), title: Text(AppLocalizations.of(context)!.reactivate, style: TextStyle(fontSize: 13, color: AppColors.primary)))),
                                                if (sk != 'ended' && sk != 'cancelled')
                                                  PopupMenuItem(value: 'cancel', child: ListTile(leading: Icon(Icons.cancel, size: 18, color: AppTheme.errorColor), title: Text(AppLocalizations.of(context)!.cancelEvent, style: TextStyle(fontSize: 13, color: AppTheme.errorColor)))),
                                              ],
                                            ),
                                          ]),
                                          const Divider(height: 12),
                                          Row(children: [
                                        if (widget.onViewReservations != null && event.idEvenement != null)
                                          Expanded(
                                            child: SizedBox(
                                              height: 30,
                                              child: OutlinedButton.icon(
                                                onPressed: () => widget.onViewReservations!(event.idEvenement!),
                                                icon: const Icon(Icons.receipt_long, size: 14),
                                                label: Text(AppLocalizations.of(context)!.reservations, style: TextStyle(fontSize: 10)),
                                                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4)),
                                              ),
                                            ),
                                          ),
                                        if (widget.onViewReservations != null && event.idEvenement != null)
                                          const SizedBox(width: 6),
                                        Expanded(
                                          child: SizedBox(
                                            height: 30,
                                            child: OutlinedButton.icon(
                                              onPressed: () => _showEventInfo(event),
                                              icon: const Icon(Icons.info_outline, size: 14),
                                              label: Text(AppLocalizations.of(context)!.info, style: TextStyle(fontSize: 10)),
                                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4)),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: SizedBox(
                                            height: 30,
                                            child: OutlinedButton.icon(
                                              onPressed: () async {
                                                await Navigator.push(context, MaterialPageRoute(builder: (_) => CreateEventPage(event: event)));
                                                _loadData(showLoader: false);
                                              },
                                              icon: const Icon(Icons.edit, size: 14),
                                              label: Text(AppLocalizations.of(context)!.commonEdit, style: TextStyle(fontSize: 10)),
                                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4)),
                                            ),
                                          ),
                                        ),
                                      ]),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            );
                            },
                          ),
                  ),
                ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateEventPage()));
          _loadData(showLoader: false);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
