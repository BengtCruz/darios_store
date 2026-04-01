import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable()
class Category {
  final String id;
  final String name;
  final String? description;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;

  const Category({
    required this.id,
    required this.name,
    this.description,
    this.sortOrder = 0,
    this.isActive = true,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}
