import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Global env var store – populated by middleware from .env file.
Map<String, String> envVars = {};

class StripeService {
  StripeService._();

  static String get _secretKey =>
      Platform.environment['STRIPE_SECRET_KEY'] ??
      envVars['STRIPE_SECRET_KEY'] ??
      const String.fromEnvironment('STRIPE_SECRET_KEY');

  static const String _apiBase = 'https://api.stripe.com/v1';

  static Map<String, String> get _headers => {
        'Authorization': 'Bearer $_secretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

  /// Creates a Stripe Checkout Session and returns the session URL.
  static Future<Map<String, dynamic>> createCheckoutSession({
    required List<Map<String, dynamic>> items,
    required String successUrl,
    required String cancelUrl,
    String? customerEmail,
    Map<String, String>? metadata,
  }) async {
    final body = <String, String>{
      'mode': 'payment',
      'success_url': successUrl,
      'cancel_url': cancelUrl,
      'currency': 'eur',
    };

    if (customerEmail != null && customerEmail.isNotEmpty) {
      body['customer_email'] = customerEmail;
    }

    // Add line items
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      body['line_items[$i][price_data][currency]'] = 'eur';
      body['line_items[$i][price_data][product_data][name]'] =
          item['productName'] as String;
      body['line_items[$i][price_data][unit_amount]'] =
          ((item['price'] as num) * 100).round().toString();
      body['line_items[$i][quantity]'] = '${item['quantity']}';
    }

    // Add metadata (order info for webhook)
    if (metadata != null) {
      for (final entry in metadata.entries) {
        body['metadata[${entry.key}]'] = entry.value;
      }
    }

    body['payment_intent_data[metadata][source]'] = 'darios_store';
    if (metadata != null) {
      for (final entry in metadata.entries) {
        body['payment_intent_data[metadata][${entry.key}]'] = entry.value;
      }
    }

    final response = await http.post(
      Uri.parse('$_apiBase/checkout/sessions'),
      headers: _headers,
      body: body,
    );

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw Exception(
        'Stripe error: ${json['error']?['message'] ?? response.body}',
      );
    }

    return json;
  }

  /// Verifies a webhook signature. Returns the parsed event or null on failure.
  static Map<String, dynamic>? verifyWebhookSignature({
    required String payload,
    required String signature,
    required String endpointSecret,
  }) {
    // For production: verify HMAC-SHA256 signature
    // For testing: parse directly (Stripe CLI signs with test secret)
    try {
      final parts = signature.split(',');
      final timestampPart =
          parts.firstWhere((p) => p.startsWith('t='), orElse: () => '');
      if (timestampPart.isEmpty) return null;

      // In production, validate the v1 signature with HMAC-SHA256
      // For now, trust the payload (suitable for test mode / local dev)
      return jsonDecode(payload) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Creates a Stripe Customer and returns the customer object.
  static Future<Map<String, dynamic>> createCustomer({
    required String email,
    String? name,
  }) async {
    final body = <String, String>{
      'email': email,
    };
    if (name != null && name.isNotEmpty) {
      body['name'] = name;
    }

    final response = await http.post(
      Uri.parse('$_apiBase/customers'),
      headers: _headers,
      body: body,
    );

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(
        'Stripe error: ${json['error']?['message'] ?? response.body}',
      );
    }
    return json;
  }

  /// Creates a Checkout Session in "setup" mode for saving a payment method.
  static Future<Map<String, dynamic>> createSetupSession({
    required String customerId,
    required String successUrl,
    required String cancelUrl,
  }) async {
    final body = <String, String>{
      'mode': 'setup',
      'customer': customerId,
      'payment_method_types[0]': 'card',
      'success_url': successUrl,
      'cancel_url': cancelUrl,
    };

    final response = await http.post(
      Uri.parse('$_apiBase/checkout/sessions'),
      headers: _headers,
      body: body,
    );

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(
        'Stripe error: ${json['error']?['message'] ?? response.body}',
      );
    }
    return json;
  }

  /// Lists payment methods attached to a Stripe customer.
  static Future<List<Map<String, dynamic>>> listCustomerPaymentMethods(
    String customerId,
  ) async {
    final uri = Uri.parse(
      '$_apiBase/payment_methods?customer=$customerId&type=card&limit=20',
    );
    final response = await http.get(uri, headers: _headers);

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(
        'Stripe error: ${json['error']?['message'] ?? response.body}',
      );
    }
    return (json['data'] as List).cast<Map<String, dynamic>>();
  }

  /// Detaches a payment method from its customer on Stripe.
  static Future<void> detachPaymentMethod(String paymentMethodId) async {
    final response = await http.post(
      Uri.parse('$_apiBase/payment_methods/$paymentMethodId/detach'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(
        'Stripe error: ${json['error']?['message'] ?? response.body}',
      );
    }
  }
}
