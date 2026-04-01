import 'dart:io';

import 'package:postgres/postgres.dart';

class Database {
  Database._();
  static Database? _instance;
  static Database get instance => _instance ??= Database._();

  Connection? _connection;

  Future<Connection> get connection async {
    if (_connection != null && _connection!.isOpen) {
      return _connection!;
    }
    _connection = await Connection.open(
      Endpoint(
        host: Platform.environment['DB_HOST'] ?? 'localhost',
        port: int.parse(Platform.environment['DB_PORT'] ?? '5432'),
        database: Platform.environment['DB_NAME'] ?? 'darios_store',
        username: Platform.environment['DB_USER'] ?? 'postgres',
        password: Platform.environment['DB_PASSWORD'] ?? 'postgres',
      ),
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );
    return _connection!;
  }

  Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }
}
