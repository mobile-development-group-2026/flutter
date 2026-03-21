class ApiProfile {
  final int id;
  final String clerkId;
  final String role;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? bio;
  final String? profilePhoto;
  final String? university;
  final bool verified;
  final bool onboarded;
  final String createdAt;
  final String updatedAt;

  ApiProfile({
    required this.id,
    required this.clerkId,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.bio,
    this.profilePhoto,
    this.university,
    required this.verified,
    required this.onboarded,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApiProfile.fromJson(Map<String, dynamic> json) {
    return ApiProfile(
      id: json['id'],
      clerkId: json['clerk_id'] ?? '',
      role: json['role'] ?? 'student',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      bio: json['bio'],
      profilePhoto: json['avatar_url'],
      university: json['university'],
      verified: json['verified'] ?? false,
      onboarded: json['onboarded'] ?? false,
      createdAt: json['created_at'] ?? DateTime.now().toIso8601String(),
      updatedAt: json['updated_at'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() => {
    'first_name': firstName,
    'last_name': lastName,
    'phone': phone,
    'avatar_url': profilePhoto,
    'onboarded': onboarded,
  };
}