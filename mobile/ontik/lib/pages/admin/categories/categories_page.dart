import 'package:flutter/material.dart';
import 'package:ontik/core/services/categorie_service.dart';
import 'package:ontik/models/categorie_model.dart';
import 'package:ontik/core/assets/app_colors.dart';
import 'package:ontik/core/utils/error_helper.dart';
import 'package:ontik/widgets/admin/admin_search_field.dart';
import 'package:ontik/widgets/admin/admin_empty_state.dart';
import 'package:ontik/widgets/admin/admin_error_state.dart';
import 'package:ontik/widgets/admin/admin_toast.dart';
import 'package:ontik/widgets/admin/admin_confirmation_dialog.dart';
import 'category_form_sheet.dart';
import 'caracteristiques_page.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final _service = CategorieService();
  final _searchCtrl = TextEditingController();
  bool _loading = true;
  String? _error;
  List<Categorie> _categories = [];
  List<Categorie> _filteredCategories = [];
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
      final data = await _service.getCategories();
      if (!mounted) return;
      final cats = data.map((e) => Categorie.fromJson(e as Map<String, dynamic>)).toList();
      setState(() { _categories = cats; _filteredCategories = cats; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = apiErrorString(e); _loading = false; });
    }
  }

  void _filter(String query) {
    _searchQuery = query.toLowerCase();
    setState(() {
      _filteredCategories = _categories.where((c) =>
        c.nomCategorie.toLowerCase().contains(_searchQuery) ||
        c.codeCategorie.toLowerCase().contains(_searchQuery)
      ).toList();
    });
  }

  Future<void> _addCategory() async {
    final result = await CategoryFormSheet.show(context);
    if (result == null) return;
    try {
      await _service.createCategory(result);
      if (!mounted) return;
      AdminToast.show(context, message: 'Catégorie créée', isSuccess: true);
      _load();
    } catch (e) {
      if (!mounted) return;
      AdminToast.show(context, message: apiErrorString(e), isSuccess: false);
    }
  }

  Future<void> _editCategory(Categorie cat) async {
    final result = await CategoryFormSheet.show(context, category: cat);
    if (result == null) return;
    try {
      await _service.updateCategory(cat.codeCategorie, result);
      if (!mounted) return;
      AdminToast.show(context, message: 'Catégorie modifiée', isSuccess: true);
      _load();
    } catch (e) {
      if (!mounted) return;
      AdminToast.show(context, message: apiErrorString(e), isSuccess: false);
    }
  }

  Future<void> _deleteCategory(Categorie cat) async {
    final confirm = await AdminConfirmationDialog.show(
      context,
      title: 'Supprimer la catégorie',
      message: 'Voulez-vous vraiment supprimer "${cat.nomCategorie}" ?',
    );
    if (confirm != true) return;
    try {
      await _service.deleteCategory(cat.codeCategorie);
      if (!mounted) return;
      AdminToast.show(context, message: 'Catégorie supprimée', isSuccess: true);
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
                const Text('Catégories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.refresh, size: 20), onPressed: _load),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: AdminSearchField(
              hintText: 'Rechercher par nom ou code...',
              controller: _searchCtrl,
              onChanged: _filter,
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return AdminErrorState(message: _error!, onRetry: _load);
    if (_filteredCategories.isEmpty) {
      return AdminEmptyState(
        icon: Icons.category,
        message: _searchQuery.isNotEmpty ? 'Aucune catégorie trouvée' : 'Aucune catégorie',
        actionLabel: 'Ajouter',
        onAction: _addCategory,
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredCategories.length,
        itemBuilder: (ctx, i) => _buildCategoryCard(_filteredCategories[i]),
      ),
    );
  }

  Widget _buildCategoryCard(Categorie cat) {
    final firstLetter = cat.codeCategorie.isNotEmpty ? cat.codeCategorie[0].toUpperCase() : '?';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(firstLetter, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ),
        title: Text(cat.nomCategorie, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Code: ${cat.codeCategorie}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            if (cat.description != null && cat.description!.isNotEmpty)
              Text(cat.description!, style: const TextStyle(fontSize: 11, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton.icon(
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => CaracteristiquesPage(categorie: cat)));
                _load();
              },
              icon: const Icon(Icons.list_alt, size: 16),
              label: const Text('Caract.', style: TextStyle(fontSize: 11)),
            ),
            IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _editCategory(cat)),
            IconButton(icon: const Icon(Icons.delete, size: 20, color: AppColors.error), onPressed: () => _deleteCategory(cat)),
          ],
        ),
      ),
    );
  }
}
