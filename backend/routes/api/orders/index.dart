import 'dart:convert';

import 'package:backend/models/order.dart';
import 'package:backend/repositories/order_repository.dart';
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
  final repo = context.read<OrderRepository>();
  final params = context.request.uri.queryParameters;
  final orders = await repo.findAll(
    status: params['status'],
    email: params['email'],
  );
  return Response.json(body: orders.map((o) => o.toJson()).toList());
}

Future<Response> _post(RequestContext context) async {
  final repo = context.read<OrderRepository>();
  final body = jsonDecode(await context.request.body()) as Map<String, dynamic>;

  final items = (body['items'] as List?)
      ?.map((i) => OrderItem.fromJson(i as Map<String, dynamic>))
      .toList();

  if (items == null || items.isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'items are required'},
    );
  }

  final totalAmount = (body['totalAmount'] as num?)?.toDouble() ??
      items.fold<double>(0, (sum, item) => sum + item.price * item.quantity);

  final order = await repo.create(
    customerName: body['customerName'] as String?,
    customerEmail: body['customerEmail'] as String?,
    totalAmount: totalAmount,
    items: items,
  );

  return Response.json(statusCode: 201, body: order.toJson());
}
