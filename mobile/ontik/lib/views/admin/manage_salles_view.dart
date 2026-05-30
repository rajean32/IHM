import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/providers.dart';
import '../../models/venue.dart';
import '../../widgets/error_state.dart';

class ManageSallesView extends ConsumerStatefulWidget {
  const ManageSallesView({super.key});

  @override
  ConsumerState<ManageSallesView> createState() => _ManageSallesViewState();
}

class _ManageSallesViewState extends ConsumerState<ManageSallesView> {
  bool _loading = true;
  String? _error;
  List<Salle> _salles = [];
  List<Lieu> _lieux = [];
  final _formKey = GlobalKey<FormState>();

  final _numeroCtrl = TextEditingController();
  final _nomCtrl = TextEditingController();
  int? _selectedLieu;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _numeroCtrl.dispose();
    _nomCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final salleRepo = ref.read(salleRepositoryProvider);
      final lieuRepo = ref.read(lieuRepositoryProvider);
      final salles = await salleRepo.getAll();
      final lieux = await lieuRepo.getAll();
      if (!mounted) return;
      setState(() {
        _salles = salles;
        _lieux = lieux;
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

  Future<void> _addSalle() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final salleRepo = ref.read(salleRepositoryProvider);
      await salleRepo.create(Salle(
        numeroSalle: _numeroCtrl.text,
        nomSalle: _nomCtrl.text,
        idLieu: _selectedLieu,
      ));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Room added successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _numeroCtrl.clear();
      _nomCtrl.clear();
      setState(() => _selectedLieu = null);
      _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add room: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Rooms')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorState(message: _error!, onRetry: _loadData)
              : Column(
                  children: [
                    _buildAddForm(),
                    const Divider(),
                    Expanded(
                      child: _salles.isEmpty
                          ? const Center(child: Text('No rooms found'))
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _salles.length,
                              itemBuilder: (context, index) {
                                final salle = _salles[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: const CircleAvatar(
                                      child: Icon(Icons.meeting_room),
                                    ),
                                    title: Text(salle.nomSalle),
                                    subtitle: Text(
                                      'Room #: ${salle.numeroSalle}',
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {},
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildAddForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add New Room',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _numeroCtrl,
              decoration: const InputDecoration(
                labelText: 'Room Number',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nomCtrl,
              decoration: const InputDecoration(
                labelText: 'Room Name',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _selectedLieu,
              decoration: const InputDecoration(
                labelText: 'Venue',
                border: OutlineInputBorder(),
              ),
              items: _lieux
                  .map((l) => DropdownMenuItem(
                        value: l.idLieu,
                        child: Text(l.nomLieu),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedLieu = v),
              validator: (v) => v == null ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _addSalle,
              icon: const Icon(Icons.meeting_room),
              label: const Text('Add Room'),
            ),
          ],
        ),
      ),
    );
  }
}
