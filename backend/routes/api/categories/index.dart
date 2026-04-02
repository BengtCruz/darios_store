import 'dart:convert';

import 'package:backend/repositories/category_repository.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return _get(context);
    case HttpMethod.post:
      return _post(context);
    case HttpMethod.options:
      return Response();
    default:
      return Response(statusCode: 405);
  }
}

Future<Response> _get(RequestContext context) async {
  final repo = context.read<CategoryRepository>();
  final params = context.request.uri.queryParameters;
  final isActive = params['active'] == 'false' ? false : null;
  final categories = await repo.findAll(isActive: isActive);
  return Response.json(body: categories.map((c) => c.toJson()).toList());
}

Future<Response> _post(RequestContext context) async {
  final repo = context.read<CategoryRepository>();
  final body = jsonDecode(await context.request.body()) as Map<String, dynamic>;

  final name = body['name'] as String?;
  if (name == null || name.isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'name is required'},
    );
  }

  final category = await repo.create(
    name: name,
    description: body['description'] as String?,
    sortOrder: body['sortOrder'] as int? ?? 0,
  );

  return Response.json(statusCode: 201, body: category.toJson());
}
