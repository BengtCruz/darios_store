import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/product.dart';
import '../providers/provider_scope.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import 'product_detail_page.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final _api = ApiClient();
  List<Product> _products = [];
  List<String> _categories = [];
  String? _selectedCategory;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        _api.getProducts(),
        _api.getCategories(),
      ]);
      if (!mounted) return;
      setState(() {
        _products = results[0]
            .map((j) => Product.fromJson(j))
            .toList();
        _categories = results[1]
            .map((j) => j['name'] as String)
            .toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  List<Product> get _filteredProducts {
    if (_selectedCategory == null) return _products;
    return _products
        .where((p) => p.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = Responsive.isWide(context);
    final columns = Responsive.gridColumns(context);
    final hPad = isWide ? 32.0 : 20.0;
    final s = S.of(context);

    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.nero),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            if (isWide) const SizedBox(height: 24),
            // Category filter
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: hPad),
                children: [
                  _buildFilterChip(s.catalogAll, null),
                  ..._categories.map((c) => _buildFilterChip(c, c)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Product count
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s.productCount(_filteredProducts.length),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          letterSpacing: 2,
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
            ),
            const Divider(height: 24),
            // Product grid
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  childAspectRatio: 0.65,
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 20,
                ),
                itemCount: _filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = _filteredProducts[index];
                  return _CatalogProductCard(product: product);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String? categoryValue) {
    final isSelected = _selectedCategory == categoryValue;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = categoryValue),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.nero : Colors.transparent,
            border: Border.all(
              color: isSelected ? AppTheme.nero : AppTheme.grigioChiaro,
              width: 1.5,
            ),
          ),
          child: Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontSize: 11,
                  letterSpacing: 1.5,
                  color: isSelected ? AppTheme.bianco : AppTheme.nero,
                ),
          ),
        ),
      ),
    );
  }
}

class _CatalogProductCard extends StatelessWidget {
  final Product product;

  const _CatalogProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: product),
          ),
        );
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
                  if (product.isFeatured)
                    Positioned(
                      top: 8,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        color: AppTheme.nero,
                        child: Text(
                          S.of(context).catalogFeaturedBadge,
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontSize: 9,
                                    color: AppTheme.bianco,
                                    letterSpacing: 1.5,
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
                  CartProviderScope.of(context).addToCart(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        S.of(context).detailAddedToCart(product.name),
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
