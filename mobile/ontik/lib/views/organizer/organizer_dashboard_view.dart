import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/auth_controller.dart';
import '../../repositories/dashboard_repository.dart';
import '../../models/dashboard.dart';
import '../../models/evenement.dart';
import '../../core/api_client.dart';
import '../../core/constants.dart';
import '../../widgets/error_state.dart';

class OrganizerDashboardView extends ConsumerStatefulWidget {
  const OrganizerDashboardView({super.key});

  @override
  ConsumerState<OrganizerDashboardView> createState() => _OrganizerDashboardViewState();
}

class _OrganizerDashboardViewState extends ConsumerState<OrganizerDashboardView> {
  bool _loading = true;
  String? _error;
  OrganizerDashboardStats? _stats;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authState = ref.read(authControllerProvider);
    final orgCode = authState.user?.codeUtilisateur ?? '';
    if (orgCode.isEmpty) return;

    setState(() => _loading = true);
    try {
      final dashboardRepo = DashboardRepository(ApiClient());
      final stats = await dashboardRepo.getOrganizerStats(orgCode);
      if (!mounted) return;
      setState(() { _stats = stats; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
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
                        _buildStatsGrid(),
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

  Widget _buildStatsGrid() {
    final stats = _stats!;
    return Column(
      children: [
        Row(children: [
          Expanded(child: _statCard('CA Global', '${stats.totalRevenue.toStringAsFixed(2)} €', Icons.attach_money, Colors.green)),
          const SizedBox(width: 12),
          Expanded(child: _statCard('Taux Remplissage', '${stats.fillRate.toStringAsFixed(1)}%', Icons.pie_chart, Colors.blue)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _statCard('Billets Vendus', '${stats.totalTicketsSold}', Icons.confirmation_number, Colors.orange)),
          const SizedBox(width: 12),
          Expanded(child: _statCard('Places Dispo.', '${stats.placesDisponibles}', Icons.event_seat, Colors.purple)),
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
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
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
                      color: Colors.green,
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
              trailing: Text('${e.value.placesDisponibles ?? 0} billets', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(children: [
      Expanded(child: _actionButton('Créer Événement', Icons.add, Colors.blue, () => context.push('/organizer/create-event'))),
      const SizedBox(width: 12),
      Expanded(child: _actionButton('Scanner', Icons.qr_code_scanner, Colors.green, () => context.push('/organizer/scan'))),
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
