import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/providers.dart';
import '../../models/venue.dart';
import '../../widgets/crud_list_view.dart';

class ManageLieuxView extends ConsumerStatefulWidget {
  const ManageLieuxView({super.key});
  @override
  ConsumerState<ManageLieuxView> createState() => _ManageLieuxViewState();
}

class _ManageLieuxViewState extends ConsumerState<ManageLieuxView> {
  bool _loading = true;
  String? _error;
  List<Lieu> _lieux = [];
  List<Salle> _allSalles = [];
  List<Place> _allPlaces = [];

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final lieux = await ref.read(lieuRepositoryProvider).getAll();
      final salles = await ref.read(salleRepositoryProvider).getAll();
      final places = await ref.read(placeRepositoryProvider).getAll();
      if (!mounted) return;
      setState(() { _lieux = lieux; _allSalles = salles; _allPlaces = places; _loading = false; _error = null; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<Salle> _sallesForLieu(int? idLieu) {
    return _allSalles.where((s) => s.idLieu == idLieu).toList();
  }

  int _placeCountForSalle(String numeroSalle) {
    return _allPlaces.where((p) => p.numeroSalle == numeroSalle).length;
  }

  void _showSallesModal(Lieu lieu) {
    final salles = _sallesForLieu(lieu.idLieu);
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
                const Expanded(child: Center(child: Text('Aucune salle pour ce lieu')))
              else
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
                            backgroundColor: Colors.indigo.withValues(alpha: 0.1),
                            child: Text('$nPlaces', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.indigo)),
                          ),
                          title: Text(s.nomSalle),
                          subtitle: Text('N° ${s.numeroSalle}  •  $nPlaces place(s)'),
                          trailing: TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              context.push('/admin/salle-places', extra: s.numeroSalle);
                            },
                            child: const Text('Gérer les places'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _add(Map<String, dynamic> data) async {
    await ref.read(lieuRepositoryProvider).create(Lieu(
      nomLieu: data['nom'].toString().trim(),
      adresse: data['adresse']?.toString().trim(),
      ville: data['ville']?.toString().trim(),
    ));
    _loadData();
  }

  Future<bool> _delete(String id) async {
    try {
      await ref.read(lieuRepositoryProvider).delete(int.parse(id));
      _loadData();
      return true;
    } catch (_) { return false; }
  }

  @override
  Widget build(BuildContext context) {
    return CrudListView(
      title: 'Lieux',
      isLoading: _loading,
      error: _error,
      items: _lieux.map((l) => CrudItem(
        id: l.idLieu.toString(),
        title: l.nomLieu,
        subtitle: '${l.ville ?? ''}  •  ${l.adresse ?? ''}',
        leading: const CircleAvatar(child: Icon(Icons.location_city)),
        data: {'nom': l.nomLieu, 'adresse': l.adresse ?? '', 'ville': l.ville ?? ''},
      )).toList(),
      formFields: [
        CrudField(key: 'nom', label: 'Nom', required: true),
        CrudField(key: 'adresse', label: 'Adresse'),
        CrudField(key: 'ville', label: 'Ville', required: true),
      ],
      onAdd: _add,
      onDelete: _delete,
      onRefresh: _loadData,
      emptyMessage: 'Aucun lieu trouvé',
      itemBuilder: (item, onEdit, onDelete) {
        final lieu = _lieux.firstWhere((l) => l.idLieu.toString() == item.id);
        final salles = _sallesForLieu(lieu.idLieu);
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
                IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: onDelete),
              ],
            ),
          ),
        );
      },
    );
  }
}
