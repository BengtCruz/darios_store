import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

import 'package:backend/db/db.dart';
import 'package:backend/repositories/repositories.dart';

Database? _db;
bool _migrated = false;

Handler middleware(Handler handler) {
  return (context) async {
    // Initialize DB once
    _db ??= Database.instance;

    if (!_migrated) {
      stdout.writeln('Running database migrations...');
      await Migrator(_db!).run();
      _migrated = true;
      stdout.writeln('Migrations complete.');
    }

    // CORS headers
    final response = await handler
        .use(provider<Database>((ctx) => _db!))
        .use(provider<ProductRepository>((ctx) => ProductRepository(_db!)))
        .use(provider<CategoryRepository>((ctx) => CategoryRepository(_db!)))
        .use(provider<OrderRepository>((ctx) => OrderRepository(_db!)))
        .call(context);

    return response.copyWith(
      headers: {
        ...response.headers,
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      },
    );
  };
}
