class LandlordProfile {
  final String id;
  final String bio;
  final String profilePhoto;
  final String name;
  final String email;
  final String phone;
  final double responseRate;
  final int responseTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  LandlordProfile({
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

  factory LandlordProfile.fromJson(Map<String, dynamic> json) {
    return LandlordProfile(
      id: json['id'] ?? '',
      bio: json['bio'] ?? '',
      profilePhoto: json['profilePhoto'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      responseRate: (json['responseRate'] ?? 100).toDouble(),
      responseTime: json['responseTime'] ?? 1,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  LandlordProfile copyWith({
    String? id,
    String? bio,
    String? profilePhoto,
    String? name,
    String? email,
    String? phone,
    double? responseRate,
    int? responseTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LandlordProfile(
      id: id ?? this.id,
      bio: bio ?? this.bio,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      responseRate: responseRate ?? this.responseRate,
      responseTime: responseTime ?? this.responseTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}