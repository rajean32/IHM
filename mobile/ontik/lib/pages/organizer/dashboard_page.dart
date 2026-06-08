import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/services/dashboard_service.dart';
import '../../core/api/dio_config.dart';
import '../../models/dashboard_model.dart';
import '../../models/evenement_model.dart';
import '../../core/assets/app_colors.dart';
import '../../widgets/error_state.dart';
import 'create_event_page.dart';
import 'scan_page.dart';
import 'refund_page.dart';
import 'data_export_page.dart';
import '../../core/utils/error_helper.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _loading = true;
  String? _error;
  OrganizerDashboardStats? _stats;

  int? _filterEventId;
  String _periodFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final orgCode = userCode ?? '';
    if (orgCode.isEmpty) return;

    setState(() => _loading = true);
    try {
      final dashboardService = DashboardService();
      final data = await dashboardService.getDashboard(orgCode: orgCode);
      final stats = OrganizerDashboardStats.fromJson(data);
      if (!mounted) return;
      setState(() { _stats = stats; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = apiErrorString(e); _loading = false; });
    }
  }

  List<Evenement> get _timelineEvents {
    final events = _stats?.myEvents ?? [];
    return events.where((e) {
      if (_filterEventId != null && e.idEvenement != _filterEventId) return false;
      if (_periodFilter == 'all') return true;
      final now = DateTime.now();
      if (e.dateEvenement == null) return true;
      if (_periodFilter == 'ongoing') {
        final diff = e.dateEvenement!.difference(now);
        return diff.isNegative && diff.inDays > -1;
      }
      if (_periodFilter == 'upcoming') return e.dateEvenement!.isAfter(now);
      if (_periodFilter == 'past') return e.dateEvenement!.isBefore(now);
      return true;
    }).toList();
  }

  String _eventStatusLabel(Evenement event) {
    if (event.dateEvenement == null) return 'UPCOMING';
    final now = DateTime.now();
    final diff = event.dateEvenement!.difference(now);
    if (diff.isNegative && diff.inDays > -1) return 'ONGOING';
    if (diff.isNegative) return 'TERMINATED';
    return 'UPCOMING';
  }

  String _eventCountdown(Evenement event) {
    if (event.dateEvenement == null) return '';
    final now = DateTime.now();
    final diff = event.dateEvenement!.difference(now);
    if (diff.isNegative) {
      final past = -diff;
      if (past.inMinutes < 60) return 'Terminé il y a ${past.inMinutes} min';
      if (past.inHours < 24) return 'Terminé il y a ${past.inHours}h';
      if (past.inDays < 30) return 'Terminé il y a ${past.inDays}j';
      if (past.inDays < 365) return 'Terminé il y a ${(past.inDays / 30).round()} mois';
      return 'Terminé il y a ${(past.inDays / 365).round()} an(s)';
    }
    if (diff.inMinutes < 60) return 'Commence dans ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Commence dans ${diff.inHours}h';
    return 'Commence dans ${diff.inDays}j';
  }

  Color _eventStatusColor(String status) {
    switch (status) {
      case 'UPCOMING': return AppColors.statusPlanned;
      case 'ONGOING': return AppColors.statusInProgress;
      case 'TERMINATED': return AppColors.statusDone;
      default: return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorState(message: _error!, onRetry: _loadData)
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFilters(),
                        const SizedBox(height: 12),
                        _buildStatsGrid(),
                        const SizedBox(height: 16),
                        _buildEventTimeline(),
                        const SizedBox(height: 16),
                        _buildDailySalesChart(),
                        const SizedBox(height: 16),
                        _buildTopEvents(),
                        const SizedBox(height: 16),
                        _buildQuickActions(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildFilters() {
    final events = _stats?.myEvents ?? [];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Row(children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                value: _filterEventId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Événement', border: OutlineInputBorder(), isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
                items: [
                  const DropdownMenuItem<int>(value: null, child: Text('Tous', style: TextStyle(fontSize: 12))),
                  ...events.map((e) => DropdownMenuItem<int>(
                    value: e.idEvenement,
                    child: Text(e.titre, style: const TextStyle(fontSize: 12)),
                  )),
                ],
                onChanged: (v) => setState(() => _filterEventId = v),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 100,
              child: DropdownButtonFormField<String>(
                value: _periodFilter,
                isExpanded: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(), isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                ),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('Tout', style: TextStyle(fontSize: 11))),
                  DropdownMenuItem(value: 'ongoing', child: Text('En cours', style: TextStyle(fontSize: 11))),
                  DropdownMenuItem(value: 'upcoming', child: Text('À venir', style: TextStyle(fontSize: 11))),
                  DropdownMenuItem(value: 'past', child: Text('Passés', style: TextStyle(fontSize: 11))),
                ],
                onChanged: (v) => setState(() => _periodFilter = v!),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(children: [
          Expanded(child: _statCard('Recettes', '${_stats!.totalRevenue.toStringAsFixed(2)} ${AppConstants.currency}', Icons.attach_money, AppTheme.secondaryColor)),
          const SizedBox(width: 12),
          Expanded(child: _statCard('Taux Remplissage', '${_stats!.fillRate.toStringAsFixed(1)}%', Icons.pie_chart, AppTheme.primaryColor)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _statCard('Billets Vendus', '${_stats!.totalTicketsSold}', Icons.confirmation_number, AppTheme.accentColor)),
          const SizedBox(width: 12),
          Expanded(child: _statCard('Places Dispo.', '${_stats!.placesDisponibles}', Icons.event_seat, const Color(0xFF7B1FA2))),
        ]),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildEventTimeline() {
    final events = _timelineEvents;
    if (events.isEmpty) return const SizedBox.shrink();
    final sorted = List<Evenement>.from(events)
      ..sort((a, b) {
        if (a.dateEvenement == null && b.dateEvenement == null) return 0;
        if (a.dateEvenement == null) return 1;
        if (b.dateEvenement == null) return -1;
        return a.dateEvenement!.compareTo(b.dateEvenement!);
      });
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chronologie des événements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...sorted.take(5).map((e) {
              final status = _eventStatusLabel(e);
              final color = _eventStatusColor(status);
              return ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 14,
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Icon(
                    status == 'ONGOING' ? Icons.play_circle : (status == 'TERMINATED' ? Icons.check_circle_outline : Icons.schedule),
                    size: 16, color: color,
                  ),
                ),
                title: Text(e.titre, style: const TextStyle(fontSize: 14)),
                subtitle: Text(
                  status == 'TERMINATED'
                      ? 'Top Découlé — ${_eventCountdown(e)}'
                      : _eventCountdown(e),
                  style: TextStyle(fontSize: 11, color: color, fontStyle: FontStyle.italic),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withValues(alpha: 0.4)),
                  ),
                  child: Text(status, style: TextStyle(fontSize: 8, color: color, fontWeight: FontWeight.w700)),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDailySalesChart() {
    final sales = _stats!.dailySales;
    if (sales.isEmpty) return const SizedBox.shrink();
    final maxY = sales.fold<double>(0, (m, s) => s.ticketsSold > m ? s.ticketsSold.toDouble() : m) * 1.3;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Évolution des Ventes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY > 0 ? maxY : 10,
                  barGroups: sales.asMap().entries.map((e) => BarChartGroupData(
                    x: e.key,
                    barRods: [BarChartRodData(
                      toY: e.value.ticketsSold.toDouble(),
                      color: AppTheme.primaryColor,
                      width: 14,
                      borderRadius: BorderRadius.circular(4),
                    )],
                  )).toList(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (v, m) => Text('${v.toInt()}', style: const TextStyle(fontSize: 10)))),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
                      final idx = v.toInt();
                      if (idx < 0 || idx >= sales.length) return const Text('');
                      final parts = sales[idx].date.split('-');
                      return Text('${parts[2]}/${parts[1]}', style: const TextStyle(fontSize: 8));
                    })),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopEvents() {
    final top = _stats!.topEvents;
    if (top.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Top Événements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...top.take(5).toList().asMap().entries.map((e) => ListTile(
              dense: true,
              leading: CircleAvatar(
                radius: 14,
                child: Text('${e.key + 1}', style: const TextStyle(fontSize: 12)),
              ),
              title: Text(e.value.titre, style: const TextStyle(fontSize: 14)),
              trailing: Text('${e.value.placesDisponibles ?? 0} billets', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(children: [
      Row(children: [
        Expanded(child: _actionButton('Créer', Icons.add, AppTheme.primaryColor, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateEventPage())))),
        const SizedBox(width: 12),
        Expanded(child: _actionButton('Scanner', Icons.qr_code_scanner, AppTheme.secondaryColor, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanPage())))),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _actionButton('Remboursements', Icons.money_off, AppTheme.accentColor, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RefundPage())))),
        const SizedBox(width: 12),
        Expanded(child: _actionButton('Export', Icons.download, AppColors.statusPlanned, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DataExportPage())))),
      ]),
    ]);
  }

  Widget _actionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      height: 80,
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}
