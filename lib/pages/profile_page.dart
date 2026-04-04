import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../providers/provider_scope.dart';
import '../theme/app_theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthProviderScope.of(context);

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
            child: Center(
              child: auth.isLoggedIn
                  ? Text(
                      auth.userName.isNotEmpty
                          ? auth.userName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.nero,
                      ),
                    )
                  : const Icon(Icons.person_outline, size: 48, color: AppTheme.nero),
            ),
          ),
          const SizedBox(height: 16),

          if (auth.isLoggedIn) ...[
            Text(
              auth.userName,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              auth.userEmail,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => auth.logout(),
                child: Text(S.of(context).authLogout),
              ),
            ),
          ] else ...[
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
                onPressed: () {
                  context.push('/login');
                },
                child: Text(S.of(context).profileSignIn),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  context.push('/register');
                },
                child: Text(S.of(context).profileCreateAccount),
              ),
            ),
          ],

          const Divider(height: 48),

          // Language switcher
          _buildLanguageSwitcher(context),

          if (auth.isLoggedIn) ...[
          const Divider(height: 32),

          // Menu items
          _buildMenuItem(context, Icons.shopping_bag_outlined, S.of(context).profileMyOrders, onTap: () => context.push('/my-orders')),
          _buildMenuItem(context, Icons.favorite_outline, S.of(context).profileWishlist, onTap: () => context.push('/wishlist')),
          _buildMenuItem(context, Icons.location_on_outlined, S.of(context).profileAddresses, onTap: () => context.push('/addresses')),
          _buildMenuItem(context, Icons.payment_outlined, S.of(context).profilePaymentMethods, onTap: () => context.push('/payment-methods')),
          ],

          const Divider(height: 32),

          // Admin panel link (only for admins)
          if (auth.isAdmin) ...[
          InkWell(
            onTap: () {
              context.push('/admin');
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
          ],
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

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
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
