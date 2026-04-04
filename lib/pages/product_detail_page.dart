import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../models/product.dart';
import '../providers/provider_scope.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;
  final Product? product;

  const ProductDetailPage({super.key, required this.productId, this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  Product? _product;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    if (_product == null) {
      _loadProduct();
    }
  }

  Future<void> _loadProduct() async {
    setState(() => _loading = true);
    try {
      final api = ApiClient();
      final json = await api.getProduct(widget.productId);
      if (!mounted) return;
      setState(() {
        _product = Product.fromJson(json);
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
    final isWide = Responsive.isWide(context);

    if (_loading) {
      return Scaffold(
        appBar: isWide ? null : AppBar(title: Text(S.of(context).brandName)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _product == null) {
      return Scaffold(
        appBar: isWide ? null : AppBar(title: Text(S.of(context).brandName)),
        body: Center(child: Text(_error ?? 'Product not found')),
      );
    }

    final product = _product!;

    return Scaffold(
      appBar: isWide
          ? null
          : AppBar(
              title: Text(S.of(context).brandName),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () {},
                ),
              ],
            ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: isWide
                ? _buildWebLayout(context, product)
                : _buildMobileLayout(context, product),
          ),
        ),
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context, Product product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_back, size: 18, color: AppTheme.grigio),
                  const SizedBox(width: 8),
                  Text(
                    S.of(context).detailBackToCatalog,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          decoration: TextDecoration.underline,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image (left)
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    color: AppTheme.grigioChiaro.withValues(alpha: 0.3),
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.image_outlined,
                            size: 80, color: AppTheme.grigio),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48),
              // Details (right)
              Expanded(
                child: _buildProductInfo(context, product),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            color: AppTheme.grigioChiaro.withValues(alpha: 0.3),
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.image_outlined,
                    size: 80, color: AppTheme.grigio),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: _buildProductInfo(context, product),
        ),
      ],
    );
  }

  Widget _buildProductInfo(BuildContext context, Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category
        Text(
          product.category.toUpperCase(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 11,
                letterSpacing: 3,
              ),
        ),
        const SizedBox(height: 8),

        // Name
        Text(
          product.name,
          style: TextStyle(
            fontFamily: 'Playfair Display',
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppTheme.nero,
          ),
        ),
        const SizedBox(height: 12),

        // Price & Rating
        Row(
          children: [
            Text(
              '${product.price.toStringAsFixed(2)} kr',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const Spacer(),
            if (AuthProviderScope.of(context).isLoggedIn) ...[
              Builder(builder: (context) {
                final wishlist = WishlistProviderScope.of(context);
                final isWishlisted = wishlist.isWishlisted(product.id);
                return GestureDetector(
                  onTap: () => wishlist.toggle(product.id),
                  child: Icon(
                    isWishlisted ? Icons.favorite : Icons.favorite_border,
                    size: 24,
                    color: isWishlisted ? Colors.red : AppTheme.grigio,
                  ),
                );
              }),
              const SizedBox(width: 16),
            ],
            const Icon(Icons.star, size: 18, color: AppTheme.nero),
            const SizedBox(width: 4),
            Text(
              product.rating.toString(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          product.stock > 0
              ? S.of(context).detailStockCount(product.stock)
              : S.of(context).detailOutOfStock,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: product.stock > 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
        ),
        const Divider(height: 32),

        // Description
        Text(
          S.of(context).detailDescription,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                letterSpacing: 3,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          product.description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.7,
              ),
        ),
        const SizedBox(height: 32),

        // Add to Cart
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: product.stock <= 0 ? null : () {
              final added = CartProviderScope.of(context).addToCart(product);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    added
                        ? S.of(context).detailAddedToCart(product.name)
                        : S.of(context).stockLimitReached(product.name),
                    style: TextStyle(fontFamily: 'Lato', color: AppTheme.bianco),
                  ),
                  backgroundColor: AppTheme.nero,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Text(product.stock <= 0
                ? S.of(context).detailOutOfStock
                : S.of(context).detailAddToCart),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: product.stock <= 0 ? null : () {
              CartProviderScope.of(context).addToCart(product);
            },
            child: Text(S.of(context).detailBuyNow),
          ),
        ),
        const SizedBox(height: 32),

        // Details table
        _buildDetailRow(context, S.of(context).detailCategory, product.category),
        _buildDetailRow(context, S.of(context).detailRating, '${product.rating}/5.0'),
        _buildDetailRow(context, S.of(context).detailShipping, S.of(context).detailShippingValue),
        _buildDetailRow(context, S.of(context).detailReturns, S.of(context).detailReturnsValue),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label.toUpperCase(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    letterSpacing: 2,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
