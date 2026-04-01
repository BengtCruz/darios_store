import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'utils/responsive.dart';
import 'widgets/web_nav_bar.dart';
import 'pages/home_page.dart';
import 'pages/catalog_page.dart';
import 'pages/search_page.dart';
import 'pages/cart_page.dart';
import 'pages/profile_page.dart';

void main() {
  runApp(const DariosStoreApp());
}

class DariosStoreApp extends StatelessWidget {
  const DariosStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Dario's Store",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const MainShell(),
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
    const titles = [
      "DARIO'S STORE",
      'CATALOGO',
      'CERCA',
      'CARRELLO',
      'PROFILO',
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view),
            label: 'Catalogo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            activeIcon: Icon(Icons.search),
            label: 'Cerca',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'Carrello',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profilo',
          ),
        ],
      ),
    );
  }
}
