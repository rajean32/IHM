import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/auth_controller.dart';
import '../../repositories/event_repository.dart';
import '../../repositories/admin_repositories.dart';
import '../../models/evenement.dart';
import '../../models/categorie.dart';
import '../../core/api_client.dart';

class CreateEventView extends ConsumerStatefulWidget {
  const CreateEventView({super.key});

  @override
  ConsumerState<CreateEventView> createState() => _CreateEventViewState();
}

class _CreateEventViewState extends ConsumerState<CreateEventView> {
  final _formKey = GlobalKey<FormState>();
  final _titreCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedTime;
  String? _selectedCategorie;
  int? _selectedLieu;
  List<Categorie> _categories = [];
  List<dynamic> _lieux = [];
  bool _loading = false;
  bool _dataLoading = true;

  final _statuts = ['planifie', 'en_cours', 'termine'];
  String _selectedStatut = 'planifie';

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  @override
  void dispose() {
    _titreCtrl.dispose();
    _descriptionCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadFormData() async {
    try {
      final catRepo = ref.read(
        Provider<CategorieRepository>(
          (ref) => CategorieRepository(ref.watch(Provider<ApiClient>((ref) => ApiClient()))),
        ),
      );
      final lieuRepo = ref.read(
        Provider<LieuRepository>(
          (ref) => LieuRepository(ref.watch(Provider<ApiClient>((ref) => ApiClient()))),
        ),
      );

      final categories = await catRepo.getAll();
      final lieux = await lieuRepo.getAll();

      if (!mounted) return;
      setState(() {
        _categories = categories;
        _lieux = lieux;
        _dataLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _dataLoading = false);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final authState = ref.read(authControllerProvider);
      final eventRepo = ref.read(
        Provider<EventRepository>(
          (ref) => EventRepository(ref.watch(Provider<ApiClient>((ref) => ApiClient()))),
        ),
      );

      final event = Evenement(
        titre: _titreCtrl.text,
        description: _descriptionCtrl.text.isEmpty ? null : _descriptionCtrl.text,
        dateEvenement: _selectedDate,
        heureEvenement: _selectedTime,
        image: _imageCtrl.text.isEmpty ? null : _imageCtrl.text,
        statut: _selectedStatut,
        codeCategorie: _selectedCategorie,
        idLieu: _selectedLieu,
        codeOrganisateur: authState.user?.codeUtilisateur ?? '',
      );

      await eventRepo.create(event);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create event: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: _dataLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _titreCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Event Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _imageCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Image URL (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _selectedDate != null
                            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                            : 'Select date',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _selectTime,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(_selectedTime ?? 'Select time'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCategorie,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: _categories
                        .map((c) => DropdownMenuItem(
                              value: c.codeCategorie,
                              child: Text(c.nomCategorie),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCategorie = v),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _selectedLieu,
                    decoration: const InputDecoration(
                      labelText: 'Venue',
                      border: OutlineInputBorder(),
                    ),
                    items: _lieux
                        .map((l) => DropdownMenuItem(
                              value: l['idLieu'] as int,
                              child: Text(l['nomLieu'] as String),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedLieu = v),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedStatut,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: _statuts
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedStatut = v!),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create Event'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
