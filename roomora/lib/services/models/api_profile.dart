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

  const ApiProfile({
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
      id: json['id']?.toString() ?? '',
      bio: json['bio'] as String?,
      profilePhoto: json['profile_photo'] as String?,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      university: json['university'] as String?,
      verified: json['verified'] as bool? ?? false,
      role: json['role'] as String? ?? 'landlord',
      clerkId: json['clerk_id'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
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

  ApiProfile copyWith({
    String? id,
    String? bio,
    String? profilePhoto,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? university,
    bool? verified,
    String? role,
    String? clerkId,
    String? createdAt,
    String? updatedAt,
  }) {
    return ApiProfile(
      id: id ?? this.id,
      bio: bio ?? this.bio,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      university: university ?? this.university,
      verified: verified ?? this.verified,
      role: role ?? this.role,
      clerkId: clerkId ?? this.clerkId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ApiProfile &&
        other.id == id &&
        other.bio == bio &&
        other.profilePhoto == profilePhoto &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.email == email &&
        other.phone == phone &&
        other.university == university &&
        other.verified == verified &&
        other.role == role &&
        other.clerkId == clerkId;
  }

  @override
  int get hashCode => Object.hash(
    id,
    bio,
    profilePhoto,
    firstName,
    lastName,
    email,
    phone,
    university,
    verified,
    role,
    clerkId,
    createdAt,
    updatedAt,
  );
}