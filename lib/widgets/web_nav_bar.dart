import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../providers/provider_scope.dart';
import '../theme/app_theme.dart';

class WebNavBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const WebNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 900;

    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: AppTheme.bianco,
        border: Border(
          bottom: BorderSide(color: AppTheme.grigioChiaro, width: 1),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              children: [
                // Logo / Brand
                GestureDetector(
                  onTap: () => onTap(0),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Row(
                      children: [
                        const Icon(Icons.storefront, size: 24, color: AppTheme.nero),
                        const SizedBox(width: 12),
                        if (!compact)
                          Text(
                            "DARIO'S STORE",
                            style: TextStyle(
                              fontFamily: 'Playfair Display',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.nero,
                              letterSpacing: 2,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                if (!compact) ...[
                  const SizedBox(width: 48),
                  // Nav links (full-size)
                  _NavLink(
                    label: S.of(context).navHome.toUpperCase(),
                    isActive: currentIndex == 0,
                    onTap: () => onTap(0),
                  ),
                  _NavLink(
                    label: S.of(context).navCatalog,
                    isActive: currentIndex == 1,
                    onTap: () => onTap(1),
                  ),
                  _NavLink(
                    label: S.of(context).navSupport,
                    isActive: GoRouterState.of(context).uri.path == '/support',
                    onTap: () => context.push('/support'),
                  ),
                  _NavLink(
                    label: S.of(context).navAbout,
                    isActive: GoRouterState.of(context).uri.path == '/about',
                    onTap: () => context.push('/about'),
                  ),
                ],

                const Spacer(),

                // Right side actions
                _NavIconButton(
                  icon: Icons.search,
                  isActive: currentIndex == 2,
                  onTap: () => onTap(2),
                  tooltip: S.of(context).navSearchLabel,
                ),
                const SizedBox(width: 8),
                _CartNavIcon(
                  isActive: currentIndex == 3,
                  onTap: () => onTap(3),
                  tooltip: S.of(context).navCartLabel,
                ),
                const SizedBox(width: 8),
                _NavIconButton(
                  icon: Icons.person_outline,
                  isActive: currentIndex == 4,
                  onTap: () => onTap(4),
                  tooltip: S.of(context).navProfileLabel,
                ),

                // Hamburger menu (compact mode)
                if (compact) ...[
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.menu, color: AppTheme.nero),
                    tooltip: 'Menu',
                    offset: const Offset(0, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    color: AppTheme.bianco,
                    onSelected: (value) {
                      switch (value) {
                        case 'home':
                          onTap(0);
                        case 'catalog':
                          onTap(1);
                        case 'support':
                          context.push('/support');
                        case 'about':
                          context.push('/about');
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'home',
                        child: Text(S.of(context).navHome),
                      ),
                      PopupMenuItem(
                        value: 'catalog',
                        child: Text(S.of(context).navCatalog),
                      ),
                      PopupMenuItem(
                        value: 'support',
                        child: Text(S.of(context).profileSupport),
                      ),
                      PopupMenuItem(
                        value: 'about',
                        child: Text(S.of(context).profileAbout),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavLink({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: widget.isActive || _hovering
                      ? AppTheme.nero
                      : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 13,
                fontWeight:
                    widget.isActive ? FontWeight.w700 : FontWeight.w500,
                color: AppTheme.nero,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIconButton extends StatefulWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final String tooltip;

  const _NavIconButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.tooltip,
  });

  @override
  State<_NavIconButton> createState() => _NavIconButtonState();
}

class _NavIconButtonState extends State<_NavIconButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _hovering
                  ? AppTheme.grigioChiaro.withValues(alpha: 0.5)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.icon,
              size: 22,
              color: widget.isActive ? AppTheme.nero : AppTheme.grigio,
            ),
          ),
        ),
      ),
    );
  }
}

class _CartNavIcon extends StatefulWidget {
  final bool isActive;
  final VoidCallback onTap;
  final String tooltip;

  const _CartNavIcon({
    required this.isActive,
    required this.onTap,
    required this.tooltip,
  });

  @override
  State<_CartNavIcon> createState() => _CartNavIconState();
}

class _CartNavIconState extends State<_CartNavIcon> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final count = CartProviderScope.of(context).itemCount;
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _hovering
                    ? AppTheme.grigioChiaro.withValues(alpha: 0.5)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Badge(
                  isLabelVisible: count > 0,
                  offset: const Offset(10, -6),
                  label: Text('$count'),
                  backgroundColor: AppTheme.nero,
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    size: 22,
                    color: widget.isActive ? AppTheme.nero : AppTheme.grigio,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
