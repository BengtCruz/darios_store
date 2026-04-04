import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../models/product.dart';
import '../providers/provider_scope.dart';
import '../main.dart' show apiClient;
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final _api = apiClient;
  List<Product> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _api.getWishlist();
      if (!mounted) return;
      setState(() {
        _products = data.map((j) => Product.fromJson(j)).toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final isWide = Responsive.isWide(context);

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
          : _products.isEmpty
              ? _buildEmptyState(context, s)
              : _buildContent(context, s, isWide),
    );
  }

  Widget _buildEmptyState(BuildContext context, S s) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_border, size: 64, color: AppTheme.grigioChiaro),
          const SizedBox(height: 16),
          Text(
            s.wishlistEmpty,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            s.wishlistEmptyDesc,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => context.go('/catalog'),
            child: Text(s.wishlistBrowse),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, S s, bool isWide) {
    final columns = Responsive.gridColumns(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isWide) const SizedBox(height: 24),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 20),
              child: Row(
                children: [
                  Text(
                    s.wishlistTitle.toUpperCase(),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          letterSpacing: 3,
                        ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_products.length} ${_products.length == 1 ? s.myOrdersItem : s.myOrdersItems}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          letterSpacing: 2,
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
            ),
            const Divider(height: 24),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 20),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  childAspectRatio: 0.65,
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 20,
                ),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return _WishlistProductCard(
                    product: product,
                    onRemoved: () {
                      setState(() {
                        _products.removeAt(index);
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WishlistProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onRemoved;

  const _WishlistProductCard({required this.product, required this.onRemoved});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/product/${product.id}', extra: product);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: AppTheme.grigioChiaro.withValues(alpha: 0.3),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.image_outlined,
                            size: 48, color: AppTheme.grigio),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        WishlistProviderScope.of(context).toggle(product.id);
                        onRemoved();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.bianco.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite,
                          size: 18,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.category.toUpperCase(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 10,
                  letterSpacing: 2,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            product.name,
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '${product.price.toStringAsFixed(2)} kr',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  final added = CartProviderScope.of(context).addToCart(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        added
                            ? S.of(context).detailAddedToCart(product.name)
                            : S.of(context).stockLimitReached(product.name),
                        style: const TextStyle(color: AppTheme.bianco),
                      ),
                      backgroundColor: AppTheme.nero,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: const Icon(
                  Icons.add_shopping_cart,
                  size: 18,
                  color: AppTheme.grigio,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  const Icon(Icons.star, size: 14, color: AppTheme.nero),
                  const SizedBox(width: 2),
                  Text(
                    product.rating.toString(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
