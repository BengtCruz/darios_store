import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_client.dart';
import '../../theme/app_theme.dart';
import 'admin_product_form.dart';

class AdminProductsPage extends StatefulWidget {
  const AdminProductsPage({super.key});

  @override
  State<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
  final _api = ApiClient();
  List<Map<String, dynamic>> _products = [];
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
      final products = await _api.getProducts();
      if (!mounted) return;
      setState(() {
        _products = products;
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

  Future<void> _deleteProduct(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context).confirmDelete),
        content: Text(S.of(context).confirmDeleteProduct(name)),
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
        await _api.deleteProduct(id);
        _load();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).errorMessage(e.toString()))),
        );
      }
    }
  }

  void _openForm([Map<String, dynamic>? product]) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AdminProductForm(product: product),
      ),
    );
    if (result == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.adminProductsTitle, style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: 4),
                    Text(
                      s.adminProductsCount(_products.length),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _openForm(),
                icon: const Icon(Icons.add, size: 18),
                label: Text(s.adminNewProduct),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Content
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
          columnSpacing: 20,
          columns: [
            DataColumn(label: Text(s.tableHeaderName, style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1))),
            DataColumn(label: Text(s.tableHeaderCategory, style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1))),
            DataColumn(label: Text(s.tableHeaderPrice, style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1)), numeric: true),
            DataColumn(label: Text(s.tableHeaderActive, style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1))),
            DataColumn(label: Text(s.tableHeaderFeatured, style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1))),
            DataColumn(label: Text(s.tableHeaderActions, style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1))),
          ],
          rows: _products.map((p) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    p['name'] as String? ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DataCell(Text(p['category'] as String? ?? '')),
                DataCell(Text('${(p['price'] as num? ?? 0).toStringAsFixed(2)} kr')),
                DataCell(
                  Icon(
                    (p['isActive'] as bool? ?? true) ? Icons.check_circle : Icons.cancel,
                    size: 18,
                    color: (p['isActive'] as bool? ?? true) ? Colors.green : Colors.red,
                  ),
                ),
                DataCell(
                  Icon(
                    (p['isFeatured'] as bool? ?? false) ? Icons.star : Icons.star_border,
                    size: 18,
                    color: (p['isFeatured'] as bool? ?? false) ? Colors.amber : AppTheme.grigio,
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        tooltip: s.edit,
                        onPressed: () => _openForm(p),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        tooltip: s.delete,
                        onPressed: () => _deleteProduct(
                          p['id'] as String,
                          p['name'] as String? ?? '',
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
