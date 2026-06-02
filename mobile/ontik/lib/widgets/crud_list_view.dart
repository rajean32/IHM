import 'package:flutter/material.dart';
import '../core/assets/app_colors.dart';

class CrudItem {
  final String id;
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Map<String, dynamic> data;

  CrudItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.data = const {},
  });
}

class CrudField {
  final String key;
  final String label;
  final CrudFieldType type;
  final bool required;
  final String? hint;
  final List<String>? options;
  final dynamic initialValue;
  final String? Function(dynamic)? validator;
  final bool readOnly;

  CrudField({
    required this.key,
    required this.label,
    this.type = CrudFieldType.text,
    this.required = false,
    this.hint,
    this.options,
    this.initialValue,
    this.validator,
    this.readOnly = false,
  });
}

enum CrudFieldType { text, number, dropdown, date, email, phone, password, multiline, boolean }

class CrudListView extends StatefulWidget {
  final String title;
  final List<CrudItem> items;
  final List<CrudField> formFields;
  final bool isLoading;
  final String? error;
  final Future<void> Function()? onRefresh;
  final Future<void> Function(Map<String, dynamic> data)? onAdd;
  final Future<void> Function(String id, Map<String, dynamic> data)? onEdit;
  final Future<bool> Function(String id)? onDelete;
  final Future<void> Function(List<String> ids)? onBulkDelete;
  final Widget Function(CrudItem item, VoidCallback onEdit, VoidCallback onDelete)? itemBuilder;
  final List<String>? filterOptions;
  final String? filterLabel;
  final String? emptyMessage;
  final Widget Function()? emptyBuilder;

  const CrudListView({
    super.key,
    required this.title,
    required this.items,
    this.formFields = const [],
    this.isLoading = false,
    this.error,
    this.onRefresh,
    this.onAdd,
    this.onEdit,
    this.onDelete,
    this.onBulkDelete,
    this.itemBuilder,
    this.filterOptions,
    this.filterLabel,
    this.emptyMessage,
    this.emptyBuilder,
  });

  @override
  State<CrudListView> createState() => _CrudListViewState();
}

class _CrudListViewState extends State<CrudListView> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _activeFilter;
  bool _bulkMode = false;
  final Set<String> _selectedIds = {};
  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<CrudItem> get _filteredItems {
    var items = widget.items;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      items = items.where((i) =>
        i.title.toLowerCase().contains(q) ||
        (i.subtitle?.toLowerCase().contains(q) ?? false)
      ).toList();
    }
    if (_activeFilter != null && widget.filterOptions != null) {
      items = items.where((i) =>
        i.data.values.any((v) => v.toString() == _activeFilter)
      ).toList();
    }
    return items;
  }

  void _toggleBulk(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedIds.length == _filteredItems.length) {
        _selectedIds.clear();
      } else {
        _selectedIds.addAll(_filteredItems.map((e) => e.id));
      }
    });
  }

  Future<void> _handleDelete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer'),
        content: const Text('Supprimer cet élément ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer', style: TextStyle(color: AppTheme.errorColor))),
        ],
      ),
    );
    if (confirm == true && widget.onDelete != null) {
      await widget.onDelete!(id);
    }
  }

  Future<void> _handleBulkDelete() async {
    if (_selectedIds.isEmpty) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Suppression groupée'),
        content: Text('Supprimer ${_selectedIds.length} élément(s) ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer tout', style: TextStyle(color: AppTheme.errorColor))),
        ],
      ),
    );
    if (confirm == true && widget.onBulkDelete != null) {
      await widget.onBulkDelete!(_selectedIds.toList());
      setState(() { _selectedIds.clear(); _bulkMode = false; });
    }
  }

  void _showForm({CrudItem? item}) {
    final ctrls = <String, TextEditingController>{};
    final dropdownValues = <String, String>{};
    DateTime? dateValue;
    final editItem = item;

    for (final field in widget.formFields) {
      final initial = editItem != null ? editItem.data[field.key] ?? field.initialValue : field.initialValue;
      if (field.type == CrudFieldType.dropdown) {
        dropdownValues[field.key] = initial?.toString() ?? (field.options?.first ?? '');
        ctrls[field.key] = TextEditingController();
      } else if (field.type == CrudFieldType.date) {
        dateValue = initial is DateTime ? initial : null;
        ctrls[field.key] = TextEditingController(
          text: initial?.toString() ?? '',
        );
      } else {
        ctrls[field.key] = TextEditingController(text: initial?.toString() ?? '');
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final formKey = GlobalKey<FormState>();

        return StatefulBuilder(
          builder: (ctx, setSheetState) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 16, right: 16, top: 16,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(editItem != null ? 'Modifier' : 'Ajouter', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                        IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                      ],
                    ),
                    const Divider(),
                    ...widget.formFields.map((field) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildFormField(field, ctrls[field.key]!, dropdownValues, dateValue, setSheetState),
                    )),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        final data = <String, dynamic>{};
                        for (final field in widget.formFields) {
                          if (field.type == CrudFieldType.dropdown) {
                            data[field.key] = dropdownValues[field.key];
                          } else if (field.type == CrudFieldType.date) {
                            data[field.key] = dateValue?.toIso8601String().split('T').first;
                          } else if (field.type == CrudFieldType.number) {
                            data[field.key] = double.tryParse(ctrls[field.key]!.text) ?? 0;
                          } else {
                            data[field.key] = ctrls[field.key]!.text;
                          }
                        }
                        if (editItem != null) {
                          await widget.onEdit?.call(editItem.id, data);
                        } else {
                          await widget.onAdd?.call(data);
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(editItem != null ? 'Enregistrer' : 'Ajouter'),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormField(CrudField field, TextEditingController ctrl, Map<String, String> dropdownValues, DateTime? dateValue, void Function(void Function()) setSheetState) {
    switch (field.type) {
      case CrudFieldType.dropdown:
        return DropdownButtonFormField<String>(
          value: dropdownValues[field.key],
          decoration: InputDecoration(labelText: field.label, border: const OutlineInputBorder()),
          items: (field.options ?? []).map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
          onChanged: (v) => setSheetState(() => dropdownValues[field.key] = v ?? field.options!.first),
          validator: field.required ? (v) => v == null ? 'Requis' : null : null,
        );
      case CrudFieldType.date:
        return InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: dateValue ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setSheetState(() {
                ctrl.text = picked.toIso8601String().split('T').first;
              });
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(labelText: field.label, border: const OutlineInputBorder()),
            child: Text(ctrl.text.isEmpty ? 'Sélectionner une date' : ctrl.text),
          ),
        );
      case CrudFieldType.number:
        return TextFormField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: field.label, hintText: field.hint, border: const OutlineInputBorder()),
          validator: field.required ? (v) => v == null || v.isEmpty ? 'Requis' : null : null,
        );
      case CrudFieldType.email:
        return TextFormField(
          controller: ctrl,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(labelText: field.label, hintText: field.hint, border: const OutlineInputBorder()),
          validator: field.required ? (v) => v == null || v.isEmpty ? 'Requis' : null : null,
        );
      case CrudFieldType.phone:
        return TextFormField(
          controller: ctrl,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(labelText: field.label, hintText: field.hint, border: const OutlineInputBorder()),
          validator: field.required ? (v) => v == null || v.isEmpty ? 'Requis' : null : null,
        );
      case CrudFieldType.password:
        return TextFormField(
          controller: ctrl,
          obscureText: true,
          decoration: InputDecoration(labelText: field.label, border: const OutlineInputBorder()),
          validator: field.required ? (v) => v == null || v.isEmpty ? 'Requis' : null : null,
        );
      case CrudFieldType.multiline:
        return TextFormField(
          controller: ctrl,
          maxLines: 3,
          decoration: InputDecoration(labelText: field.label, border: const OutlineInputBorder()),
          validator: field.required ? (v) => v == null || v.isEmpty ? 'Requis' : null : null,
        );
      case CrudFieldType.boolean:
        return SwitchListTile(
          title: Text(field.label),
          value: ctrl.text == 'true',
          onChanged: (v) => ctrl.text = v.toString(),
        );
      case CrudFieldType.text:
        return TextFormField(
          controller: ctrl,
          readOnly: field.readOnly,
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.hint,
            border: const OutlineInputBorder(),
            filled: field.readOnly,
            fillColor: field.readOnly ? const Color(0xFFF5F5F5) : null,
          ),
          validator: field.required ? (v) => v == null || v.isEmpty ? 'Requis' : null : null,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;
    final showFab = widget.onAdd != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (_bulkMode)
            IconButton(
              icon: const Icon(Icons.select_all),
              tooltip: 'Tout sélectionner',
              onPressed: _toggleSelectAll,
            ),
          if (_bulkMode && _selectedIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: AppTheme.errorColor),
              tooltip: 'Supprimer sélection',
              onPressed: _handleBulkDelete,
            ),
          IconButton(
            icon: Icon(_bulkMode ? Icons.close : Icons.checklist),
            tooltip: _bulkMode ? 'Quitter le mode sélection' : 'Mode sélection',
            onPressed: () => setState(() { _bulkMode = !_bulkMode; _selectedIds.clear(); }),
          ),
          if (widget.onRefresh != null)
            IconButton(icon: const Icon(Icons.refresh), onPressed: widget.onRefresh),
        ],
      ),
      body: Column(children: [
        if (widget.filterOptions != null || widget.formFields.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Column(children: [
              TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(
                  hintText: 'Rechercher...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
              if (widget.filterOptions != null) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      FilterChip(
                        label: const Text('Tout'),
                        selected: _activeFilter == null,
                        onSelected: (_) => setState(() => _activeFilter = null),
                      ),
                      const SizedBox(width: 6),
                      ...widget.filterOptions!.map((opt) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: FilterChip(
                          label: Text(opt),
                          selected: _activeFilter == opt,
                          onSelected: (_) => setState(() => _activeFilter = _activeFilter == opt ? null : opt),
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ]),
          ),
        const SizedBox(height: 4),
        Expanded(
          child: widget.isLoading
              ? const Center(child: CircularProgressIndicator())
              : widget.error != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(widget.error!, style: const TextStyle(color: AppTheme.errorColor), textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          ElevatedButton(onPressed: widget.onRefresh, child: const Text('Réessayer')),
                        ],
                      ),
                    )
                  : filtered.isEmpty
                      ? Center(
                          child: widget.emptyBuilder != null
                              ? widget.emptyBuilder!()
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.inbox, size: 48, color: AppTheme.textSecondary.withValues(alpha: 0.4)),
                                    const SizedBox(height: 12),
                                    Text(
                                      widget.emptyMessage ?? 'Aucun élément',
                                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                                    ),
                                    if (widget.onAdd != null) ...[
                                      const SizedBox(height: 16),
                                      ElevatedButton.icon(
                                        onPressed: () => _showForm(),
                                        icon: const Icon(Icons.add, size: 18),
                                        label: Text('Ajouter ${widget.title}'),
                                      ),
                                    ],
                                  ],
                                ),
                        )
                      : RefreshIndicator(
                          onRefresh: widget.onRefresh ?? () async {},
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: filtered.length,
                            itemBuilder: (ctx, i) {
                              final item = filtered[i];
                              final isSelected = _selectedIds.contains(item.id);

                              if (_bulkMode) {
                                return CheckboxListTile(
                                  value: isSelected,
                                  onChanged: (_) => _toggleBulk(item.id),
                                  title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w500)),
                                  subtitle: item.subtitle != null ? Text(item.subtitle!, style: const TextStyle(fontSize: 12)) : null,
                                  secondary: item.leading,
                                );
                              }

                              if (widget.itemBuilder != null) {
                                return widget.itemBuilder!(item, () => _showForm(item: item), () => _handleDelete(item.id));
                              }

                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                child: ListTile(
                                  leading: item.leading,
                                  title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w500)),
                                  subtitle: item.subtitle != null ? Text(item.subtitle!, style: const TextStyle(fontSize: 12)) : null,
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (widget.onEdit != null)
                                        IconButton(
                                          icon: const Icon(Icons.edit, size: 20),
                                          onPressed: () => _showForm(item: item),
                                        ),
                                      if (widget.onDelete != null)
                                        IconButton(
                                          icon: const Icon(Icons.delete, size: 20, color: AppTheme.errorColor),
                                          onPressed: () => _handleDelete(item.id),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
        ),
      ]),
      floatingActionButton: showFab && !_bulkMode
          ? FloatingActionButton(
              onPressed: () => _showForm(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
