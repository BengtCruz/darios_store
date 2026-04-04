import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/order.dart';
import '../providers/provider_scope.dart';
import '../main.dart' show apiClient;
import '../theme/app_theme.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  List<Order>? _orders;
  bool _loading = true;
  String? _error;
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final auth = AuthProviderScope.of(context);
      final api = apiClient;
      if (auth.token != null) api.setToken(auth.token!);

      final json = await api.getOrders(
        email: auth.userEmail,
        status: _statusFilter,
      );
      if (!mounted) return;
      setState(() {
        _orders = json.map((j) => Order.fromJson(j)).toList();
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

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.myOrdersTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          _buildStatusFilters(context),
          Expanded(child: _buildBody(context)),
        ],
      ),
    );
  }

  Widget _buildStatusFilters(BuildContext context) {
    final s = S.of(context);
    final filters = <String?, String>{
      null: s.orderFilterAll,
      'pending': s.orderStatusPending,
      'confirmed': s.orderStatusConfirmed,
      'shipped': s.orderStatusShipped,
      'delivered': s.orderStatusDelivered,
      'cancelled': s.orderStatusCancelled,
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: filters.entries.map((e) {
          final isSelected = _statusFilter == e.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(e.value),
              selected: isSelected,
              onSelected: (_) {
                setState(() => _statusFilter = e.key);
                _loadOrders();
              },
              selectedColor: AppTheme.nero,
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.bianco : AppTheme.nero,
                fontSize: 12,
                letterSpacing: 1,
              ),
              checkmarkColor: AppTheme.bianco,
              backgroundColor: AppTheme.bianco,
              side: BorderSide(color: AppTheme.grigioChiaro),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final s = S.of(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(s.dashboardServerError),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOrders,
              child: Text(s.dashboardRetry),
            ),
          ],
        ),
      );
    }

    if (_orders == null || _orders!.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long_outlined, size: 64, color: AppTheme.grigio),
            const SizedBox(height: 16),
            Text(
              s.myOrdersEmpty,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              s.myOrdersEmptyDesc,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/catalog'),
              child: Text(s.cartDiscover),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: _orders!.length,
        itemBuilder: (context, index) => _OrderCard(order: _orders![index]),
      ),
    );
  }
}

class _OrderCard extends StatefulWidget {
  final Order order;

  const _OrderCard({required this.order});

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  bool _expanded = false;

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return AppTheme.grigio;
    }
  }

  String _statusLabel(String status, S s) {
    switch (status) {
      case 'pending':
        return s.orderStatusPending;
      case 'confirmed':
        return s.orderStatusConfirmed;
      case 'shipped':
        return s.orderStatusShipped;
      case 'delivered':
        return s.orderStatusDelivered;
      case 'cancelled':
        return s.orderStatusCancelled;
      default:
        return status;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'shipped':
        return Icons.local_shipping_outlined;
      case 'delivered':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final order = widget.order;
    final dateFormat = DateFormat('d MMM yyyy, HH:mm');
    final color = _statusColor(order.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
        side: BorderSide(color: AppTheme.grigioChiaro),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.orderTitle(order.id.substring(0, 8)),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_statusIcon(order.status), size: 14, color: color),
                            const SizedBox(width: 4),
                            Text(
                              _statusLabel(order.status, s),
                              style: TextStyle(
                                color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.grigio),
                      const SizedBox(width: 6),
                      Text(
                        dateFormat.format(order.createdAt.toLocal()),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.grigio,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        '${order.totalAmount.toStringAsFixed(2)} kr',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${order.items.length} ${order.items.length == 1 ? s.myOrdersItem : s.myOrdersItems}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.grigio,
                            ),
                      ),
                      const Spacer(),
                      Icon(
                        _expanded ? Icons.expand_less : Icons.expand_more,
                        color: AppTheme.grigio,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Expanded details
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.orderItems,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          letterSpacing: 2,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppTheme.grigioChiaro.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Text(
                                  '${item.quantity}x',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.productName,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            Text(
                              '${(item.price * item.quantity).toStringAsFixed(2)} kr',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      )),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        s.cartTotal,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              letterSpacing: 2,
                            ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${order.totalAmount.toStringAsFixed(2)} kr',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
