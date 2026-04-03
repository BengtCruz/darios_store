import 'dart:convert';

import 'package:backend/models/order.dart';
import 'package:backend/repositories/order_repository.dart';
import 'package:backend/services/stripe_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final body =
      jsonDecode(await context.request.body()) as Map<String, dynamic>;

  final items = (body['items'] as List?)
      ?.map((i) => i as Map<String, dynamic>)
      .toList();

  if (items == null || items.isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'items are required'},
    );
  }

  final customerName = body['customerName'] as String? ?? '';
  final customerEmail = body['customerEmail'] as String? ?? '';

  // Create order in DB with status 'pending'
  final repo = context.read<OrderRepository>();
  final orderItems =
      items.map((i) => OrderItem.fromJson(i)).toList();
  final totalAmount = orderItems.fold<double>(
    0,
    (sum, item) => sum + item.price * item.quantity,
  );

  final order = await repo.create(
    customerName: customerName,
    customerEmail: customerEmail,
    totalAmount: totalAmount,
    items: orderItems,
  );

  // Determine the frontend origin for redirect URLs
  final origin = context.request.headers['origin'] ?? 'http://localhost:8082';

  try {
    final session = await StripeService.createCheckoutSession(
      items: items,
      customerEmail: customerEmail.isNotEmpty ? customerEmail : null,
      successUrl: '$origin/#/checkout/success?order_id=${order.id}',
      cancelUrl: '$origin/#/checkout/cancel?order_id=${order.id}',
      metadata: {
        'order_id': order.id,
        'customer_name': customerName,
      },
    );

    return Response.json(body: {
      'sessionId': session['id'],
      'url': session['url'],
      'orderId': order.id,
    });
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Failed to create checkout session: $e'},
    );
  }
}
