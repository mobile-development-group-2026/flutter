class RoommateProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? bio;
  final String? profilePhoto;
  final String? university;
  final String role;
  final bool verified;
  final String clerkId;
  final DateTime createdAt;
  final DateTime updatedAt;

  RoommateProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.bio,
    this.profilePhoto,
    this.university,
    required this.role,
    required this.verified,
    required this.clerkId,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';
  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$f$l';
  }

  factory RoommateProfile.fromJson(Map<String, dynamic> json) {
    return RoommateProfile(
      id: json['id']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      bio: json['bio']?.toString(),
      profilePhoto: json['avatar_url']?.toString() ?? json['profile_photo']?.toString(),
      university: json['university']?.toString(),
      role: json['role']?.toString() ?? 'tenant',
      verified: json['verified'] == true || json['verified'] == 1,
      clerkId: json['clerk_id']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'bio': bio,
      'profile_photo': profilePhoto,
      'university': university,
      'role': role,
      'verified': verified,
      'clerk_id': clerkId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}