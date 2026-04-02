import 'package:flutter/material.dart';
import '../services/api_client.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _api;

  String? _token;
  Map<String, dynamic>? _user;
  bool _loading = false;

  AuthProvider(this._api);

  bool get isLoggedIn => _token != null && _user != null;
  bool get isLoading => _loading;
  Map<String, dynamic>? get user => _user;
  String? get token => _token;
  String get userName => _user?['name'] as String? ?? '';
  String get userEmail => _user?['email'] as String? ?? '';
  String get userRole => _user?['role'] as String? ?? 'customer';
  bool get isAdmin => userRole == 'admin';

  void setAuth(String token, Map<String, dynamic> user) {
    _token = token;
    _user = user;
    _api.setToken(token);
    notifyListeners();
  }

  Future<String?> register({
    required String email,
    required String name,
    required String password,
  }) async {
    _loading = true;
    notifyListeners();
    try {
      final result = await _api.register(
        email: email,
        name: name,
        password: password,
      );
      if (result.containsKey('error')) {
        return result['error'] as String;
      }
      setAuth(
        result['token'] as String,
        result['user'] as Map<String, dynamic>,
      );
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    _loading = true;
    notifyListeners();
    try {
      final result = await _api.login(
        email: email,
        password: password,
      );
      if (result.containsKey('error')) {
        return result['error'] as String;
      }
      setAuth(
        result['token'] as String,
        result['user'] as Map<String, dynamic>,
      );
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refreshUser() async {
    if (_token == null) return;
    try {
      final user = await _api.getMe();
      if (user.containsKey('error')) {
        logout();
        return;
      }
      _user = user;
      notifyListeners();
    } catch (_) {
      logout();
    }
  }

  void logout() {
    _token = null;
    _user = null;
    _api.setToken(null);
    notifyListeners();
  }
}
