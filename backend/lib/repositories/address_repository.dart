import 'package:postgres/postgres.dart';

import 'package:backend/db/database.dart';

class AddressRepository {
  AddressRepository(this._db);
  final Database _db;

  Future<List<Map<String, dynamic>>> findByUser(String userId) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('''
        SELECT * FROM addresses
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
      Sql.named('SELECT * FROM addresses WHERE id = @id'),
      parameters: {'id': id},
    );
    if (result.isEmpty) return null;
    return _rowToMap(result.first);
  }

  Future<Map<String, dynamic>> create({
    required String userId,
    required String label,
    required String fullName,
    required String street,
    String? street2,
    required String city,
    String? state,
    required String postalCode,
    required String country,
    String? phone,
    bool isDefault = false,
  }) async {
    final conn = await _db.connection;

    // If setting as default, unset other defaults first
    if (isDefault) {
      await conn.execute(
        Sql.named('UPDATE addresses SET is_default = false WHERE user_id = @userId'),
        parameters: {'userId': userId},
      );
    }

    final result = await conn.execute(
      Sql.named('''
        INSERT INTO addresses (user_id, label, full_name, street, street2, city, state, postal_code, country, phone, is_default)
        VALUES (@userId, @label, @fullName, @street, @street2, @city, @state, @postalCode, @country, @phone, @isDefault)
        RETURNING *
      '''),
      parameters: {
        'userId': userId,
        'label': label,
        'fullName': fullName,
        'street': street,
        'street2': street2,
        'city': city,
        'state': state,
        'postalCode': postalCode,
        'country': country,
        'phone': phone,
        'isDefault': isDefault,
      },
    );
    return _rowToMap(result.first);
  }

  Future<Map<String, dynamic>> update(
    String id, {
    String? label,
    String? fullName,
    String? street,
    String? street2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    String? phone,
    bool? isDefault,
  }) async {
    final conn = await _db.connection;

    // If setting as default, unset other defaults first
    if (isDefault == true) {
      // Get the user_id for this address
      final addr = await findById(id);
      if (addr != null) {
        await conn.execute(
          Sql.named('UPDATE addresses SET is_default = false WHERE user_id = @userId'),
          parameters: {'userId': addr['userId']},
        );
      }
    }

    final sets = <String>[];
    final params = <String, Object?>{'id': id};

    if (label != null) { sets.add('label = @label'); params['label'] = label; }
    if (fullName != null) { sets.add('full_name = @fullName'); params['fullName'] = fullName; }
    if (street != null) { sets.add('street = @street'); params['street'] = street; }
    if (street2 != null) { sets.add('street2 = @street2'); params['street2'] = street2; }
    if (city != null) { sets.add('city = @city'); params['city'] = city; }
    if (state != null) { sets.add('state = @state'); params['state'] = state; }
    if (postalCode != null) { sets.add('postal_code = @postalCode'); params['postalCode'] = postalCode; }
    if (country != null) { sets.add('country = @country'); params['country'] = country; }
    if (phone != null) { sets.add('phone = @phone'); params['phone'] = phone; }
    if (isDefault != null) { sets.add('is_default = @isDefault'); params['isDefault'] = isDefault; }

    sets.add('updated_at = NOW()');

    final result = await conn.execute(
      Sql.named('UPDATE addresses SET ${sets.join(', ')} WHERE id = @id RETURNING *'),
      parameters: params,
    );
    return _rowToMap(result.first);
  }

  Future<void> delete(String id) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named('DELETE FROM addresses WHERE id = @id'),
      parameters: {'id': id},
    );
  }

  Map<String, dynamic> _rowToMap(ResultRow row) {
    final m = row.toColumnMap();
    return {
      'id': m['id'] as String,
      'userId': m['user_id'] as String,
      'label': m['label'] as String,
      'fullName': m['full_name'] as String,
      'street': m['street'] as String,
      'street2': m['street2'] as String?,
      'city': m['city'] as String,
      'state': m['state'] as String?,
      'postalCode': m['postal_code'] as String,
      'country': m['country'] as String,
      'phone': m['phone'] as String?,
      'isDefault': m['is_default'] as bool,
      'createdAt': (m['created_at'] as DateTime).toIso8601String(),
      'updatedAt': (m['updated_at'] as DateTime).toIso8601String(),
    };
  }
}
