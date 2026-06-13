import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/api/dio_config.dart';
import '../../core/services/evenement_service.dart';
import '../../core/services/lieu_service.dart';
import '../../core/services/place_service.dart';
import '../../core/services/categorie_service.dart';
import '../../core/services/caracteristique_service.dart';
import '../../models/event_place_config_model.dart';
import '../../models/evenement_model.dart';
import '../../models/lieu_model.dart';
import '../../models/categorie_model.dart';
import '../../models/caracteristique_model.dart';
import '../../core/assets/app_colors.dart';
import '../../widgets/event_image_widget.dart';
import 'pricing_page.dart';
import '../../core/utils/error_helper.dart';

const _steps = ['Infos', 'Date & Heure', 'Lieu & Places', 'Prix', 'Récapitulatif'];

class CreateEventPage extends StatefulWidget {
  final Evenement? event;
  const CreateEventPage({super.key, this.event});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  bool get _isEditing => widget.event != null;

  int _currentStep = 0;

  final _formKey = GlobalKey<FormState>();
  final _titreCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _imagePicker = ImagePicker();
  String? _selectedImagePath;
  bool get _hasNewImage => _selectedImagePath != null;

  DateTime? _selectedDate;
  TimeOfDay? _selectedHeureDebut;
  TimeOfDay? _selectedHeureFin;

  String? _selectedCategorie;
  String? _selectedLieu;
  String? _selectedSalle;
  List<Categorie> _categories = [];
  List<Lieu> _lieux = [];
  List<Map<String, dynamic>> _salles = [];
  bool _loadingSalles = false;

  String _typePlacement = 'LIBRE';
  final List<String> _placeTypes = ['Standard', 'VIP'];
  final _newPlaceTypeCtrl = TextEditingController();

  final Map<String, TextEditingController> _typePriceCtrls = {};
  final Set<String> _selectedRows = {};
  final Set<String> _selectedPlaceIds = {};
  String _assignType = 'Standard';
  final Map<String, String> _pendingRowAssignments = {};
  final Map<String, String> _pendingPlaceAssignments = {};
  bool _gridExpanded = false;
  List<EventPlaceConfig> _places = [];
  bool _loadingPlaces = false;

  List<Caracteristique> _caracteristiques = [];
  Map<int, TextEditingController> _caracControllers = {};
  Map<int, String> _caracDropdownValues = {};
  Map<int, bool> _caracBooleanValues = {};
  bool _loadingCaracteristiques = false;

  bool _loading = false;
  bool _dataLoading = true;

  final _eventService = EvenementService();
  final _lieuService = LieuService();
  final _placeService = PlaceService();
  final _categorieService = CategorieService();
  final _caracService = CaracteristiqueService();

  @override
  void initState() {
    super.initState();
    _loadFormData().then((_) {
      if (_isEditing) _populateFromEvent(widget.event!);
    });
  }

  @override
  void dispose() {
    _titreCtrl.dispose();
    _descriptionCtrl.dispose();
    _newPlaceTypeCtrl.dispose();
    for (final ctrl in _typePriceCtrls.values) ctrl.dispose();
    for (final ctrl in _caracControllers.values) ctrl.dispose();
    super.dispose();
  }

  Future<void> _loadFormData() async {
    try {
      final categories = (await _categorieService.getCategories())
          .map((e) => Categorie.fromJson(e as Map<String, dynamic>)).toList();
      final lieux = (await _lieuService.getLieux())
          .map((e) => Lieu.fromJson(e as Map<String, dynamic>)).toList();
      if (!mounted) return;
      setState(() { _categories = categories; _lieux = lieux; _dataLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _dataLoading = false);
    }
  }

  void _populateFromEvent(Evenement event) {
    _titreCtrl.text = event.titre;
    if (event.description != null) _descriptionCtrl.text = event.description!;
    _selectedDate = event.dateEvenement;
    _selectedCategorie = event.codeCategorie;
    _selectedLieu = event.codeLieu;
    if (event.typeAgencement != null) {
      if (event.typeAgencement == 'DEBOUT_SANS_LIMITE' || event.typeAgencement == 'DEBOUT_AVEC_LIMITE') {
        _typePlacement = 'LIBRE';
      } else if (event.typeAgencement == 'ASSIS_DEBOUT') {
        _typePlacement = 'MIXTE';
      } else {
        _typePlacement = 'NUMEROTE';
      }
    }
    if (event.codeCategorie != null) {
      _loadCaracteristiques(event.codeCategorie!, existingValues: event.caracteristiqueValeurs);
    }
  }

  Future<void> _loadCaracteristiques(String codeCategorie, {List<EvenementCaracteristiqueValeur>? existingValues}) async {
    setState(() => _loadingCaracteristiques = true);
    try {
      final data = await _caracService.getByCategorie(codeCategorie);
      if (!mounted) return;
      final caracs = data.map((e) => Caracteristique.fromJson(e as Map<String, dynamic>)).toList();
      final controllers = <int, TextEditingController>{};
      final dropdownValues = <int, String>{};
      final booleanValues = <int, bool>{};
      final existingMap = <int, String>{};
      if (existingValues != null) {
        for (final v in existingValues) existingMap[v.idCaracteristique] = v.valeur;
      }
      for (final c in caracs) {
        if (c.idCaracteristique != null) {
          final existingVal = existingMap[c.idCaracteristique!];
          controllers[c.idCaracteristique!] = TextEditingController(
            text: (existingVal != null && c.typeDonnee != 'boolean' && c.typeDonnee != 'select') ? existingVal : '',
          );
          dropdownValues[c.idCaracteristique!] = (existingVal != null && c.typeDonnee == 'select') ? existingVal : '';
          booleanValues[c.idCaracteristique!] = (existingVal != null && c.typeDonnee == 'boolean') ? (existingVal == 'true') : false;
        }
      }
      setState(() {
        _caracteristiques = caracs;
        _caracControllers = controllers;
        _caracDropdownValues = dropdownValues;
        _caracBooleanValues = booleanValues;
        _loadingCaracteristiques = false;
      });
    } catch (_) {
      if (mounted) setState(() { _caracteristiques = []; _loadingCaracteristiques = false; });
    }
  }

  String get _typeAgencementFromPlacement {
    switch (_typePlacement) {
      case 'LIBRE': return 'DEBOUT_SANS_LIMITE';
      case 'MIXTE': return 'ASSIS_DEBOUT';
      default: return 'UNIQUEMENT_ASSIS';
    }
  }

  Duration? get _dureeCalculee {
    if (_selectedHeureDebut != null && _selectedHeureFin != null) {
      final debut = _selectedHeureDebut!;
      final fin = _selectedHeureFin!;
      final d = DateTime(2000, 1, 1, fin.hour, fin.minute).difference(DateTime(2000, 1, 1, debut.hour, debut.minute));
      if (d.isNegative) return d + const Duration(hours: 24);
      return d;
    }
    return null;
  }

  bool get _step1Valid => _titreCtrl.text.trim().isNotEmpty && _selectedCategorie != null;
  bool get _step2Valid => _selectedDate != null && _selectedHeureDebut != null;

  Future<void> _loadSalles(String lieuCode, {String? categorieCode}) async {
    setState(() { if (!_isEditing) _selectedSalle = null; _loadingSalles = true; });
    try {
      final List<dynamic> filtered;
      if (categorieCode != null) {
        filtered = await _lieuService.getSallesCompatible(lieuCode, categorieCode);
      } else {
        final allSalles = await _lieuService.getSalles();
        filtered = allSalles.where((s) => (s as Map<String, dynamic>)['codeLieu'] == lieuCode).cast<Map<String, dynamic>>().toList();
      }
      if (!mounted) return;
      setState(() { _salles = filtered.cast<Map<String, dynamic>>(); _loadingSalles = false; });
    } catch (_) {
      if (mounted) setState(() { _salles = []; _loadingSalles = false; });
    }
  }

  Future<void> _loadPlaces() async {
    if (_selectedSalle == null) return;
    setState(() => _loadingPlaces = true);
    try {
      final List<dynamic> raw;
      if (_isEditing && widget.event?.idEvenement != null) {
        raw = await _placeService.getPlacesConfig(widget.event!.idEvenement!, _selectedSalle!);
      } else {
        raw = await _placeService.getPlacesBySalle(_selectedSalle!);
      }
      final places = raw.map((e) => EventPlaceConfig.fromJson(e as Map<String, dynamic>)).toList();
      if (!mounted) return;
      setState(() { _places = places; _loadingPlaces = false; });
    } catch (_) {
      if (mounted) setState(() { _places = []; _loadingPlaces = false; });
    }
  }

  void _addPlaceType() {
    final name = _newPlaceTypeCtrl.text.trim();
    if (name.isEmpty || _placeTypes.contains(name)) return;
    setState(() {
      _placeTypes.add(name);
      _newPlaceTypeCtrl.clear();
    });
  }

  void _removePlaceType(String type) {
    if (type == 'Standard' || type == 'VIP') return;
    setState(() {
      _placeTypes.remove(type);
      _typePriceCtrls.remove(type)?.dispose();
    });
  }

  void _addPendingAssignment() {
    if (_assignType.isEmpty || (_selectedRows.isEmpty && _selectedPlaceIds.isEmpty)) return;
    setState(() {
      for (final r in _selectedRows) _pendingRowAssignments[r] = _assignType;
      for (final p in _selectedPlaceIds) _pendingPlaceAssignments[p] = _assignType;
      _selectedRows.clear();
      _selectedPlaceIds.clear();
    });
  }

  Widget _buildCaracteristiquesInputs() {
    if (_caracteristiques.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Divider(),
      const Text('Caractéristiques', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      ..._caracteristiques.map((c) {
        final id = c.idCaracteristique!;
        final label = '${c.nom}${c.obligatoire ? ' *' : ''}';
        switch (c.typeDonnee) {
          case 'boolean':
            return SwitchListTile(
              title: Text(label, style: const TextStyle(fontSize: 14)),
              value: _caracBooleanValues[id] ?? false,
              onChanged: (v) => setState(() => _caracBooleanValues[id] = v),
            );
          case 'select':
            final options = (c.options ?? '').split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
            return DropdownButtonFormField<String>(
              value: (_caracDropdownValues[id]?.isNotEmpty == true) ? _caracDropdownValues[id] : null,
              isExpanded: true,
              decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
              items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
              onChanged: (v) => setState(() => _caracDropdownValues[id] = v ?? ''),
            );
          case 'number':
            return TextFormField(
              controller: _caracControllers[id]!,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
            );
          case 'date':
            return InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context, initialDate: DateTime.now(),
                  firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) { _caracControllers[id]!.text = picked.toIso8601String().split('T').first; setState(() {}); }
              },
              child: InputDecorator(
                decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
                child: Text(_caracControllers[id]!.text.isEmpty ? 'Sélectionner une date' : _caracControllers[id]!.text),
              ),
            );
          default:
            return TextFormField(
              controller: _caracControllers[id]!,
              decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
            );
        }
      }).toList(),
    ]);
  }

  List<Map<String, dynamic>> _buildCaracteristiqueValeurs() {
    final values = <Map<String, dynamic>>[];
    for (final c in _caracteristiques) {
      if (c.idCaracteristique == null) continue;
      String valeur;
      switch (c.typeDonnee) {
        case 'boolean': valeur = _caracBooleanValues[c.idCaracteristique!]?.toString() ?? 'false'; break;
        case 'select': valeur = _caracDropdownValues[c.idCaracteristique!] ?? ''; break;
        default: valeur = _caracControllers[c.idCaracteristique!]?.text ?? '';
      }
      if (valeur.isNotEmpty) values.add({'idCaracteristique': c.idCaracteristique, 'valeur': valeur});
    }
    return values;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final orgCode = userCode ?? '';
      final event = Evenement(
        idEvenement: _isEditing ? widget.event!.idEvenement : null,
        titre: _titreCtrl.text,
        description: _descriptionCtrl.text.isEmpty ? null : _descriptionCtrl.text,
        dateEvenement: _selectedDate,
        heureEvenement: '${_selectedHeureDebut!.hour.toString().padLeft(2, '0')}:${_selectedHeureDebut!.minute.toString().padLeft(2, '0')}:00',
        dateFin: _selectedDate,
        prix: null,
        capacite: null,
        statut: 'planifie',
        codeCategorie: _selectedCategorie,
        codeLieu: _selectedLieu,
        typeAgencement: _typeAgencementFromPlacement,
        numeroSalle: _selectedSalle,
        codeOrganisateur: orgCode,
        caracteristiqueValeurs: _buildCaracteristiqueValeurs()
            .map((e) => EvenementCaracteristiqueValeur(idCaracteristique: e['idCaracteristique'] as int, valeur: e['valeur'] as String))
            .toList(),
      );

      if (_isEditing) {
        await _eventService.updateEvent(widget.event!.idEvenement!, event.toJson());
      } else {
        final createdData = await _eventService.createEvent(event.toJson());
        final created = Evenement.fromJson(createdData);
        if (mounted && created.idEvenement != null) {
          if (_typePlacement == 'NUMEROTE' || _typePlacement == 'MIXTE') {
            try {
              for (final entry in _typePriceCtrls.entries) {
                final prixText = entry.value.text;
                final prix = prixText.isNotEmpty ? double.tryParse(prixText) : null;
                if (prix != null) {
                  await _placeService.setTypePricing(created.idEvenement!, entry.key, prix);
                }
              }
              final rowGroups = <String, List<String>>{};
              for (final entry in _pendingRowAssignments.entries) {
                rowGroups.putIfAbsent(entry.value, () => []); rowGroups[entry.value]!.add(entry.key);
              }
              final placeGroups = <String, List<String>>{};
              for (final entry in _pendingPlaceAssignments.entries) {
                placeGroups.putIfAbsent(entry.value, () => []); placeGroups[entry.value]!.add(entry.key);
              }
              for (final type in {...rowGroups.keys, ...placeGroups.keys}) {
                await _placeService.assignTypes(created.idEvenement!, {
                  'typePlace': type, 'placeIds': placeGroups[type] ?? [], 'rows': rowGroups[type] ?? [],
                });
              }
            } catch (_) {}
          }
          if (_hasNewImage) {
            try { await _eventService.uploadImage(created.idEvenement!, File(_selectedImagePath!)); } catch (_) {}
          }
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEditing ? 'Événement modifié' : 'Événement créé'),
        backgroundColor: AppTheme.secondaryColor,
      ));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(apiErrorString(e)), backgroundColor: AppTheme.errorColor));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<String> get _availableTypes => _placeTypes.where((t) {
    final text = _typePriceCtrls[t]?.text.trim() ?? '';
    return text.isNotEmpty && double.tryParse(text) != null;
  }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Modifier' : 'Créer un événement')),
      body: _dataLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildStepper(),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: _buildCurrentStep(),
                    ),
                  ),
                ),
                _buildFooter(),
              ],
            ),
    );
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        border: Border(bottom: BorderSide(color: AppTheme.dividerColor)),
      ),
      child: Row(
        children: List.generate(_steps.length, (i) {
          final isActive = i == _currentStep;
          final isDone = i < _currentStep;
          return Expanded(
            child: GestureDetector(
              onTap: i <= _currentStep ? () => setState(() => _currentStep = i) : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? AppTheme.primaryColor : (isDone ? AppTheme.secondaryColor : AppTheme.surfaceColor),
                      border: Border.all(color: isActive || isDone ? Colors.transparent : AppTheme.textSecondary),
                    ),
                    child: Center(
                      child: isDone
                          ? const Icon(Icons.check, color: Colors.white, size: 16)
                          : Text('${i + 1}', style: TextStyle(
                              color: isActive ? Colors.white : AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(_steps[i], style: TextStyle(
                    fontSize: 9, color: isActive ? AppTheme.primaryColor : AppTheme.textSecondary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  )),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0: return _buildStep1();
      case 1: return _buildStep2();
      case 2: return _buildStep3();
      case 3: return _buildStep4();
      case 4: return _buildStep5();
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildStep1() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Informations générales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      TextFormField(
        controller: _titreCtrl,
        decoration: const InputDecoration(labelText: 'Titre *', border: OutlineInputBorder()),
        validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _descriptionCtrl,
        decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
        maxLines: 3,
      ),
      const SizedBox(height: 12),
      InkWell(
        onTap: () async {
          final picked = await _imagePicker.pickImage(source: ImageSource.gallery, maxWidth: 1920, maxHeight: 1080);
          if (picked != null) setState(() => _selectedImagePath = picked.path);
        },
        child: Container(
          height: 120, width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.textSecondary.withValues(alpha: 0.3)),
          ),
          child: _hasNewImage
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(File(_selectedImagePath!), height: 120, width: double.infinity, fit: BoxFit.cover),
                )
              : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.add_photo_alternate, size: 40, color: AppTheme.textSecondary),
                  Text('Ajouter une affiche', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                ]),
        ),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        value: _selectedCategorie,
        isExpanded: true,
        decoration: const InputDecoration(labelText: 'Genre *', border: OutlineInputBorder()),
        items: _categories.map((c) => DropdownMenuItem(value: c.codeCategorie, child: Text(c.nomCategorie))).toList(),
        onChanged: (v) {
          setState(() { _selectedCategorie = v; });
          if (v != null) _loadCaracteristiques(v);
        },
        validator: (v) => v == null ? 'Requis' : null,
      ),
      if (_loadingCaracteristiques)
        const LinearProgressIndicator()
      else
        _buildCaracteristiquesInputs(),
      const SizedBox(height: 12),
      const Text('Type de placement', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Row(children: [
        _buildPlacementChip('LIBRE', 'Placement\nLibre', Icons.people),
        const SizedBox(width: 8),
        _buildPlacementChip('NUMEROTE', 'Placement\nNuméroté', Icons.event_seat),
        const SizedBox(width: 8),
        _buildPlacementChip('MIXTE', 'Placement\nMixte', Icons.swap_horiz),
      ]),
    ]);
  }

  Widget _buildPlacementChip(String value, String label, IconData icon) {
    final selected = _typePlacement == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _typePlacement = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryColor.withValues(alpha: 0.1) : AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? AppTheme.primaryColor : AppTheme.dividerColor, width: selected ? 2 : 1),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? AppTheme.primaryColor : AppTheme.textSecondary, size: 24),
              const SizedBox(height: 6),
              Text(label, textAlign: TextAlign.center, style: TextStyle(
                fontSize: 11, fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? AppTheme.primaryColor : AppTheme.textSecondary,
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep2() {
    final duree = _dureeCalculee;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Date & Heure', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context, initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
            firstDate: _isEditing ? DateTime(2020) : DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (picked != null) setState(() => _selectedDate = picked);
        },
        child: InputDecorator(
          decoration: const InputDecoration(labelText: 'Date *', border: OutlineInputBorder()),
          child: Text(_selectedDate != null
              ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
              : 'Sélectionner la date'),
        ),
      ),
      const SizedBox(height: 12),
      InkWell(
        onTap: () async {
          final picked = await showTimePicker(context: context, initialTime: _selectedHeureDebut ?? TimeOfDay.now());
          if (picked != null) setState(() => _selectedHeureDebut = picked);
        },
        child: InputDecorator(
          decoration: const InputDecoration(labelText: 'Heure début *', border: OutlineInputBorder()),
          child: Text(_selectedHeureDebut != null
              ? '${_selectedHeureDebut!.hour.toString().padLeft(2, '0')}:${_selectedHeureDebut!.minute.toString().padLeft(2, '0')}'
              : 'Sélectionner l\'heure'),
        ),
      ),
      const SizedBox(height: 12),
      InkWell(
        onTap: () async {
          final picked = await showTimePicker(context: context, initialTime: _selectedHeureFin ?? TimeOfDay.now());
          if (picked != null) setState(() => _selectedHeureFin = picked);
        },
        child: InputDecorator(
          decoration: const InputDecoration(labelText: 'Heure fin', border: OutlineInputBorder()),
          child: Text(_selectedHeureFin != null
              ? '${_selectedHeureFin!.hour.toString().padLeft(2, '0')}:${_selectedHeureFin!.minute.toString().padLeft(2, '0')}'
              : 'Sélectionner l\'heure'),
        ),
      ),
      if (duree != null) ...[
        const SizedBox(height: 8),
        Card(
          color: AppTheme.primaryColor.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              const Icon(Icons.timer, size: 20, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text('Durée : ${duree.inHours}h ${duree.inMinutes.remainder(60)}min',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      ],
    ]);
  }

  Widget _buildStep3() {
    final lieuxFiltres = _lieux;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Lieu & Configuration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(
        value: _selectedLieu,
        isExpanded: true,
        decoration: const InputDecoration(labelText: 'Lieu / Bâtiment', border: OutlineInputBorder()),
        items: lieuxFiltres.map((l) => DropdownMenuItem(value: l.code, child: Text(l.nomLieu))).toList(),
        onChanged: (v) {
          setState(() { _selectedLieu = v; _selectedSalle = null; _salles = []; });
          if (v != null) _loadSalles(v, categorieCode: _selectedCategorie);
        },
      ),
      const SizedBox(height: 12),
      if (_selectedLieu != null)
        _loadingSalles
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : _salles.isEmpty
                ? Text('Aucune salle disponible', style: TextStyle(color: AppTheme.textSecondary))
                : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Salle', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    ..._salles.map((s) {
                      final id = s['numeroSalle'] as String? ?? '';
                      final nom = s['nomSalle'] as String? ?? id;
                      final capacite = s['capacite'];
                      final selected = _selectedSalle == id;
                      return GestureDetector(
                        onTap: () {
                          setState(() { _selectedSalle = id; });
                          _loadPlaces();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: selected ? AppTheme.primaryColor.withValues(alpha: 0.08) : AppTheme.surfaceColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: selected ? AppTheme.primaryColor : AppTheme.dividerColor),
                          ),
                          child: Row(children: [
                            Icon(Icons.meeting_room, size: 20, color: selected ? AppTheme.primaryColor : AppTheme.textSecondary),
                            const SizedBox(width: 10),
                            Expanded(child: Text(nom, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                            if (capacite != null) Text('$capacite pl.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                          ]),
                        ),
                      );
                    }),
                  ]),
      const SizedBox(height: 20),
      const Text('Types de places', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text('Créez les catégories de places (Standard, VIP, Fosse, Balcon...)',
          style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: _placeTypes.map((type) {
        final isDefault = type == 'Standard' || type == 'VIP';
        return Chip(
          label: Text(type, style: TextStyle(fontSize: 12, color: isDefault ? Colors.white : null)),
          backgroundColor: isDefault ? AppTheme.primaryColor : AppTheme.surfaceColor,
          deleteIcon: isDefault ? null : const Icon(Icons.close, size: 16),
          onDeleted: isDefault ? null : () => _removePlaceType(type),
        );
      }).toList()),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(
          child: TextField(
            controller: _newPlaceTypeCtrl,
            decoration: const InputDecoration(hintText: 'Nouveau type...', border: OutlineInputBorder(), isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
            style: const TextStyle(fontSize: 13),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed: _addPlaceType,
          icon: const Icon(Icons.add, size: 20),
        ),
      ]),
    ]);
  }

  Widget _buildStep4() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Tarification', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text('Définissez le prix pour chaque type de place.',
          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      const SizedBox(height: 16),
      if (_typePlacement == 'NUMEROTE' || _typePlacement == 'MIXTE') ...[
        if (_selectedSalle == null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Veuillez d\'abord sélectionner une salle à l\'étape précédente.',
                style: TextStyle(color: AppTheme.textSecondary)),
          )
        else ...[
          ..._placeTypes.map((type) {
            _typePriceCtrls.putIfAbsent(type, () => TextEditingController());
            final count = _places.where((p) => (p.typePlace ?? 'Standard') == type).length;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(type, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      Text('$count place(s)', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                    ]),
                  ),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: _typePriceCtrls[type]!,
                      decoration: const InputDecoration(
                        hintText: 'Prix', border: OutlineInputBorder(), isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        prefixText: 'Ar ',
                      ),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ]),
              ),
            );
          }),
          const SizedBox(height: 8),
          if (_places.isNotEmpty) ...[
            const Text('Configurer le plan de salle', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            _buildRowSelector(),
            const SizedBox(height: 4),
            InkWell(
              onTap: () => setState(() => _gridExpanded = !_gridExpanded),
              child: Row(children: [
                Icon(_gridExpanded ? Icons.expand_less : Icons.expand_more, size: 18),
                Text('Places individuelles', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.primaryColor)),
                const SizedBox(width: 8),
                Text('${_selectedPlaceIds.length} sélectionnée(s)', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
              ]),
            ),
            if (_gridExpanded) ...[const SizedBox(height: 4), _buildSeatGrid()],
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: DropdownButtonFormField<String>(
                value: _availableTypes.contains(_assignType) ? _assignType : null,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder(), isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
                items: _availableTypes.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12)))).toList(),
                onChanged: (v) => setState(() => _assignType = v!),
              )),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _selectedRows.isEmpty && _selectedPlaceIds.isEmpty ? null : _addPendingAssignment,
                child: const Text('Affecter', style: TextStyle(fontSize: 12)),
              ),
            ]),
            if (_pendingRowAssignments.isNotEmpty || _pendingPlaceAssignments.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.pending, size: 14, color: AppTheme.primaryColor),
                      const SizedBox(width: 4),
                      Text('Assignations (${_pendingRowAssignments.length + _pendingPlaceAssignments.length})',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() { _pendingRowAssignments.clear(); _pendingPlaceAssignments.clear(); }),
                        child: Text('Effacer', style: TextStyle(fontSize: 10, color: AppTheme.errorColor)),
                      ),
                    ]),
                    ..._pendingRowAssignments.entries.map((e) => Text('  Rangée ${e.key} → ${e.value}', style: const TextStyle(fontSize: 10))),
                    ..._pendingPlaceAssignments.entries.map((e) => Text('  Place ${e.key} → ${e.value}', style: const TextStyle(fontSize: 10))),
                  ],
                ),
              ),
            ],
          ],
        ],
      ],
      if (_typePlacement == 'LIBRE' || _typePlacement == 'MIXTE') ...[
        const Divider(),
        const Text('Places libres / debout', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Pour les zones debout ou libres, la tarification sera gérée après la création.',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ],
    ]);
  }
  Widget _buildRowSelector() {
    final rangs = _places.map((p) => p.range).whereType<String>().toSet().toList()..sort();
    if (rangs.isEmpty) return const Text('Aucune rangée', style: TextStyle(color: AppTheme.textSecondary));
    return Wrap(spacing: 6, runSpacing: 4, children: rangs.map((rang) {
      final selected = _selectedRows.contains(rang);
      final count = _places.where((p) => p.range == rang).length;
      return FilterChip(
        label: Text('$rang ($count)', style: TextStyle(fontSize: 11, color: selected ? Colors.white : null)),
        selected: selected,
        onSelected: (v) { setState(() { if (v) _selectedRows.add(rang); else _selectedRows.remove(rang); }); },
      );
    }).toList());
  }

  Widget _buildSeatGrid() {
    final rangs = _places.map((p) => p.range).whereType<String>().toSet().toList()..sort();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rangs.map((rang) {
      final rowPlaces = _places.where((p) => p.range == rang).toList()..sort((a, b) => a.numeroPlace.compareTo(b.numeroPlace));
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Rangée $rang', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          const SizedBox(height: 2),
          Wrap(spacing: 3, runSpacing: 3, children: rowPlaces.map((p) {
            final selected = _selectedPlaceIds.contains(p.numeroPlace);
            return GestureDetector(
              onTap: () => setState(() { if (selected) _selectedPlaceIds.remove(p.numeroPlace); else _selectedPlaceIds.add(p.numeroPlace); }),
              child: Container(
                width: 34, height: 26,
                decoration: BoxDecoration(
                  color: selected ? AppTheme.primaryColor.withValues(alpha: 0.3) : AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: selected ? AppTheme.primaryColor : AppTheme.dividerColor, width: selected ? 2 : 0.5),
                ),
                child: Center(child: Text(p.numeroPlace.replaceAll(rang, ''),
                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: selected ? AppTheme.primaryColor : AppTheme.textSecondary))),
              ),
            );
          }).toList()),
        ]),
      );
    }).toList());
  }

  Widget _buildStep5() {
    final duree = _dureeCalculee;
    final cat = _categories.where((c) => c.codeCategorie == _selectedCategorie).firstOrNull;
    final salle = _salles.where((s) => (s['numeroSalle'] as String?) == _selectedSalle).firstOrNull;
    final lieu = _lieux.where((l) => l.code == _selectedLieu).firstOrNull;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Récapitulatif', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (_hasNewImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(File(_selectedImagePath!), height: 140, width: double.infinity, fit: BoxFit.cover),
              ),
            if (_hasNewImage) const SizedBox(height: 12),
            Text(_titreCtrl.text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            if (cat != null) ...[
              const SizedBox(height: 4),
              Text(cat.nomCategorie, style: TextStyle(color: AppTheme.textSecondary)),
            ],
            const Divider(),
            _recapRow(Icons.calendar_today, _selectedDate != null
                ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}' : '—'),
            if (_selectedHeureDebut != null)
              _recapRow(Icons.access_time,
                  '${_selectedHeureDebut!.hour.toString().padLeft(2, '0')}:${_selectedHeureDebut!.minute.toString().padLeft(2, '0')}'
                  '${_selectedHeureFin != null ? ' → ${_selectedHeureFin!.hour.toString().padLeft(2, '0')}:${_selectedHeureFin!.minute.toString().padLeft(2, '0')}' : ''}'
                  '${duree != null ? ' (${duree.inHours}h${duree.inMinutes.remainder(60)}min)' : ''}'),
            if (lieu != null) _recapRow(Icons.location_on, lieu.nomLieu),
            if (salle != null) _recapRow(Icons.meeting_room, salle['nomSalle'] as String? ?? ''),
            const Divider(),
            _recapRow(Icons.people, _typePlacement == 'LIBRE' ? 'Placement libre' : (_typePlacement == 'MIXTE' ? 'Mixte' : 'Numéroté')),
            _recapRow(Icons.category, _placeTypes.join(', ')),
            if (_typePriceCtrls.entries.any((e) => e.value.text.isNotEmpty)) ...[
              const Divider(),
              ..._typePriceCtrls.entries.where((e) => e.value.text.isNotEmpty).map((e) =>
                _recapRow(Icons.monetization_on, '${e.key} : Ar ${double.tryParse(e.value.text)?.toStringAsFixed(2) ?? e.value.text}')),
            ],
            if (_caracteristiques.isNotEmpty && _buildCaracteristiqueValeurs().isNotEmpty) ...[
              const Divider(),
              ..._buildCaracteristiqueValeurs().map((v) {
                final nom = _caracteristiques
                    .where((c) => c.idCaracteristique == v['idCaracteristique'])
                    .firstOrNull?.nom ?? '';
                return _recapRow(Icons.info_outline, '$nom : ${v['valeur']}');
              }),
            ],
          ]),
        ),
      ),
    ]);
  }

  Widget _recapRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
      ]),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        border: Border(top: BorderSide(color: AppTheme.dividerColor)),
      ),
      child: Row(children: [
        if (_currentStep > 0)
          TextButton.icon(
            onPressed: () => setState(() => _currentStep--),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Retour'),
          )
        else
          const SizedBox(),
        const Spacer(),
        if (_currentStep < _steps.length - 1)
          ElevatedButton(
            onPressed: _canNext() ? () => setState(() => _currentStep++) : null,
            child: const Text('Suivant'),
          )
        else
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondaryColor),
            child: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Publier l\'événement'),
          ),
      ]),
    );
  }

  bool _canNext() {
    switch (_currentStep) {
      case 0: return _step1Valid;
      case 1: return _step2Valid;
      case 2: return _selectedLieu != null;
      case 3: return true;
      default: return true;
    }
  }
}
