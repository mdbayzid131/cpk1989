import 'package:cpk1989/data/models/product_model.dart';

class CheckoutResponseModel {
  final bool? success;
  final String? message;
  final CheckoutDataModel? data;

  CheckoutResponseModel({this.success, this.message, this.data});

  factory CheckoutResponseModel.fromJson(Map<String, dynamic> json) {
    return CheckoutResponseModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? CheckoutDataModel.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data?.toJson()};
  }
}

class CheckoutDataModel {
  final OrderModel? order;
  final String? clientSecret;
  final String? publishableKey;

  CheckoutDataModel({this.order, this.clientSecret, this.publishableKey});

  factory CheckoutDataModel.fromJson(Map<String, dynamic> json) {
    return CheckoutDataModel(
      order: json['order'] != null ? OrderModel.fromJson(json['order']) : null,
      clientSecret: json['clientSecret'],
      publishableKey: json['publishableKey'] ?? json['stripePublishableKey'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order': order?.toJson(),
      'clientSecret': clientSecret,
      'publishableKey': publishableKey,
    };
  }
}

class OrderModel {
  final String? id;
  final String? orderNumber;
  final String? product;
  final ProductModel? productModel;
  final OrderBuyerModel? buyerModel;
  final OrderSellerModel? sellerModel;
  final double? price;
  final double? platformFee;
  final double? sellerPayout;
  final DeliveryDetailsModel? deliveryDetails;
  final PaymentDetailsModel? payment;
  final String? payoutStatus;
  final String? status;
  final List<StatusHistoryModel>? statusHistory;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrderModel({
    this.id,
    this.orderNumber,
    this.product,
    this.productModel,
    this.buyerModel,
    this.sellerModel,
    this.price,
    this.platformFee,
    this.sellerPayout,
    this.deliveryDetails,
    this.payment,
    this.payoutStatus,
    this.status,
    this.statusHistory,
    this.createdAt,
    this.updatedAt,
  });

  /// Convenience: buyer display name
  String get buyerName => buyerModel?.name ?? '';

  /// Convenience: seller display name
  String get sellerName => sellerModel?.name ?? '';

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    ProductModel? parsedProd;
    String? prodId;
    if (json['product'] is Map) {
      parsedProd = ProductModel.fromJson(
        Map<String, dynamic>.from(json['product']),
      );
      prodId = parsedProd.id;
    } else if (json['product'] is String) {
      prodId = json['product'];
    }

    OrderBuyerModel? parsedBuyer;
    if (json['buyer'] is Map) {
      parsedBuyer = OrderBuyerModel.fromJson(
        Map<String, dynamic>.from(json['buyer']),
      );
    } else if (json['buyer'] is String) {
      parsedBuyer = OrderBuyerModel(id: json['buyer']);
    }

    OrderSellerModel? parsedSeller;
    if (json['seller'] is Map) {
      parsedSeller = OrderSellerModel.fromJson(
        Map<String, dynamic>.from(json['seller']),
      );
    } else if (json['seller'] is String) {
      parsedSeller = OrderSellerModel(id: json['seller']);
    }

    return OrderModel(
      id: json['id'] ?? json['_id'],
      orderNumber: json['orderNumber'],
      product: prodId,
      productModel: parsedProd,
      buyerModel: parsedBuyer,
      sellerModel: parsedSeller,
      price: json['price'] != null
          ? double.tryParse(json['price'].toString())
          : parsedProd?.price,
      platformFee: json['platformFee'] != null
          ? double.tryParse(json['platformFee'].toString())
          : null,
      sellerPayout: json['sellerPayout'] != null
          ? double.tryParse(json['sellerPayout'].toString())
          : null,
      deliveryDetails:
          json['deliveryDetails'] != null && json['deliveryDetails'] is Map
          ? DeliveryDetailsModel.fromJson(
              Map<String, dynamic>.from(json['deliveryDetails']),
            )
          : null,
      payment: json['payment'] != null && json['payment'] is Map
          ? PaymentDetailsModel.fromJson(
              Map<String, dynamic>.from(json['payment']),
            )
          : null,
      payoutStatus: json['payoutStatus'],
      status: json['status'],
      statusHistory:
          json['statusHistory'] != null && json['statusHistory'] is List
          ? (json['statusHistory'] as List)
                .map(
                  (e) =>
                      StatusHistoryModel.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'product': product,
      'buyer': buyerModel?.toJson(),
      'seller': sellerModel?.toJson(),
      'price': price,
      'platformFee': platformFee,
      'sellerPayout': sellerPayout,
      'deliveryDetails': deliveryDetails?.toJson(),
      'payment': payment?.toJson(),
      'payoutStatus': payoutStatus,
      'status': status,
      'statusHistory': statusHistory?.map((e) => e.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class OrderBuyerModel {
  final String? id;
  final String? name;
  final String? email;

  OrderBuyerModel({this.id, this.name, this.email});

  factory OrderBuyerModel.fromJson(Map<String, dynamic> json) {
    return OrderBuyerModel(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email};
  }
}

class OrderSellerModel {
  final String? id;
  final String? name;
  final String? email;
  final String? contact;

  OrderSellerModel({this.id, this.name, this.email, this.contact});

  factory OrderSellerModel.fromJson(Map<String, dynamic> json) {
    return OrderSellerModel(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      email: json['email'],
      contact: json['contact'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'contact': contact};
  }
}

class DeliveryDetailsModel {
  final String? address;
  final String? location;
  final String? phone;

  DeliveryDetailsModel({this.address, this.location, this.phone});

  factory DeliveryDetailsModel.fromJson(Map<String, dynamic> json) {
    return DeliveryDetailsModel(
      address: json['address'],
      location: json['location'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'address': address, 'location': location, 'phone': phone};
  }
}

class PaymentDetailsModel {
  final String? provider;
  final String? paymentIntentId;
  final String? status;

  PaymentDetailsModel({this.provider, this.paymentIntentId, this.status});

  factory PaymentDetailsModel.fromJson(Map<String, dynamic> json) {
    return PaymentDetailsModel(
      provider: json['provider'],
      paymentIntentId: json['paymentIntentId'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'paymentIntentId': paymentIntentId,
      'status': status,
    };
  }
}

class StatusHistoryModel {
  final String? id;
  final String? status;
  final DateTime? changedAt;

  StatusHistoryModel({this.id, this.status, this.changedAt});

  factory StatusHistoryModel.fromJson(Map<String, dynamic> json) {
    return StatusHistoryModel(
      id: json['id'] ?? json['_id'],
      status: json['status'],
      changedAt: json['changedAt'] != null
          ? DateTime.tryParse(json['changedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'changedAt': changedAt?.toIso8601String(),
    };
  }
}
