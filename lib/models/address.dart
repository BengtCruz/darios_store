class Address {
  final String id;
  final String label;
  final String fullName;
  final String street;
  final String? street2;
  final String city;
  final String? state;
  final String postalCode;
  final String country;
  final String? phone;
  final bool isDefault;

  const Address({
    required this.id,
    required this.label,
    required this.fullName,
    required this.street,
    this.street2,
    required this.city,
    this.state,
    required this.postalCode,
    required this.country,
    this.phone,
    this.isDefault = false,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String,
      label: json['label'] as String? ?? 'Home',
      fullName: json['fullName'] as String,
      street: json['street'] as String,
      street2: json['street2'] as String?,
      city: json['city'] as String,
      state: json['state'] as String?,
      postalCode: json['postalCode'] as String,
      country: json['country'] as String? ?? 'Sweden',
      phone: json['phone'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'fullName': fullName,
        'street': street,
        if (street2 != null) 'street2': street2,
        'city': city,
        if (state != null) 'state': state,
        'postalCode': postalCode,
        'country': country,
        if (phone != null) 'phone': phone,
        'isDefault': isDefault,
      };

  String get formattedAddress {
    final parts = <String>[street];
    if (street2 != null && street2!.isNotEmpty) parts.add(street2!);
    parts.add('$postalCode $city');
    if (state != null && state!.isNotEmpty) parts.add(state!);
    parts.add(country);
    return parts.join('\n');
  }
}
