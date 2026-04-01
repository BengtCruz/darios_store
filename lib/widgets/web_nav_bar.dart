import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
                        Text(
                          "DARIO'S STORE",
                          style: GoogleFonts.playfairDisplay(
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
                const SizedBox(width: 48),

                // Nav links
                _NavLink(
                  label: 'HOME',
                  isActive: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
                _NavLink(
                  label: 'CATALOGO',
                  isActive: currentIndex == 1,
                  onTap: () => onTap(1),
                ),

                const Spacer(),

                // Right side actions
                _NavIconButton(
                  icon: Icons.search,
                  isActive: currentIndex == 2,
                  onTap: () => onTap(2),
                  tooltip: 'Cerca',
                ),
                const SizedBox(width: 8),
                _NavIconButton(
                  icon: Icons.shopping_bag_outlined,
                  isActive: currentIndex == 3,
                  onTap: () => onTap(3),
                  tooltip: 'Carrello',
                ),
                const SizedBox(width: 8),
                _NavIconButton(
                  icon: Icons.person_outline,
                  isActive: currentIndex == 4,
                  onTap: () => onTap(4),
                  tooltip: 'Profilo',
                ),
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
              style: GoogleFonts.lato(
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
