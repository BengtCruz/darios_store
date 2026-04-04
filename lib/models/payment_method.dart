class PaymentMethod {
  final String id;
  final String label;
  final String cardBrand;
  final String lastFour;
  final int expiryMonth;
  final int expiryYear;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.label,
    required this.cardBrand,
    required this.lastFour,
    required this.expiryMonth,
    required this.expiryYear,
    this.isDefault = false,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as String,
      label: json['label'] as String,
      cardBrand: json['cardBrand'] as String,
      lastFour: json['lastFour'] as String,
      expiryMonth: json['expiryMonth'] as int,
      expiryYear: json['expiryYear'] as int,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'cardBrand': cardBrand,
        'lastFour': lastFour,
        'expiryMonth': expiryMonth,
        'expiryYear': expiryYear,
        'isDefault': isDefault,
      };

  String get expiryDisplay =>
      '${expiryMonth.toString().padLeft(2, '0')}/${expiryYear.toString().substring(2)}';

  String get maskedNumber => '•••• •••• •••• $lastFour';
}
