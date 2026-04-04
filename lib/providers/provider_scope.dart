import 'package:flutter/material.dart';
import 'auth_provider.dart';
import 'cart_provider.dart';
import 'wishlist_provider.dart';

class CartProviderScope extends InheritedNotifier<CartProvider> {
  const CartProviderScope({
    super.key,
    required CartProvider cart,
    required super.child,
  }) : super(notifier: cart);

  static CartProvider of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<CartProviderScope>()!
        .notifier!;
  }
}

class AuthProviderScope extends InheritedNotifier<AuthProvider> {
  const AuthProviderScope({
    super.key,
    required AuthProvider auth,
    required super.child,
  }) : super(notifier: auth);

  static AuthProvider of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AuthProviderScope>()!
        .notifier!;
  }
}

class WishlistProviderScope extends InheritedNotifier<WishlistProvider> {
  const WishlistProviderScope({
    super.key,
    required WishlistProvider wishlist,
    required super.child,
  }) : super(notifier: wishlist);

  static WishlistProvider of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<WishlistProviderScope>()!
        .notifier!;
  }
}
