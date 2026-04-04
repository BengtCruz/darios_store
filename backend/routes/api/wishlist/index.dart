import 'dart:convert';
import 'dart:io';

import 'package:backend/repositories/repositories.dart';
import 'package:backend/services/auth_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return _get(context);
    case HttpMethod.post:
      return _post(context);
    case HttpMethod.delete:
      return _delete(context);
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

/// GET /api/wishlist — returns the user's wishlisted products
Future<Response> _get(RequestContext context) async {
  final payload = _authenticate(context);
  if (payload == null) {
    return Response.json(
      statusCode: HttpStatus.unauthorized,
      body: {'error': 'Authentication required'},
    );
  }

  final userId = payload['sub'] as String;
  final repo = context.read<WishlistRepository>();
  final products = await repo.findByUser(userId);
  return Response.json(body: products);
}

/// POST /api/wishlist — add a product to wishlist
/// Body: { "productId": "..." }
Future<Response> _post(RequestContext context) async {
  final payload = _authenticate(context);
  if (payload == null) {
    return Response.json(
      statusCode: HttpStatus.unauthorized,
      body: {'error': 'Authentication required'},
    );
  }

  final userId = payload['sub'] as String;
  final body = jsonDecode(await context.request.body()) as Map<String, dynamic>;
  final productId = body['productId'] as String?;
  if (productId == null || productId.isEmpty) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'productId is required'},
    );
  }

  final repo = context.read<WishlistRepository>();
  await repo.add(userId, productId);
  return Response.json(body: {'success': true});
}

/// DELETE /api/wishlist — remove a product from wishlist
/// Body: { "productId": "..." }
Future<Response> _delete(RequestContext context) async {
  final payload = _authenticate(context);
  if (payload == null) {
    return Response.json(
      statusCode: HttpStatus.unauthorized,
      body: {'error': 'Authentication required'},
    );
  }

  final userId = payload['sub'] as String;
  final body = jsonDecode(await context.request.body()) as Map<String, dynamic>;
  final productId = body['productId'] as String?;
  if (productId == null || productId.isEmpty) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'productId is required'},
    );
  }

  final repo = context.read<WishlistRepository>();
  await repo.remove(userId, productId);
  return Response.json(body: {'success': true});
}
