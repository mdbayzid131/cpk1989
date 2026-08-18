class SavedCardModel {
  final String id;
  final String brand;
  final String last4;
  final int expMonth;
  final int expYear;
  final String funding;

  const SavedCardModel({
    required this.id,
    required this.brand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
    required this.funding,
  });

  factory SavedCardModel.fromJson(Map<String, dynamic> json) {
    return SavedCardModel(
      id: json['id'] as String? ?? '',
      brand: json['brand'] as String? ?? 'Card',
      last4: json['last4'] as String? ?? '0000',
      expMonth: json['expMonth'] as int? ?? 1,
      expYear: json['expYear'] as int? ?? 2030,
      funding: json['funding'] as String? ?? 'credit',
    );
  }

  String get maskedNumber => '•••• $last4';
  String get expiry => '${expMonth.toString().padLeft(2, '0')}/$expYear';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'last4': last4,
      'expMonth': expMonth,
      'expYear': expYear,
      'funding': funding,
    };
  }
}

class PaymentMethodsPageModel {
  final List<SavedCardModel> paymentMethods;
  final bool hasMore;
  final String? nextCursor;

  const PaymentMethodsPageModel({
    required this.paymentMethods,
    required this.hasMore,
    required this.nextCursor,
  });

  factory PaymentMethodsPageModel.fromJson(Map<String, dynamic> json) {
    final list = json['paymentMethods'] as List<dynamic>? ?? [];
    return PaymentMethodsPageModel(
      paymentMethods: list
          .map(
            (item) =>
                SavedCardModel.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
      hasMore: json['hasMore'] as bool? ?? false,
      nextCursor: json['nextCursor'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentMethods': paymentMethods.map((e) => e.toJson()).toList(),
      'hasMore': hasMore,
      'nextCursor': nextCursor,
    };
  }
}
