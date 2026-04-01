import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String _baseUrl = 'http://localhost:8080';

  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  // Products
  Future<List<Map<String, dynamic>>> getProducts({
    String? category,
    bool? featured,
  }) async {
    final params = <String, String>{};
    if (category != null) params['category'] = category;
    if (featured == true) params['featured'] = 'true';

    final uri = Uri.parse('$_baseUrl/api/products').replace(queryParameters: params.isNotEmpty ? params : null);
    final response = await _client.get(uri);
    return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getProduct(String id) async {
    final response = await _client.get(Uri.parse('$_baseUrl/api/products/$id'));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/products'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProduct(String id, Map<String, dynamic> data) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/api/products/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> deleteProduct(String id) async {
    await _client.delete(Uri.parse('$_baseUrl/api/products/$id'));
  }

  // Categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await _client.get(Uri.parse('$_baseUrl/api/categories'));
    return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> createCategory(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/categories'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateCategory(String id, Map<String, dynamic> data) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/api/categories/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> deleteCategory(String id) async {
    await _client.delete(Uri.parse('$_baseUrl/api/categories/$id'));
  }

  // Orders
  Future<List<Map<String, dynamic>>> getOrders({String? status}) async {
    final params = <String, String>{};
    if (status != null) params['status'] = status;

    final uri = Uri.parse('$_baseUrl/api/orders').replace(queryParameters: params.isNotEmpty ? params : null);
    final response = await _client.get(uri);
    return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> updateOrderStatus(String id, String status) async {
    final response = await _client.patch(
      Uri.parse('$_baseUrl/api/orders/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> deleteOrder(String id) async {
    await _client.delete(Uri.parse('$_baseUrl/api/orders/$id'));
  }

  // Dashboard
  Future<Map<String, dynamic>> getDashboard() async {
    final response = await _client.get(Uri.parse('$_baseUrl/api/admin/dashboard'));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  void dispose() {
    _client.close();
  }
}
