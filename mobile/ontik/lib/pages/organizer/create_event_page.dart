import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/api/dio_config.dart';
import '../../core/services/evenement_service.dart';
import '../../core/services/lieu_service.dart';
import '../../core/services/place_service.dart';
import '../../core/services/categorie_service.dart';
import '../../models/event_place_config_model.dart';
import '../../models/evenement_model.dart';
import '../../models/lieu_model.dart';
import '../../models/categorie_model.dart';
import '../../core/assets/app_colors.dart';
import '../../widgets/event_image_widget.dart';
import 'pricing_page.dart';
import '../../core/utils/error_helper.dart';

class CreateEventPage extends StatefulWidget {
  final Evenement? event;

  const CreateEventPage({super.key, this.event});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  bool get _isEditing => widget.event != null;
  final _formKey = GlobalKey<FormState>();
  final _titreCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _imagePicker = ImagePicker();
  String? _selectedImagePath;
  bool get _hasNewImage => _selectedImagePath != null;
  DateTime? _selectedDate;
  String? _selectedTime;
  String? _selectedCategorie;
  String? _selectedLieu;
  List<Categorie> _categories = [];
  List<Lieu> _lieux = [];
  List<Map<String, dynamic>> _salles = [];
  String? _selectedSalle;
  bool _loadingSalles = false;

  List<EventPlaceConfig> _places = [];
  bool _loadingPlaces = false;
  final Map<String, TextEditingController> _typePrices = {};
  final List<String> _typeOrder = [];
  final _newTypeNameCtrl = TextEditingController();
  final _newTypePriceCtrl = TextEditingController();

  final Set<String> _selectedRows = {};
  final Set<String> _selectedPlaceIds = {};
  String _assignType = 'Standard';
  final Map<String, String> _pendingRowAssignments = {};
  final Map<String, String> _pendingPlaceAssignments = {};
  bool _gridExpanded = false;

  bool _loading = false;
  bool _dataLoading = true;

  final _eventService = EvenementService();
  final _lieuService = LieuService();
  final _placeService = PlaceService();
  final _categorieService = CategorieService();

  final _statuts = ['planifie', 'en_cours', 'termine'];
  String _selectedStatut = 'planifie';

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
    _newTypeNameCtrl.dispose();
    _newTypePriceCtrl.dispose();
    for (final ctrl in _typePrices.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _loadFormData() async {
    try {
      final categories = (await _categorieService.getCategories())
          .map((e) => Categorie.fromJson(e as Map<String, dynamic>)).toList();
      final lieux = (await _lieuService.getLieux())
          .map((e) => Lieu.fromJson(e as Map<String, dynamic>)).toList();

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

  Future<void> _loadSalles(String lieuCode) async {
    setState(() {
      if (!_isEditing) _selectedSalle = null;
      _loadingSalles = true;
    });
    try {
      final allSalles = await _lieuService.getSalles();
      final filtered = allSalles.where((s) => (s as Map<String, dynamic>)['codeLieu'] == lieuCode).cast<Map<String, dynamic>>().toList();
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
      final List<dynamic> raw;
      if (_isEditing && widget.event?.idEvenement != null) {
        raw = await _placeService.getPlacesConfig(widget.event!.idEvenement!, _selectedSalle!);
      } else {
        raw = await _placeService.getPlacesBySalle(_selectedSalle!);
      }
      final places = raw.map((e) => EventPlaceConfig.fromJson(e as Map<String, dynamic>)).toList();
      if (!mounted) return;
      final distinctTypes = places.map((p) => p.effectiveType).toSet().toList()..sort();
      for (final t in distinctTypes) {
        final existing = _typePrices[t];
        if (existing == null) {
          final prix = places.any((p) => p.effectiveType == t && p.effectivePrice > 0)
              ? places.firstWhere((p) => p.effectiveType == t).effectivePrice.toString()
              : '';
          _typePrices[t] = TextEditingController(text: prix);
        }
        if (!_typeOrder.contains(t)) _typeOrder.add(t);
      }
      setState(() { _places = places; _loadingPlaces = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _places = []; _loadingPlaces = false; });
    }
  }

  void _populateFromEvent(Evenement event) {
    _titreCtrl.text = event.titre;
    if (event.description != null) _descriptionCtrl.text = event.description!;
    _selectedDate = event.dateEvenement;
    _selectedTime = event.heureEvenement;
    _selectedCategorie = event.codeCategorie;
    _selectedLieu = event.codeLieu;
    _selectedStatut = event.statut ?? 'planifie';
    if (event.codeLieu != null && _isEditing && event.idEvenement != null) {
      _loadSalles(event.codeLieu!).then((_) async {
        String? salle;
        if (_salles.isNotEmpty) {
          salle = _salles.first['numeroSalle'] as String?;
          setState(() => _selectedSalle = salle);
          _loadPlaces();
        }
        try {
          final eventSalles = await _placeService.getOrganizerEventSalles(event.idEvenement!);
          if (eventSalles.isNotEmpty && mounted) {
            final exact = (eventSalles.first as Map<String, dynamic>)['numeroSalle'] as String?;
            if (exact != null && exact != salle) {
              setState(() => _selectedSalle = exact);
              _loadPlaces();
            }
          }
        } catch (_) {}
      });
    }
  }

  Widget _buildCreateTypePricingSection() {
    if (_typeOrder.isEmpty) return const SizedBox.shrink();
    final placesByType = <String, List<EventPlaceConfig>>{};
    for (final p in _places) {
      final t = p.typePlace ?? 'Standard';
      placesByType.putIfAbsent(t, () => []);
      placesByType[t]!.add(p);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Prix par type de place', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Définissez le prix pour chaque type. Ajoutez vos propres types si nécessaire.',
            style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        const SizedBox(height: 8),
        ..._typeOrder.map((type) {
          final places = placesByType[type] ?? [];
          final isCustom = !AppConstants.placeTypes.contains(type);
          final color = AppConstants.placeTypeColors[type] ?? AppTheme.textSecondary;
          _typePrices.putIfAbsent(type, () => TextEditingController());
          return Card(
            margin: const EdgeInsets.only(bottom: 6),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(child: Text(type.substring(0, 1).toUpperCase(),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color))),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: isCustom
                      ? GestureDetector(
                          onTap: () => _editCustomTypeName(type),
                          child: Row(children: [
                            Flexible(child: Text(type, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                            const SizedBox(width: 4),
                            Icon(Icons.edit, size: 14, color: AppTheme.textSecondary),
                          ]),
                        )
                      : Text(type, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ),
                Expanded(
                  child: Text(
                    places.isEmpty ? 'sur mesure' : '${places.length} pl.',
                    style: TextStyle(fontSize: 11, color: places.isEmpty ? AppTheme.accentColor : AppTheme.textSecondary),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _typePrices[type]!,
                    decoration: const InputDecoration(
                      hintText: 'Prix', border: OutlineInputBorder(), isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    ),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                if (isCustom)
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () => _removeCustomType(type),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ]),
            ),
          );
        }).toList(),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: TextField(
              controller: _newTypeNameCtrl,
              decoration: const InputDecoration(
                hintText: 'Nouveau type...', border: OutlineInputBorder(), isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _addCustomType,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Ajouter', style: TextStyle(fontSize: 11)),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12)),
          ),
        ]),
      ],
    );
  }

  void _addCustomType() {
    final name = _newTypeNameCtrl.text.trim();
    if (name.isEmpty || _typePrices.containsKey(name)) return;
    setState(() {
      _typePrices[name] = TextEditingController();
      _typeOrder.add(name);
      _newTypeNameCtrl.clear();
    });
  }

  void _removeCustomType(String type) {
    setState(() {
      _typePrices.remove(type)?.dispose();
      _typeOrder.remove(type);
    });
  }

  void _editCustomTypeName(String oldName) {
    final ctrl = TextEditingController(text: oldName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Renommer le type'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              final newName = ctrl.text.trim();
              if (newName.isEmpty || newName == oldName) {
                Navigator.pop(ctx);
                return;
              }
              setState(() {
                final idx = _typeOrder.indexOf(oldName);
                if (idx != -1) _typeOrder[idx] = newName;
                final ctrl = _typePrices.remove(oldName)!;
                _typePrices[newName] = ctrl;
              });
              Navigator.pop(ctx);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignTypeSection() {
    final rangs = _places.map((p) => p.range).whereType<String>().toSet().toList()..sort();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Text('Affectation des types', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryDark)),
        const SizedBox(height: 4),
        Text('Sélectionnez les rangées ou places et assignez-leur un type.',
            style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        const SizedBox(height: 8),
        _buildRowSelector(rangs),
        const SizedBox(height: 4),
        InkWell(
          onTap: () => setState(() => _gridExpanded = !_gridExpanded),
          child: Row(children: [
            Icon(_gridExpanded ? Icons.expand_less : Icons.expand_more, size: 18),
            const SizedBox(width: 4),
            Text('Places individuelles', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.primaryColor)),
            const SizedBox(width: 8),
            Text('${_selectedPlaceIds.length} sélectionnée(s)', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
          ]),
        ),
        if (_gridExpanded) ...[
          const SizedBox(height: 4),
          _buildSeatGrid(),
        ],
        Row(children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _availableTypes.contains(_assignType) ? _assignType : null,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Type à assigner', border: OutlineInputBorder(), isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              ),
              items: [
                ..._availableTypes.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12)))),
                const DropdownMenuItem(value: '__new__', child: Text('+ Nouveau type...', style: TextStyle(fontSize: 12, color: AppTheme.primaryColor))),
              ],
              onChanged: (v) => setState(() => _assignType = v!),
            ),
          ),
          if (_assignType == '__new__') ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 90,
              child: TextField(
                controller: _newTypeNameCtrl,
                decoration: const InputDecoration(
                  hintText: 'Nom', border: OutlineInputBorder(), isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                ),
                style: const TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 70,
              child: TextField(
                controller: _newTypePriceCtrl,
                decoration: const InputDecoration(
                  hintText: 'Prix', border: OutlineInputBorder(), isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _selectedRows.isEmpty && _selectedPlaceIds.isEmpty ? null : _addPendingAssignment,
            icon: const Icon(Icons.check, size: 16),
            label: const Text('Affecter', style: TextStyle(fontSize: 11)),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12)),
          ),
        ]),
        Text('${_selectedRows.length} rangée(s) • ${_selectedPlaceIds.length} place(s) sélectionnée(s)',
            style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        if (_pendingRowAssignments.isNotEmpty || _pendingPlaceAssignments.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.pending, size: 14, color: AppTheme.primaryColor),
                  const SizedBox(width: 4),
                  Text('Assignations en attente (${_pendingRowAssignments.length + _pendingPlaceAssignments.length})',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() { _pendingRowAssignments.clear(); _pendingPlaceAssignments.clear(); }),
                    child: Text('Tout effacer', style: TextStyle(fontSize: 10, color: AppTheme.errorColor)),
                  ),
                ]),
                const SizedBox(height: 4),
                ..._pendingRowAssignments.entries.map((e) => Text('  Rangée ${e.key} → ${e.value}',
                    style: const TextStyle(fontSize: 10))),
                ..._pendingPlaceAssignments.entries.map((e) => Text('  Place ${e.key} → ${e.value}',
                    style: const TextStyle(fontSize: 10))),
              ],
            ),
          ),
        ],
      ],
    );
  }

  List<String> get _availableTypes {
    return _typeOrder.where((t) {
      final text = _typePrices[t]?.text.trim() ?? '';
      return text.isNotEmpty && double.tryParse(text) != null;
    }).toList();
  }

  Widget _buildRowSelector(List<String> rangs) {
    if (rangs.isEmpty) return const Text('Aucune rangée', style: TextStyle(color: AppTheme.textSecondary));
    return Wrap(
      spacing: 6, runSpacing: 4,
      children: rangs.map((rang) {
        final selected = _selectedRows.contains(rang);
        final assigned = _pendingRowAssignments.containsKey(rang);
        final assignedType = _pendingRowAssignments[rang];
        final count = _places.where((p) => p.range == rang).length;
        if (assigned) {
          return InputChip(
            label: Text('$rang ($count) → $assignedType',
                style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
            backgroundColor: AppTheme.surfaceColor,
            onDeleted: () => setState(() => _pendingRowAssignments.remove(rang)),
            deleteIcon: Icon(Icons.close, size: 14, color: AppTheme.textSecondary),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          );
        }
        return FilterChip(
          label: Text('$rang ($count)', style: TextStyle(fontSize: 11, color: selected ? Colors.white : null)),
          selected: selected,
          onSelected: (v) { setState(() { if (v) _selectedRows.add(rang); else _selectedRows.remove(rang); }); },
        );
      }).toList(),
    );
  }

  Widget _buildSeatGrid() {
    final rangs = _places.map((p) => p.range).whereType<String>().toSet().toList()..sort();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rangs.map((rang) {
        final rowPlaces = _places.where((p) => p.range == rang).toList()
          ..sort((a, b) => a.numeroPlace.compareTo(b.numeroPlace));
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Rangée $rang', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
            const SizedBox(height: 2),
            Wrap(spacing: 3, runSpacing: 3, children: rowPlaces.map((p) {
              final selected = _selectedPlaceIds.contains(p.numeroPlace);
              final assigned = _pendingPlaceAssignments.containsKey(p.numeroPlace);
              final color = AppConstants.placeTypeColors[_pendingPlaceAssignments[p.numeroPlace] ?? p.typePlace ?? 'Standard'] ?? AppTheme.textSecondary;
              return GestureDetector(
                onTap: () => setState(() {
                  if (selected) { _selectedPlaceIds.remove(p.numeroPlace); }
                  else { _selectedPlaceIds.add(p.numeroPlace); }
                }),
                child: Container(
                  width: 36, height: 28,
                  decoration: BoxDecoration(
                    color: selected ? AppTheme.primaryColor.withValues(alpha: 0.3) : color.withValues(alpha: assigned ? 0.3 : 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: selected ? AppTheme.primaryColor : color.withValues(alpha: assigned ? 0.7 : 0.3),
                      width: selected ? 2 : (assigned ? 1.5 : 0.5),
                    ),
                  ),
                  child: Center(child: Text(
                    p.numeroPlace.replaceAll(rang, ''),
                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: selected ? AppTheme.primaryColor : color),
                  )),
                ),
              );
            }).toList()),
          ]),
        );
      }).toList(),
    );
  }

  void _addPendingAssignment() {
    final isNew = _assignType == '__new__' && _newTypeNameCtrl.text.trim().isNotEmpty;
    final type = isNew ? _newTypeNameCtrl.text.trim() : _assignType;
    if (type == '__new__' || type.isEmpty) return;
    final newPriceText = isNew ? _newTypePriceCtrl.text.trim() : null;
    setState(() {
      for (final r in _selectedRows) _pendingRowAssignments[r] = type;
      for (final p in _selectedPlaceIds) _pendingPlaceAssignments[p] = type;
      _selectedRows.clear();
      _selectedPlaceIds.clear();
      _newTypeNameCtrl.clear();
      _newTypePriceCtrl.clear();
    });
    if (!_typePrices.containsKey(type)) {
      setState(() {
        final ctrl = TextEditingController(text: newPriceText ?? '');
        _typePrices[type] = ctrl;
        if (!_typeOrder.contains(type)) _typeOrder.add(type);
      });
    }
  }

  Widget _buildPricingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Text('Configuration des prix par type', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        const SizedBox(height: 4),
        Text('Définissez le prix pour chaque type de place. Vous pourrez affiner après la création dans la vue dédiée.',
            style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        const SizedBox(height: 12),
        _buildCreateTypePricingSection(),
        _buildAssignTypeSection(),
      ],
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: _isEditing ? DateTime(2020) : DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime() async {
    final initial = _selectedTime != null
        ? TimeOfDay(
            hour: int.tryParse(_selectedTime!.split(':')[0]) ?? 12,
            minute: int.tryParse(_selectedTime!.split(':')[1]) ?? 0,
          )
        : TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null) {
      setState(() => _selectedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00');
    }
  }

  Future<void> _pickImage() async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery, maxWidth: 1920, maxHeight: 1080);
    if (picked != null) {
      setState(() => _selectedImagePath = picked.path);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une date')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final orgCode = userCode ?? '';

      final event = Evenement(
        idEvenement: _isEditing ? widget.event!.idEvenement : null,
        titre: _titreCtrl.text,
        description: _descriptionCtrl.text.isEmpty ? null : _descriptionCtrl.text,
        dateEvenement: _selectedDate,
        heureEvenement: _selectedTime,
        statut: _selectedStatut,
        codeCategorie: _selectedCategorie,
        codeLieu: _selectedLieu,
        codeOrganisateur: orgCode,
      );

      if (_isEditing) {
        await _eventService.updateEvent(widget.event!.idEvenement!, event.toJson());
        if (_hasNewImage) {
          await _eventService.uploadImage(widget.event!.idEvenement!, File(_selectedImagePath!));
        }
        if (widget.event!.idEvenement != null) {
          try {
            for (final entry in _typePrices.entries) {
              final prixText = entry.value.text;
              final prix = prixText.isNotEmpty ? double.tryParse(prixText) : null;
              if (prix != null) {
                await _placeService.setTypePricing(widget.event!.idEvenement!, entry.key, prix);
              }
            }
            final rowGroups = <String, List<String>>{};
            for (final entry in _pendingRowAssignments.entries) {
              rowGroups.putIfAbsent(entry.value, () => []);
              rowGroups[entry.value]!.add(entry.key);
            }
            final placeGroups = <String, List<String>>{};
            for (final entry in _pendingPlaceAssignments.entries) {
              placeGroups.putIfAbsent(entry.value, () => []);
              placeGroups[entry.value]!.add(entry.key);
            }
            final allTypes = {...rowGroups.keys, ...placeGroups.keys};
            for (final type in allTypes) {
              await _placeService.assignTypes(widget.event!.idEvenement!, {
                'typePlace': type,
                'placeIds': placeGroups[type] ?? [],
                'rows': rowGroups[type] ?? [],
              });
            }
          } catch (_) {}
        }
      } else {
        final createdData = await _eventService.createEvent(event.toJson());
        final created = Evenement.fromJson(createdData);

        if (mounted && created.idEvenement != null) {
          try {
            for (final entry in _typePrices.entries) {
              final prixText = entry.value.text;
              final prix = prixText.isNotEmpty ? double.tryParse(prixText) : null;
              if (prix != null) {
                await _placeService.setTypePricing(created.idEvenement!, entry.key, prix);
              }
            }
            final rowGroups = <String, List<String>>{};
            for (final entry in _pendingRowAssignments.entries) {
              rowGroups.putIfAbsent(entry.value, () => []);
              rowGroups[entry.value]!.add(entry.key);
            }
            final placeGroups = <String, List<String>>{};
            for (final entry in _pendingPlaceAssignments.entries) {
              placeGroups.putIfAbsent(entry.value, () => []);
              placeGroups[entry.value]!.add(entry.key);
            }
            final allTypes = {...rowGroups.keys, ...placeGroups.keys};
            for (final type in allTypes) {
              await _placeService.assignTypes(created.idEvenement!, {
                'typePlace': type,
                'placeIds': placeGroups[type] ?? [],
                'rows': rowGroups[type] ?? [],
              });
            }
          } catch (_) {}
        }

        if (_hasNewImage && created.idEvenement != null) {
          try {
            await _eventService.uploadImage(created.idEvenement!, File(_selectedImagePath!));
          } catch (_) {}
        }

        if (!mounted) return;
        if (_selectedSalle != null && created.idEvenement != null) {
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (_) => PricingPage(eventId: created.idEvenement!),
          ));
          return;
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Événement modifié avec succès !' : 'Événement créé avec succès !'),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(apiErrorString(e)),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Modifier l\'événement' : 'Créer un événement')),
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
                      labelText: 'Titre de l\'événement',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Obligatoire' : null,
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
                  InkWell(
                    onTap: _pickImage,
                    child: Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.textSecondary.withValues(alpha: 0.3)),
                      ),
                      child: _hasNewImage
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(File(_selectedImagePath!), height: 160, width: double.infinity, fit: BoxFit.cover),
                            )
                          : (_isEditing && widget.event?.image != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: eventImageWidget(widget.event!.image, height: 160),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate, size: 48, color: AppTheme.textSecondary),
                                    const SizedBox(height: 8),
                                    Text('Ajouter une image', style: TextStyle(color: AppTheme.textSecondary)),
                                    Text('(optionnel)', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                  ],
                                )),
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
                            : 'Sélectionner une date',
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
                      child: Text(_selectedTime ?? 'Sélectionner l\'heure'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCategorie,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Catégorie',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    ),
                    items: _categories
                        .map((c) => DropdownMenuItem(
                              value: c.codeCategorie,
                              child: Text(c.nomCategorie, style: const TextStyle(fontSize: 13)),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCategorie = v),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedLieu,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Lieu',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    ),
                    items: _lieux
                        .map((l) => DropdownMenuItem(
                              value: l.code,
                              child: Text(l.nomLieu, style: const TextStyle(fontSize: 13)),
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
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Salle',
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
                                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                              )
                            : Column(children: [
                                const SizedBox(height: 8),
                                _buildPricingSection(),
                              ]),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedStatut,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Statut',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    ),
                    items: _statuts
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s, style: const TextStyle(fontSize: 13)),
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
                          : Text(_isEditing ? 'Modifier' : 'Créer l\'événement'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
