import 'package:postgres/postgres.dart';

import '../db/database.dart';
import '../models/category.dart';

class CategoryRepository {
  final Database _db;

  CategoryRepository(this._db);

  Future<List<Category>> findAll({bool? isActive}) async {
    final conn = await _db.connection;
    final where = isActive != null ? 'WHERE is_active = @is_active' : '';
    final params = isActive != null ? {'is_active': isActive} : <String, Object?>{};
    final result = await conn.execute(
      Sql.named('SELECT * FROM categories $where ORDER BY sort_order ASC'),
      parameters: params,
    );
    return result.map(_rowToCategory).toList();
  }

  Future<Category?> findById(String id) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('SELECT * FROM categories WHERE id = @id'),
      parameters: {'id': id},
    );
    if (result.isEmpty) return null;
    return _rowToCategory(result.first);
  }

  Future<Category> create({
    required String name,
    String? description,
    int sortOrder = 0,
  }) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('''
        INSERT INTO categories (name, description, sort_order)
        VALUES (@name, @description, @sort_order)
        RETURNING *
      '''),
      parameters: {
        'name': name,
        'description': description,
        'sort_order': sortOrder,
      },
    );
    return _rowToCategory(result.first);
  }

  Future<Category?> update(
    String id, {
    String? name,
    String? description,
    int? sortOrder,
    bool? isActive,
  }) async {
    final sets = <String>[];
    final params = <String, Object?>{'id': id};

    if (name != null) { sets.add('name = @name'); params['name'] = name; }
    if (description != null) { sets.add('description = @description'); params['description'] = description; }
    if (sortOrder != null) { sets.add('sort_order = @sort_order'); params['sort_order'] = sortOrder; }
    if (isActive != null) { sets.add('is_active = @is_active'); params['is_active'] = isActive; }

    if (sets.isEmpty) return findById(id);

    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('UPDATE categories SET ${sets.join(', ')} WHERE id = @id RETURNING *'),
      parameters: params,
    );
    if (result.isEmpty) return null;
    return _rowToCategory(result.first);
  }

  Future<bool> delete(String id) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('DELETE FROM categories WHERE id = @id'),
      parameters: {'id': id},
    );
    return result.affectedRows > 0;
  }

  Category _rowToCategory(ResultRow row) {
    final m = row.toColumnMap();
    return Category(
      id: m['id'] as String,
      name: m['name'] as String,
      description: m['description'] as String?,
      sortOrder: m['sort_order'] as int? ?? 0,
      isActive: m['is_active'] as bool? ?? true,
      createdAt: m['created_at'] as DateTime,
    );
  }
}
