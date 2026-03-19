import '../../models/landlord_profile.dart';

class ApiProfile {
  final String id;
  final String bio;
  final String profilePhoto;
  final String name;
  final String email;
  final String phone;
  final double responseRate;
  final int responseTime;
  final String createdAt;
  final String updatedAt;

  ApiProfile({
    required this.id,
    required this.bio,
    required this.profilePhoto,
    required this.name,
    required this.email,
    required this.phone,
    required this.responseRate,
    required this.responseTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApiProfile.fromJson(Map<String, dynamic> json) {
    return ApiProfile(
      id: json['id']?.toString() ?? '',
      bio: json['bio'] ?? '',
      profilePhoto: json['profilePhoto'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      responseRate: (json['responseRate'] ?? 100).toDouble(),
      responseTime: json['responseTime'] ?? 1,
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
      updatedAt: json['updatedAt'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bio': bio,
      'profilePhoto': profilePhoto,
      'name': name,
      'email': email,
      'phone': phone,
      'responseRate': responseRate,
      'responseTime': responseTime,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  LandlordProfile toProfile() {
    return LandlordProfile(
      id: id,
      bio: bio,
      profilePhoto: profilePhoto,
      name: name,
      email: email,
      phone: phone,
      responseRate: responseRate,
      responseTime: responseTime,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  static ApiProfile fromProfile(LandlordProfile profile) {
    return ApiProfile(
      id: profile.id,
      bio: profile.bio,
      profilePhoto: profile.profilePhoto,
      name: profile.name,
      email: profile.email,
      phone: profile.phone,
      responseRate: profile.responseRate,
      responseTime: profile.responseTime,
      createdAt: profile.createdAt.toIso8601String(),
      updatedAt: profile.updatedAt.toIso8601String(),
    );
  }
}