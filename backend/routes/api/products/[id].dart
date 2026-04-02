import 'dart:convert';

import 'package:backend/repositories/product_repository.dart';
import 'package:dart_frog/dart_frog.dart';

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
  final repo = context.read<ProductRepository>();
  final product = await repo.findById(id);
  if (product == null) {
    return Response.json(statusCode: 404, body: {'error': 'Product not found'});
  }
  return Response.json(body: product.toJson());
}

Future<Response> _put(RequestContext context, String id) async {
  final repo = context.read<ProductRepository>();
  final body = jsonDecode(await context.request.body()) as Map<String, dynamic>;

  final product = await repo.update(
    id,
    name: body['name'] as String?,
    description: body['description'] as String?,
    price: (body['price'] as num?)?.toDouble(),
    imageUrl: body['imageUrl'] as String?,
    category: body['category'] as String?,
    rating: (body['rating'] as num?)?.toDouble(),
    isFeatured: body['isFeatured'] as bool?,
    isActive: body['isActive'] as bool?,
  );

  if (product == null) {
    return Response.json(statusCode: 404, body: {'error': 'Product not found'});
  }
  return Response.json(body: product.toJson());
}

Future<Response> _delete(RequestContext context, String id) async {
  final repo = context.read<ProductRepository>();
  final deleted = await repo.delete(id);
  if (!deleted) {
    return Response.json(statusCode: 404, body: {'error': 'Product not found'});
  }
  return Response.json(body: {'deleted': true});
}
