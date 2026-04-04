import 'dart:io';

import 'package:backend/repositories/repositories.dart';
import 'package:backend/services/auth_service.dart';
import 'package:backend/services/stripe_service.dart';
import 'package:dart_frog/dart_frog.dart';

/// POST /api/payment-methods/sync — sync payment methods from Stripe
/// to the local database. Call this after user returns from Stripe setup.
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

  try {
    final stripeCustomerId = await userRepo.getStripeCustomerId(userId);
    if (stripeCustomerId == null) {
      return Response.json(body: <Map<String, dynamic>>[]);
    }

    // Fetch all cards from Stripe
    final stripeMethods =
        await StripeService.listCustomerPaymentMethods(stripeCustomerId);

    final repo = context.read<PaymentMethodRepository>();

    // Get existing Stripe IDs in our DB to preserve labels and defaults
    final existingIds = await repo.findStripeIdsByUser(userId);
    final isFirst = existingIds.isEmpty && stripeMethods.isNotEmpty;

    for (final sm in stripeMethods) {
      final stripeId = sm['id'] as String;
      final card = sm['card'] as Map<String, dynamic>;
      final brand = (card['brand'] as String?)?.capitalize() ?? 'Card';
      final last4 = card['last4'] as String? ?? '0000';
      final expMonth = card['exp_month'] as int? ?? 1;
      final expYear = card['exp_year'] as int? ?? 2030;

      // Upsert: create creates or updates on conflict
      await repo.create(
        userId: userId,
        stripePaymentMethodId: stripeId,
        label: 'My Card',
        cardBrand: brand,
        lastFour: last4,
        expiryMonth: expMonth,
        expiryYear: expYear,
        isDefault: isFirst && sm == stripeMethods.first,
      );
    }

    // Return updated list
    final methods = await repo.findByUser(userId);
    return Response.json(body: methods);
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to sync payment methods: $e'},
    );
  }
}

extension _StringExt on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
