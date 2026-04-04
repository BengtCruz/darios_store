import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../models/product.dart';
import '../providers/provider_scope.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _api = ApiClient();
  final _controller = TextEditingController();
  List<Product> _allProducts = [];
  List<Product> _results = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final data = await _api.getProducts();
      if (!mounted) return;
      setState(() {
        _allProducts = data.map((j) => Product.fromJson(j)).toList();
      });
    } catch (_) {}
  }

  void _search(String query) {
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }
    final lower = query.toLowerCase();
    setState(() {
      _results = _allProducts
          .where((p) =>
              p.name.toLowerCase().contains(lower) ||
              p.category.toLowerCase().contains(lower) ||
              p.description.toLowerCase().contains(lower))
          .toList();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _controller,
                onChanged: _search,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: S.of(context).searchHint,
                  hintStyle: Theme.of(context).textTheme.bodyMedium,
                  prefixIcon:
                      const Icon(Icons.search, color: AppTheme.grigio),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close,
                              size: 20, color: AppTheme.grigio),
                          onPressed: () {
                            _controller.clear();
                            _search('');
                          },
                        )
                      : null,
                  filled: false,
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide:
                        BorderSide(color: AppTheme.grigioChiaro, width: 1.5),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide:
                        BorderSide(color: AppTheme.nero, width: 1.5),
                  ),
                ),
              ),
            ),

            // Results
            if (_controller.text.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search,
                          size: 64, color: AppTheme.grigioChiaro),
                      const SizedBox(height: 16),
                      Text(
                        S.of(context).searchEmpty,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              )
            else if (_results.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off,
                          size: 64, color: AppTheme.grigioChiaro),
                      const SizedBox(height: 16),
                      Text(
                        S.of(context).searchNoResults,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        S.of(context).searchTryAnother,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _results.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final product = _results[index];
                    return _SearchResultTile(product: product);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final Product product;

  const _SearchResultTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push('/product/${product.id}', extra: product);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              color: AppTheme.grigioChiaro.withValues(alpha: 0.3),
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.image_outlined, size: 24, color: AppTheme.grigio),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  ),
                ],
              ),
            ),
            Text(
              '${product.price.toStringAsFixed(2)} kr',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            if (AuthProviderScope.of(context).isLoggedIn) ...[
              const SizedBox(width: 12),
              Builder(builder: (context) {
                final wishlist = WishlistProviderScope.of(context);
                final isWishlisted = wishlist.isWishlisted(product.id);
                return GestureDetector(
                  onTap: () => wishlist.toggle(product.id),
                  child: Icon(
                    isWishlisted ? Icons.favorite : Icons.favorite_border,
                    size: 20,
                    color: isWishlisted ? Colors.red : AppTheme.grigio,
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
