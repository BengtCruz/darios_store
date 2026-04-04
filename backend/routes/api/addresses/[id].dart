import 'dart:convert';
import 'dart:io';

import 'package:backend/repositories/repositories.dart';
import 'package:backend/services/auth_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  switch (context.request.method) {
    case HttpMethod.put:
      return _put(context, id);
    case HttpMethod.delete:
      return _delete(context, id);
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

/// PUT /api/addresses/:id — update an address
Future<Response> _put(RequestContext context, String id) async {
  final payload = _authenticate(context);
  if (payload == null) {
    return Response.json(
      statusCode: HttpStatus.unauthorized,
      body: {'error': 'Authentication required'},
    );
  }

  // Verify ownership
  final repo = context.read<AddressRepository>();
  final existing = await repo.findById(id);
  if (existing == null) {
    return Response.json(
      statusCode: HttpStatus.notFound,
      body: {'error': 'Address not found'},
    );
  }
  if (existing['userId'] != payload['sub']) {
    return Response.json(
      statusCode: HttpStatus.forbidden,
      body: {'error': 'Not your address'},
    );
  }

  final body = jsonDecode(await context.request.body()) as Map<String, dynamic>;
  final updated = await repo.update(
    id,
    label: body['label'] as String?,
    fullName: body['fullName'] as String?,
    street: body['street'] as String?,
    street2: body['street2'] as String?,
    city: body['city'] as String?,
    state: body['state'] as String?,
    postalCode: body['postalCode'] as String?,
    country: body['country'] as String?,
    phone: body['phone'] as String?,
    isDefault: body['isDefault'] as bool?,
  );
  return Response.json(body: updated);
}

/// DELETE /api/addresses/:id — delete an address
Future<Response> _delete(RequestContext context, String id) async {
  final payload = _authenticate(context);
  if (payload == null) {
    return Response.json(
      statusCode: HttpStatus.unauthorized,
      body: {'error': 'Authentication required'},
    );
  }

  final repo = context.read<AddressRepository>();
  final existing = await repo.findById(id);
  if (existing == null) {
    return Response.json(
      statusCode: HttpStatus.notFound,
      body: {'error': 'Address not found'},
    );
  }
  if (existing['userId'] != payload['sub']) {
    return Response.json(
      statusCode: HttpStatus.forbidden,
      body: {'error': 'Not your address'},
    );
  }

  await repo.delete(id);
  return Response.json(body: {'success': true});
}
