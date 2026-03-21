class ApiProfile {
  final String id;
  final String? bio;
  final String? profilePhoto;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? university;
  final bool verified;
  final String role;
  final String clerkId;
  final String createdAt;
  final String updatedAt;

  ApiProfile({
    required this.id,
    this.bio,
    this.profilePhoto,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.university,
    required this.verified,
    required this.role,
    required this.clerkId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApiProfile.fromJson(Map<String, dynamic> json) {
    return ApiProfile(
      id: json['id'] ?? '',
      bio: json['bio'],
      profilePhoto: json['profile_photo'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      university: json['university'],
      verified: json['verified'] ?? false,
      role: json['role'] ?? 'landlord',
      clerkId: json['clerk_id'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'university': university,
      'bio': bio,
      'profile_photo': profilePhoto,
    };
  }
}