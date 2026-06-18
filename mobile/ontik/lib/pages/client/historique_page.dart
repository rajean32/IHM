import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/api/dio_config.dart';
import '../../core/api/endpoints.dart';
import '../../core/assets/app_colors.dart';
import '../../core/routes/client_routes.dart';
import '../../core/utils/error_helper.dart';
import '../../models/ticket_model.dart';
import '../../widgets/event_image_widget.dart';
import '../../core/services/app_config.dart';
import '../../generated/app_localizations.dart';

class HistoriquePage extends StatefulWidget {
  const HistoriquePage({super.key});

  @override
  State<HistoriquePage> createState() => _HistoriquePageState();
}

class _HistoriquePageState extends State<HistoriquePage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final code = userCode ?? '';
    if (code.isEmpty) return;
    setState(() => _loading = true);
    try {
      final resp = await dio.get(Endpoints.reservationHistory(code));
      final data = (resp.data['data'] as List?) ?? [];
      if (!mounted) return;
      setState(() {
        _history = data.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = apiErrorString(e); _loading = false; });
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '—';
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('d MMMM yyyy \'à\' HH:mm', appLanguage).format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historique d\'achat')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 12), Text(_error!),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _loadHistory, child: const Text('Réessayer')),
                ]))
              : _history.isEmpty
                  ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textMuted),
                      const SizedBox(height: 16),
                      Text('Aucun achat', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                    ]))
                  : RefreshIndicator(
                      onRefresh: _loadHistory,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        children: _history.map((entry) => _buildReservationCard(entry)).toList(),
                      ),
                    ),
    );
  }

  Widget _buildReservationCard(Map<String, dynamic> entry) {
    final id = entry['idReservation'];
    final date = _formatDate(entry['dateReservation']?.toString());
    final ticketsData = (entry['tickets'] as List?) ?? [];
    final tickets = ticketsData.map((t) => Ticket.fromJson(t as Map<String, dynamic>)).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.ticketBorder),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.confirmation_number, color: AppColors.primary, size: 22),
        ),
        title: Text('Réservation #$id', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(date, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        children: tickets.map((t) => _buildTicketMini(t)).toList(),
      ),
    );
  }

  Widget _buildTicketMini(Ticket t) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, ClientRoutes.ticket, arguments: {'code': t.codeTicket}),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 48,
                height: 48,
                child: t.image != null
                    ? eventImageWidget(t.image, width: 48, height: 48, fit: BoxFit.cover)
                    : Container(color: AppColors.divider, child: const Icon(Icons.event, size: 24, color: AppColors.textMuted)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.evenementTitre ?? 'Événement', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(t.codeTicket, style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'monospace')),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}