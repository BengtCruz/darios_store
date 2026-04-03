import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../providers/provider_scope.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = AuthProviderScope.of(context);
      if (auth.isLoggedIn) {
        _nameController.text = auth.userName;
        _emailController.text = auth.userEmail;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _processing = true);

    final cart = CartProviderScope.of(context);
    final items = cart.items
        .map((item) => {
              'productId': item.product.id,
              'productName': item.product.name,
              'price': item.product.price,
              'quantity': item.quantity,
            })
        .toList();

    try {
      final api = ApiClient();
      final auth = AuthProviderScope.of(context);
      if (auth.isLoggedIn && auth.token != null) {
        api.setToken(auth.token!);
      }

      final result = await api.createCheckoutSession({
        'items': items,
        'customerName': _nameController.text.trim(),
        'customerEmail': _emailController.text.trim(),
      });

      final url = result['url'] as String?;
      if (url != null) {
        cart.clearCart();
        await launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView);
        if (mounted) Navigator.of(context).pop();
      } else {
        throw Exception(result['error'] ?? 'No checkout URL returned');
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).checkoutFailed),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final cart = CartProviderScope.of(context);
    final items = cart.items;

    return Scaffold(
      appBar: AppBar(title: Text(s.checkoutTitle)),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer info
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: s.checkoutName),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? s.checkoutNameRequired : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: s.checkoutEmail),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return s.checkoutEmailRequired;
                        if (!v.contains('@') || !v.contains('.')) return s.checkoutEmailInvalid;
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Order summary
                    Text(
                      s.checkoutOrderSummary,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            letterSpacing: 3,
                          ),
                    ),
                    const Divider(height: 24),
                    ...items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  s.checkoutItemLine(item.product.name, item.quantity),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              Text(
                                '${item.total.toStringAsFixed(2)} kr',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        )),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          s.cartTotal,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                letterSpacing: 3,
                              ),
                        ),
                        Text(
                          '${cart.totalPrice.toStringAsFixed(2)} kr',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.nero,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Place order button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _processing ? null : _placeOrder,
                        child: Text(
                          _processing ? s.checkoutProcessing : s.checkoutPlaceOrder,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_outline, size: 14, color: AppTheme.grigio),
                        const SizedBox(width: 6),
                        Text(
                          s.checkoutPaymentSecure,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.grigio,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.checkoutStripeNotice,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.grigio,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
