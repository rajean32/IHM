import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/services/dashboard_service.dart';
import '../../../models/dashboard_model.dart';
import '../../../models/evenement_model.dart';
import '../../../core/assets/app_colors.dart';
import '../../../core/utils/error_helper.dart';
import '../../../widgets/admin/admin_stat_card.dart';
import '../../../widgets/admin/admin_error_state.dart';
import '../../../widgets/admin/admin_empty_state.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _service = DashboardService();
  bool _loading = true;
  String? _error;
  AdminDashboardStats? _stats;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _service.getDashboard();
      if (!mounted) return;
      setState(() { _stats = AdminDashboardStats.fromJson(data); _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = apiErrorString(e); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return AdminErrorState(message: _error!, onRetry: _load);
    if (_stats == null) return const AdminEmptyState(icon: Icons.dashboard, message: 'Aucune donnée');

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsGrid(),
            const SizedBox(height: 24),
            _buildChartsRow(),
            const SizedBox(height: 24),
            _buildRecentEvents(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        AdminStatCard(
          label: 'Événements',
          value: '${_stats!.totalEvents}',
          icon: Icons.event,
          color: AppColors.primary,
        ),
        AdminStatCard(
          label: 'Clients',
          value: '${_stats!.totalClients}',
          icon: Icons.people,
          color: AppColors.secondary,
        ),
        AdminStatCard(
          label: 'Organisateurs',
          value: '${_stats!.totalOrganisateurs}',
          icon: Icons.badge,
          color: AppColors.accent,
        ),
        AdminStatCard(
          label: 'Revenus',
          value: '${_stats!.totalRevenue} Ar',
          icon: Icons.attach_money,
          color: AppColors.primary,
        ),
        AdminStatCard(
          label: 'Lieux',
          value: '${_stats!.totalLieux}',
          icon: Icons.location_city,
          color: const Color(0xFF00897B),
        ),
        AdminStatCard(
          label: 'Salles',
          value: '${_stats!.totalSalles}',
          icon: Icons.meeting_room,
          color: AppColors.primaryDark,
        ),
      ],
    );
  }

  Widget _buildChartsRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Analytiques',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildPieChart()),
            const SizedBox(width: 12),
            Expanded(child: _buildBarChart()),
          ],
        ),
      ],
    );
  }

  Widget _buildPieChart() {
    final data = _stats!.eventsByStatus;
    final colors = [AppColors.primary, AppColors.secondary, AppColors.accent, AppColors.placeOrchestre, const Color(0xFF00897B), AppColors.error, AppColors.primaryDark];
    var i = 0;
    final sections = data.entries.map((e) {
      final c = colors[i % colors.length];
      i++;
      return PieChartSectionData(
        value: e.value.toDouble(),
        title: '${e.key}\n${e.value}',
        color: c,
        radius: 40,
        titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    if (sections.isEmpty) {
      return Card(child: SizedBox(height: 180, child: Center(child: Text('Aucune donnée', style: TextStyle(color: AppColors.textMuted)))));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Text('Par statut', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SizedBox(height: 150, child: PieChart(PieChartData(sections: sections, centerSpaceRadius: 20))),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    final data = _stats!.eventsByCategorie;
    if (data.isEmpty) {
      return Card(child: SizedBox(height: 180, child: Center(child: Text('Aucune donnée', style: TextStyle(color: AppColors.textMuted)))));
    }

    final groups = data.entries.map((e) {
      return BarChartGroupData(
        x: data.keys.toList().indexOf(e.key),
        barRods: [BarChartRodData(toY: e.value.toDouble(), color: AppColors.primary, width: 16)],
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Text('Par catégorie', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SizedBox(
              height: 150,
              child: BarChart(BarChartData(
                barGroups: groups,
                gridData: const FlGridData(show: true),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
                    final keys = data.keys.toList();
                    final idx = v.toInt();
                    if (idx < 0 || idx >= keys.length) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(keys[idx].length > 6 ? '${keys[idx].substring(0, 6)}..' : keys[idx], style: const TextStyle(fontSize: 9)),
                    );
                  })),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, getTitlesWidget: (v, m) => Text('${v.toInt()}', style: const TextStyle(fontSize: 9)))),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentEvents() {
    final events = _stats!.recentEvents;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Événements récents', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (events.isEmpty)
          const AdminEmptyState(icon: Icons.event_busy, message: 'Aucun événement récent')
        else
          ...events.map(_buildEventRow),
      ],
    );
  }

  Widget _buildEventRow(Evenement event) {
    final statusColor = AppConstants.statutColors[event.statut] ?? AppColors.textMuted;
    final dateStr = event.dateEvenement != null ? DateFormat('dd/MM/yyyy').format(event.dateEvenement!) : '';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.event, color: AppColors.primary),
        title: Text(event.titre, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(dateStr, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(event.statut ?? '', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
        ),
      ),
    );
  }
}
