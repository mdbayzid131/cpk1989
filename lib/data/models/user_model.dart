import 'package:cpk1989/config/constants/api_constants.dart';

class ProfileResponseModel {
  final bool? success;
  final String? message;
  final UserModel? data;

  ProfileResponseModel({this.success, this.message, this.data});

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return ProfileResponseModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? UserModel.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data?.toJson()};
  }
}

class UserModel {
  final String? id;
  final String? name;
  final String? role;
  final String? email;
  final String? image;
  final String? avatar;
  final String? provider;
  final String? country;
  final String? location;
  final String? address;
  final String? gender;
  final String? dateOfBirth;
  final String? phone;
  final bool? isOnboardingCompleted;
  final String? status;
  final bool? verified;
  final List<DeviceToken>? deviceTokens;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    this.id,
    this.name,
    this.role,
    this.email,
    this.image,
    this.avatar,
    this.provider,
    this.country,
    this.location,
    this.address,
    this.gender,
    this.dateOfBirth,
    this.phone,
    this.isOnboardingCompleted,
    this.status,
    this.verified,
    this.deviceTokens,
    this.createdAt,
    this.updatedAt,
  });

  String get displayImage {
    final raw = (image != null && image!.isNotEmpty)
        ? image!
        : (avatar != null && avatar!.isNotEmpty)
        ? avatar!
        : '';
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

  UserModel copyWith({
    String? id,
    String? name,
    String? role,
    String? email,
    String? image,
    String? avatar,
    String? provider,
    String? country,
    String? location,
    String? address,
    String? gender,
    String? dateOfBirth,
    String? phone,
    bool? isOnboardingCompleted,
    String? status,
    bool? verified,
    List<DeviceToken>? deviceTokens,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      email: email ?? this.email,
      image: image ?? this.image,
      avatar: avatar ?? this.avatar,
      provider: provider ?? this.provider,
      country: country ?? this.country,
      location: location ?? this.location,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phone: phone ?? this.phone,
      isOnboardingCompleted:
          isOnboardingCompleted ?? this.isOnboardingCompleted,
      status: status ?? this.status,
      verified: verified ?? this.verified,
      deviceTokens: deviceTokens ?? this.deviceTokens,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'],
      name: json['name'],
      role: json['role'],
      email: json['email'],
      image: json['image'] ?? json['profileImage'] ?? json['profilePicture'],
      avatar: json['avatar'],
      provider: json['provider'],
      country: json['country'],
      location: json['location'],
      address: json['address'],
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'],
      phone: json['phone'],
      isOnboardingCompleted: json['isOnboardingCompleted'],
      status: json['status'],
      verified: json['verified'],
      deviceTokens: json['deviceTokens'] != null
          ? (json['deviceTokens'] as List)
                .map((e) => DeviceToken.fromJson(e))
                .toList()
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'email': email,
      'image': image,
      'avatar': avatar,
      'provider': provider,
      'country': country,
      'location': location,
      'address': address,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'phone': phone,
      'isOnboardingCompleted': isOnboardingCompleted,
      'status': status,
      'verified': verified,
      'deviceTokens': deviceTokens?.map((e) => e.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class DeviceToken {
  final String? token;
  final DateTime? lastSeenAt;

  DeviceToken({this.token, this.lastSeenAt});

  factory DeviceToken.fromJson(Map<String, dynamic> json) {
    return DeviceToken(
      token: json['token'],
      lastSeenAt: json['lastSeenAt'] != null
          ? DateTime.tryParse(json['lastSeenAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'token': token, 'lastSeenAt': lastSeenAt?.toIso8601String()};
  }
}
