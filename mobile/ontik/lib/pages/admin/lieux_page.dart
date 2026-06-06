import 'package:flutter/material.dart';
import '../../core/services/lieu_service.dart';
import '../../core/api/dio_config.dart';
import '../../core/api/endpoints.dart';
import '../../core/assets/app_colors.dart';
import '../../core/utils/error_helper.dart';
import '../../models/lieu_model.dart';
import '../../widgets/crud_list_view.dart';

class LieuxPage extends StatefulWidget {
  final void Function(String? salleFilter)? onGestionPlaces;
  const LieuxPage({super.key, this.onGestionPlaces});
  @override
  State<LieuxPage> createState() => _LieuxPageState();
}

class _LieuxPageState extends State<LieuxPage> {
  bool _loading = true;
  String? _error;
  List<Lieu> _lieux = [];
  List<Salle> _allSalles = [];
  List<Place> _allPlaces = [];
  final _api = LieuService();

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final lieuxData = await _api.getLieux();
      final sallesData = await _api.getSalles();
      final placesResp = await dio.get(Endpoints.places);
      final placesData = (placesResp.data['data'] as List?) ?? [];
      if (!mounted) return;
      setState(() {
        _lieux = lieuxData.map((e) => Lieu.fromJson(e as Map<String, dynamic>)).toList();
        _allSalles = sallesData.map((e) => Salle.fromJson(e as Map<String, dynamic>)).toList();
        _allPlaces = placesData.map((e) => Place.fromJson(e as Map<String, dynamic>)).toList();
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = apiErrorString(e); _loading = false; });
    }
  }

  List<Salle> _sallesForLieu(String codeLieu) {
    return _allSalles.where((s) => s.codeLieu == codeLieu).toList();
  }

  int _placeCountForSalle(String numeroSalle) {
    return _allPlaces.where((p) => p.numeroSalle == numeroSalle).length;
  }

  void _showSallesModal(Lieu lieu) {
    final salles = _sallesForLieu(lieu.code);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (ctx, scrollCtrl) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text('Salles — ${lieu.nomLieu}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                ],
              ),
              const Divider(),
              if (salles.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.meeting_room, size: 48, color: AppColors.textSecondary),
                        const SizedBox(height: 12),
                        const Text('Aucune salle pour ce lieu', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showAddSalleDialog(lieu),
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter une salle'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: scrollCtrl,
                          itemCount: salles.length,
                          itemBuilder: (ctx, i) {
                            final s = salles[i];
                            final nPlaces = _placeCountForSalle(s.numeroSalle);
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                  child: Text('$nPlaces', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                ),
                                title: Text('${s.nomSalle} — ${lieu.nomLieu}'),
                                subtitle: Text('$nPlaces place(s)'),
                                trailing: TextButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    widget.onGestionPlaces?.call(s.numeroSalle);
                                  },
                                  child: const Text('Gérer les places'),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _showAddSalleDialog(lieu),
                            icon: const Icon(Icons.add),
                            label: const Text('Ajouter une salle'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _add(Map<String, dynamic> data) async {
    await _api.createLieu(data);
    _loadData();
  }

  void _showAddSalleDialog(Lieu lieu) {
    final nomCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ajouter une salle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomCtrl,
              decoration: const InputDecoration(labelText: 'Nom de la salle', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              if (nomCtrl.text.trim().isEmpty) return;
              try {
                await _api.createSalle({
                  'nomSalle': nomCtrl.text.trim(),
                  'codeLieu': lieu.code,
                });
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                _loadData();
              } catch (e) {
                if (!ctx.mounted) return;
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(apiErrorString(e)), backgroundColor: AppColors.error));
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  Future<bool> _delete(String code) async {
    try {
      await _api.deleteLieu(code);
      _loadData();
      return true;
    } catch (_) { return false; }
  }

  @override
  Widget build(BuildContext context) {
    return CrudListView(
      title: 'Lieux',
      showAppBar: false,
      isLoading: _loading,
      error: _error,
      items: _lieux.map((l) => CrudItem(
        id: l.code,
        title: l.nomLieu,
        subtitle: '${l.ville ?? ''}  •  ${l.adresse ?? ''}',
        leading: const CircleAvatar(child: Icon(Icons.location_city)),
        data: {'code': l.code, 'nomLieu': l.nomLieu, 'adresse': l.adresse ?? '', 'ville': l.ville ?? ''},
      )).toList(),
      formFields: [
        CrudField(key: 'code', label: 'Code lieu', required: true),
        CrudField(key: 'nomLieu', label: 'Nom', required: true),
        CrudField(key: 'adresse', label: 'Adresse'),
        CrudField(key: 'ville', label: 'Ville', required: true),
      ],
      onAdd: _add,
      onDelete: _delete,
      onRefresh: _loadData,
      emptyMessage: 'Aucun lieu trouvé',
      itemBuilder: (item, onEdit, onDelete) {
        final lieu = _lieux.firstWhere((l) => l.code == item.id);
        final salles = _sallesForLieu(lieu.code);
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: ListTile(
            leading: item.leading,
            title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text('${item.subtitle ?? ''}  •  ${salles.length} salle(s)', style: const TextStyle(fontSize: 12)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton.icon(
                  onPressed: () => _showSallesModal(lieu),
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: const Text('Info', style: TextStyle(fontSize: 12)),
                ),
                IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: onEdit),
                IconButton(icon: const Icon(Icons.delete, size: 20, color: AppColors.error), onPressed: onDelete),
              ],
            ),
          ),
        );
      },
    );
  }
}
