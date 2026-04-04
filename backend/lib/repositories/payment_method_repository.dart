import 'package:postgres/postgres.dart';

import 'package:backend/db/database.dart';

class PaymentMethodRepository {
  PaymentMethodRepository(this._db);
  final Database _db;

  Future<List<Map<String, dynamic>>> findByUser(String userId) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('''
        SELECT * FROM payment_methods
        WHERE user_id = @userId
        ORDER BY is_default DESC, created_at DESC
      '''),
      parameters: {'userId': userId},
    );
    return result.map(_rowToMap).toList();
  }

  Future<Map<String, dynamic>?> findById(String id) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('SELECT * FROM payment_methods WHERE id = @id'),
      parameters: {'id': id},
    );
    if (result.isEmpty) return null;
    return _rowToMap(result.first);
  }

  Future<List<String>> findStripeIdsByUser(String userId) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named(
        'SELECT stripe_payment_method_id FROM payment_methods WHERE user_id = @userId',
      ),
      parameters: {'userId': userId},
    );
    return result
        .map((r) => r.toColumnMap()['stripe_payment_method_id'] as String)
        .toList();
  }

  Future<Map<String, dynamic>> create({
    required String userId,
    required String stripePaymentMethodId,
    required String label,
    required String cardBrand,
    required String lastFour,
    required int expiryMonth,
    required int expiryYear,
    bool isDefault = false,
  }) async {
    final conn = await _db.connection;

    if (isDefault) {
      await conn.execute(
        Sql.named(
          'UPDATE payment_methods SET is_default = false WHERE user_id = @userId',
        ),
        parameters: {'userId': userId},
      );
    }

    final result = await conn.execute(
      Sql.named('''
        INSERT INTO payment_methods (user_id, stripe_payment_method_id, label, card_brand, last_four, expiry_month, expiry_year, is_default)
        VALUES (@userId, @stripePaymentMethodId, @label, @cardBrand, @lastFour, @expiryMonth, @expiryYear, @isDefault)
        ON CONFLICT (stripe_payment_method_id) DO UPDATE SET
          card_brand = EXCLUDED.card_brand,
          last_four = EXCLUDED.last_four,
          expiry_month = EXCLUDED.expiry_month,
          expiry_year = EXCLUDED.expiry_year,
          updated_at = NOW()
        RETURNING *
      '''),
      parameters: {
        'userId': userId,
        'stripePaymentMethodId': stripePaymentMethodId,
        'label': label,
        'cardBrand': cardBrand,
        'lastFour': lastFour,
        'expiryMonth': expiryMonth,
        'expiryYear': expiryYear,
        'isDefault': isDefault,
      },
    );
    return _rowToMap(result.first);
  }

  Future<Map<String, dynamic>> update(
    String id, {
    String? label,
    String? cardBrand,
    String? lastFour,
    int? expiryMonth,
    int? expiryYear,
    bool? isDefault,
  }) async {
    final conn = await _db.connection;

    if (isDefault ?? false) {
      final pm = await findById(id);
      if (pm != null) {
        await conn.execute(
          Sql.named(
            'UPDATE payment_methods SET is_default = false WHERE user_id = @userId',
          ),
          parameters: {'userId': pm['userId']},
        );
      }
    }

    final sets = <String>[];
    final params = <String, Object?>{'id': id};

    if (label != null) { sets.add('label = @label'); params['label'] = label; }
    if (cardBrand != null) { sets.add('card_brand = @cardBrand'); params['cardBrand'] = cardBrand; }
    if (lastFour != null) { sets.add('last_four = @lastFour'); params['lastFour'] = lastFour; }
    if (expiryMonth != null) { sets.add('expiry_month = @expiryMonth'); params['expiryMonth'] = expiryMonth; }
    if (expiryYear != null) { sets.add('expiry_year = @expiryYear'); params['expiryYear'] = expiryYear; }
    if (isDefault != null) { sets.add('is_default = @isDefault'); params['isDefault'] = isDefault; }

    sets.add('updated_at = NOW()');

    final result = await conn.execute(
      Sql.named('UPDATE payment_methods SET ${sets.join(', ')} WHERE id = @id RETURNING *'),
      parameters: params,
    );
    return _rowToMap(result.first);
  }

  Future<void> delete(String id) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named('DELETE FROM payment_methods WHERE id = @id'),
      parameters: {'id': id},
    );
  }

  Map<String, dynamic> _rowToMap(ResultRow row) {
    final m = row.toColumnMap();
    return {
      'id': m['id'] as String,
      'userId': m['user_id'] as String,
      'stripePaymentMethodId': m['stripe_payment_method_id'] as String,
      'label': m['label'] as String,
      'cardBrand': m['card_brand'] as String,
      'lastFour': m['last_four'] as String,
      'expiryMonth': m['expiry_month'] as int,
      'expiryYear': m['expiry_year'] as int,
      'isDefault': m['is_default'] as bool,
      'createdAt': (m['created_at'] as DateTime).toIso8601String(),
      'updatedAt': (m['updated_at'] as DateTime).toIso8601String(),
    };
  }
}
