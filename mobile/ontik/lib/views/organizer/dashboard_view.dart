import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/auth_controller.dart';
import '../../repositories/dashboard_repository.dart';
import '../../repositories/event_repository.dart';
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
  List<Evenement> _events = [];

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
      final dashboardRepo = ref.read(
        Provider<DashboardRepository>(
          (ref) => DashboardRepository(ref.watch(Provider<ApiClient>((ref) => ApiClient()))),
        ),
      );
      final eventRepo = ref.read(
        Provider<EventRepository>(
          (ref) => EventRepository(ref.watch(Provider<ApiClient>((ref) => ApiClient()))),
        ),
      );

      final stats = await dashboardRepo.getOrganizerStats(orgCode);
      final events = await eventRepo.getByOrganisateur(orgCode);

      if (!mounted) return;
      setState(() {
        _stats = stats;
        _events = events;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
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
                        const SizedBox(height: 24),
                        _buildChartsSection(),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'My Events',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => context.push('/organizer/create-event'),
                              icon: const Icon(Icons.add),
                              label: const Text('New Event'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () => context.push('/organizer/scan'),
                              icon: const Icon(Icons.qr_code_scanner),
                              label: const Text('Scan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_events.isEmpty)
                          const Center(child: Text('No events created yet'))
                        else
                          ..._events.map((e) => _buildEventCard(e)),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildChartsSection() {
    final events = _events;
    if (events.isEmpty) return const SizedBox.shrink();

    final statusCounts = <String, int>{};
    for (final e in events) {
      final s = e.statut ?? 'unknown';
      statusCounts[s] = (statusCounts[s] ?? 0) + 1;
    }
    final colors = [
      Colors.blue, Colors.green, Colors.grey, Colors.red,
      Colors.orange, Colors.purple, Colors.teal,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Analytics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                        const Text('Events by Status', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sections: statusCounts.entries.map((e) {
                                final idx = statusCounts.keys.toList().indexOf(e.key);
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
                        const Text('Ticket Sales', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Expanded(
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: (_stats?.totalTicketsSold ?? 10).toDouble() * 1.3,
                              barGroups: [
                                BarChartGroupData(
                                  x: 0,
                                  barRods: [
                                    BarChartRodData(
                                      toY: (_stats?.totalTicketsSold ?? 0).toDouble(),
                                      color: Colors.green,
                                      width: 20,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                ),
                                BarChartGroupData(
                                  x: 1,
                                  barRods: [
                                    BarChartRodData(
                                      toY: (_stats?.totalReservations ?? 0).toDouble(),
                                      color: Colors.orange,
                                      width: 20,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                ),
                              ],
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        value == 0 ? 'Sold' : 'Reserved',
                                        style: const TextStyle(fontSize: 10),
                                      );
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
        _statCard('Total Events', stats.totalEvents.toString(), Icons.event, Colors.blue),
        _statCard('Tickets Sold', stats.totalTicketsSold.toString(), Icons.confirmation_number, Colors.green),
        _statCard('Reservations', stats.totalReservations.toString(), Icons.receipt_long, Colors.orange),
        _statCard('Revenue', '\$${stats.totalRevenue.toStringAsFixed(2)}', Icons.attach_money, Colors.purple),
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
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(Evenement event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppConstants.statutColors[event.statut]?.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.event,
            color: AppConstants.statutColors[event.statut],
          ),
        ),
        title: Text(event.titre),
        subtitle: event.dateEvenement != null
            ? Text(DateFormat('MMM d, yyyy').format(event.dateEvenement!))
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (event.statut != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppConstants.statutColors[event.statut]?.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  event.statut!,
                  style: TextStyle(
                    color: AppConstants.statutColors[event.statut],
                    fontSize: 11,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
