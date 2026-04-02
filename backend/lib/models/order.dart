import 'package:json_annotation/json_annotation.dart';

part 'order.g.dart';

@JsonSerializable()
class Order {

  const Order({
    required this.id,
    this.customerName,
    this.customerEmail,
    this.status = 'pending',
    required this.totalAmount,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  final String id;
  final String? customerName;
  final String? customerEmail;
  final String status;
  final double totalAmount;
  final List<OrderItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => _$OrderToJson(this);
}

@JsonSerializable()
class OrderItem {

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);
  final String productId;
  final String productName;
  final double price;
  final int quantity;

  Map<String, dynamic> toJson() => _$OrderItemToJson(this);
}
