import 'package:postgres/postgres.dart';

import 'package:backend/db/database.dart';

class WishlistRepository {
  WishlistRepository(this._db);
  final Database _db;

  Future<List<Map<String, dynamic>>> findByUser(String userId) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('''
        SELECT w.id, w.product_id, w.created_at,
          p.name, p.description, p.price, p.image_url, p.category,
          p.rating, p.is_featured, p.is_active, p.stock,
          p.created_at as product_created_at, p.updated_at as product_updated_at
        FROM wishlists w
        JOIN products p ON w.product_id = p.id
        WHERE w.user_id = @userId
        ORDER BY w.created_at DESC
      '''),
      parameters: {'userId': userId},
    );
    return result.map((row) {
      final cols = row.toColumnMap();
      return {
        'id': cols['product_id'] as String,
        'name': cols['name'] as String,
        'description': cols['description'] as String? ?? '',
        'price': double.parse(cols['price'].toString()),
        'imageUrl': cols['image_url'] as String? ?? '',
        'category': cols['category'] as String,
        'rating': double.parse(cols['rating'].toString()),
        'isFeatured': cols['is_featured'] as bool? ?? false,
        'isActive': cols['is_active'] as bool? ?? true,
        'stock': (cols['stock'] as int?) ?? 0,
        'createdAt': (cols['product_created_at'] as DateTime).toIso8601String(),
        'updatedAt': (cols['product_updated_at'] as DateTime).toIso8601String(),
      };
    }).toList();
  }

  Future<List<String>> findProductIdsByUser(String userId) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('SELECT product_id FROM wishlists WHERE user_id = @userId'),
      parameters: {'userId': userId},
    );
    return result
        .map((row) => row.toColumnMap()['product_id'] as String)
        .toList();
  }

  Future<bool> exists(String userId, String productId) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named(
        'SELECT 1 FROM wishlists WHERE user_id = @userId AND product_id = @productId',
      ),
      parameters: {'userId': userId, 'productId': productId},
    );
    return result.isNotEmpty;
  }

  Future<void> add(String userId, String productId) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named('''
        INSERT INTO wishlists (user_id, product_id)
        VALUES (@userId, @productId)
        ON CONFLICT (user_id, product_id) DO NOTHING
      '''),
      parameters: {'userId': userId, 'productId': productId},
    );
  }

  Future<void> remove(String userId, String productId) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named(
        'DELETE FROM wishlists WHERE user_id = @userId AND product_id = @productId',
      ),
      parameters: {'userId': userId, 'productId': productId},
    );
  }
}
