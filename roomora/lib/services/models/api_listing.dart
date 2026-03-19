import '../../models/listing.dart';

class ApiListing {
  final String id;
  final String title;
  final double rent;
  final double deposit;
  final String leaseLength;
  final String moveInDate;
  final List<String> houseRules;
  final List<String> photos;
  final String propertyType;
  final List<String> amenities;
  final String description;
  final String coverPhoto;
  final String landlordId;
  final bool isPublished;
  final String createdAt;
  final String updatedAt;

  ApiListing({
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

  factory ApiListing.fromJson(Map<String, dynamic> json) {
    return ApiListing(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      rent: (json['rent'] ?? 0).toDouble(),
      deposit: (json['deposit'] ?? 0).toDouble(),
      leaseLength: json['leaseLength'] ?? '',
      moveInDate: json['moveInDate'] ?? DateTime.now().toIso8601String(),
      houseRules: List<String>.from(json['houseRules'] ?? []),
      photos: List<String>.from(json['photos'] ?? []),
      propertyType: json['propertyType'] ?? '',
      amenities: List<String>.from(json['amenities'] ?? []),
      description: json['description'] ?? '',
      coverPhoto: json['coverPhoto'] ?? '',
      landlordId: json['landlordId'] ?? '',
      isPublished: json['isPublished'] ?? false,
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
      updatedAt: json['updatedAt'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'rent': rent,
      'deposit': deposit,
      'leaseLength': leaseLength,
      'moveInDate': moveInDate,
      'houseRules': houseRules,
      'photos': photos,
      'propertyType': propertyType,
      'amenities': amenities,
      'description': description,
      'coverPhoto': coverPhoto,
      'landlordId': landlordId,
      'isPublished': isPublished,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Listing toListing() {
    return Listing(
      id: id,
      title: title,
      rent: rent,
      deposit: deposit,
      leaseLength: leaseLength,
      moveInDate: DateTime.parse(moveInDate),
      houseRules: houseRules,
      photos: photos,
      propertyType: propertyType,
      amenities: amenities,
      description: description,
      coverPhoto: coverPhoto,
      landlordId: landlordId,
      isPublished: isPublished,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  static ApiListing fromListing(Listing listing) {
    return ApiListing(
      id: listing.id,
      title: listing.title,
      rent: listing.rent,
      deposit: listing.deposit,
      leaseLength: listing.leaseLength,
      moveInDate: listing.moveInDate.toIso8601String(),
      houseRules: listing.houseRules,
      photos: listing.photos,
      propertyType: listing.propertyType,
      amenities: listing.amenities,
      description: listing.description,
      coverPhoto: listing.coverPhoto,
      landlordId: listing.landlordId,
      isPublished: listing.isPublished,
      createdAt: listing.createdAt.toIso8601String(),
      updatedAt: listing.updatedAt.toIso8601String(),
    );
  }
}