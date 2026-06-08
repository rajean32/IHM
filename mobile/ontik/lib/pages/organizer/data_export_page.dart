import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../core/services/evenement_service.dart';
import '../../core/services/ticket_service.dart';
import '../../core/services/reservation_service.dart';
import '../../core/api/dio_config.dart';
import '../../models/evenement_model.dart';
import '../../core/assets/app_colors.dart';
import '../../widgets/error_state.dart';
import '../../core/utils/error_helper.dart';

class DataExportPage extends StatefulWidget {
  const DataExportPage({super.key});

  @override
  State<DataExportPage> createState() => _DataExportPageState();
}

class _DataExportPageState extends State<DataExportPage> {
  bool _loading = true;
  String? _error;
  List<Evenement> _events = [];
  bool _exporting = false;
  String? _exportMessage;

  @override
  void initState() { super.initState(); _loadEvents(); }

  Future<void> _loadEvents() async {
    final orgCode = userCode ?? '';
    if (orgCode.isEmpty) return;
    setState(() => _loading = true);
    try {
      final data = await EvenementService().getEvents(orgCode: orgCode);
      final events = data.map((e) => Evenement.fromJson(e as Map<String, dynamic>)).toList();
      if (!mounted) return;
      setState(() { _events = events; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = apiErrorString(e); _loading = false; });
    }
  }

  Future<void> _exportTickets(Evenement event) async {
    setState(() { _exporting = true; _exportMessage = null; });
    try {
      final raw = await TicketService().getEventTickets(event.idEvenement!);
      final tickets = raw.cast<Map<String, dynamic>>();
      final buffer = StringBuffer();
      buffer.writeln('CodeTicket;Client;Place;Rang;Type;Prix;Statut');
      for (final t in tickets) {
        buffer.writeln('${t['codeTicket'] ?? ''};${t['clientNom'] ?? ''};${t['numeroPlace'] ?? ''};${t['rang'] ?? ''};${t['typePlace'] ?? ''};${t['prix'] ?? ''};${t['statut'] ?? ''}');
      }
      await _saveFile('tickets_${event.titre.replaceAll(' ', '_')}.csv', buffer.toString());
    } catch (e) {
      if (!mounted) return;
      setState(() => _exportMessage = 'Erreur: ${apiErrorString(e)}');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _exportReservations(Evenement event) async {
    setState(() { _exporting = true; _exportMessage = null; });
    try {
      final raw = await ReservationService().getEventReservations(event.idEvenement!);
      final reservations = raw.cast<Map<String, dynamic>>();
      final buffer = StringBuffer();
      buffer.writeln('ID Reservation;Client;Date;Montant;Statut;Tickets');
      for (final r in reservations) {
        final id = r['idReservation'] ?? r['id'] ?? '';
        final client = r['clientNom'] ?? '';
        final date = r['dateReservation']?.toString() ?? '';
        final montant = r['paiement'] is Map ? r['paiement']['montant'] ?? '' : r['montant'] ?? '';
        final tickets = r['tickets'] is List ? (r['tickets'] as List).length : 0;
        buffer.writeln('$id;$client;$date;$montant;${r['statut'] ?? ''};$tickets');
      }
      await _saveFile('reservations_${event.titre.replaceAll(' ', '_')}.csv', buffer.toString());
    } catch (e) {
      if (!mounted) return;
      setState(() => _exportMessage = 'Erreur: ${apiErrorString(e)}');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _exportAll(Evenement event) async {
    await _exportTickets(event);
    if (_exportMessage != null && _exportMessage!.startsWith('Erreur')) return;
    await _exportReservations(event);
  }

  Future<void> _saveFile(String filename, String content) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsString(content);
    if (!mounted) return;
    setState(() => _exportMessage = 'Exporté: ${file.path}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fichier sauvegardé: $filename'),
        backgroundColor: AppTheme.secondaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export des données')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorState(message: _error!, onRetry: _loadEvents)
              : _events.isEmpty
                  ? const Center(child: Text('Aucun événement', style: TextStyle(color: AppTheme.textSecondary)))
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        const Text(
                          'Sélectionnez un événement pour exporter les données',
                          style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        ..._events.map((event) => Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(event.titre, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                const SizedBox(height: 8),
                                Row(children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 36,
                                      child: OutlinedButton.icon(
                                        onPressed: _exporting ? null : () => _exportTickets(event),
                                        icon: const Icon(Icons.confirmation_number, size: 14),
                                        label: const Text('Billets CSV', style: TextStyle(fontSize: 10)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: SizedBox(
                                      height: 36,
                                      child: OutlinedButton.icon(
                                        onPressed: _exporting ? null : () => _exportReservations(event),
                                        icon: const Icon(Icons.receipt, size: 14),
                                        label: const Text('Réserv. CSV', style: TextStyle(fontSize: 10)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: SizedBox(
                                      height: 36,
                                      child: ElevatedButton.icon(
                                        onPressed: _exporting ? null : () => _exportAll(event),
                                        icon: _exporting
                                            ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2))
                                            : const Icon(Icons.download, size: 14),
                                        label: const Text('Tout', style: TextStyle(fontSize: 10)),
                                      ),
                                    ),
                                  ),
                                ]),
                              ],
                            ),
                          ),
                        )),
                        if (_exportMessage != null) ...[
                          const SizedBox(height: 12),
                          Card(
                            color: _exportMessage!.startsWith('Erreur')
                                ? AppTheme.errorColor.withValues(alpha: 0.1)
                                : AppTheme.secondaryColor.withValues(alpha: 0.1),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(children: [
                                Icon(
                                  _exportMessage!.startsWith('Erreur') ? Icons.error : Icons.check_circle,
                                  size: 18,
                                  color: _exportMessage!.startsWith('Erreur') ? AppTheme.errorColor : AppTheme.secondaryColor,
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Text(_exportMessage!, style: const TextStyle(fontSize: 12))),
                              ]),
                            ),
                          ),
                        ],
                      ],
                    ),
    );
  }
}
