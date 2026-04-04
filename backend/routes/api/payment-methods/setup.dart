import 'dart:io';

import 'package:backend/repositories/repositories.dart';
import 'package:backend/services/auth_service.dart';
import 'package:backend/services/stripe_service.dart';
import 'package:dart_frog/dart_frog.dart';

/// POST /api/payment-methods/setup — create a Stripe Checkout Session
/// in "setup" mode so the user can securely add a card.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {'error': 'Method not allowed'},
    );
  }

  // Authenticate
  final authHeader = context.request.headers['Authorization'];
  if (authHeader == null || !authHeader.startsWith('Bearer ')) {
    return Response.json(
      statusCode: HttpStatus.unauthorized,
      body: {'error': 'Authentication required'},
    );
  }
  final token = authHeader.substring(7);
  final userRepo = context.read<UserRepository>();
  final authService = AuthService(userRepo);
  final payload = authService.verifyToken(token);
  if (payload == null) {
    return Response.json(
      statusCode: HttpStatus.unauthorized,
      body: {'error': 'Invalid token'},
    );
  }

  final userId = payload['sub'] as String;
  final userEmail = payload['email'] as String;

  try {
    // Get or create Stripe customer
    var stripeCustomerId = await userRepo.getStripeCustomerId(userId);
    if (stripeCustomerId == null) {
      final user = await userRepo.findById(userId);
      final customer = await StripeService.createCustomer(
        email: userEmail,
        name: user?['name'] as String?,
      );
      stripeCustomerId = customer['id'] as String;
      await userRepo.setStripeCustomerId(userId, stripeCustomerId);
    }

    // Determine frontend origin for redirect
    final origin =
        context.request.headers['origin'] ?? 'http://localhost:8082';

    final session = await StripeService.createSetupSession(
      customerId: stripeCustomerId,
      successUrl: '$origin/#/payment-methods?setup=success',
      cancelUrl: '$origin/#/payment-methods?setup=cancel',
    );

    return Response.json(body: {
      'url': session['url'],
      'sessionId': session['id'],
    });
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to create setup session: $e'},
    );
  }
}
