import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_client.dart';
import '../../theme/app_theme.dart';

class AdminCategoriesPage extends StatefulWidget {
  const AdminCategoriesPage({super.key});

  @override
  State<AdminCategoriesPage> createState() => _AdminCategoriesPageState();
}

class _AdminCategoriesPageState extends State<AdminCategoriesPage> {
  final _api = ApiClient();
  List<Map<String, dynamic>> _categories = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final categories = await _api.getCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _deleteCategory(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context).confirmDelete),
        content: Text(S.of(context).confirmDeleteCategory(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(S.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(S.of(context).delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _api.deleteCategory(id);
        _load();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).errorMessage(e.toString()))),
        );
      }
    }
  }

  void _openForm([Map<String, dynamic>? category]) {
    final isEditing = category != null;
    final nameCtrl = TextEditingController(text: category?['name'] as String? ?? '');
    final descCtrl = TextEditingController(text: category?['description'] as String? ?? '');
    final sortCtrl = TextEditingController(
      text: (category?['sortOrder'] as int? ?? 0).toString(),
    );
    var isActive = category?['isActive'] as bool? ?? true;
    final s = S.of(context);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEditing ? s.editCategory : s.newCategory),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: s.formName,
                    border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: s.formDescription,
                    border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: sortCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: s.formSortOrder,
                    border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: Text(s.formActive),
                  value: isActive,
                  activeThumbColor: AppTheme.nero,
                  onChanged: (v) => setDialogState(() => isActive = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(s.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                final data = {
                  'name': nameCtrl.text.trim(),
                  'description': descCtrl.text.trim(),
                  'sortOrder': int.tryParse(sortCtrl.text.trim()) ?? 0,
                  'isActive': isActive,
                };
                try {
                  if (isEditing) {
                    await _api.updateCategory(
                      category['id'] as String,
                      data,
                    );
                  } else {
                    await _api.createCategory(data);
                  }
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                  _load();
                } catch (e) {
                  if (!ctx.mounted) return;
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text(S.of(context).errorMessage(e.toString()))),
                  );
                }
              },
              child: Text(isEditing ? s.save : s.create),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.adminCategoriesTitle, style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: 4),
                    Text(
                      s.adminCategoriesCount(_categories.length),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _openForm(),
                icon: const Icon(Icons.add, size: 18),
                label: Text(s.adminNewCategory),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (_loading)
            const Expanded(
              child: Center(child: CircularProgressIndicator(color: AppTheme.nero)),
            )
          else if (_error != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _load, child: Text(s.adminRetry)),
                  ],
                ),
              ),
            )
          else
            Expanded(child: _buildTable()),
        ],
      ),
    );
  }

  Widget _buildTable() {
    final s = S.of(context);
    return SingleChildScrollView(
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppTheme.nero.withValues(alpha: 0.05)),
          columns: [
            DataColumn(label: Text(s.tableHeaderName, style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1))),
            DataColumn(label: Text(s.tableHeaderDescription, style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1))),
            DataColumn(label: Text(s.tableHeaderOrder, style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1)), numeric: true),
            DataColumn(label: Text(s.tableHeaderActive, style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1))),
            DataColumn(label: Text(s.tableHeaderActions, style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1))),
          ],
          rows: _categories.map((c) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    c['name'] as String? ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DataCell(Text(
                  c['description'] as String? ?? '—',
                  overflow: TextOverflow.ellipsis,
                )),
                DataCell(Text('${c['sortOrder'] ?? 0}')),
                DataCell(
                  Icon(
                    (c['isActive'] as bool? ?? true) ? Icons.check_circle : Icons.cancel,
                    size: 18,
                    color: (c['isActive'] as bool? ?? true) ? Colors.green : Colors.red,
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        tooltip: s.edit,
                        onPressed: () => _openForm(c),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        tooltip: s.delete,
                        onPressed: () => _deleteCategory(
                          c['id'] as String,
                          c['name'] as String? ?? '',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
