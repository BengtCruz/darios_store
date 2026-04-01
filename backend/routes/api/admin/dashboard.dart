import 'package:dart_frog/dart_frog.dart';

import 'package:backend/repositories/repositories.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final productRepo = context.read<ProductRepository>();
  final categoryRepo = context.read<CategoryRepository>();
  final orderRepo = context.read<OrderRepository>();

  final totalProducts = await productRepo.count();
  final activeProducts = await productRepo.count(isActive: true);
  final categories = await categoryRepo.findAll();
  final orderCounts = await orderRepo.countByStatus();

  return Response.json(
    body: {
      'products': {
        'total': totalProducts,
        'active': activeProducts,
      },
      'categories': {
        'total': categories.length,
      },
      'orders': orderCounts,
    },
  );
}
