import 'package:postgres/postgres.dart';

import 'package:backend/db/database.dart';

class Migrator {

  Migrator(this._db);
  final Database _db;

  Future<void> run() async {
    final conn = await _db.connection;

    // Create migrations tracking table
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS _migrations (
        id SERIAL PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        applied_at TIMESTAMPTZ DEFAULT NOW()
      )
    ''');

    for (final migration in _migrations) {
      final applied = await conn.execute(
        Sql.named('SELECT 1 FROM _migrations WHERE name = @name'),
        parameters: {'name': migration.name},
      );
      if (applied.isEmpty) {
        await conn.execute(migration.sql);
        await conn.execute(
          Sql.named('INSERT INTO _migrations (name) VALUES (@name)'),
          parameters: {'name': migration.name},
        );
        // ignore: avoid_print
        print('  ✓ Applied migration: ${migration.name}');
      }
    }
  }
}

class _Migration {
  const _Migration(this.name, this.sql);
  final String name;
  final String sql;
}

const _migrations = <_Migration>[
  _Migration(
    '001_create_categories',
    '''
    CREATE TABLE categories (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      name TEXT NOT NULL UNIQUE,
      description TEXT,
      sort_order INTEGER DEFAULT 0,
      is_active BOOLEAN DEFAULT true,
      created_at TIMESTAMPTZ DEFAULT NOW()
    )
    ''',
  ),
  _Migration(
    '002_create_products',
    '''
    CREATE TABLE products (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      name TEXT NOT NULL,
      description TEXT NOT NULL DEFAULT '',
      price DECIMAL(10,2) NOT NULL DEFAULT 0,
      image_url TEXT NOT NULL DEFAULT '',
      category TEXT NOT NULL,
      rating DECIMAL(2,1) DEFAULT 0,
      is_featured BOOLEAN DEFAULT false,
      is_active BOOLEAN DEFAULT true,
      created_at TIMESTAMPTZ DEFAULT NOW(),
      updated_at TIMESTAMPTZ DEFAULT NOW()
    )
    ''',
  ),
  _Migration(
    '003_create_orders',
    '''
    CREATE TABLE orders (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      customer_name TEXT,
      customer_email TEXT,
      status TEXT DEFAULT 'pending',
      total_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
      created_at TIMESTAMPTZ DEFAULT NOW(),
      updated_at TIMESTAMPTZ DEFAULT NOW()
    )
    ''',
  ),
  _Migration(
    '004_create_order_items',
    '''
    CREATE TABLE order_items (
      id SERIAL PRIMARY KEY,
      order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
      product_id UUID NOT NULL,
      product_name TEXT NOT NULL,
      price DECIMAL(10,2) NOT NULL,
      quantity INTEGER NOT NULL DEFAULT 1
    )
    ''',
  ),
  _Migration(
    '005_seed_categories',
    '''
    INSERT INTO categories (name, description, sort_order) VALUES
      ('Pasta', 'Traditional Italian pasta varieties', 1),
      ('Olive Oil', 'Premium Italian olive oils', 2),
      ('Wine', 'Fine Italian wines', 3),
      ('Cheese', 'Artisanal Italian cheeses', 4),
      ('Sauces', 'Authentic Italian sauces', 5),
      ('Sweets', 'Italian confections and desserts', 6)
    ''',
  ),
  _Migration(
    '006_seed_products',
    '''
    INSERT INTO products (name, description, price, image_url, category, rating, is_featured) VALUES
      ('Spaghetti Artigianale', 'Hand-crafted bronze-die spaghetti from Gragnano. Slow-dried for 48 hours to preserve authentic texture and flavor.', 6.90, 'https://picsum.photos/seed/pasta1/400/400', 'Pasta', 4.8, true),
      ('Penne Rigate', 'Traditional penne with ridged surface for perfect sauce grip. Made with 100% Italian durum wheat semolina.', 5.50, 'https://picsum.photos/seed/pasta2/400/400', 'Pasta', 4.5, false),
      ('Tagliatelle all''Uovo', 'Egg tagliatelle made with free-range eggs. A classic from Emilia-Romagna, pairs perfectly with ragù.', 8.20, 'https://picsum.photos/seed/pasta3/400/400', 'Pasta', 4.9, true),
      ('Olio Extra Vergine di Oliva', 'Cold-pressed extra virgin olive oil from centuries-old Tuscan groves. Fruity with a hint of pepper.', 18.50, 'https://picsum.photos/seed/oil1/400/400', 'Olive Oil', 4.9, true),
      ('Olio al Tartufo', 'Black truffle infused olive oil. A luxurious finishing oil for risotto, eggs, and pasta.', 24.00, 'https://picsum.photos/seed/oil2/400/400', 'Olive Oil', 4.7, false),
      ('Chianti Classico DOCG', 'A refined Chianti from the heart of Tuscany. Ruby red with notes of cherry, violet, and spice.', 22.00, 'https://picsum.photos/seed/wine1/400/400', 'Wine', 4.6, true),
      ('Prosecco di Valdobbiadene', 'Sparkling Prosecco DOCG with fine persistent perlage. Fresh with notes of green apple and wisteria.', 16.50, 'https://picsum.photos/seed/wine2/400/400', 'Wine', 4.4, false),
      ('Parmigiano Reggiano 24 Mesi', 'The King of Cheeses. Aged 24 months in Emilia-Romagna for a complex, granular texture and rich umami flavor.', 32.00, 'https://picsum.photos/seed/cheese1/400/400', 'Cheese', 5.0, true),
      ('Mozzarella di Bufala DOP', 'Fresh buffalo mozzarella from Campania. Creamy, milky, and melt-in-your-mouth tender.', 12.00, 'https://picsum.photos/seed/cheese2/400/400', 'Cheese', 4.8, false),
      ('Pomodori San Marzano DOP', 'Whole peeled San Marzano tomatoes. The gold standard for authentic Neapolitan pizza and pasta sauces.', 7.50, 'https://picsum.photos/seed/sauce1/400/400', 'Sauces', 4.7, false),
      ('Pesto alla Genovese', 'Classic Ligurian basil pesto with Parmigiano, Pecorino, pine nuts, and Ligurian extra virgin olive oil.', 9.80, 'https://picsum.photos/seed/sauce2/400/400', 'Sauces', 4.6, true),
      ('Cantucci alle Mandorle', 'Traditional Tuscan almond biscotti. Twice-baked for the perfect crunch, ideal with Vin Santo.', 8.90, 'https://picsum.photos/seed/sweet1/400/400', 'Sweets', 4.5, false),
      ('Panettone Classico', 'Milanese Christmas cake with candied fruits and raisins. Slow-risen for 72 hours for ultimate softness.', 28.00, 'https://picsum.photos/seed/sweet2/400/400', 'Sweets', 4.8, true)
    ''',
  ),
  _Migration(
    '007_create_users',
    '''
    CREATE TABLE users (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      email TEXT NOT NULL UNIQUE,
      name TEXT NOT NULL,
      password_hash TEXT NOT NULL,
      role TEXT NOT NULL DEFAULT 'customer',
      is_active BOOLEAN DEFAULT true,
      created_at TIMESTAMPTZ DEFAULT NOW(),
      updated_at TIMESTAMPTZ DEFAULT NOW()
    )
    ''',
  ),
  _Migration(
    '008_seed_admin_user',
    r'''
    INSERT INTO users (email, name, password_hash, role) VALUES
      ('admin@darios.store', 'Dario', '$2b$10$DyJCqgJB8BXNJ88aRxmf0O7SawmBwnxv9SEk80SSbYjQDGCIhc8Ri', 'admin')
    ON CONFLICT (email) DO NOTHING
    ''',
  ),
  _Migration(
    '009_add_stock_to_products',
    '''
    ALTER TABLE products ADD COLUMN IF NOT EXISTS stock INTEGER NOT NULL DEFAULT 0
    ''',
  ),
  _Migration(
    '010_create_wishlists',
    '''
    CREATE TABLE wishlists (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
      created_at TIMESTAMPTZ DEFAULT NOW(),
      UNIQUE (user_id, product_id)
    )
    ''',
  ),
];
