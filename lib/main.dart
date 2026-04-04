import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/provider_scope.dart';
import 'services/api_client.dart';
import 'theme/app_theme.dart';
import 'router.dart';

final appLocale = AppLocale();
final apiClient = ApiClient();
final authProvider = AuthProvider(apiClient);
final cartProvider = CartProvider();
final wishlistProvider = WishlistProvider(apiClient);

void main() {
  // Load wishlist when user logs in, clear when logging out
  authProvider.addListener(() {
    if (authProvider.isLoggedIn) {
      wishlistProvider.load();
    } else {
      wishlistProvider.clear();
    }
  });
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
        child: WishlistProviderScope(
          wishlist: wishlistProvider,
          child: AppLocaleProvider(
            locale: appLocale,
            child: Builder(
              builder: (context) {
                final s = S.of(context);
                return MaterialApp.router(
                  title: s.appTitle,
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.theme,
                  routerConfig: router,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

