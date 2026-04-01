import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import 'admin_dashboard_page.dart';
import 'admin_products_page.dart';
import 'admin_categories_page.dart';
import 'admin_orders_page.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 0;

  static const _pages = <Widget>[
    AdminDashboardPage(),
    AdminProductsPage(),
    AdminCategoriesPage(),
    AdminOrdersPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    final s = S.of(context);

    final titles = [
      s.adminDashboard,
      s.adminProducts,
      s.adminCategories,
      s.adminOrders,
    ];

    const icons = [
      Icons.dashboard_outlined,
      Icons.inventory_2_outlined,
      Icons.category_outlined,
      Icons.receipt_long_outlined,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.admin_panel_settings, size: 20),
            const SizedBox(width: 8),
            Text(
              s.adminTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: s.adminBackToStore,
        ),
      ),
      body: isWide ? _buildWideLayout(titles, icons, s) : _buildNarrowLayout(),
      bottomNavigationBar: isWide
          ? null
          : BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
              items: List.generate(
                titles.length,
                (i) => BottomNavigationBarItem(
                  icon: Icon(icons[i]),
                  label: titles[i],
                ),
              ),
            ),
    );
  }

  Widget _buildWideLayout(List<String> titles, List<IconData> icons, S s) {
    return Row(
      children: [
        // Sidebar
        Container(
          width: 240,
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(color: AppTheme.grigioChiaro),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              ...List.generate(titles.length, (i) {
                final selected = _currentIndex == i;
                return Material(
                  color: selected ? AppTheme.nero : Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(() => _currentIndex = i),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            icons[i],
                            size: 20,
                            color: selected ? AppTheme.bianco : AppTheme.nero,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            titles[i],
                            style: TextStyle(
                              color:
                                  selected ? AppTheme.bianco : AppTheme.nero,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const Spacer(),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  s.adminPanelVersion,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 11,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        // Content
        Expanded(child: _pages[_currentIndex]),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return _pages[_currentIndex];
  }
}
