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

/// GET /api/addresses — list user's addresses
Future<Response> _get(RequestContext context) async {
  final payload = _authenticate(context);
  if (payload == null) {
    return Response.json(
      statusCode: HttpStatus.unauthorized,
      body: {'error': 'Authentication required'},
    );
  }

  final userId = payload['sub'] as String;
  final repo = context.read<AddressRepository>();
  final addresses = await repo.findByUser(userId);
  return Response.json(body: addresses);
}

/// POST /api/addresses — create a new address
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

  final fullName = body['fullName'] as String?;
  final street = body['street'] as String?;
  final city = body['city'] as String?;
  final postalCode = body['postalCode'] as String?;

  if (fullName == null || street == null || city == null || postalCode == null) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'fullName, street, city, and postalCode are required'},
    );
  }

  final repo = context.read<AddressRepository>();
  final address = await repo.create(
    userId: userId,
    label: body['label'] as String? ?? 'Home',
    fullName: fullName,
    street: street,
    street2: body['street2'] as String?,
    city: city,
    state: body['state'] as String?,
    postalCode: postalCode,
    country: body['country'] as String? ?? 'Sweden',
    phone: body['phone'] as String?,
    isDefault: body['isDefault'] as bool? ?? false,
  );
  return Response.json(statusCode: HttpStatus.created, body: address);
}
