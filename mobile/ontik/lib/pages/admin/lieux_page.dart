import 'package:flutter/material.dart';
import '../../core/services/lieu_service.dart';
import '../../core/api/dio_config.dart';
import '../../core/api/endpoints.dart';
import '../../core/assets/app_colors.dart';
import '../../core/utils/error_helper.dart';
import '../../models/lieu_model.dart';

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
  String _filter = '';

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

  void _showAddDialog() {
    final codeCtrl = TextEditingController();
    final nomCtrl = TextEditingController();
    final adresseCtrl = TextEditingController();
    final villeCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollCtrl) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            controller: scrollCtrl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text('Ajouter un lieu',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(height: 24),
                const SizedBox(height: 8),
                TextField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Code lieu',
                    border: OutlineInputBorder(),
                    hintText: 'LIEU01',
                  ),
                  maxLength: 10,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nomCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 100,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: adresseCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Adresse',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 200,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: villeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Ville',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 100,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Annuler'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (codeCtrl.text.isEmpty || nomCtrl.text.isEmpty || villeCtrl.text.isEmpty) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(content: Text('Veuillez remplir tous les champs obligatoires')),
                            );
                            return;
                          }
                          try {
                            await _api.createLieu({
                              'code': codeCtrl.text,
                              'nomLieu': nomCtrl.text,
                              'adresse': adresseCtrl.text.isEmpty ? null : adresseCtrl.text,
                              'ville': villeCtrl.text,
                            });
                            if (ctx.mounted) Navigator.pop(ctx);
                            _loadData();
                          } catch (e) {
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(content: Text(apiErrorString(e)), backgroundColor: AppColors.error),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Ajouter'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(Lieu lieu) {
    final codeCtrl = TextEditingController(text: lieu.code);
    final nomCtrl = TextEditingController(text: lieu.nomLieu);
    final adresseCtrl = TextEditingController(text: lieu.adresse ?? '');
    final villeCtrl = TextEditingController(text: lieu.ville ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollCtrl) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            controller: scrollCtrl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text('Modifier le lieu',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(height: 24),
                const SizedBox(height: 8),
                TextField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Code lieu',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 10,
                  enabled: false,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nomCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 100,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: adresseCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Adresse',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 200,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: villeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Ville',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 100,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Annuler'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (nomCtrl.text.isEmpty || villeCtrl.text.isEmpty) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(content: Text('Veuillez remplir tous les champs obligatoires')),
                            );
                            return;
                          }
                          try {
                            // Utilisation directe de dio car updateLieu n'existe pas dans LieuService
                            await dio.put(
                              '${Endpoints.lieux}/${lieu.code}',
                              data: {
                                'nomLieu': nomCtrl.text,
                                'adresse': adresseCtrl.text.isEmpty ? null : adresseCtrl.text,
                                'ville': villeCtrl.text,
                              },
                            );
                            if (ctx.mounted) Navigator.pop(ctx);
                            _loadData();
                          } catch (e) {
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(content: Text(apiErrorString(e)), backgroundColor: AppColors.error),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Modifier'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(Lieu lieu) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le lieu'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${lieu.nomLieu}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _api.deleteLieu(lieu.code);
      _loadData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lieu supprimé')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(apiErrorString(e)), backgroundColor: AppColors.error),
      );
    }
  }

  void _showAddSalleDialog(Lieu lieu) {
    final nomCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.7,
        expand: false,
        builder: (ctx, scrollCtrl) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            controller: scrollCtrl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text('Ajouter une salle',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(height: 24),
                const SizedBox(height: 8),
                TextField(
                  controller: nomCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nom de la salle',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Annuler'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
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
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(content: Text(apiErrorString(e)), backgroundColor: AppColors.error),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Ajouter'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filter.isEmpty ? _lieux : _lieux.where((l) =>
    l.nomLieu.toLowerCase().contains(_filter.toLowerCase()) ||
        l.code.toLowerCase().contains(_filter.toLowerCase()) ||
        (l.ville?.toLowerCase().contains(_filter.toLowerCase()) ?? false)
    ).toList();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(children: [
              const Text('Lieux', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _filter = v),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text(_error!))
                : filtered.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_city, size: 48, color: AppColors.textSecondary.withValues(alpha: 0.4)),
                  const SizedBox(height: 12),
                  const Text('Aucun lieu trouvé', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final lieu = filtered[i];
                  final salles = _sallesForLieu(lieu.code);
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: Text(lieu.code.isNotEmpty ? lieu.code[0].toUpperCase() : '?',
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(lieu.nomLieu, style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (lieu.adresse != null && lieu.adresse!.isNotEmpty)
                            Text(lieu.adresse!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          Text('${lieu.ville ?? ''}  •  ${salles.length} salle(s)',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton.icon(
                            onPressed: () => _showSallesModal(lieu),
                            icon: const Icon(Icons.info_outline, size: 18),
                            label: const Text('Info', style: TextStyle(fontSize: 11)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () => _showEditDialog(lieu),
                            tooltip: 'Modifier',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20, color: AppColors.error),
                            onPressed: () => _showDeleteDialog(lieu),
                            tooltip: 'Supprimer',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}