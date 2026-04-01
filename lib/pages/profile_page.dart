import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'admin/admin_shell.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
        children: [
          const SizedBox(height: 20),
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.nero, width: 2),
            ),
            child: const Center(
              child: Icon(Icons.person_outline, size: 48, color: AppTheme.nero),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            S.of(context).profileWelcome,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            S.of(context).profileSubtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // Sign in button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              child: Text(S.of(context).profileSignIn),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              child: Text(S.of(context).profileCreateAccount),
            ),
          ),

          const Divider(height: 48),

          // Language switcher
          _buildLanguageSwitcher(context),

          const Divider(height: 32),

          // Menu items
          _buildMenuItem(context, Icons.shopping_bag_outlined, S.of(context).profileMyOrders),
          _buildMenuItem(context, Icons.favorite_outline, S.of(context).profileWishlist),
          _buildMenuItem(context, Icons.location_on_outlined, S.of(context).profileAddresses),
          _buildMenuItem(context, Icons.payment_outlined, S.of(context).profilePaymentMethods),
          _buildMenuItem(context, Icons.notifications_outlined, S.of(context).profileNotifications),
          _buildMenuItem(context, Icons.help_outline, S.of(context).profileSupport),
          _buildMenuItem(context, Icons.info_outline, S.of(context).profileAbout),

          const Divider(height: 32),

          // Admin panel link
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminShell()),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.nero),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.admin_panel_settings, size: 20, color: AppTheme.nero),
                  const SizedBox(width: 8),
                  Text(
                    S.of(context).profileAdmin,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 32),

          // App info
          Text(
            S.of(context).profileVersion,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 11,
                  letterSpacing: 2,
                ),
          ),
          const SizedBox(height: 20),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppTheme.nero),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.grigio),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSwitcher(BuildContext context) {
    final locale = AppLocaleProvider.of(context);
    final s = S.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.language, size: 22, color: AppTheme.nero),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              s.profileLanguage,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SegmentedButton<AppLanguage>(
            segments: const [
              ButtonSegment(value: AppLanguage.en, label: Text('EN')),
              ButtonSegment(value: AppLanguage.sv, label: Text('SV')),
            ],
            selected: {locale.language},
            onSelectionChanged: (sel) => locale.setLanguage(sel.first),
            style: ButtonStyle(
              shape: WidgetStateProperty.all(
                const RoundedRectangleBorder(),
              ),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }
}
