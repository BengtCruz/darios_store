import 'dart:io';

import 'package:backend/db/db.dart';
import 'package:backend/repositories/repositories.dart';
import 'package:backend/services/stripe_service.dart' as stripe;
import 'package:dart_frog/dart_frog.dart';

Database? _db;
bool _migrated = false;
bool _envLoaded = false;

void _loadEnv() {
  if (_envLoaded) return;
  _envLoaded = true;
  final envFile = File('backend/.env');
  // Try relative to workspace root (dart_frog runs from project root)
  final file = envFile.existsSync() ? envFile : File('.env');
  if (!file.existsSync()) return;
  for (final line in file.readAsLinesSync()) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    final idx = trimmed.indexOf('=');
    if (idx <= 0) continue;
    final key = trimmed.substring(0, idx).trim();
    final value = trimmed.substring(idx + 1).trim();
    if (value.isNotEmpty && Platform.environment[key] == null) {
      envVars[key] = value;
      stripe.envVars[key] = value;
    }
  }
  if (envVars.isNotEmpty) {
    stdout.writeln('Loaded ${envVars.length} env vars from .env');
  }
}

/// Global env var store (loaded from .env file).
final Map<String, String> envVars = {};

Handler middleware(Handler handler) {
  return (context) async {
    // Load .env vars once
    _loadEnv();

    // Initialize DB once
    _db ??= Database.instance;

    if (!_migrated) {
      stdout.writeln('Running database migrations...');
      await Migrator(_db!).run();
      _migrated = true;
      stdout.writeln('Migrations complete.');
    }

    // CORS headers
    const corsHeaders = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    };

    // Handle preflight OPTIONS immediately
    if (context.request.method == HttpMethod.options) {
      return Response(statusCode: 204, headers: corsHeaders);
    }

    final response = await handler
        .use(provider<Database>((ctx) => _db!))
        .use(provider<ProductRepository>((ctx) => ProductRepository(_db!)))
        .use(provider<CategoryRepository>((ctx) => CategoryRepository(_db!)))
        .use(provider<OrderRepository>((ctx) => OrderRepository(_db!)))
        .use(provider<UserRepository>((ctx) => UserRepository(_db!)))
        .use(provider<WishlistRepository>((ctx) => WishlistRepository(_db!)))
        .use(provider<AddressRepository>((ctx) => AddressRepository(_db!)))
        .call(context);

    return response.copyWith(
      headers: {
        ...response.headers,
        ...corsHeaders,
      },
    );
  };
}
