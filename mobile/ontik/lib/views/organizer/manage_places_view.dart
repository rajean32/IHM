import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/event_repository.dart';
import '../../repositories/admin_repositories.dart';
import '../../models/venue.dart';
import '../../core/api_client.dart';
import '../../widgets/error_state.dart';

class ManagePlacesView extends ConsumerStatefulWidget {
  final int eventId;
  const ManagePlacesView({super.key, required this.eventId});

  @override
  ConsumerState<ManagePlacesView> createState() => _ManagePlacesViewState();
}

class _ManagePlacesViewState extends ConsumerState<ManagePlacesView> {
  bool _loading = true;
  String? _error;
  List<SeatingPlace> _places = [];
  final _formKey = GlobalKey<FormState>();

  final _numeroCtrl = TextEditingController();
  final _rangCtrl = TextEditingController();
  String _typePlace = 'Standard';

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  @override
  void dispose() {
    _numeroCtrl.dispose();
    _rangCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPlaces() async {
    setState(() => _loading = true);
    try {
      final eventRepo = ref.read(
        Provider<EventRepository>(
          (ref) => EventRepository(ref.watch(Provider<ApiClient>((ref) => ApiClient()))),
        ),
      );
      final places = await eventRepo.getAvailableSeats(widget.eventId);
      if (!mounted) return;
      setState(() {
        _places = places;
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

  Future<void> _addPlace() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final placeRepo = ref.read(
        Provider<PlaceRepository>(
          (ref) => PlaceRepository(ref.watch(Provider<ApiClient>((ref) => ApiClient()))),
        ),
      );

      await placeRepo.create({
        'numeroPlace': _numeroCtrl.text,
        'range': _rangCtrl.text,
        'typePlace': _typePlace,
        'numeroSalle': 'S1',
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Place added successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _numeroCtrl.clear();
      _rangCtrl.clear();
      _loadPlaces();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add place: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Places')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorState(message: _error!, onRetry: _loadPlaces)
              : Column(
                  children: [
                    _buildAddForm(),
                    const Divider(),
                    Expanded(
                      child: _places.isEmpty
                          ? const Center(child: Text('No places configured'))
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _places.length,
                              itemBuilder: (context, index) {
                                final place = _places[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: place.disponible
                                          ? Colors.green
                                          : Colors.red,
                                      child: Icon(
                                        Icons.event_seat,
                                        color: Colors.white,
                                      ),
                                    ),
                                    title: Text(place.numeroPlace),
                                    subtitle: Text(
                                      '${place.rang ?? 'N/A'} - ${place.typePlace ?? 'Standard'}',
                                    ),
                                    trailing: place.prix != null
                                        ? Text('\$${place.prix}')
                                        : null,
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
              'Add New Place',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _numeroCtrl,
              decoration: const InputDecoration(
                labelText: 'Place Number',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _rangCtrl,
              decoration: const InputDecoration(
                labelText: 'Row',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _typePlace,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Standard', child: Text('Standard')),
                DropdownMenuItem(value: 'VIP', child: Text('VIP')),
                DropdownMenuItem(value: 'Premium', child: Text('Premium')),
              ],
              onChanged: (v) => setState(() => _typePlace = v!),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _addPlace,
              icon: const Icon(Icons.add),
              label: const Text('Add Place'),
            ),
          ],
        ),
      ),
    );
  }
}
