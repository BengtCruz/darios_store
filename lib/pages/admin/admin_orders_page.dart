import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_client.dart';
import '../../theme/app_theme.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  final _api = ApiClient();
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;
  String? _error;
  String? _statusFilter;

  static const _statusColors = {
    'pending': Colors.orange,
    'confirmed': Colors.blue,
    'shipped': Colors.purple,
    'delivered': Colors.green,
    'cancelled': Colors.red,
  };

  Map<String, String> _statusLabels(S s) => {
    'pending': s.orderStatusPending,
    'confirmed': s.orderStatusConfirmed,
    'shipped': s.orderStatusShipped,
    'delivered': s.orderStatusDelivered,
    'cancelled': s.orderStatusCancelled,
  };

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
      final orders = await _api.getOrders(status: _statusFilter);
      if (!mounted) return;
      setState(() {
        _orders = orders;
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

  Future<void> _updateStatus(String id, String newStatus) async {
    try {
      await _api.updateOrderStatus(id, newStatus);
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).errorMessage(e.toString()))),
      );
    }
  }

  Future<void> _deleteOrder(String id) async {
    final s = S.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.confirmDelete),
        content: Text(s.confirmDeleteOrder),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(s.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _api.deleteOrder(id);
        _load();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).errorMessage(e.toString()))),
        );
      }
    }
  }

  void _showOrderDetail(Map<String, dynamic> order) {
    final items = (order['items'] as List?) ?? [];
    final dateStr = order['createdAt'] as String?;
    final date = dateStr != null ? DateTime.tryParse(dateStr) : null;
    final s = S.of(context);
    final labels = _statusLabels(s);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.orderTitle((order['id'] as String).substring(0, 8))),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _detailRow(s.orderCustomer, order['customerName'] as String? ?? '—'),
                _detailRow(s.orderEmail, order['customerEmail'] as String? ?? '—'),
                _detailRow(s.orderStatus, labels[order['status']] ?? order['status'] as String? ?? ''),
                _detailRow(s.orderTotal, '${(order['totalAmount'] as num? ?? 0).toStringAsFixed(2)} kr'),
                if (date != null) _detailRow(s.orderDate, DateFormat('dd/MM/yyyy HH:mm').format(date)),
                const Divider(height: 24),
                Text(s.orderItems, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                ...items.map((item) {
                  final i = item as Map<String, dynamic>;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Expanded(child: Text(i['productName'] as String? ?? '')),
                        Text('x${i['quantity']}'),
                        const SizedBox(width: 12),
                        Text('${(i['price'] as num? ?? 0).toStringAsFixed(2)} kr'),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.close),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final labels = _statusLabels(s);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.adminOrdersTitle, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 4),
          Text(
            s.adminOrdersCount(_orders.length),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),

          // Filter chips
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: Text(s.orderFilterAll),
                selected: _statusFilter == null,
                onSelected: (_) {
                  _statusFilter = null;
                  _load();
                },
                selectedColor: AppTheme.nero,
                labelStyle: TextStyle(
                  color: _statusFilter == null ? AppTheme.bianco : AppTheme.nero,
                ),
                checkmarkColor: AppTheme.bianco,
                shape: const RoundedRectangleBorder(),
              ),
              ...labels.entries.map((e) => FilterChip(
                    label: Text(e.value),
                    selected: _statusFilter == e.key,
                    onSelected: (_) {
                      _statusFilter = e.key;
                      _load();
                    },
                    selectedColor: _statusColors[e.key],
                    labelStyle: TextStyle(
                      color: _statusFilter == e.key ? Colors.white : AppTheme.nero,
                    ),
                    checkmarkColor: Colors.white,
                    shape: const RoundedRectangleBorder(),
                  )),
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
          else if (_orders.isEmpty)
            Expanded(
              child: Center(
                child: Text(s.noOrdersFound),
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
    final labels = _statusLabels(s);
    return SingleChildScrollView(
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppTheme.nero.withValues(alpha: 0.05)),
          columnSpacing: 20,
          columns: [
            DataColumn(label: Text(s.tableHeaderId, style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1))),
            DataColumn(label: Text(s.tableHeaderCustomer, style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1))),
            DataColumn(label: Text(s.tableHeaderTotal, style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1)), numeric: true),
            DataColumn(label: Text(s.tableHeaderStatus, style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1))),
            DataColumn(label: Text(s.tableHeaderDate, style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1))),
            DataColumn(label: Text(s.tableHeaderActions, style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1))),
          ],
          rows: _orders.map((o) {
            final id = o['id'] as String? ?? '';
            final status = o['status'] as String? ?? 'pending';
            final dateStr = o['createdAt'] as String?;
            final date = dateStr != null ? DateTime.tryParse(dateStr) : null;

            return DataRow(
              cells: [
                DataCell(
                  InkWell(
                    onTap: () => _showOrderDetail(o),
                    child: Text(
                      '#${id.length > 8 ? id.substring(0, 8) : id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                DataCell(Text(o['customerName'] as String? ?? '—')),
                DataCell(Text('${(o['totalAmount'] as num? ?? 0).toStringAsFixed(2)} kr')),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: (_statusColors[status] ?? Colors.grey).withValues(alpha: 0.15),
                    child: Text(
                      labels[status] ?? status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _statusColors[status] ?? Colors.grey,
                      ),
                    ),
                  ),
                ),
                DataCell(Text(
                  date != null ? DateFormat('dd/MM/yy').format(date) : '—',
                )),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility_outlined, size: 18),
                        tooltip: s.orderDetails,
                        onPressed: () => _showOrderDetail(o),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.swap_horiz, size: 18),
                        tooltip: s.orderChangeStatus,
                        onSelected: (st) => _updateStatus(id, st),
                        itemBuilder: (_) => labels.entries
                            .where((e) => e.key != status)
                            .map((e) => PopupMenuItem(
                                  value: e.key,
                                  child: Row(
                                    children: [
                                      Icon(Icons.circle, size: 10, color: _statusColors[e.key]),
                                      const SizedBox(width: 8),
                                      Text(e.value),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        tooltip: s.delete,
                        onPressed: () => _deleteOrder(id),
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
