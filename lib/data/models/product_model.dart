import 'package:cpk1989/config/constants/api_constants.dart';

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
  final SellerModel? seller;
  final bool? originalPackagingAvailable;
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
    this.seller,
    this.originalPackagingAvailable,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
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
      seller: json['seller'] != null
          ? SellerModel.fromJson(json['seller'])
          : null,
      originalPackagingAvailable: json['originalPackagingAvailable'],
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
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class SellerModel {
  final String? id;
  final String? name;
  final String? profileImage;
  final String? contact;
  final String? location;
  final String? country;

  SellerModel({
    this.id,
    this.name,
    this.profileImage,
    this.contact,
    this.location,
    this.country,
  });

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
      return SellerModel(
        id: map['id'] ?? map['_id'],
        name: map['name'],
        profileImage:
            map['profileImage'] ??
            map['image'] ??
            map['avatar'] ??
            map['profilePicture'],
        contact: map['contact'],
        location: map['location'],
        country: map['country'],
      );
    }
    return SellerModel();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profileImage': profileImage,
      'contact': contact,
      'location': location,
      'country': country,
    };
  }
}
