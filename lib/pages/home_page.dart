import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../models/product.dart';
import '../providers/provider_scope.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/web_footer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _api = ApiClient();
  List<Product> _featured = [];
  List<String> _categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        _api.getProducts(featured: true),
        _api.getCategories(),
      ]);
      if (!mounted) return;
      setState(() {
        _featured = results[0]
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

  @override
  Widget build(BuildContext context) {
    final isWide = Responsive.isWide(context);
    final s = S.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Banner
          _buildHeroBanner(context, isWide),
          const SizedBox(height: 32),

          if (_loading)
            const Padding(
              padding: EdgeInsets.all(64),
              child: Center(child: CircularProgressIndicator(color: AppTheme.nero)),
            )
          else ...[
          // Centered content wrapper
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Categories
                    Text(
                      s.homeCategories,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            letterSpacing: 3,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryList(context),
                    const SizedBox(height: 48),

                    // Featured Products
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          s.homeFeatured,
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    letterSpacing: 3,
                                  ),
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Text(
                            s.homeSeeAll,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  decoration: TextDecoration.underline,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildFeaturedGrid(context, _featured),
                    const SizedBox(height: 48),

                    // About section
                    _buildAboutSection(context),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
          ],

          // Web footer
          const WebFooter(),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context, bool isWide) {
    return Container(
      width: double.infinity,
      color: AppTheme.nero,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 32 : 20,
              vertical: isWide ? 80 : 48,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).heroTitle,
                  style: TextStyle(
                    fontFamily: 'Playfair Display',
                    fontSize: isWide ? 64 : 42,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.bianco,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  S.of(context).heroSubtitle,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: isWide ? 18 : 16,
                    color: AppTheme.grigioChiaro,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side:
                        const BorderSide(color: AppTheme.bianco, width: 1.5),
                    foregroundColor: AppTheme.bianco,
                  ),
                  onPressed: () {},
                  child: Text(S.of(context).heroButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context) {
    final isWide = Responsive.isWide(context);
    if (isWide) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _categories.map((cat) {
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.nero, width: 1.5),
              ),
              child: Text(
                cat.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
              ),
            ),
          );
        }).toList(),
      );
    }

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.nero, width: 1.5),
            ),
            child: Center(
              child: Text(
                _categories[index].toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedGrid(BuildContext context, List<Product> products) {
    final columns = Responsive.gridColumns(context);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: 0.65,
        mainAxisSpacing: 24,
        crossAxisSpacing: 20,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _ProductCard(product: products[index]);
      },
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.grigioChiaro),
      ),
      child: Column(
        children: [
          Text(
            S.of(context).aboutTitle,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  letterSpacing: 3,
                ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Text(
              S.of(context).aboutText,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final wishlist = WishlistProviderScope.of(context);
    final auth = AuthProviderScope.of(context);
    final isWishlisted = wishlist.isWishlisted(product.id);

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
                        child: Icon(Icons.image_outlined, size: 48, color: AppTheme.grigio),
                      ),
                    ),
                  ),
                  if (auth.isLoggedIn)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => wishlist.toggle(product.id),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.bianco.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isWishlisted ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: isWishlisted ? Colors.red : AppTheme.nero,
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
                  size: 20,
                  color: AppTheme.grigio,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
