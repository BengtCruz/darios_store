import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../models/cart_item.dart';
import '../providers/provider_scope.dart';
import '../theme/app_theme.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = CartProviderScope.of(context);
    final items = cart.items;

    if (items.isEmpty) {
      return _buildEmptyCart(context);
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 32),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _buildCartItem(context, item);
                },
              ),
            ),
            _buildCartSummary(context, cart.totalPrice),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: AppTheme.grigioChiaro,
            ),
            const SizedBox(height: 24),
            Text(
              S.of(context).cartEmpty,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              S.of(context).cartEmptyDesc,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                  ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {},
              child: Text(S.of(context).cartDiscover),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item) {
    final cart = CartProviderScope.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product image
        Container(
          width: 90,
          height: 90,
          color: AppTheme.grigioChiaro.withValues(alpha: 0.3),
          child: Image.network(
            item.product.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.image_outlined, color: AppTheme.grigio),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '€${item.product.price.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              // Quantity controls
              Row(
                children: [
                  _quantityButton(Icons.remove, () {
                    if (item.quantity > 1) {
                      cart.updateQuantity(item.product.id, item.quantity - 1);
                    } else {
                      cart.removeFromCart(item.product.id);
                    }
                  }),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '${item.quantity}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  _quantityButton(Icons.add, () {
                    cart.updateQuantity(item.product.id, item.quantity + 1);
                  }),
                ],
              ),
            ],
          ),
        ),
        // Line total
        Text(
          '€${item.total.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }

  Widget _quantityButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.grigioChiaro, width: 1.5),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context, double total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.grigioChiaro)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).cartTotal,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      letterSpacing: 3,
                    ),
              ),
              Text(
                '€${total.toStringAsFixed(2)}',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.nero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            S.of(context).cartShippingNote,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              child: Text(S.of(context).cartCheckout),
            ),
          ),
        ],
      ),
    );
  }
}
