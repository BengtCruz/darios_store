import 'package:flutter/material.dart';
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
        title: const Text('Conferma Eliminazione'),
        content: Text('Eliminare la categoria "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ANNULLA'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ELIMINA'),
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
          SnackBar(content: Text('Errore: $e')),
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

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Modifica Categoria' : 'Nuova Categoria'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nome *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Descrizione',
                    border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: sortCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Ordine',
                    border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Attiva'),
                  value: isActive,
                  activeColor: AppTheme.nero,
                  onChanged: (v) => setDialogState(() => isActive = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('ANNULLA'),
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
                    SnackBar(content: Text('Errore: $e')),
                  );
                }
              },
              child: Text(isEditing ? 'SALVA' : 'CREA'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    Text('Categorie', style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: 4),
                    Text(
                      '${_categories.length} categorie totali',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _openForm(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('NUOVA CATEGORIA'),
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
                    ElevatedButton(onPressed: _load, child: const Text('RIPROVA')),
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
    return SingleChildScrollView(
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppTheme.nero.withValues(alpha: 0.05)),
          columns: const [
            DataColumn(label: Text('NOME', style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1))),
            DataColumn(label: Text('DESCRIZIONE', style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1))),
            DataColumn(label: Text('ORDINE', style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1)), numeric: true),
            DataColumn(label: Text('ATTIVA', style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1))),
            DataColumn(label: Text('AZIONI', style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1))),
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
                        tooltip: 'Modifica',
                        onPressed: () => _openForm(c),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        tooltip: 'Elimina',
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
