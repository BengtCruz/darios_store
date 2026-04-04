import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String _baseUrl = 'http://localhost:8081';

  final http.Client _client;
  String? _token;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  void setToken(String? token) => _token = token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // Auth
  Future<Map<String, dynamic>> register({
    required String email,
    required String name,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/auth/register'),
      headers: _headers,
      body: jsonEncode({'email': email, 'name': name, 'password': password}),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/auth/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMe() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/api/auth/me'),
      headers: _headers,
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // Products
  Future<List<Map<String, dynamic>>> getProducts({
    String? category,
    bool? featured,
  }) async {
    final params = <String, String>{};
    if (category != null) params['category'] = category;
    if (featured == true) params['featured'] = 'true';

    final uri = Uri.parse('$_baseUrl/api/products').replace(queryParameters: params.isNotEmpty ? params : null);
    final response = await _client.get(uri, headers: _headers);
    return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getProduct(String id) async {
    final response = await _client.get(Uri.parse('$_baseUrl/api/products/$id'), headers: _headers);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/products'),
      headers: _headers,
      body: jsonEncode(data),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProduct(String id, Map<String, dynamic> data) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/api/products/$id'),
      headers: _headers,
      body: jsonEncode(data),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> deleteProduct(String id) async {
    await _client.delete(Uri.parse('$_baseUrl/api/products/$id'), headers: _headers);
  }

  // Categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await _client.get(Uri.parse('$_baseUrl/api/categories'), headers: _headers);
    return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> createCategory(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/categories'),
      headers: _headers,
      body: jsonEncode(data),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateCategory(String id, Map<String, dynamic> data) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/api/categories/$id'),
      headers: _headers,
      body: jsonEncode(data),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> deleteCategory(String id) async {
    await _client.delete(Uri.parse('$_baseUrl/api/categories/$id'), headers: _headers);
  }

  // Orders
  Future<List<Map<String, dynamic>>> getOrders({String? status, String? email}) async {
    final params = <String, String>{};
    if (status != null) params['status'] = status;
    if (email != null) params['email'] = email;

    final uri = Uri.parse('$_baseUrl/api/orders').replace(queryParameters: params.isNotEmpty ? params : null);
    final response = await _client.get(uri, headers: _headers);
    return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> updateOrderStatus(String id, String status) async {
    final response = await _client.patch(
      Uri.parse('$_baseUrl/api/orders/$id'),
      headers: _headers,
      body: jsonEncode({'status': status}),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> deleteOrder(String id) async {
    await _client.delete(Uri.parse('$_baseUrl/api/orders/$id'), headers: _headers);
  }

  // Orders
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/orders'),
      headers: _headers,
      body: jsonEncode(data),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // Stripe Checkout
  Future<Map<String, dynamic>> createCheckoutSession(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/checkout'),
      headers: _headers,
      body: jsonEncode(data),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // Dashboard
  Future<Map<String, dynamic>> getDashboard() async {
    final response = await _client.get(Uri.parse('$_baseUrl/api/admin/dashboard'), headers: _headers);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // Wishlist
  Future<List<Map<String, dynamic>>> getWishlist() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/api/wishlist'),
      headers: _headers,
    );
    return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
  }

  Future<List<String>> getWishlistIds() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/api/wishlist/ids'),
      headers: _headers,
    );
    return (jsonDecode(response.body) as List).cast<String>();
  }

  Future<void> addToWishlist(String productId) async {
    await _client.post(
      Uri.parse('$_baseUrl/api/wishlist'),
      headers: _headers,
      body: jsonEncode({'productId': productId}),
    );
  }

  Future<void> removeFromWishlist(String productId) async {
    await _client.delete(
      Uri.parse('$_baseUrl/api/wishlist'),
      headers: _headers,
      body: jsonEncode({'productId': productId}),
    );
  }

  void dispose() {
    _client.close();
  }
}
