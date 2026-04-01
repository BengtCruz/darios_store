import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';

import 'package:backend/repositories/order_repository.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return _get(context, id);
    case HttpMethod.patch:
      return _patch(context, id);
    case HttpMethod.delete:
      return _delete(context, id);
    case HttpMethod.options:
      return Response();
    default:
      return Response(statusCode: 405);
  }
}

Future<Response> _get(RequestContext context, String id) async {
  final repo = context.read<OrderRepository>();
  final order = await repo.findById(id);
  if (order == null) {
    return Response.json(statusCode: 404, body: {'error': 'Order not found'});
  }
  return Response.json(body: order.toJson());
}

Future<Response> _patch(RequestContext context, String id) async {
  final repo = context.read<OrderRepository>();
  final body = jsonDecode(await context.request.body()) as Map<String, dynamic>;
  final status = body['status'] as String?;

  if (status == null) {
    return Response.json(statusCode: 400, body: {'error': 'status is required'});
  }

  const validStatuses = ['pending', 'confirmed', 'shipped', 'delivered', 'cancelled'];
  if (!validStatuses.contains(status)) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid status. Must be one of: $validStatuses'},
    );
  }

  final order = await repo.updateStatus(id, status);
  if (order == null) {
    return Response.json(statusCode: 404, body: {'error': 'Order not found'});
  }
  return Response.json(body: order.toJson());
}

Future<Response> _delete(RequestContext context, String id) async {
  final repo = context.read<OrderRepository>();
  final deleted = await repo.delete(id);
  if (!deleted) {
    return Response.json(statusCode: 404, body: {'error': 'Order not found'});
  }
  return Response.json(body: {'deleted': true});
}
