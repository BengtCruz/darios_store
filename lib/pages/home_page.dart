import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/mock_products.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import 'product_detail_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final featured =
        mockProducts.where((p) => p.isFeatured).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Banner
          _buildHeroBanner(context),
          const SizedBox(height: 32),

          // Categories
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'CATEGORIE',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    letterSpacing: 3,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          _buildCategoryList(context),
          const SizedBox(height: 32),

          // Featured Products
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'IN VETRINA',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        letterSpacing: 3,
                      ),
                ),
                Text(
                  'Vedi tutto',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        decoration: TextDecoration.underline,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildFeaturedGrid(context, featured),
          const SizedBox(height: 32),

          // About section
          _buildAboutSection(context),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppTheme.nero,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sapori\nd\'Italia',
            style: GoogleFonts.playfairDisplay(
              fontSize: 42,
              fontWeight: FontWeight.w700,
              color: AppTheme.bianco,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Authentic Italian flavors,\ndelivered to your door.',
            style: GoogleFonts.lato(
              fontSize: 16,
              color: AppTheme.grigioChiaro,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.bianco, width: 1.5),
              foregroundColor: AppTheme.bianco,
            ),
            onPressed: () {},
            child: const Text('SCOPRI ORA'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.nero, width: 1.5),
            ),
            child: Center(
              child: Text(
                categories[index].toUpperCase(),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          mainAxisSpacing: 20,
          crossAxisSpacing: 16,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return _ProductCard(product: products[index]);
        },
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.grigioChiaro),
      ),
      child: Column(
        children: [
          Text(
            'LA NOSTRA STORIA',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  letterSpacing: 3,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'From the rolling hills of Tuscany to your table. '
            'We source only the finest artisanal ingredients from family-run '
            'producers across Italy.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
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
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.image_outlined, size: 48, color: AppTheme.grigio),
                ),
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
          Text(
            '€${product.price.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
