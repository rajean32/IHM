import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/admin_repositories.dart';
import '../../core/api_client.dart';
import '../../widgets/error_state.dart';

class ManageLieuxView extends ConsumerStatefulWidget {
  const ManageLieuxView({super.key});

  @override
  ConsumerState<ManageLieuxView> createState() => _ManageLieuxViewState();
}

class _ManageLieuxViewState extends ConsumerState<ManageLieuxView> {
  bool _loading = true;
  String? _error;
  List<dynamic> _lieux = [];
  final _formKey = GlobalKey<FormState>();

  final _nomCtrl = TextEditingController();
  final _adresseCtrl = TextEditingController();
  final _villeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _adresseCtrl.dispose();
    _villeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final lieuRepo = ref.read(
        Provider<LieuRepository>(
          (ref) => LieuRepository(ref.watch(Provider<ApiClient>((ref) => ApiClient()))),
        ),
      );
      final lieux = await lieuRepo.getAll();
      if (!mounted) return;
      setState(() {
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

  Future<void> _addLieu() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final lieuRepo = ref.read(
        Provider<LieuRepository>(
          (ref) => LieuRepository(ref.watch(Provider<ApiClient>((ref) => ApiClient()))),
        ),
      );
      await lieuRepo.create({
        'nomLieu': _nomCtrl.text,
        'adresse': _adresseCtrl.text,
        'ville': _villeCtrl.text,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Venue added successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _nomCtrl.clear();
      _adresseCtrl.clear();
      _villeCtrl.clear();
      _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add venue: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Venues')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorState(message: _error!, onRetry: _loadData)
              : Column(
                  children: [
                    _buildAddForm(),
                    const Divider(),
                    Expanded(
                      child: _lieux.isEmpty
                          ? const Center(child: Text('No venues found'))
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _lieux.length,
                              itemBuilder: (context, index) {
                                final lieu = _lieux[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: const CircleAvatar(
                                      child: Icon(Icons.location_city),
                                    ),
                                    title: Text(lieu['nomLieu'] ?? 'N/A'),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (lieu['adresse'] != null)
                                          Text(lieu['adresse']),
                                        if (lieu['ville'] != null)
                                          Text(lieu['ville']),
                                      ],
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
              'Add New Venue',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nomCtrl,
              decoration: const InputDecoration(
                labelText: 'Venue Name',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _adresseCtrl,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _villeCtrl,
              decoration: const InputDecoration(
                labelText: 'City',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _addLieu,
              icon: const Icon(Icons.add_location),
              label: const Text('Add Venue'),
            ),
          ],
        ),
      ),
    );
  }
}
