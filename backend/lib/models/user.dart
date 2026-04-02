import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.passwordHash,
    this.role = 'customer',
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  final String id;
  final String email;
  final String name;
  @JsonKey(includeToJson: false)
  final String passwordHash;
  final String role; // 'customer' or 'admin'
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => _$UserToJson(this);

  /// Public-safe representation (no password hash).
  Map<String, dynamic> toPublicJson() => {
        'id': id,
        'email': email,
        'name': name,
        'role': role,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
      };
}
