import 'package:flutter/material.dart';
import '../../core/services/reservation_service.dart';
import '../../core/assets/app_colors.dart';
import '../../widgets/error_state.dart';
import '../../core/utils/error_helper.dart';

class ReservationDetailPage extends StatefulWidget {
  final int id;
  const ReservationDetailPage({super.key, required this.id});

  @override
  State<ReservationDetailPage> createState() => _ReservationDetailPageState();
}

class _ReservationDetailPageState extends State<ReservationDetailPage> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _data;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ReservationService().getReservationDetail(widget.id);
      if (!mounted) return;
      setState(() { _data = data; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = apiErrorString(e); _loading = false; });
    }
  }

  String _fmt(dynamic v) => v?.toString() ?? '-';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('R\u00E9servation #${widget.id}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorState(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _sectionHeader('Client', Icons.person),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _row('Nom', _fmt(_data!['clientNom'])),
                              _row('Code', _fmt(_data!['codeClient'])),
                              _row('Email', _fmt(_data!['clientEmail'])),
                              _row('T\u00E9l\u00E9phone', _fmt(_data!['clientTel'])),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _sectionHeader('Paiement', Icons.payment),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _row('Montant', '${_fmt(_data!['montant'])} Ar'),
                              _row('Mode', _fmt(_data!['modePaiement'])),
                              _row('Date', _fmt(_data!['datePaiement'])),
                              _row('Statut', _fmt(_data!['statutPaiement'])),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _sectionHeader('Billets', Icons.confirmation_number),
                      ..._buildTickets(),
                    ],
                  ),
                ),
    );
  }

  Widget _sectionHeader(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Icon(icon, size: 18, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text('$label :', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  List<Widget> _buildTickets() {
    final tickets = _data!['tickets'] as List? ?? [];
    if (tickets.isEmpty) {
      return [const Padding(padding: EdgeInsets.all(16), child: Text('Aucun billet', style: TextStyle(color: AppTheme.textSecondary)))];
    }
    return tickets.map((t) {
      final m = t as Map<String, dynamic>;
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_fmt(m['codeTicket']), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 4),
              Row(children: [
                if (m['numeroPlace'] != null) ...[
                  Icon(Icons.event_seat, size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text('Place ${m['numeroPlace']}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ],
                if (m['rang'] != null) ...[
                  const SizedBox(width: 8),
                  Text('Rang ${m['rang']}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ]),
              if (m['typePlace'] != null || m['prix'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(children: [
                    if (m['typePlace'] != null)
                      Text(_fmt(m['typePlace']), style: const TextStyle(fontSize: 12, color: AppTheme.primaryColor)),
                    if (m['prix'] != null) ...[
                      const SizedBox(width: 8),
                      Text('${_fmt(m['prix'])} Ar', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ]),
                ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
