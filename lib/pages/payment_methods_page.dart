import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../main.dart' show apiClient;
import '../models/payment_method.dart';
import '../theme/app_theme.dart';
import '../utils/web_helper.dart' as web;

class PaymentMethodsPage extends StatefulWidget {
  final String? setupResult;
  const PaymentMethodsPage({super.key, this.setupResult});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  List<PaymentMethod> _methods = [];
  bool _loading = true;
  bool _addingCard = false;

  @override
  void initState() {
    super.initState();
    if (widget.setupResult == 'success') {
      // Returned from Stripe — sync new cards then load
      _syncFromStripe();
    } else {
      _load();
    }
  }

  Future<void> _load() async {
    try {
      final data = await apiClient.getPaymentMethods();
      if (!mounted) return;
      setState(() {
        _methods = data.map((j) => PaymentMethod.fromJson(j)).toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _syncFromStripe() async {
    setState(() => _loading = true);
    try {
      final data = await apiClient.syncPaymentMethods();
      if (!mounted) return;
      setState(() {
        _methods = data.map((j) => PaymentMethod.fromJson(j)).toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      // Fall back to regular load
      _load();
    }
  }

  Future<void> _addCard() async {
    setState(() => _addingCard = true);
    try {
      final result = await apiClient.setupPaymentMethod();
      final url = result['url'] as String?;
      if (url != null) {
        // Redirect in the same tab — app will reload when Stripe sends us back
        web.redirectToUrl(url);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _addingCard = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).paymentSetupFailed),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteMethod(PaymentMethod method) async {
    final s = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.paymentDeleteConfirm),
        content: Text(s.paymentDeleteMessage(method.label)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await apiClient.deletePaymentMethod(method.id);
      if (!mounted) return;
      setState(() {
        _methods.removeWhere((m) => m.id == method.id);
      });
    } catch (_) {}
  }

  Future<void> _setDefault(PaymentMethod method) async {
    try {
      await apiClient.updatePaymentMethod(method.id, {'isDefault': true});
      await _load();
    } catch (_) {}
  }

  Future<void> _editLabel(PaymentMethod method) async {
    final s = S.of(context);
    final controller = TextEditingController(text: method.label);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.paymentEditLabel),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: s.paymentLabel),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(s.save),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null || result.isEmpty || result == method.label) return;

    try {
      await apiClient.updatePaymentMethod(method.id, {'label': result});
      await _load();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.brandName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.nero))
          : _methods.isEmpty
              ? _buildEmptyState(context, s)
              : _buildContent(context, s),
      floatingActionButton: !_loading
          ? FloatingActionButton(
              onPressed: _addingCard ? null : _addCard,
              backgroundColor: AppTheme.nero,
              child: _addingCard
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppTheme.bianco,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.add, color: AppTheme.bianco),
            )
          : null,
    );
  }

  Widget _buildEmptyState(BuildContext context, S s) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.credit_card_off_outlined, size: 64, color: AppTheme.grigioChiaro),
          const SizedBox(height: 16),
          Text(
            s.paymentEmpty,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            s.paymentEmptyDesc,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: _addingCard ? null : _addCard,
            child: Text(s.paymentAdd),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 14, color: AppTheme.grigio),
              const SizedBox(width: 6),
              Text(
                s.paymentStripeSecure,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.grigio,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, S s) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                s.paymentTitle.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      letterSpacing: 3,
                    ),
              ),
            ),
            const Divider(height: 24),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _methods.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final method = _methods[index];
                  return _PaymentMethodCard(
                    method: method,
                    onEditLabel: () => _editLabel(method),
                    onDelete: () => _deleteMethod(method),
                    onSetDefault: () => _setDefault(method),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, size: 14, color: AppTheme.grigio),
                  const SizedBox(width: 6),
                  Text(
                    s.paymentStripeSecure,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.grigio,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final PaymentMethod method;
  final VoidCallback onEditLabel;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const _PaymentMethodCard({
    required this.method,
    required this.onEditLabel,
    required this.onDelete,
    required this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.credit_card,
            size: 24,
            color: AppTheme.nero,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      method.label.toUpperCase(),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            letterSpacing: 2,
                            fontSize: 12,
                          ),
                    ),
                    if (method.isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.nero,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          s.paymentDefault.toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.bianco,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${method.cardBrand}  ${method.maskedNumber}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        letterSpacing: 1.5,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${s.paymentExpires} ${method.expiryDisplay}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _actionButton(context, s.paymentEditLabel, onEditLabel),
                    const SizedBox(width: 16),
                    _actionButton(context, s.delete, onDelete, color: Colors.red),
                    if (!method.isDefault) ...[
                      const SizedBox(width: 16),
                      _actionButton(context, s.paymentSetDefault, onSetDefault),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context, String label, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                decoration: TextDecoration.underline,
                color: color,
                fontSize: 13,
              ),
        ),
      ),
    );
  }
}
