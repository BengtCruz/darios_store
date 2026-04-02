import 'dart:convert';
import 'dart:io';

import 'package:backend/repositories/repositories.dart';
import 'package:backend/services/auth_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.post) {
    return _login(context);
  }
  return Response(statusCode: HttpStatus.methodNotAllowed);
}

Future<Response> _login(RequestContext context) async {
  final body = await context.request.body();
  final data = jsonDecode(body) as Map<String, dynamic>;

  final email = (data['email'] as String?)?.trim();
  final password = data['password'] as String?;

  if (email == null || email.isEmpty) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'Email is required'},
    );
  }
  if (password == null || password.isEmpty) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'Password is required'},
    );
  }

  final userRepo = context.read<UserRepository>();
  final authService = AuthService(userRepo);

  final user = await authService.login(email: email, password: password);

  if (user == null) {
    return Response.json(
      statusCode: HttpStatus.unauthorized,
      body: {'error': 'Invalid email or password'},
    );
  }

  final token = authService.generateToken(user);
  return Response.json(
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
