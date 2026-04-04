class Order {
  final String id;
  final String? customerName;
  final String? customerEmail;
  final String status;
  final double totalAmount;
  final List<OrderItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Order({
    required this.id,
    this.customerName,
    this.customerEmail,
    required this.status,
    required this.totalAmount,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      customerName: json['customerName'] as String?,
      customerEmail: json['customerEmail'] as String?,
      status: json['status'] as String? ?? 'pending',
      totalAmount: (json['totalAmount'] as num).toDouble(),
      items: (json['items'] as List? ?? [])
          .map((i) => OrderItem.fromJson(i as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
    );
  }
}
