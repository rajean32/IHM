import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';
import '../../core/services/dashboard_service.dart';

import '../../core/api/dio_config.dart';
import '../../models/dashboard_model.dart';

import '../../core/assets/app_colors.dart';
import '../../widgets/error_state.dart';
import 'create_event_page.dart';
import 'scan_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _loading = true;
  String? _error;
  OrganizerDashboardStats? _stats;

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
          Expanded(child: _statCard('CA Global', '${stats.totalRevenue.toStringAsFixed(2)} ${AppConstants.currency}', Icons.attach_money, AppTheme.secondaryColor)),
          const SizedBox(width: 12),
          Expanded(child: _statCard('Taux Remplissage', '${stats.fillRate.toStringAsFixed(1)}%', Icons.pie_chart, AppTheme.primaryColor)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _statCard('Billets Vendus', '${stats.totalTicketsSold}', Icons.confirmation_number, AppTheme.accentColor)),
          const SizedBox(width: 12),
          Expanded(child: _statCard('Places Dispo.', '${stats.placesDisponibles}', Icons.event_seat, const Color(0xFF7B1FA2))),
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
            const Text('\u00C9volution des Ventes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
            const Text('Top \u00C9v\u00E9nements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
    return Row(children: [
      Expanded(child: _actionButton('Cr\u00E9er \u00C9v\u00E9nement', Icons.add, AppTheme.primaryColor, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateEventPage())))),
      const SizedBox(width: 12),
      Expanded(child: _actionButton('Scanner', Icons.qr_code_scanner, AppTheme.secondaryColor, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanPage())))),
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
