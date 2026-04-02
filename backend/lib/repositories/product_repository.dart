import 'package:postgres/postgres.dart';

import 'package:backend/db/database.dart';
import 'package:backend/models/product.dart';

class ProductRepository {

  ProductRepository(this._db);
  final Database _db;

  Future<List<Product>> findAll({
    String? category,
    bool? isFeatured,
    bool? isActive,
    String orderBy = 'created_at',
    bool descending = true,
  }) async {
    final conn = await _db.connection;
    final where = <String>[];
    final params = <String, Object?>{};

    if (category != null) {
      where.add('category = @category');
      params['category'] = category;
    }
    if (isFeatured != null) {
      where.add('is_featured = @is_featured');
      params['is_featured'] = isFeatured;
    }
    if (isActive != null) {
      where.add('is_active = @is_active');
      params['is_active'] = isActive;
    }

    final whereClause = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';
    final dir = descending ? 'DESC' : 'ASC';

    // Whitelist allowed order-by columns
    const allowedColumns = {
      'created_at', 'updated_at', 'name', 'price', 'rating',
    };
    final safeOrderBy = allowedColumns.contains(orderBy) ? orderBy : 'created_at';

    final result = await conn.execute(
      Sql.named('SELECT * FROM products $whereClause ORDER BY $safeOrderBy $dir'),
      parameters: params,
    );

    return result.map(_rowToProduct).toList();
  }

  Future<Product?> findById(String id) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('SELECT * FROM products WHERE id = @id'),
      parameters: {'id': id},
    );
    if (result.isEmpty) return null;
    return _rowToProduct(result.first);
  }

  Future<Product> create({
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    required String category,
    double rating = 0,
    bool isFeatured = false,
  }) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('''
        INSERT INTO products (name, description, price, image_url, category, rating, is_featured)
        VALUES (@name, @description, @price, @image_url, @category, @rating, @is_featured)
        RETURNING *
      '''),
      parameters: {
        'name': name,
        'description': description,
        'price': price,
        'image_url': imageUrl,
        'category': category,
        'rating': rating,
        'is_featured': isFeatured,
      },
    );
    return _rowToProduct(result.first);
  }

  Future<Product?> update(
    String id, {
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    double? rating,
    bool? isFeatured,
    bool? isActive,
  }) async {
    final sets = <String>[];
    final params = <String, Object?>{'id': id};

    if (name != null) { sets.add('name = @name'); params['name'] = name; }
    if (description != null) { sets.add('description = @description'); params['description'] = description; }
    if (price != null) { sets.add('price = @price'); params['price'] = price; }
    if (imageUrl != null) { sets.add('image_url = @image_url'); params['image_url'] = imageUrl; }
    if (category != null) { sets.add('category = @category'); params['category'] = category; }
    if (rating != null) { sets.add('rating = @rating'); params['rating'] = rating; }
    if (isFeatured != null) { sets.add('is_featured = @is_featured'); params['is_featured'] = isFeatured; }
    if (isActive != null) { sets.add('is_active = @is_active'); params['is_active'] = isActive; }

    if (sets.isEmpty) return findById(id);

    sets.add('updated_at = NOW()');

    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('UPDATE products SET ${sets.join(', ')} WHERE id = @id RETURNING *'),
      parameters: params,
    );
    if (result.isEmpty) return null;
    return _rowToProduct(result.first);
  }

  Future<bool> delete(String id) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('DELETE FROM products WHERE id = @id'),
      parameters: {'id': id},
    );
    return result.affectedRows > 0;
  }

  Future<int> count({String? category, bool? isActive}) async {
    final conn = await _db.connection;
    final where = <String>[];
    final params = <String, Object?>{};
    if (category != null) { where.add('category = @category'); params['category'] = category; }
    if (isActive != null) { where.add('is_active = @is_active'); params['is_active'] = isActive; }
    final whereClause = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';
    final result = await conn.execute(
      Sql.named('SELECT COUNT(*) as cnt FROM products $whereClause'),
      parameters: params,
    );
    return result.first.toColumnMap()['cnt'] as int;
  }

  Product _rowToProduct(ResultRow row) {
    final m = row.toColumnMap();
    return Product(
      id: m['id'] as String,
      name: m['name'] as String,
      description: m['description'] as String? ?? '',
      price: (m['price'] is int)
          ? (m['price'] as int).toDouble()
          : double.parse(m['price'].toString()),
      imageUrl: m['image_url'] as String? ?? '',
      category: m['category'] as String,
      rating: (m['rating'] is int)
          ? (m['rating'] as int).toDouble()
          : double.parse(m['rating'].toString()),
      isFeatured: m['is_featured'] as bool? ?? false,
      isActive: m['is_active'] as bool? ?? true,
      createdAt: m['created_at'] as DateTime,
      updatedAt: m['updated_at'] as DateTime,
    );
  }
}
