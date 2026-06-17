import 'package:flutter/material.dart';
import 'package:ontik/models/lieu_model.dart';
import 'package:ontik/core/assets/app_colors.dart';
import 'package:ontik/core/api/endpoints.dart';
import 'package:ontik/core/api/dio_config.dart';
import 'package:ontik/core/utils/error_helper.dart';
import 'package:ontik/widgets/admin/admin_empty_state.dart';
import 'package:ontik/widgets/admin/admin_toast.dart';
import 'package:ontik/widgets/admin/admin_confirmation_dialog.dart';
import 'salle_form_sheet.dart';

class SallesSheet extends StatelessWidget {
  final Lieu lieu;
  final List<Salle> salles;
  final ValueChanged<String?>? onGestionPlaces;
  final VoidCallback? onRefresh;

  const SallesSheet({
    super.key,
    required this.lieu,
    required this.salles,
    this.onGestionPlaces,
    this.onRefresh,
  });

  static void show(BuildContext context, {required Lieu lieu, required List<Salle> salles, ValueChanged<String?>? onGestionPlaces, VoidCallback? onRefresh}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollCtrl) => _SallesSheetContent(
          lieu: lieu,
          salles: salles,
          onGestionPlaces: onGestionPlaces,
          onRefresh: onRefresh,
          scrollCtrl: scrollCtrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}

class _SallesSheetContent extends StatefulWidget {
  final Lieu lieu;
  final List<Salle> salles;
  final ValueChanged<String?>? onGestionPlaces;
  final VoidCallback? onRefresh;
  final ScrollController scrollCtrl;

  const _SallesSheetContent({required this.lieu, required this.salles, this.onGestionPlaces, this.onRefresh, required this.scrollCtrl});

  @override
  State<_SallesSheetContent> createState() => _SallesSheetContentState();
}

class _SallesSheetContentState extends State<_SallesSheetContent> {
  late List<Salle> _salles;

  @override
  void initState() {
    super.initState();
    _salles = List.from(widget.salles);
  }

  Future<void> _addSalle() async {
    final result = await SalleFormSheet.show(context, codeLieu: widget.lieu.code);
    if (result == null) return;
    try {
      await dio.post(Endpoints.salles, data: result);
      if (!mounted) return;
      AdminToast.show(context, message: 'Salle ajoutée', isSuccess: true);
      widget.onRefresh?.call();
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AdminToast.show(context, message: apiErrorString(e), isSuccess: false);
    }
  }

  Future<void> _editSalle(Salle salle) async {
    final result = await SalleFormSheet.show(context, salle: salle, codeLieu: widget.lieu.code);
    if (result == null) return;
    try {
      await dio.put('${Endpoints.salles}/${salle.numeroSalle}', data: result);
      if (!mounted) return;
      AdminToast.show(context, message: 'Salle modifiée', isSuccess: true);
      widget.onRefresh?.call();
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AdminToast.show(context, message: apiErrorString(e), isSuccess: false);
    }
  }

  Future<void> _deleteSalle(Salle salle) async {
    final confirm = await AdminConfirmationDialog.show(context, title: 'Supprimer la salle', message: 'Supprimer "${salle.nomSalle}" ?');
    if (confirm != true) return;
    try {
      await dio.delete('${Endpoints.salles}/${salle.numeroSalle}');
      if (!mounted) return;
      AdminToast.show(context, message: 'Salle supprimée', isSuccess: true);
      widget.onRefresh?.call();
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AdminToast.show(context, message: apiErrorString(e), isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.scrollCtrl,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 32, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Salles — ${widget.lieu.nomLieu}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 12),
            if (_salles.isEmpty)
              AdminEmptyState(icon: Icons.meeting_room, message: 'Aucune salle pour ce lieu', actionLabel: 'Ajouter une salle', onAction: _addSalle)
            else
              ..._salles.map((s) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(child: Text('${_salles.indexOf(s) + 1}', style: const TextStyle(fontSize: 12))),
                  title: Text('${s.nomSalle} — ${widget.lieu.nomLieu}', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                  subtitle: Text('${_placeCount(s.numeroSalle)} place(s)', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () { Navigator.pop(context); widget.onGestionPlaces?.call(s.numeroSalle); },
                        child: const Text('Gérer les places', style: TextStyle(fontSize: 11)),
                      ),
                      IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _editSalle(s)),
                      IconButton(icon: const Icon(Icons.delete, size: 18, color: AppColors.error), onPressed: () => _deleteSalle(s)),
                    ],
                  ),
                ),
              )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _addSalle,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter une salle'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  int _placeCount(String numeroSalle) => 0;
}
