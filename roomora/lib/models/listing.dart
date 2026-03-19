class Listing {
  final String id;
  final String title;
  final double rent;
  final double deposit;
  final String leaseLength;
  final DateTime moveInDate;
  final List<String> houseRules;
  final List<String> photos;
  final String propertyType;
  final List<String> amenities;
  final String description;
  final String coverPhoto;
  final String landlordId;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;

  Listing({
    required this.id,
    required this.title,
    required this.rent,
    required this.deposit,
    required this.leaseLength,
    required this.moveInDate,
    required this.houseRules,
    required this.photos,
    required this.propertyType,
    required this.amenities,
    required this.description,
    required this.coverPhoto,
    required this.landlordId,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      rent: (json['rent'] ?? 0).toDouble(),
      deposit: (json['deposit'] ?? 0).toDouble(),
      leaseLength: json['leaseLength'] ?? '',
      moveInDate: DateTime.parse(json['moveInDate'] ?? DateTime.now().toIso8601String()),
      houseRules: List<String>.from(json['houseRules'] ?? []),
      photos: List<String>.from(json['photos'] ?? []),
      propertyType: json['propertyType'] ?? '',
      amenities: List<String>.from(json['amenities'] ?? []),
      description: json['description'] ?? '',
      coverPhoto: json['coverPhoto'] ?? '',
      landlordId: json['landlordId'] ?? '',
      isPublished: json['isPublished'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'rent': rent,
      'deposit': deposit,
      'leaseLength': leaseLength,
      'moveInDate': moveInDate.toIso8601String(),
      'houseRules': houseRules,
      'photos': photos,
      'propertyType': propertyType,
      'amenities': amenities,
      'description': description,
      'coverPhoto': coverPhoto,
      'landlordId': landlordId,
      'isPublished': isPublished,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Listing copyWith({
    String? id,
    String? title,
    double? rent,
    double? deposit,
    String? leaseLength,
    DateTime? moveInDate,
    List<String>? houseRules,
    List<String>? photos,
    String? propertyType,
    List<String>? amenities,
    String? description,
    String? coverPhoto,
    String? landlordId,
    bool? isPublished,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Listing(
      id: id ?? this.id,
      title: title ?? this.title,
      rent: rent ?? this.rent,
      deposit: deposit ?? this.deposit,
      leaseLength: leaseLength ?? this.leaseLength,
      moveInDate: moveInDate ?? this.moveInDate,
      houseRules: houseRules ?? this.houseRules,
      photos: photos ?? this.photos,
      propertyType: propertyType ?? this.propertyType,
      amenities: amenities ?? this.amenities,
      description: description ?? this.description,
      coverPhoto: coverPhoto ?? this.coverPhoto,
      landlordId: landlordId ?? this.landlordId,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}