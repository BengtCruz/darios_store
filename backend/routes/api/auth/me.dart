import 'dart:io';

import 'package:backend/repositories/repositories.dart';
import 'package:backend/services/auth_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.get) {
    return _getMe(context);
  }
  return Response(statusCode: HttpStatus.methodNotAllowed);
}

Future<Response> _getMe(RequestContext context) async {
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
      body: {'error': 'Invalid or expired token'},
    );
  }

  final user = await userRepo.findById(payload['sub'] as String);
  if (user == null || user['isActive'] != true) {
    return Response.json(
      statusCode: HttpStatus.unauthorized,
      body: {'error': 'User not found'},
    );
  }

  return Response.json(
    body: {
      'id': user['id'],
      'email': user['email'],
      'name': user['name'],
      'role': user['role'],
    },
  );
}
