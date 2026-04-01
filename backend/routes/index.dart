import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response.json(
    body: {
      'name': "Dario's Store API",
      'version': '1.0.0',
      'endpoints': {
        'products': '/api/products',
        'categories': '/api/categories',
        'orders': '/api/orders',
        'admin': '/api/admin/dashboard',
      },
    },
  );
}
