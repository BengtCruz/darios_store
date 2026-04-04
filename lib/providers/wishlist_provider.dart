import 'package:flutter/material.dart';
import '../services/api_client.dart';

class WishlistProvider extends ChangeNotifier {
  final ApiClient _api;

  WishlistProvider(this._api);

  final Set<String> _wishlistIds = {};
  bool _loaded = false;

  Set<String> get wishlistIds => _wishlistIds;
  bool get loaded => _loaded;

  bool isWishlisted(String productId) => _wishlistIds.contains(productId);

  Future<void> load() async {
    try {
      final ids = await _api.getWishlistIds();
      _wishlistIds
        ..clear()
        ..addAll(ids);
      _loaded = true;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> toggle(String productId) async {
    if (_wishlistIds.contains(productId)) {
      _wishlistIds.remove(productId);
      notifyListeners();
      try {
        await _api.removeFromWishlist(productId);
      } catch (_) {
        _wishlistIds.add(productId);
        notifyListeners();
      }
    } else {
      _wishlistIds.add(productId);
      notifyListeners();
      try {
        await _api.addToWishlist(productId);
      } catch (_) {
        _wishlistIds.remove(productId);
        notifyListeners();
      }
    }
  }

  void clear() {
    _wishlistIds.clear();
    _loaded = false;
    notifyListeners();
  }
}
