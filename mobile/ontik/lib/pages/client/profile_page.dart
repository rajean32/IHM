import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/reservation_model.dart';
import '../../models/ticket_model.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/reservation_service.dart';
import '../../core/api/dio_config.dart';
import '../../core/assets/app_colors.dart';
import '../../core/routes/client_routes.dart';
import '../../widgets/error_state.dart';
import '../../core/utils/error_helper.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = true;
  String? _error;
  List<Reservation> _reservations = [];
  List<Ticket> _tickets = [];
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final clientCode = userCode ?? '';
    if (clientCode.isEmpty) return;

    setState(() => _loading = true);
    try {
      final _reservationService = ReservationService();
      final reservationsData = await _reservationService.getMyReservations(clientCode);

      if (!mounted) return;
      final reservations = reservationsData.map((e) => Reservation.fromJson(e as Map<String, dynamic>)).toList();
      final tickets = <Ticket>[];
      for (final r in reservations) {
        if (r.tickets != null) tickets.addAll(r.tickets!);
      }
      setState(() {
        _reservations = reservations;
        _tickets = tickets;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = apiErrorString(e);
        _loading = false;
      });
    }
  }

  Future<void> _changePassword() async {
    if (_currentPasswordCtrl.text.isEmpty) return;
    if (_newPasswordCtrl.text.length < 6) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le mot de passe doit contenir au moins 6 caractères'), backgroundColor: AppColors.error),
      );
      return;
    }
    if (_newPasswordCtrl.text != _confirmPasswordCtrl.text) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les mots de passe ne correspondent pas'), backgroundColor: AppColors.error),
      );
      return;
    }
    try {
      await AuthService().changePassword(_currentPasswordCtrl.text, _newPasswordCtrl.text);
      if (!mounted) return;
      Navigator.pop(context);
      _currentPasswordCtrl.clear();
      _newPasswordCtrl.clear();
      _confirmPasswordCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mot de passe modifié'), backgroundColor: AppColors.secondary),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(apiErrorString(e)), backgroundColor: AppColors.error),
      );
    }
  }

  void _showPasswordDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Changer le mot de passe', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: _currentPasswordCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mot de passe actuel', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _newPasswordCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Nouveau mot de passe', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _confirmPasswordCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirmer', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _changePassword,
                  child: const Text('Changer le mot de passe'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Réservations'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, ClientRoutes.home);
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showPasswordDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.receipt_long), text: 'Réservations'),
            Tab(icon: Icon(Icons.confirmation_number), text: 'Billets'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorState(message: _error!, onRetry: _loadData)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildReservationsList(),
                    _buildTicketsList(),
                  ],
                ),
    );
  }

  Widget _buildReservationsList() {
    if (_reservations.isEmpty) {
      return const Center(child: Text('Aucune réservation'));
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _reservations.length,
        itemBuilder: (context, index) {
          final r = _reservations[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.event),
              ),
              title: Text('Réservation #${r.idReservation}'),
              subtitle: r.dateReservation != null
                  ? Text(DateFormat('d MMM yyyy', 'fr').format(r.dateReservation!))
                  : null,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _tabController.animateTo(1),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTicketsList() {
    if (_tickets.isEmpty) {
      return const Center(child: Text('Aucun billet'));
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _tickets.length,
        itemBuilder: (context, index) {
          final t = _tickets[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: t.statut == 'UTILISE' ? AppColors.error : AppColors.secondary,
                child: Icon(Icons.confirmation_number, color: Colors.white, size: 20),
              ),
              title: Text(t.evenementTitre ?? 'Ticket ${t.codeTicket}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (t.dateEvenement != null) Text(DateFormat('d MMM yyyy', 'fr').format(DateTime.parse(t.dateEvenement!)), style: const TextStyle(fontSize: 11)),
                  if (t.lieuNom != null) Text(t.lieuNom!, style: const TextStyle(fontSize: 11)),
                  if (t.numeroPlace != null) Text('Place ${t.numeroPlace}${t.rang != null ? ' (Rang ${t.rang})' : ''}', style: const TextStyle(fontSize: 11)),
                  if (t.prix != null) Text('Ar ${t.prix!.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                  if (t.statut != null) Chip(
                    label: Text(t.statut!, style: const TextStyle(fontSize: 9, color: Colors.white)),
                    backgroundColor: t.statut == 'UTILISE' ? AppColors.error : AppColors.secondary,
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ].map((w) => Padding(padding: const EdgeInsets.only(top: 2), child: w)).toList(),
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right, size: 18),
              onTap: () => Navigator.pushNamed(
                context,
                ClientRoutes.ticket,
                arguments: {'code': t.codeTicket},
              ),
            ),
          );
        },
      ),
    );
  }
}
