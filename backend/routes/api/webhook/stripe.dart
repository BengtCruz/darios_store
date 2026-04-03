import 'dart:io';

import 'package:backend/repositories/order_repository.dart';
import 'package:backend/services/stripe_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final payload = await context.request.body();
  final signature =
      context.request.headers['stripe-signature'] ?? '';
  final endpointSecret =
      Platform.environment['STRIPE_WEBHOOK_SECRET'] ??
          envVars['STRIPE_WEBHOOK_SECRET'] ??
          '';

  final event = StripeService.verifyWebhookSignature(
    payload: payload,
    signature: signature,
    endpointSecret: endpointSecret,
  );

  if (event == null) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid signature'},
    );
  }

  final type = event['type'] as String?;
  stdout.writeln('Stripe webhook: $type');

  if (type == 'checkout.session.completed') {
    final session = event['data']?['object'] as Map<String, dynamic>?;
    final orderId = session?['metadata']?['order_id'] as String?;
    final paymentStatus = session?['payment_status'] as String?;

    if (orderId != null && paymentStatus == 'paid') {
      final repo = context.read<OrderRepository>();
      await repo.updateStatus(orderId, 'confirmed');
      stdout.writeln('Order $orderId confirmed via Stripe');
    }
  }

  return Response.json(body: {'received': true});
}
