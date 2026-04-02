import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/provider_scope.dart';
import 'services/api_client.dart';
import 'theme/app_theme.dart';
import 'utils/responsive.dart';
import 'widgets/web_nav_bar.dart';
import 'pages/home_page.dart';
import 'pages/catalog_page.dart';
import 'pages/search_page.dart';
import 'pages/cart_page.dart';
import 'pages/profile_page.dart';

final appLocale = AppLocale();
final apiClient = ApiClient();
final authProvider = AuthProvider(apiClient);
final cartProvider = CartProvider();

void main() {
  runApp(const DariosStoreApp());
}

class DariosStoreApp extends StatelessWidget {
  const DariosStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthProviderScope(
      auth: authProvider,
      child: CartProviderScope(
        cart: cartProvider,
        child: AppLocaleProvider(
          locale: appLocale,
          child: Builder(
            builder: (context) {
              final s = S.of(context);
              return MaterialApp(
                title: s.appTitle,
                debugShowCheckedModeBanner: false,
                theme: AppTheme.theme,
                home: const MainShell(),
              );
            },
          ),
        ),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _pages = <Widget>[
    HomePage(),
    CatalogPage(),
    SearchPage(),
    CartPage(),
    ProfilePage(),
  ];

  void _onNavigate(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final isWide = Responsive.isWide(context);

    if (isWide) {
      return _buildWebLayout();
    }
    return _buildMobileLayout();
  }

  Widget _buildWebLayout() {
    return Scaffold(
      body: Column(
        children: [
          WebNavBar(
            currentIndex: _currentIndex,
            onTap: _onNavigate,
          ),
          Expanded(child: _pages[_currentIndex]),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    final s = S.of(context);
    final titles = [
      s.brandName,
      s.navCatalog,
      s.navSearch,
      s.navCart,
      s.navProfile,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_currentIndex]),
        leading: _currentIndex == 0
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.storefront, size: 24),
              )
            : null,
        actions: [
          if (_currentIndex == 0)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _onNavigate(2),
            ),
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () => _onNavigate(3),
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
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
            icon: const Icon(Icons.shopping_bag_outlined),
            activeIcon: const Icon(Icons.shopping_bag),
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
