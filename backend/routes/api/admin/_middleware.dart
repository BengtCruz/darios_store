import 'dart:io';

import 'package:backend/repositories/repositories.dart';
import 'package:backend/services/auth_service.dart';
import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  return (context) async {
    // Allow OPTIONS for CORS preflight
    if (context.request.method == HttpMethod.options) {
      return handler(context);
    }

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

    if (payload['role'] != 'admin') {
      return Response.json(
        statusCode: HttpStatus.forbidden,
        body: {'error': 'Admin access required'},
      );
    }

    return handler(context);
  };
}
