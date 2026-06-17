import 'package:flutter/material.dart';
import '../../core/services/evenement_service.dart';
import '../../core/services/reservation_service.dart';
import '../../core/api/dio_config.dart';
import '../../models/evenement_model.dart';
import '../../core/assets/app_colors.dart';
import '../../widgets/error_state.dart';
import '../../core/utils/error_helper.dart';
import '../../generated/app_localizations.dart';

class RefundPage extends StatefulWidget {
  const RefundPage({super.key});

  @override
  State<RefundPage> createState() => _RefundPageState();
}

class _RefundPageState extends State<RefundPage> {
  bool _loading = true;
  String? _error;
  List<Evenement> _events = [];
  int? _selectedEventId;
  List<Map<String, dynamic>> _reservations = [];
  bool _loadingReservations = false;
  int _processingId = -1;

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

  Future<void> _loadReservations(int eventId) async {
    setState(() { _selectedEventId = eventId; _loadingReservations = true; });
    try {
      final data = await ReservationService().getEventReservations(eventId);
      if (!mounted) return;
      setState(() { _reservations = data.cast<Map<String, dynamic>>(); _loadingReservations = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _reservations = []; _loadingReservations = false; });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(apiErrorString(e)), backgroundColor: AppTheme.errorColor));
    }
  }

  Future<void> _processRefund(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.confirmRefundTitle),
        content: Text(AppLocalizations.of(context)!.confirmRefundText('$id')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppLocalizations.of(context)!.cancelRefundButton)),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentColor),
            child: Text(AppLocalizations.of(context)!.confirmRefundButton, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _processingId = id);
    try {
      final result = await ReservationService().cancelReservation(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.refundResultMessage('$id', '${result['refundAmount'] ?? 0}', AppConstants.currency)),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );
      if (_selectedEventId != null) _loadReservations(_selectedEventId!);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(apiErrorString(e)), backgroundColor: AppTheme.errorColor),
      );
    } finally {
      if (mounted) setState(() => _processingId = -1);
    }
  }

  String _fmtDate(dynamic d) {
    if (d == null) return '-';
    final s = d.toString();
    return s.length >= 10 ? s.substring(0, 10) : s;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: ModalRoute.of(context)?.canPop == true
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 22),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Text(AppLocalizations.of(context)!.refundsTitle),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorState(message: _error!, onRetry: _loadEvents)
              : Column(children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: DropdownButtonFormField<int>(
                      value: _selectedEventId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.eventDropdown, border: OutlineInputBorder(), isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                      items: _events.map((e) => DropdownMenuItem(
                        value: e.idEvenement,
                        child: Text(e.titre, style: const TextStyle(fontSize: 12)),
                      )).toList(),
                      onChanged: (v) { if (v != null) _loadReservations(v); },
                    ),
                  ),
                  Expanded(
                    child: _loadingReservations
                        ? const Center(child: CircularProgressIndicator())
                        : _selectedEventId == null
                            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.money_off, size: 48, color: AppTheme.textSecondary.withValues(alpha: 0.4)),
                                const SizedBox(height: 12),
                                Text(AppLocalizations.of(context)!.selectEvent, style: TextStyle(color: AppTheme.textSecondary)),
                              ]))
                            : _reservations.isEmpty
                                ? Center(child: Text(AppLocalizations.of(context)!.noReservations, style: TextStyle(color: AppTheme.textSecondary)))
                                : RefreshIndicator(
                                    onRefresh: () => _loadReservations(_selectedEventId!),
                                    child: ListView.builder(
                                      padding: const EdgeInsets.all(8),
                                      itemCount: _reservations.length,
                                      itemBuilder: (ctx, i) {
                                        final r = _reservations[i];
                                        final id = r['idReservation'] ?? r['id'];
                                        final idInt = id is int ? id : int.parse(id.toString());
                                        final client = r['clientNom'] ?? 'Inconnu';
                                        final date = _fmtDate(r['dateReservation']);
                                        final statut = r['statut']?.toString() ?? 'ACTIVE';
                                        final isCancelled = statut.toUpperCase() == 'CANCELLED';
                                        final montant = r['paiement'] is Map
                                            ? '${r['paiement']['montant']?.toString() ?? '-'} Ar'
                                            : '${r['montant']?.toString() ?? '-'} Ar';
                                        return Card(
                                          margin: const EdgeInsets.symmetric(vertical: 4),
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: isCancelled
                                                  ? AppTheme.errorColor.withValues(alpha: 0.1)
                                                  : AppTheme.accentColor.withValues(alpha: 0.1),
                                              child: Icon(
                                                isCancelled ? Icons.cancel : Icons.payment,
                                                color: isCancelled ? AppTheme.errorColor : AppTheme.accentColor,
                                              ),
                                            ),
                                            title: Text('Réservation #$idInt', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                            subtitle: Text('$client • $date', style: const TextStyle(fontSize: 11)),
                                            trailing: isCancelled
                                                ? Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: AppTheme.errorColor.withValues(alpha: 0.1),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(AppLocalizations.of(context)!.cancelledBadgeLabel, style: TextStyle(fontSize: 9, color: AppTheme.errorColor, fontWeight: FontWeight.w700)),
                                                  )
                                                : Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text(montant, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                                      const SizedBox(width: 4),
                                                      SizedBox(
                                                        height: 28,
                                                        child: ElevatedButton.icon(
                                                          onPressed: _processingId == idInt ? null : () => _processRefund(idInt),
                                                          icon: _processingId == idInt
                                                              ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2))
                                                              : const Icon(Icons.money_off, size: 12),
                                                          label: Text(
                                                            _processingId == idInt ? '...' : AppLocalizations.of(context)!.refundActionButton,
                                                            style: const TextStyle(fontSize: 9),
                                                          ),
                                                          style: ElevatedButton.styleFrom(
                                                            padding: const EdgeInsets.symmetric(horizontal: 6),
                                                            backgroundColor: AppTheme.accentColor,
                                                          ),
                                                        ),
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
