import '../models/product.dart';

const List<String> categories = [
  'Pasta',
  'Olive Oil',
  'Wine',
  'Cheese',
  'Sauces',
  'Sweets',
];

const List<Product> mockProducts = [
  // Pasta
  Product(
    id: '1',
    name: 'Spaghetti Artigianale',
    description:
        'Hand-crafted bronze-die spaghetti from Gragnano. Slow-dried for 48 hours to preserve authentic texture and flavor.',
    price: 6.90,
    imageUrl: 'https://picsum.photos/seed/pasta1/400/400',
    category: 'Pasta',
    rating: 4.8,
    isFeatured: true,
  ),
  Product(
    id: '2',
    name: 'Penne Rigate',
    description:
        'Traditional penne with ridged surface for perfect sauce grip. Made with 100% Italian durum wheat semolina.',
    price: 5.50,
    imageUrl: 'https://picsum.photos/seed/pasta2/400/400',
    category: 'Pasta',
    rating: 4.5,
  ),
  Product(
    id: '3',
    name: 'Tagliatelle all\'Uovo',
    description:
        'Egg tagliatelle made with free-range eggs. A classic from Emilia-Romagna, pairs perfectly with ragù.',
    price: 8.20,
    imageUrl: 'https://picsum.photos/seed/pasta3/400/400',
    category: 'Pasta',
    rating: 4.9,
    isFeatured: true,
  ),

  // Olive Oil
  Product(
    id: '4',
    name: 'Olio Extra Vergine di Oliva',
    description:
        'Cold-pressed extra virgin olive oil from centuries-old Tuscan groves. Fruity with a hint of pepper.',
    price: 18.50,
    imageUrl: 'https://picsum.photos/seed/oil1/400/400',
    category: 'Olive Oil',
    rating: 4.9,
    isFeatured: true,
  ),
  Product(
    id: '5',
    name: 'Olio al Tartufo',
    description:
        'Black truffle infused olive oil. A luxurious finishing oil for risotto, eggs, and pasta.',
    price: 24.00,
    imageUrl: 'https://picsum.photos/seed/oil2/400/400',
    category: 'Olive Oil',
    rating: 4.7,
  ),

  // Wine
  Product(
    id: '6',
    name: 'Chianti Classico DOCG',
    description:
        'A refined Chianti from the heart of Tuscany. Ruby red with notes of cherry, violet, and spice.',
    price: 22.00,
    imageUrl: 'https://picsum.photos/seed/wine1/400/400',
    category: 'Wine',
    rating: 4.6,
    isFeatured: true,
  ),
  Product(
    id: '7',
    name: 'Prosecco di Valdobbiadene',
    description:
        'Sparkling Prosecco DOCG with fine persistent perlage. Fresh with notes of green apple and wisteria.',
    price: 16.50,
    imageUrl: 'https://picsum.photos/seed/wine2/400/400',
    category: 'Wine',
    rating: 4.4,
  ),

  // Cheese
  Product(
    id: '8',
    name: 'Parmigiano Reggiano 24 Mesi',
    description:
        'The King of Cheeses. Aged 24 months in Emilia-Romagna for a complex, granular texture and rich umami flavor.',
    price: 32.00,
    imageUrl: 'https://picsum.photos/seed/cheese1/400/400',
    category: 'Cheese',
    rating: 5.0,
    isFeatured: true,
  ),
  Product(
    id: '9',
    name: 'Mozzarella di Bufala DOP',
    description:
        'Fresh buffalo mozzarella from Campania. Creamy, milky, and melt-in-your-mouth tender.',
    price: 12.00,
    imageUrl: 'https://picsum.photos/seed/cheese2/400/400',
    category: 'Cheese',
    rating: 4.8,
  ),

  // Sauces
  Product(
    id: '10',
    name: 'Pomodori San Marzano DOP',
    description:
        'Whole peeled San Marzano tomatoes. The gold standard for authentic Neapolitan pizza and pasta sauces.',
    price: 7.50,
    imageUrl: 'https://picsum.photos/seed/sauce1/400/400',
    category: 'Sauces',
    rating: 4.7,
  ),
  Product(
    id: '11',
    name: 'Pesto alla Genovese',
    description:
        'Classic Ligurian basil pesto with Parmigiano, Pecorino, pine nuts, and Ligurian extra virgin olive oil.',
    price: 9.80,
    imageUrl: 'https://picsum.photos/seed/sauce2/400/400',
    category: 'Sauces',
    rating: 4.6,
    isFeatured: true,
  ),

  // Sweets
  Product(
    id: '12',
    name: 'Cantucci alle Mandorle',
    description:
        'Traditional Tuscan almond biscotti. Twice-baked for the perfect crunch, ideal with Vin Santo.',
    price: 8.90,
    imageUrl: 'https://picsum.photos/seed/sweet1/400/400',
    category: 'Sweets',
    rating: 4.5,
  ),
  Product(
    id: '13',
    name: 'Panettone Classico',
    description:
        'Milanese Christmas cake with candied fruits and raisins. Slow-risen for 72 hours for ultimate softness.',
    price: 28.00,
    imageUrl: 'https://picsum.photos/seed/sweet2/400/400',
    category: 'Sweets',
    rating: 4.8,
    isFeatured: true,
  ),
];
