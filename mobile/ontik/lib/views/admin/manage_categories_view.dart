import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/providers.dart';
import '../../models/categorie.dart';
import '../../widgets/crud_list_view.dart';

class ManageCategoriesView extends ConsumerStatefulWidget {
  const ManageCategoriesView({super.key});
  @override
  ConsumerState<ManageCategoriesView> createState() => _ManageCategoriesViewState();
}

class _ManageCategoriesViewState extends ConsumerState<ManageCategoriesView> {
  bool _loading = true;
  String? _error;
  List<Categorie> _categories = [];

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final cats = await ref.read(categorieRepositoryProvider).getAll();
      if (!mounted) return;
      setState(() { _categories = cats; _loading = false; _error = null; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _add(Map<String, dynamic> data) async {
    await ref.read(categorieRepositoryProvider).create(Categorie(
      codeCategorie: data['code'].toString().trim(),
      nomCategorie: data['nom'].toString().trim(),
    ));
    _loadData();
  }

  Future<bool> _delete(String id) async {
    try {
      await ref.read(categorieRepositoryProvider).delete(id);
      _loadData();
      return true;
    } catch (_) { return false; }
  }

  @override
  Widget build(BuildContext context) {
    return CrudListView(
      title: 'Catégories',
      isLoading: _loading,
      error: _error,
      items: _categories.map((c) => CrudItem(
        id: c.codeCategorie,
        title: c.nomCategorie,
        subtitle: 'Code: ${c.codeCategorie}',
        leading: CircleAvatar(child: Text(c.codeCategorie.isNotEmpty ? c.codeCategorie[0].toUpperCase() : '?')),
        data: {'code': c.codeCategorie, 'nom': c.nomCategorie},
      )).toList(),
      formFields: [
        CrudField(key: 'code', label: 'Code', hint: 'CAT01', required: true),
        CrudField(key: 'nom', label: 'Nom', required: true),
      ],
      onAdd: _add,
      onDelete: _delete,
      onRefresh: _loadData,
      emptyMessage: 'Aucune catégorie trouvée',
    );
  }
}
