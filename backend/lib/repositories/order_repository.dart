import 'dart:convert';

import 'package:backend/db/database.dart';
import 'package:backend/models/order.dart';
import 'package:postgres/postgres.dart';

class OrderRepository {

  OrderRepository(this._db);
  final Database _db;

  Future<List<Order>> findAll({String? status, String? email}) async {
    final conn = await _db.connection;
    final conditions = <String>[];
    final params = <String, Object?>{};

    if (status != null) {
      conditions.add('o.status = @status');
      params['status'] = status;
    }
    if (email != null) {
      conditions.add('o.customer_email = @email');
      params['email'] = email;
    }

    final where = conditions.isNotEmpty ? 'WHERE ${conditions.join(' AND ')}' : '';
    final result = await conn.execute(
      Sql.named('''
        SELECT o.*,
          COALESCE(json_agg(
            json_build_object(
              'productId', oi.product_id,
              'productName', oi.product_name,
              'price', oi.price,
              'quantity', oi.quantity
            )
          ) FILTER (WHERE oi.id IS NOT NULL), '[]') as items
        FROM orders o
        LEFT JOIN order_items oi ON o.id = oi.order_id
        $where
        GROUP BY o.id
        ORDER BY o.created_at DESC
      '''),
      parameters: params,
    );

    return result.map(_rowToOrder).toList();
  }

  Future<Order?> findById(String id) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('''
        SELECT o.*,
          COALESCE(json_agg(
            json_build_object(
              'productId', oi.product_id,
              'productName', oi.product_name,
              'price', oi.price,
              'quantity', oi.quantity
            )
          ) FILTER (WHERE oi.id IS NOT NULL), '[]') as items
        FROM orders o
        LEFT JOIN order_items oi ON o.id = oi.order_id
        WHERE o.id = @id
        GROUP BY o.id
      '''),
      parameters: {'id': id},
    );
    if (result.isEmpty) return null;
    return _rowToOrder(result.first);
  }

  Future<Order> create({
    required double totalAmount, required List<OrderItem> items, String? customerName,
    String? customerEmail,
  }) async {
    final conn = await _db.connection;

    // Create order
    final orderResult = await conn.execute(
      Sql.named('''
        INSERT INTO orders (customer_name, customer_email, total_amount)
        VALUES (@customer_name, @customer_email, @total_amount)
        RETURNING *
      '''),
      parameters: {
        'customer_name': customerName,
        'customer_email': customerEmail,
        'total_amount': totalAmount,
      },
    );

    final orderId = orderResult.first.toColumnMap()['id'] as String;

    // Insert items
    for (final item in items) {
      await conn.execute(
        Sql.named('''
          INSERT INTO order_items (order_id, product_id, product_name, price, quantity)
          VALUES (@order_id, @product_id, @product_name, @price, @quantity)
        '''),
        parameters: {
          'order_id': orderId,
          'product_id': item.productId,
          'product_name': item.productName,
          'price': item.price,
          'quantity': item.quantity,
        },
      );
    }

    return (await findById(orderId))!;
  }

  Future<Order?> updateStatus(String id, String status) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named(
        'UPDATE orders SET status = @status, updated_at = NOW() WHERE id = @id',
      ),
      parameters: {'id': id, 'status': status},
    );
    return findById(id);
  }

  Future<bool> delete(String id) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('DELETE FROM orders WHERE id = @id'),
      parameters: {'id': id},
    );
    return result.affectedRows > 0;
  }

  Future<Map<String, int>> countByStatus() async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('SELECT status, COUNT(*) as cnt FROM orders GROUP BY status'),
    );
    return {
      for (final row in result)
        row.toColumnMap()['status'] as String: row.toColumnMap()['cnt'] as int,
    };
  }

  Order _rowToOrder(ResultRow row) {
    final m = row.toColumnMap();
    final itemsRaw = m['items'];
    final items = (itemsRaw is String ? jsonDecode(itemsRaw) : itemsRaw) as List;

    return Order(
      id: m['id'] as String,
      customerName: m['customer_name'] as String?,
      customerEmail: m['customer_email'] as String?,
      status: m['status'] as String? ?? 'pending',
      totalAmount: double.parse(m['total_amount'].toString()),
      items: items
          .map((i) => OrderItem(
                productId: (i as Map)['productId']?.toString() ?? '',
                productName: i['productName']?.toString() ?? '',
                price: double.parse(i['price'].toString()),
                quantity: (i['quantity'] as num).toInt(),
              ))
          .toList(),
      createdAt: m['created_at'] as DateTime,
      updatedAt: m['updated_at'] as DateTime,
    );
  }
}
