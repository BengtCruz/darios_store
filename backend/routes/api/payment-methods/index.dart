import 'dart:io';

import 'package:backend/repositories/repositories.dart';
import 'package:backend/services/auth_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return _get(context);
    default:
      return Response.json(
        statusCode: HttpStatus.methodNotAllowed,
        body: {'error': 'Method not allowed'},
      );
  }
}

Map<String, dynamic>? _authenticate(RequestContext context) {
  final authHeader = context.request.headers['Authorization'];
  if (authHeader == null || !authHeader.startsWith('Bearer ')) return null;
  final token = authHeader.substring(7);
  final userRepo = context.read<UserRepository>();
  final authService = AuthService(userRepo);
  return authService.verifyToken(token);
}

/// GET /api/payment-methods — list user's payment methods
Future<Response> _get(RequestContext context) async {
  final payload = _authenticate(context);
  if (payload == null) {
    return Response.json(
      statusCode: HttpStatus.unauthorized,
      body: {'error': 'Authentication required'},
    );
  }

  final userId = payload['sub'] as String;
  final repo = context.read<PaymentMethodRepository>();
  final methods = await repo.findByUser(userId);
  return Response.json(body: methods);
}
