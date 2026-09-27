import 'package:cpk1989/config/constants/api_constants.dart';
import 'package:cpk1989/data/models/order_model.dart';

class ProductModel {
  final String? id;
  final List<String>? images;
  final String? proofOfPurchase;
  final DateTime? reservationExpiresAt;
  final String? name;
  final String? brand;
  final String? description;
  final double? price;
  final String? condition;
  final String? status;
  final String? rejectionReason;
  final double? commissionAmount;
  final double? sellerEarnings;
  final String? packaging;
  final String? collectionAddress;
  final String? sellerPhone;
  final SellerModel? seller;
  final OrderBuyerModel? buyer;
  final OrderModel? order;
  final String? orderStatus;
  final bool? originalPackagingAvailable;
  final int? wishlistCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductModel({
    this.id,
    this.images,
    this.proofOfPurchase,
    this.reservationExpiresAt,
    this.name,
    this.brand,
    this.description,
    this.price,
    this.condition,
    this.status,
    this.rejectionReason,
    this.commissionAmount,
    this.sellerEarnings,
    this.packaging,
    this.collectionAddress,
    this.sellerPhone,
    this.seller,
    this.buyer,
    this.order,
    this.orderStatus,
    this.originalPackagingAvailable,
    this.wishlistCount,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    OrderModel? parsedOrder;
    if (json['order'] is Map) {
      parsedOrder = OrderModel.fromJson(
        Map<String, dynamic>.from(json['order']),
      );
    }

    OrderBuyerModel? parsedBuyer;
    if (json['buyer'] is Map) {
      parsedBuyer = OrderBuyerModel.fromJson(
        Map<String, dynamic>.from(json['buyer']),
      );
    } else if (parsedOrder?.buyerModel != null) {
      parsedBuyer = parsedOrder!.buyerModel;
    }

    return ProductModel(
      id: json['id'] ?? json['_id'],
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      proofOfPurchase: json['proofOfPurchase'],
      reservationExpiresAt: json['reservationExpiresAt'] != null
          ? DateTime.tryParse(json['reservationExpiresAt'].toString())
          : null,
      name: json['name'],
      brand: json['brand'],
      description: json['description'],
      price: json['price'] != null
          ? double.tryParse(json['price'].toString())
          : null,
      condition: json['condition'],
      status: json['status'],
      rejectionReason: json['rejectionReason'],
      commissionAmount: json['commissionAmount'] != null
          ? double.tryParse(json['commissionAmount'].toString())
          : null,
      sellerEarnings: json['sellerEarnings'] != null
          ? double.tryParse(json['sellerEarnings'].toString())
          : null,
      packaging: json['packaging'],
      collectionAddress: json['collectionAddress'],
      sellerPhone: json['sellerPhone'],
      seller: json['seller'] != null
          ? SellerModel.fromJson(json['seller'])
          : null,
      buyer: parsedBuyer,
      order: parsedOrder,
      orderStatus: json['orderStatus'] ?? parsedOrder?.status,
      originalPackagingAvailable: json['originalPackagingAvailable'],
      wishlistCount: json['wishlistCount'] != null
          ? int.tryParse(json['wishlistCount'].toString())
          : null,
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
      'images': images,
      'proofOfPurchase': proofOfPurchase,
      'reservationExpiresAt': reservationExpiresAt?.toIso8601String(),
      'name': name,
      'brand': brand,
      'description': description,
      'price': price,
      'condition': condition,
      'status': status,
      'seller': seller?.toJson(),
      'originalPackagingAvailable': originalPackagingAvailable,
      'wishlistCount': wishlistCount,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  String get displayFirstImage {
    if (images != null && images!.isNotEmpty) {
      final raw = images!.first;
      if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
      final serverBase = ApiConstants.baseUrl.replaceAll(
        RegExp(r'/api/v1/?$'),
        '',
      );
      return raw.startsWith('/') ? '$serverBase$raw' : '$serverBase/$raw';
    }
    return '';
  }

  String? get sellerId => seller?.id;

  List<String> get displayImages {
    if (images == null) return [];
    final serverBase = ApiConstants.baseUrl.replaceAll(
      RegExp(r'/api/v1/?$'),
      '',
    );
    return images!.map((raw) {
      if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
      return raw.startsWith('/') ? '$serverBase$raw' : '$serverBase/$raw';
    }).toList();
  }
}

class SellerModel {
  final String? id;
  final String? name;
  final String? profileImage;
  final String? contact;
  final String? phone;
  final String? location;
  final String? country;
  final bool? isVerified;

  SellerModel({
    this.id,
    this.name,
    this.profileImage,
    this.contact,
    this.phone,
    this.location,
    this.country,
    this.isVerified,
  });

  String? get effectivePhone => phone ?? contact;

  String get displayProfileImage {
    final raw = profileImage ?? '';
    if (raw.isEmpty) return '';
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }
    final serverBase = ApiConstants.baseUrl.replaceAll(
      RegExp(r'/api/v1/?$'),
      '',
    );
    return raw.startsWith('/') ? '$serverBase$raw' : '$serverBase/$raw';
  }

  factory SellerModel.fromJson(dynamic json) {
    if (json is String) {
      return SellerModel(id: json);
    }
    if (json is Map) {
      final map = Map<String, dynamic>.from(json);
      final ph = map['phone'] ?? map['contact'];
      return SellerModel(
        id: map['id'] ?? map['_id'],
        name: map['name'],
        profileImage:
            map['profileImage'] ??
            map['image'] ??
            map['avatar'] ??
            map['profilePicture'],
        contact: ph,
        phone: ph,
        location: map['location'],
        country: (map['country'] != null && map['country'].toString().trim().isNotEmpty)
            ? map['country'].toString().trim()
            : 'UAE',
        isVerified: map['isVerified'],
      );
    }
    return SellerModel();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profileImage': profileImage,
      'contact': contact ?? phone,
      'phone': phone ?? contact,
      'location': location,
      'country': country ?? 'UAE',
      'isVerified': isVerified,
    };
  }
}
