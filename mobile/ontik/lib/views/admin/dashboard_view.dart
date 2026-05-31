import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/providers.dart';
import '../../models/dashboard.dart';
import '../../models/evenement.dart';
import '../../core/constants.dart';
import '../../widgets/error_state.dart';

class AdminDashboardView extends ConsumerStatefulWidget {
  const AdminDashboardView({super.key});

  @override
  ConsumerState<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends ConsumerState<AdminDashboardView> {
  bool _loading = true;
  String? _error;
  AdminDashboardStats? _stats;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final dashboardRepo = ref.read(dashboardRepositoryProvider);
      final stats = await dashboardRepo.getAdminStats();
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading
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
                      const SizedBox(height: 24),
                      _buildChartsSection(),
                      if (_stats!.recentEvents.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Événements récents',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ..._stats!.recentEvents.map((e) => _buildEventRow(e)),
                      ],
                    ],
                  ),
                ),
              );
  }

  Widget _buildChartsSection() {
    final stats = _stats;
    if (stats == null) return const SizedBox.shrink();
    final colors = [
      Colors.blue, Colors.green, Colors.orange, Colors.purple,
      Colors.teal, Colors.red, Colors.indigo,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Analytiques', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Par statut', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Expanded(
                          child: stats.eventsByStatus.isEmpty
                              ? const Center(child: Text('Aucune donnée'))
                              : PieChart(
                                  PieChartData(
                                    sections: stats.eventsByStatus.entries.map((e) {
                                      final idx = stats.eventsByStatus.keys.toList().indexOf(e.key);
                                      return PieChartSectionData(
                                        value: e.value.toDouble(),
                                        title: '${e.key}\n${e.value}',
                                        radius: 40,
                                        color: colors[idx % colors.length],
                                        titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                      );
                                    }).toList(),
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 20,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Par catégorie', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Expanded(
                          child: stats.eventsByCategorie.isEmpty
                              ? const Center(child: Text('Aucune donnée'))
                              : BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    maxY: stats.eventsByCategorie.values.isEmpty
                                        ? 10
                                        : stats.eventsByCategorie.values.reduce((a, b) => a > b ? a : b).toDouble() * 1.3,
                                    barGroups: stats.eventsByCategorie.entries.map((e) {
                                      final idx = stats.eventsByCategorie.keys.toList().indexOf(e.key);
                                      return BarChartGroupData(
                                        x: idx,
                                        barRods: [
                                          BarChartRodData(
                                            toY: e.value.toDouble(),
                                            color: colors[idx % colors.length],
                                            width: 16,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            final keys = stats.eventsByCategorie.keys.toList();
                                            if (value.toInt() >= 0 && value.toInt() < keys.length) {
                                              return Text(
                                                keys[value.toInt()].length > 6
                                                    ? '${keys[value.toInt()].substring(0, 6)}..'
                                                    : keys[value.toInt()],
                                                style: const TextStyle(fontSize: 9),
                                              );
                                            }
                                            return const SizedBox.shrink();
                                          },
                                        ),
                                      ),
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
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    final stats = _stats!;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _statCard('Événements', stats.totalEvents.toString(), Icons.event, Colors.blue),
        _statCard('Clients', stats.totalClients.toString(), Icons.people, Colors.green),
        _statCard('Organisateurs', stats.totalOrganisateurs.toString(), Icons.badge, Colors.orange),
        _statCard('Revenus', '${stats.totalRevenue.toStringAsFixed(0)} FCFA', Icons.attach_money, Colors.purple),
        _statCard('Lieux', stats.totalLieux.toString(), Icons.location_city, Colors.teal),
        _statCard('Salles', stats.totalSalles.toString(), Icons.meeting_room, Colors.indigo),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildEventRow(Evenement event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.event),
        title: Text(event.titre),
        subtitle: event.dateEvenement != null
            ? Text(DateFormat('MMM d, yyyy').format(event.dateEvenement!))
            : null,
        trailing: event.statut != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppConstants.statutColors[event.statut]?.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  event.statut!,
                  style: TextStyle(color: AppConstants.statutColors[event.statut]),
                ),
              )
            : null,
      ),
    );
  }
}
