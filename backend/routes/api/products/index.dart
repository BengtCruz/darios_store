import 'dart:convert';

import 'package:backend/repositories/product_repository.dart';
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
  final repo = context.read<ProductRepository>();
  final params = context.request.uri.queryParameters;

  final products = await repo.findAll(
    category: params['category'],
    isFeatured: params['featured'] == 'true' ? true : null,
    isActive: params['active'] == 'false' ? false : null,
    orderBy: params['order_by'] ?? 'created_at',
    descending: params['order'] != 'asc',
  );

  return Response.json(
    body: products.map((p) => p.toJson()).toList(),
  );
}

Future<Response> _post(RequestContext context) async {
  final repo = context.read<ProductRepository>();
  final body = jsonDecode(await context.request.body()) as Map<String, dynamic>;

  final name = body['name'] as String?;
  final description = body['description'] as String?;
  final price = (body['price'] as num?)?.toDouble();
  final category = body['category'] as String?;

  if (name == null || description == null || price == null || category == null) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'name, description, price, and category are required'},
    );
  }

  final product = await repo.create(
    name: name,
    description: description,
    price: price,
    imageUrl: body['imageUrl'] as String? ?? '',
    category: category,
    rating: (body['rating'] as num?)?.toDouble() ?? 0,
    isFeatured: body['isFeatured'] as bool? ?? false,
    stock: (body['stock'] as num?)?.toInt() ?? 0,
  );

  return Response.json(statusCode: 201, body: product.toJson());
}
