import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';

import 'package:backend/repositories/category_repository.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return _get(context, id);
    case HttpMethod.put:
      return _put(context, id);
    case HttpMethod.delete:
      return _delete(context, id);
    case HttpMethod.options:
      return Response();
    default:
      return Response(statusCode: 405);
  }
}

Future<Response> _get(RequestContext context, String id) async {
  final repo = context.read<CategoryRepository>();
  final category = await repo.findById(id);
  if (category == null) {
    return Response.json(statusCode: 404, body: {'error': 'Category not found'});
  }
  return Response.json(body: category.toJson());
}

Future<Response> _put(RequestContext context, String id) async {
  final repo = context.read<CategoryRepository>();
  final body = jsonDecode(await context.request.body()) as Map<String, dynamic>;

  final category = await repo.update(
    id,
    name: body['name'] as String?,
    description: body['description'] as String?,
    sortOrder: body['sortOrder'] as int?,
    isActive: body['isActive'] as bool?,
  );

  if (category == null) {
    return Response.json(statusCode: 404, body: {'error': 'Category not found'});
  }
  return Response.json(body: category.toJson());
}

Future<Response> _delete(RequestContext context, String id) async {
  final repo = context.read<CategoryRepository>();
  final deleted = await repo.delete(id);
  if (!deleted) {
    return Response.json(statusCode: 404, body: {'error': 'Category not found'});
  }
  return Response.json(body: {'deleted': true});
}
