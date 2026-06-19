import 'package:flutter/material.dart';
import 'package:ontik/core/services/lieu_service.dart';
import 'package:ontik/models/lieu_model.dart';
import 'package:ontik/core/assets/app_colors.dart';
import 'package:ontik/core/utils/error_helper.dart';
import 'package:ontik/core/api/dio_config.dart';
import 'package:ontik/core/api/endpoints.dart';
import 'package:ontik/widgets/admin/admin_search_field.dart';
import 'package:ontik/widgets/admin/admin_empty_state.dart';
import 'package:ontik/widgets/admin/admin_error_state.dart';
import 'package:ontik/widgets/admin/admin_toast.dart';
import 'package:ontik/widgets/admin/admin_confirmation_dialog.dart';
import 'lieu_form_sheet.dart';
import 'salles_sheet.dart';

class LieuxPage extends StatefulWidget {
  final ValueChanged<String?>? onGestionPlaces;
  const LieuxPage({super.key, this.onGestionPlaces});

  @override
  State<LieuxPage> createState() => _LieuxPageState();
}

class _LieuxPageState extends State<LieuxPage> {
  final _service = LieuService();
  final _searchCtrl = TextEditingController();
  bool _loading = true;
  String? _error;
  List<Lieu> _lieux = [];
  List<dynamic> _allSalles = [];
  List<Lieu> _filteredLieux = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final lieuxData = await _service.getLieux();
      final sallesData = await _service.getSalles();
      if (!mounted) return;
      final lieux = lieuxData.map((e) => Lieu.fromJson(e as Map<String, dynamic>)).toList();
      setState(() { _lieux = lieux; _allSalles = sallesData; _filteredLieux = lieux; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = apiErrorString(e); _loading = false; });
    }
  }

  void _filter(String query) {
    _searchQuery = query.toLowerCase();
    setState(() {
      _filteredLieux = _lieux.where((l) =>
        l.nomLieu.toLowerCase().contains(_searchQuery) ||
        l.code.toLowerCase().contains(_searchQuery) ||
        (l.ville?.toLowerCase().contains(_searchQuery) ?? false)
      ).toList();
    });
  }

  List<Salle> _sallesForLieu(String codeLieu) {
    return _allSalles.where((s) => (s as Map<String, dynamic>)['codeLieu'] == codeLieu)
        .map((e) => Salle.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> _showAddDialog() async {
    final result = await LieuFormSheet.show(context);
    if (result == null) return;
    try {
      await _service.createLieu(result);
      if (!mounted) return;
      AdminToast.show(context, message: 'Lieu créé', isSuccess: true);
      _load();
    } catch (e) {
      if (!mounted) return;
      AdminToast.show(context, message: apiErrorString(e), isSuccess: false);
    }
  }

  Future<void> _showEditDialog(Lieu lieu) async {
    final result = await LieuFormSheet.show(context, lieu: lieu);
    if (result == null) return;
    try {
      await dio.put('${Endpoints.lieux}/${lieu.code}', data: result);
      if (!mounted) return;
      AdminToast.show(context, message: 'Lieu modifié', isSuccess: true);
      _load();
    } catch (e) {
      if (!mounted) return;
      AdminToast.show(context, message: apiErrorString(e), isSuccess: false);
    }
  }

  Future<void> _deleteLieu(Lieu lieu) async {
    final confirm = await AdminConfirmationDialog.show(context, title: 'Supprimer le lieu', message: 'Voulez-vous vraiment supprimer "${lieu.nomLieu}" ?');
    if (confirm != true) return;
    try {
      await _service.deleteLieu(lieu.code);
      if (!mounted) return;
      AdminToast.show(context, message: 'Lieu supprimé', isSuccess: true);
      _load();
    } catch (e) {
      if (!mounted) return;
      AdminToast.show(context, message: apiErrorString(e), isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                const Text('Lieux', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.refresh, size: 20), onPressed: _load),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: AdminSearchField(
              hintText: 'Rechercher par nom, code ou ville...',
              controller: _searchCtrl,
              onChanged: _filter,
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return AdminErrorState(message: _error!, onRetry: _load);
    if (_filteredLieux.isEmpty) {
      return AdminEmptyState(icon: Icons.location_city, message: 'Aucun lieu trouvé', actionLabel: 'Ajouter', onAction: _showAddDialog);
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredLieux.length,
        itemBuilder: (ctx, i) => _buildCard(_filteredLieux[i]),
      ),
    );
  }

  Widget _buildCard(Lieu lieu) {
    final salles = _sallesForLieu(lieu.code);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          child: Text(lieu.code.isNotEmpty ? lieu.code[0].toUpperCase() : '?', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
        ),
        title: Text(lieu.nomLieu, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        subtitle: Text('${lieu.adresse ?? ""}${lieu.ville != null ? "  •  ${lieu.ville}" : ""}  •  ${salles.length} salle(s)', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton.icon(
              onPressed: () => SallesSheet.show(context, lieu: lieu, salles: salles, onGestionPlaces: widget.onGestionPlaces, onRefresh: _load),
              icon: const Icon(Icons.info_outline, size: 16),
              label: const Text('Info', style: TextStyle(fontSize: 11)),
            ),
            IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _showEditDialog(lieu)),
            IconButton(icon: const Icon(Icons.delete, size: 20, color: AppColors.error), onPressed: () => _deleteLieu(lieu)),
          ],
        ),
      ),
    );
  }
}
