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
import '../../core/utils/error_helper.dart';
import 'create_event_page/step_1_general.dart';
import 'create_event_page/step_2_date_time.dart';
import 'create_event_page/step_3_location.dart';
import 'create_event_page/step_4_pricing.dart';
import 'create_event_page/step_5_summary.dart';

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
  int _nombreJours = 1;
  int _dureeHeures = 2;
  int _dureeMinutes = 0;

  String? _selectedCategorie;
  String? _selectedLieu;
  String? _selectedSalle;
  List<Categorie> _categories = [];
  List<Lieu> _lieux = [];
  List<Map<String, dynamic>> _salles = [];
  bool _loadingSalles = false;

  String _typePlacement = 'LIBRE';
  bool _salleOptionnelle = true;
  final _capaciteLibreCtrl = TextEditingController();
  bool _capaciteIllimitee = true;

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

  final List<Map<String, dynamic>> _standingZones = [];
  final _zoneNomCtrl = TextEditingController();
  final _zoneCapaciteCtrl = TextEditingController();
  final _zonePrixCtrl = TextEditingController();
  bool _zoneCapaciteIllimitee = true;

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
    _capaciteLibreCtrl.dispose();
    _zoneNomCtrl.dispose();
    _zoneCapaciteCtrl.dispose();
    _zonePrixCtrl.dispose();
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
      case 'LIBRE':
        return _capaciteIllimitee ? 'DEBOUT_SANS_LIMITE' : 'DEBOUT_AVEC_LIMITE';
      case 'MIXTE':
        return 'ASSIS_DEBOUT';
      default:
        return 'UNIQUEMENT_ASSIS';
    }
  }

  Duration get _dureeCalculee => Duration(hours: _dureeHeures, minutes: _dureeMinutes);

  bool get _step1Valid => _titreCtrl.text.trim().isNotEmpty && _selectedCategorie != null && _requiredCaracteristiquesValid;

  bool get _step2Valid => _selectedDate != null && _selectedHeureDebut != null;

  bool get _requiredCaracteristiquesValid {
    for (final c in _caracteristiques) {
      if (!c.obligatoire || c.idCaracteristique == null) continue;
      switch (c.typeDonnee) {
        case 'boolean':
          break;
        case 'select':
          final value = _caracDropdownValues[c.idCaracteristique!];
          if (value == null || value.isEmpty) return false;
          break;
        default:
          final value = _caracControllers[c.idCaracteristique!]?.text.trim() ?? '';
          if (value.isEmpty) return false;
      }
    }
    return true;
  }

  Future<void> _loadSalles(String lieuCode) async {
    setState(() { if (!_isEditing) _selectedSalle = null; _loadingSalles = true; });
    try {
      final allSalles = await _lieuService.getSallesByLieu(lieuCode);
      if (!mounted) return;
      setState(() { _salles = allSalles.cast<Map<String, dynamic>>(); _loadingSalles = false; });
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

  void _addStandingZone() {
    final nom = _zoneNomCtrl.text.trim();
    if (nom.isEmpty) return;
    setState(() {
      _standingZones.add({
        'nom': nom,
        'capacite': _zoneCapaciteIllimitee ? null : (int.tryParse(_zoneCapaciteCtrl.text) ?? 0),
        'prix': double.tryParse(_zonePrixCtrl.text) ?? 0.0,
      });
      _zoneNomCtrl.clear();
      _zoneCapaciteCtrl.clear();
      _zonePrixCtrl.clear();
      _zoneCapaciteIllimitee = true;
    });
  }

  void _removeStandingZone(int index) {
    setState(() => _standingZones.removeAt(index));
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
      final dateFin = _selectedDate!.add(Duration(days: _nombreJours - 1));
      final event = Evenement(
        idEvenement: _isEditing ? widget.event!.idEvenement : null,
        titre: _titreCtrl.text,
        description: _descriptionCtrl.text.isEmpty ? null : _descriptionCtrl.text,
        dateEvenement: _selectedDate,
        heureEvenement: '${_selectedHeureDebut!.hour.toString().padLeft(2, '0')}:${_selectedHeureDebut!.minute.toString().padLeft(2, '0')}:00',
        dateFin: dateFin,
        prix: null,
        capacite: (_typePlacement == 'LIBRE' && !_capaciteIllimitee)
            ? int.tryParse(_capaciteLibreCtrl.text)
            : null,
        statut: 'planifie',
        codeCategorie: _selectedCategorie,
        codeLieu: _selectedLieu,
        typeAgencement: _typeAgencementFromPlacement,
        numeroSalle: _typePlacement == 'LIBRE' ? (_salleOptionnelle ? null : _selectedSalle) : _selectedSalle,
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
          if (_typePlacement == 'MIXTE') {
            for (final zone in _standingZones) {
              try {
                await _eventService.createStandingZone(created.idEvenement!, {
                  'nom': zone['nom'],
                  'capacite': zone['capacite'],
                  'prix': zone['prix'],
                });
              } catch (_) {}
            }
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
  Future<bool> _onWillPop() async {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      return false;
    }
    final dirty = _titreCtrl.text.isNotEmpty || _descriptionCtrl.text.isNotEmpty;
    if (!dirty) return true;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quitter la création ?'),
        content: const Text('Les informations saisies seront perdues.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Quitter')),
        ],
      ),
    );
    return confirm ?? false;
  }

  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
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
    return buildStep1(
      titreCtrl: _titreCtrl,
      descriptionCtrl: _descriptionCtrl,
      selectedCategorie: _selectedCategorie,
      categories: _categories,
      selectedImagePath: _selectedImagePath,
      hasNewImage: _hasNewImage,
      typePlacement: _typePlacement,
      caracteristiques: _caracteristiques,
      caracControllers: _caracControllers,
      caracDropdownValues: _caracDropdownValues,
      caracBooleanValues: _caracBooleanValues,
      loadingCaracteristiques: _loadingCaracteristiques,
      imagePicker: _imagePicker,
      onCategorieChanged: (v) {
        setState(() { _selectedCategorie = v; _caracteristiques = []; });
        if (v != null) _loadCaracteristiques(v);
      },
      onPlacementChanged: (v) => setState(() => _typePlacement = v),
      onImagePicked: (path) => setState(() => _selectedImagePath = path),
      onRefresh: () => setState(() {}),
    );
  }

  Widget _buildStep2() {
    return buildStep2(
      selectedDate: _selectedDate,
      nombreJours: _nombreJours,
      selectedHeureDebut: _selectedHeureDebut,
      dureeHeures: _dureeHeures,
      dureeMinutes: _dureeMinutes,
      isEditing: _isEditing,
      onDateChanged: (v) => setState(() => _selectedDate = v),
      onNombreJoursChanged: (v) => setState(() => _nombreJours = v),
      onHeureChanged: (v) => setState(() => _selectedHeureDebut = v),
      onDureeHeuresChanged: (v) => setState(() => _dureeHeures = v),
      onDureeMinutesChanged: (v) => setState(() => _dureeMinutes = v),
    );
  }

  Widget _buildStep3() {
    return buildStep3(
      selectedLieu: _selectedLieu,
      lieux: _lieux,
      selectedSalle: _selectedSalle,
      salles: _salles,
      loadingSalles: _loadingSalles,
      typePlacement: _typePlacement,
      salleOptionnelle: _salleOptionnelle,
      capaciteIllimitee: _capaciteIllimitee,
      capaciteLibreCtrl: _capaciteLibreCtrl,
      placeTypes: _placeTypes,
      typePriceCtrls: _typePriceCtrls,
      standingZones: _standingZones,
      zoneNomCtrl: _zoneNomCtrl,
      zoneCapaciteCtrl: _zoneCapaciteCtrl,
      zonePrixCtrl: _zonePrixCtrl,
      zoneCapaciteIllimitee: _zoneCapaciteIllimitee,
      newPlaceTypeCtrl: _newPlaceTypeCtrl,
      places: _places,
      onLieuChanged: (v) {
        setState(() { _selectedLieu = v; _selectedSalle = null; _salles = []; });
        if (v != null) _loadSalles(v);
      },
      onSalleChanged: (v) {
        setState(() => _selectedSalle = v);
        _loadPlaces();
      },
      onSalleOptionnelleChanged: (v) => setState(() { _salleOptionnelle = v; _selectedSalle = null; _salles = []; }),
      onCapaciteIllimiteeChanged: (v) => setState(() => _capaciteIllimitee = v),
      onAddPlaceType: _addPlaceType,
      onRemovePlaceType: _removePlaceType,
      onAddStandingZone: _addStandingZone,
      onRemoveStandingZone: _removeStandingZone,
      onToggleCapaciteIllimitee: (v) => setState(() => _zoneCapaciteIllimitee = v),
      onRefresh: () => setState(() {}),
    );
  }

  Widget _buildStep4() {
    return buildStep4(
      typePlacement: _typePlacement,
      placeTypes: _placeTypes,
      typePriceCtrls: _typePriceCtrls,
      standingZones: _standingZones,
      selectedSalle: _selectedSalle,
      places: _places,
      selectedRows: _selectedRows,
      selectedPlaceIds: _selectedPlaceIds,
      assignType: _assignType,
      availableTypes: _availableTypes,
      gridExpanded: _gridExpanded,
      pendingRowAssignments: _pendingRowAssignments,
      pendingPlaceAssignments: _pendingPlaceAssignments,
      onAssignTypeChanged: (v) => setState(() => _assignType = v),
      onAddPendingAssignment: _addPendingAssignment,
      onClearPendingAssignments: () => setState(() { _pendingRowAssignments.clear(); _pendingPlaceAssignments.clear(); }),
      onToggleRow: (v) => setState(() { if (_selectedRows.contains(v)) _selectedRows.remove(v); else _selectedRows.add(v); }),
      onTogglePlace: (v) => setState(() { if (_selectedPlaceIds.contains(v)) _selectedPlaceIds.remove(v); else _selectedPlaceIds.add(v); }),
      onToggleGridExpanded: (v) => setState(() => _gridExpanded = v),
      onRemoveStandingZone: _removeStandingZone,
      onRefresh: () => setState(() {}),
    );
  }

  Widget _buildStep5() {
    return buildStep5(
      titreCtrl: _titreCtrl,
      selectedImagePath: _selectedImagePath,
      hasNewImage: _hasNewImage,
      selectedCategorie: _selectedCategorie,
      categories: _categories,
      selectedDate: _selectedDate,
      nombreJours: _nombreJours,
      selectedHeureDebut: _selectedHeureDebut,
      dureeCalculee: _dureeCalculee,
      selectedLieu: _selectedLieu,
      lieux: _lieux,
      selectedSalle: _selectedSalle,
      salles: _salles,
      typePlacement: _typePlacement,
      salleOptionnelle: _salleOptionnelle,
      capaciteIllimitee: _capaciteIllimitee,
      capaciteLibreCtrl: _capaciteLibreCtrl,
      placeTypes: _placeTypes,
      typePriceCtrls: _typePriceCtrls,
      standingZones: _standingZones,
      caracteristiques: _caracteristiques,
      caracDropdownValues: _caracDropdownValues,
      caracControllers: _caracControllers,
      caracBooleanValues: _caracBooleanValues,
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
      case 2:
        if (_typePlacement == 'LIBRE') return _selectedLieu != null;
        return _selectedLieu != null && _selectedSalle != null;
      case 3: return true;
      default: return true;
    }
  }
}
