class UserModel {
  final String? id;
  final String? name;
  final String? role;
  final String? email;
  final String? country;
  final String? gender;
  final String? dateOfBirth;
  final String? phone;
  final String? profilePicture;
  final bool? isOnboardingCompleted;
  final String? status;
  final bool? verified;
  final List<DeviceToken>? deviceTokens;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? specialty;
  final String? hospital;

  UserModel({
    this.id,
    this.name,
    this.role,
    this.email,
    this.country,
    this.gender,
    this.dateOfBirth,
    this.phone,
    this.profilePicture,
    this.isOnboardingCompleted,
    this.status,
    this.verified,
    this.deviceTokens,
    this.createdAt,
    this.updatedAt,
    this.specialty,
    this.hospital,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'],
      name: json['name'],
      role: json['role'],
      email: json['email'],
      country: json['country'],
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'],
      phone: json['phone'],
      profilePicture: json['profilePicture'],
      isOnboardingCompleted: json['isOnboardingCompleted'],
      status: json['status'],
      verified: json['verified'],
      specialty: json['specialty'],
      hospital: json['hospital'],
      deviceTokens: json['deviceTokens'] != null
          ? (json['deviceTokens'] as List)
              .map((e) => DeviceToken.fromJson(e))
              .toList()
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'email': email,
      'country': country,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'phone': phone,
      'profilePicture': profilePicture,
      'isOnboardingCompleted': isOnboardingCompleted,
      'status': status,
      'verified': verified,
      'deviceTokens': deviceTokens?.map((e) => e.toJson()).toList(),
      'specialty': specialty,
      'hospital': hospital,
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
          ? DateTime.parse(json['lastSeenAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'lastSeenAt': lastSeenAt?.toIso8601String(),
    };
  }
}
