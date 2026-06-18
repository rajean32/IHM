import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/services/dashboard_service.dart';
import '../../core/services/app_config.dart';
import '../../core/api/dio_config.dart';
import '../../models/dashboard_model.dart';
import '../../models/evenement_model.dart';
import '../../core/assets/app_colors.dart';
import '../../widgets/error_state.dart';
import '../../core/utils/error_helper.dart';
import '../../generated/app_localizations.dart';

class DashboardPage extends StatefulWidget {
  final VoidCallback? onNavigateToEvents;

  const DashboardPage({super.key, this.onNavigateToEvents});

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
    eventContextNotifier.addListener(_onContextChanged);
    _loadData();
  }

  @override
  void dispose() {
    eventContextNotifier.removeListener(_onContextChanged);
    super.dispose();
  }

  void _onContextChanged() {
    if (mounted) setState(() {});
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
      case 'upcoming': return AppLocalizations.of(context)!.statusUpcoming;
      case 'in_progress': return AppLocalizations.of(context)!.statusInProgress;
      case 'ended': return AppLocalizations.of(context)!.statusEnded;
      case 'suspended': return AppLocalizations.of(context)!.statusSuspended;
      case 'cancelled': return AppLocalizations.of(context)!.statusCancelled;
      default: return AppLocalizations.of(context)!.statusUpcoming;
    }
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
                        _buildPageHeader(),
                        const SizedBox(height: 16),
                        _buildStatsGrid(),
                        const SizedBox(height: 20),
                        _buildDailySalesChart(),
                        const SizedBox(height: 20),
                        _buildTopEvents(),
                        const SizedBox(height: 20),
                        _buildCompactEventList(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildPageHeader() {
    return Card(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.all(16),
              child: Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(AppLocalizations.of(context)!.overview, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                    if (activeEventId != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(activeEventName, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.primary)),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 4),
                  Text(AppLocalizations.of(context)!.eventsActive('${_stats?.myEvents.length ?? 0}'),
                      style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                ],
              ),
            ),
            if (widget.onNavigateToEvents != null)
              FilledButton.tonalIcon(
              onPressed: widget.onNavigateToEvents,
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: Text(AppLocalizations.of(context)!.manage, style: TextStyle(fontSize: 12)),
            ),
        ]),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(children: [
          Expanded(child: _buildModernStatCard(
            label: AppLocalizations.of(context)!.revenue,
            value: '${_stats!.totalRevenue.toStringAsFixed(0)} ${AppConstants.currency}',
            icon: Icons.attach_money,
            color: AppColors.secondary,
          )),
          const SizedBox(width: 12),
          Expanded(child: _buildModernStatCard(
            label: AppLocalizations.of(context)!.fillRate,
            value: '${_stats!.fillRate.toStringAsFixed(1)}%',
            icon: Icons.pie_chart,
            color: AppColors.primary,
          )),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _buildModernStatCard(
            label: AppLocalizations.of(context)!.ticketsSold,
            value: '${_stats!.totalTicketsSold}',
            icon: Icons.confirmation_number,
            color: AppColors.accent,
          )),
          const SizedBox(width: 12),
          Expanded(child: _buildModernStatCard(
            label: AppLocalizations.of(context)!.seatsAvailable,
            value: '${_stats!.placesDisponibles}',
            icon: Icons.event_seat,
            color: AppColors.primary,
          )),
        ]),
      ],
    );
  }

  Widget _buildModernStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark ? color.withValues(alpha: 0.25) : color.withValues(alpha: 0.12),
            isDark ? color.withValues(alpha: 0.10) : color.withValues(alpha: 0.04),
          ],
        ),
      ),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          child: Column(
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : color,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.white70 : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactEventList() {
    final events = _stats?.myEvents ?? [];
    if (events.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.event, size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(AppLocalizations.of(context)!.myEvents, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface))),
              if (widget.onNavigateToEvents != null)
                TextButton(
                  onPressed: widget.onNavigateToEvents,
                  child: Text(AppLocalizations.of(context)!.seeAll, style: TextStyle(fontSize: 12)),
                ),
            ]),
            const SizedBox(height: 8),
            ...events.take(5).map((e) {
              final sk = _eventStatusKey(e);
              final status = _eventStatusLabel(e);
              final sc = _eventStatusColor(sk);
              final total = e.placesTotal ?? 0;
              final dispo = e.placesDisponibles ?? 0;
              final reserved = total - dispo;
              final rate = total > 0 ? (reserved / total) : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.titre, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Theme.of(context).colorScheme.onSurface)),
                          const SizedBox(height: 2),
                          Text('$reserved / $total places', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                        ],
                      ),
                    ),
                    SizedBox(width: 40, child: Text('${(rate * 100).toStringAsFixed(0)}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: sc))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: sc.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(status, style: TextStyle(fontSize: 8, color: sc, fontWeight: FontWeight.w700)),
                    ),
                  ]),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.salesEvolution, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
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
                      color: isDark ? AppColors.primaryLight : AppTheme.primaryColor,
                      width: 14,
                      borderRadius: BorderRadius.circular(4),
                    )],
                  )).toList(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (v, m) {
                      return Text('${v.toInt()}', style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)));
                    })),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
                      final idx = v.toInt();
                      if (idx < 0 || idx >= sales.length) return const Text('');
                      final parts = sales[idx].date.split('-');
                      return Text('${parts[2]}/${parts[1]}', style: TextStyle(fontSize: 8, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)));
                    })),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                      strokeWidth: 1,
                    ),
                  ),
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
            Text(AppLocalizations.of(context)!.topEvents, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 8),
            ...top.take(5).toList().asMap().entries.map((e) => ListTile(
              dense: true,
              leading: CircleAvatar(
                radius: 14,
                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                child: Text('${e.key + 1}', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary)),
              ),
              title: Text(e.value.titre, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
              trailing: Text('${e.value.placesDisponibles ?? 0} billets', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
            )),
          ],
        ),
      ),
    );
  }

}
