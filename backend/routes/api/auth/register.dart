import 'dart:convert';
import 'dart:io';

import 'package:backend/repositories/repositories.dart';
import 'package:backend/services/auth_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.post) {
    return _register(context);
  }
  return Response(statusCode: HttpStatus.methodNotAllowed);
}

Future<Response> _register(RequestContext context) async {
  final body = await context.request.body();
  final data = jsonDecode(body) as Map<String, dynamic>;

  final email = (data['email'] as String?)?.trim();
  final name = (data['name'] as String?)?.trim();
  final password = data['password'] as String?;

  if (email == null || email.isEmpty || !email.contains('@')) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'Valid email is required'},
    );
  }
  if (name == null || name.isEmpty) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'Name is required'},
    );
  }
  if (password == null || password.length < 8) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'Password must be at least 8 characters'},
    );
  }

  final userRepo = context.read<UserRepository>();
  final authService = AuthService(userRepo);

  final user = await authService.register(
    email: email,
    name: name,
    password: password,
  );

  if (user == null) {
    return Response.json(
      statusCode: HttpStatus.conflict,
      body: {'error': 'An account with this email already exists'},
    );
  }

  final token = authService.generateToken(user);
  return Response.json(
    statusCode: HttpStatus.created,
    body: {
      'token': token,
      'user': {
        'id': user['id'],
        'email': user['email'],
        'name': user['name'],
        'role': user['role'],
      },
    },
  );
}
