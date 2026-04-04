import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'models/product.dart';
import 'pages/home_page.dart';
import 'pages/catalog_page.dart';
import 'pages/search_page.dart';
import 'pages/cart_page.dart';
import 'pages/profile_page.dart';
import 'pages/product_detail_page.dart';
import 'pages/checkout_page.dart';
import 'pages/my_orders_page.dart';
import 'pages/wishlist_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/admin/admin_shell.dart';
import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';
import 'utils/responsive.dart';
import 'providers/provider_scope.dart';
import 'widgets/web_nav_bar.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter buildRouter() {
  GoRouter.optionURLReflectsImperativeAPIs = true;
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/catalog',
              builder: (context, state) => const CatalogPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => const SearchPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/cart',
              builder: (context, state) => const CartPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/product/:id',
      builder: (context, state) {
        final product = state.extra as Product?;
        final id = state.pathParameters['id']!;
        return ProductDetailPage(productId: id, product: product);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/checkout',
      builder: (context, state) => const CheckoutPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/my-orders',
      builder: (context, state) => const MyOrdersPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/wishlist',
      builder: (context, state) => const WishlistPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/admin',
      builder: (context, state) => const AdminShell(),
    ),
  ],
  );
}

final router = buildRouter();

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  void _onNavigate(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = Responsive.isWide(context);

    if (isWide) {
      return _buildWebLayout(context);
    }
    return _buildMobileLayout(context);
  }

  Widget _buildWebLayout(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          WebNavBar(
            currentIndex: navigationShell.currentIndex,
            onTap: _onNavigate,
          ),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final s = S.of(context);
    final cart = CartProviderScope.of(context);
    final cartCount = cart.itemCount;
    final titles = [
      s.brandName,
      s.navCatalog,
      s.navSearch,
      s.navCart,
      s.navProfile,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[navigationShell.currentIndex]),
        leading: navigationShell.currentIndex == 0
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.storefront, size: 24),
              )
            : null,
        actions: [
          if (navigationShell.currentIndex == 0)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _onNavigate(2),
            ),
          IconButton(
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              backgroundColor: AppTheme.nero,
              textColor: AppTheme.bianco,
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            onPressed: () => _onNavigate(3),
          ),
        ],
      ),
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _onNavigate,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: s.navHome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.grid_view_outlined),
            activeIcon: const Icon(Icons.grid_view),
            label: s.navCatalogLabel,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search),
            activeIcon: const Icon(Icons.search),
            label: s.navSearchLabel,
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              backgroundColor: AppTheme.nero,
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            activeIcon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              backgroundColor: AppTheme.nero,
              child: const Icon(Icons.shopping_bag),
            ),
            label: s.navCartLabel,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: s.navProfileLabel,
          ),
        ],
      ),
    );
  }
}
