import 'package:backend/db/database.dart';
import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';

class UserRepository {

  UserRepository(this._db);
  final Database _db;

  Future<Map<String, dynamic>?> findByEmail(String email) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('SELECT * FROM users WHERE email = @email'),
      parameters: {'email': email.toLowerCase()},
    );
    if (result.isEmpty) return null;
    return _rowToMap(result.first);
  }

  Future<Map<String, dynamic>?> findById(String id) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('SELECT * FROM users WHERE id = @id'),
      parameters: {'id': id},
    );
    if (result.isEmpty) return null;
    return _rowToMap(result.first);
  }

  Future<Map<String, dynamic>> create({
    required String email,
    required String name,
    required String passwordHash,
    String role = 'customer',
  }) async {
    final conn = await _db.connection;
    final id = const Uuid().v4();
    final result = await conn.execute(
      Sql.named('''
        INSERT INTO users (id, email, name, password_hash, role)
        VALUES (@id, @email, @name, @passwordHash, @role)
        RETURNING *
      '''),
      parameters: {
        'id': id,
        'email': email.toLowerCase(),
        'name': name,
        'passwordHash': passwordHash,
        'role': role,
      },
    );
    return _rowToMap(result.first);
  }

  Future<void> updatePassword(String id, String passwordHash) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named('''
        UPDATE users SET password_hash = @passwordHash, updated_at = NOW()
        WHERE id = @id
      '''),
      parameters: {'id': id, 'passwordHash': passwordHash},
    );
  }

  Future<int> count() async {
    final conn = await _db.connection;
    final result = await conn.execute('SELECT COUNT(*) FROM users');
    return result.first[0]! as int;
  }

  Future<String?> getStripeCustomerId(String userId) async {
    final user = await findById(userId);
    if (user == null) return null;
    return user['stripeCustomerId'] as String?;
  }

  Future<void> setStripeCustomerId(String userId, String stripeCustomerId) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named('''
        UPDATE users SET stripe_customer_id = @stripeCustomerId, updated_at = NOW()
        WHERE id = @id
      '''),
      parameters: {'id': userId, 'stripeCustomerId': stripeCustomerId},
    );
  }

  Map<String, dynamic> _rowToMap(ResultRow row) {
    final cols = row.toColumnMap();
    return {
      'id': cols['id'],
      'email': cols['email'],
      'name': cols['name'],
      'passwordHash': cols['password_hash'],
      'role': cols['role'],
      'isActive': cols['is_active'],
      'stripeCustomerId': cols['stripe_customer_id'] as String?,
      'createdAt': (cols['created_at'] as DateTime).toIso8601String(),
      'updatedAt': cols['updated_at'] != null
          ? (cols['updated_at'] as DateTime).toIso8601String()
          : null,
    };
  }
}
