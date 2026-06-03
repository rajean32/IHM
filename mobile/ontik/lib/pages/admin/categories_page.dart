import 'package:flutter/material.dart';
import '../../core/services/categorie_service.dart';
import '../../models/categorie_model.dart';
import '../../widgets/crud_list_view.dart';
import '../../core/utils/error_helper.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});
  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  bool _loading = true;
  String? _error;
  List<Categorie> _categories = [];
  final _api = CategorieService();

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final cats = await _api.getCategories();
      if (!mounted) return;
      setState(() {
        _categories = cats.map((e) => Categorie.fromJson(e as Map<String, dynamic>)).toList();
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = apiErrorString(e); _loading = false; });
    }
  }

  Future<void> _add(Map<String, dynamic> data) async {
    await _api.createCategory(data);
    _loadData();
  }

  Future<bool> _delete(String id) async {
    try {
      await _api.deleteCategory(id);
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
