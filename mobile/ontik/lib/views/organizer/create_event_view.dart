import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/event_controller.dart';
import '../../controllers/providers.dart';
import '../../core/api_endpoints.dart';
import '../../models/event_place_config.dart';
import '../../models/evenement.dart';
import '../../models/venue.dart';
import '../../models/categorie.dart';
import '../../models/api_wrapper.dart';
import '../../core/constants.dart';
import 'event_pricing_view.dart';

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
  List<Lieu> _lieux = [];
  List<Map<String, dynamic>> _salles = [];
  String? _selectedSalle;
  bool _loadingSalles = false;

  List<EventPlaceConfig> _places = [];
  bool _loadingPlaces = false;
  final Map<String, String> _rowTypes = {};
  final Map<String, TextEditingController> _rowPrices = {};
  final Map<String, String> _individualTypes = {};
  final Map<String, double?> _individualPrices = {};

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
    for (final ctrl in _rowPrices.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _loadFormData() async {
    try {
      final catRepo = ref.read(categorieRepositoryProvider);
      final lieuRepo = ref.read(lieuRepositoryProvider);

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

  Future<void> _loadSalles(int lieuId) async {
    setState(() { _selectedSalle = null; _loadingSalles = true; });
    try {
      final client = ref.read(apiClientProvider);
      final resp = await client.get(ApiEndpoints.organizerVenues.salles);
      final wrapper = ApiWrapper.fromJson(resp);
      final allSalles = wrapper.getDataList((e) => e);
      final filtered = allSalles.where((s) => s['idLieu'] == lieuId).toList();
      if (!mounted) return;
      setState(() { _salles = filtered; _loadingSalles = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _salles = []; _loadingSalles = false; });
    }
  }

  Future<void> _loadPlaces() async {
    if (_selectedSalle == null) return;
    setState(() => _loadingPlaces = true);
    try {
      final client = ref.read(apiClientProvider);
      final resp = await client.get(
        '${ApiEndpoints.organizerVenues.places}?salle=$_selectedSalle',
      );
      final wrapper = ApiWrapper.fromJson(resp);
      final places = wrapper.getDataList((e) => EventPlaceConfig.fromJson(e));
      if (!mounted) return;
      final rangs = places.map((p) => p.range).whereType<String>().toSet().toList()..sort();
      for (final r in rangs) {
        if (!_rowTypes.containsKey(r)) _rowTypes[r] = 'Standard';
        if (!_rowPrices.containsKey(r)) _rowPrices[r] = TextEditingController();
      }
      setState(() { _places = places; _loadingPlaces = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _places = []; _loadingPlaces = false; });
    }
  }

  void _showIndividualPricingDialog() {
    final rangs = _places.map((p) => p.range).whereType<String>().toSet().toList()..sort();
    showDialog(
      context: context,
      builder: (ctx) {
        final localTypes = Map<String, String>.from(_individualTypes);
        final localPrices = Map<String, double?>.from(_individualPrices);
        return StatefulBuilder(
          builder: (ctx, setDState) {
            String? filterType;
            final displayPlaces = filterType == null
                ? _places
                : _places.where((p) => (localTypes[p.numeroPlace] ?? p.typePlace ?? 'Standard') == filterType).toList();
            return AlertDialog(
              title: Row(children: [
                const Text('Places', style: TextStyle(fontSize: 16)),
                const Spacer(),
                DropdownButton<String>(
                  value: filterType,
                  hint: const Text('Filtrer', style: TextStyle(fontSize: 11)),
                  underline: const SizedBox(),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Toutes', style: TextStyle(fontSize: 11))),
                    ...AppConstants.placeTypes.map((t) => DropdownMenuItem(
                      value: t, child: Text(t, style: const TextStyle(fontSize: 11)),
                    )),
                  ],
                  onChanged: (v) => setDState(() => filterType = v),
                ),
              ]),
              content: SizedBox(
                width: 400,
                child: ListView(
                  shrinkWrap: true,
                  children: rangs.map((r) {
                    final rowPlaces = displayPlaces.where((p) => p.range == r).toList()
                      ..sort((a, b) => a.numeroPlace.compareTo(b.numeroPlace));
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rangée $r', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: rowPlaces.map((p) {
                            final overridden = localTypes.containsKey(p.numeroPlace);
                            final type = localTypes[p.numeroPlace] ?? p.typePlace ?? 'Standard';
                            final color = AppConstants.placeTypeColors[type] ?? Colors.grey;
                            return GestureDetector(
                              onTap: () => _editSinglePlace(p, localTypes, localPrices, setDState),
                              child: Container(
                                width: 48,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: overridden ? 0.3 : 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: color.withValues(alpha: 0.5), width: overridden ? 1.5 : 0.5),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(p.numeroPlace.replaceAll(r, ''),
                                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: color)),
                                    Text('${(localPrices[p.numeroPlace] ?? p.prix ?? 0).toStringAsFixed(0)}€',
                                        style: TextStyle(fontSize: 7, color: Colors.grey.shade700)),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 6),
                      ],
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _individualTypes.clear();
                    _individualPrices.clear();
                    setDState(() {});
                  },
                  child: const Text('Réinitialiser', style: TextStyle(fontSize: 12)),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _individualTypes.clear();
                      _individualTypes.addAll(localTypes);
                      _individualPrices.clear();
                      _individualPrices.addAll(localPrices);
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text('Valider', style: TextStyle(fontSize: 12)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editSinglePlace(
    EventPlaceConfig p,
    Map<String, String> types,
    Map<String, double?> prices,
    void Function(void Function()) setDState,
  ) {
    String t = types[p.numeroPlace] ?? p.typePlace ?? 'Standard';
    final ctrl = TextEditingController(text: (prices[p.numeroPlace] ?? p.prix)?.toStringAsFixed(2) ?? '');
    showDialog(
      context: context,
      builder: (ctx2) => AlertDialog(
        title: Text('Place ${p.numeroPlace}', style: const TextStyle(fontSize: 15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: t,
              decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder(), isDense: true),
              items: AppConstants.placeTypes.map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
              onChanged: (v) => t = v!,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: ctrl,
              decoration: const InputDecoration(labelText: 'Prix (€)', border: OutlineInputBorder(), isDense: true),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx2), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              types[p.numeroPlace] = t;
              final parsed = double.tryParse(ctrl.text);
              prices[p.numeroPlace] = parsed;
              setDState(() {});
              Navigator.pop(ctx2);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection() {
    final rangs = _places.map((p) => p.range).whereType<String>().toSet().toList()..sort();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Text('Configuration des types & prix', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade800)),
        const SizedBox(height: 4),
        Text('Définissez le type et le prix par rangée. Vous pourrez affiner place par place après la création.',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        const SizedBox(height: 8),
        ...rangs.map((r) => _buildRowPricingRow(r)).toList(),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showIndividualPricingDialog(),
            icon: const Icon(Icons.grid_view, size: 18),
            label: const Text('Ajuster individuellement'),
          ),
        ),
        if (_individualTypes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('${_individualTypes.length} place(s) configurée(s) individuellement',
                style: TextStyle(fontSize: 11, color: Colors.orange.shade700)),
          ),
      ],
    );
  }

  Widget _buildRowPricingRow(String rang) {
    final rowPlaces = _places.where((p) => p.range == rang).toList();
    final count = rowPlaces.length;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(children: [
          SizedBox(
            width: 44,
            child: CircleAvatar(
              radius: 14,
              child: Text(rang, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 6),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Rangée $rang', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            Text('$count places', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
          ]),
          const Spacer(),
          SizedBox(
            width: 90,
            child: DropdownButtonFormField<String>(
              value: _rowTypes[rang] ?? 'Standard',
              isExpanded: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(), isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              ),
              items: AppConstants.placeTypes.map((t) => DropdownMenuItem(
                value: t, child: Text(t, style: const TextStyle(fontSize: 11)),
              )).toList(),
              onChanged: (v) => setState(() => _rowTypes[rang] = v!),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 60,
            child: TextField(
              controller: _rowPrices[rang] ?? (_rowPrices[rang] = TextEditingController()),
              decoration: const InputDecoration(
                hintText: 'Prix', border: OutlineInputBorder(), isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ]),
      ),
    );
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
      final eventRepo = ref.read(eventRepositoryProvider);

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

      final created = await eventRepo.create(event);

      if (!mounted) return;
      if (created.idEvenement != null) {
        try {
          final client = ref.read(apiClientProvider);
          for (final entry in _rowTypes.entries) {
            final prixText = _rowPrices[entry.key]?.text;
            final prix = prixText != null && prixText.isNotEmpty
                ? double.tryParse(prixText)
                : null;
            await client.put(
              ApiEndpoints.organizerPricing.rowPricing(created.idEvenement!),
              data: {'rang': entry.key, 'typePlace': entry.value, 'prix': prix},
            );
          }
          for (final entry in _individualTypes.entries) {
            final query = <String>['typePlace=${entry.value}'];
            final p = _individualPrices[entry.key];
            if (p != null) query.add('prix=$p');
            await client.put(
              '${ApiEndpoints.organizerPricing.singlePlaceConfig(created.idEvenement!, entry.key)}?${query.join('&')}',
            );
          }
        } catch (_) {}
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Événement créé avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
      if (_selectedSalle != null && created.idEvenement != null) {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (_) => EventPricingView(event: created),
        ));
      } else {
        context.pop();
      }
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
                      labelText: 'Lieu',
                      border: OutlineInputBorder(),
                    ),
                    items: _lieux
                        .map((l) => DropdownMenuItem(
                              value: l.idLieu,
                              child: Text(l.nomLieu),
                            ))
                        .toList(),
                    onChanged: (v) {
                      setState(() => _selectedLieu = v);
                      if (v != null) _loadSalles(v);
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_selectedLieu != null)
                    _loadingSalles
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: LinearProgressIndicator(),
                          )
                        : DropdownButtonFormField<String>(
                            value: _selectedSalle,
                            decoration: const InputDecoration(
                              labelText: 'Salle',
                              border: OutlineInputBorder(),
                            ),
                            items: _salles
                                .map((s) => DropdownMenuItem<String>(
                                      value: s['numeroSalle'] as String,
                                      child: Text(s['nomSalle'] as String? ?? s['numeroSalle'] as String),
                                    ))
                                .toList(),
                            onChanged: (v) {
                              setState(() => _selectedSalle = v);
                              if (v != null) _loadPlaces();
                            },
                          ),
                  if (_selectedSalle != null)
                    _loadingPlaces
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : _places.isEmpty
                            ? Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text('Aucune place trouvée pour cette salle',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                              )
                            : Column(children: [
                                const SizedBox(height: 8),
                                _buildPricingSection(),
                              ]),
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
