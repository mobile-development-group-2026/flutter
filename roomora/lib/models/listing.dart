class Listing {
  final int id;
  final String title;
  final String listingType;
  final String description;
  final String propertyType;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final double latitude;
  final double longitude;
  final double rent;
  final double securityDeposit;
  final bool utilitiesIncluded;
  final double? utilitiesCost;
  final DateTime availableDate;
  final int leaseTermMonths;
  final int bedrooms;
  final int bathrooms;
  final bool petsAllowed;
  final bool partiesAllowed;
  final bool smokingAllowed;
  final int userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Listing({
    required this.id,
    required this.title,
    required this.listingType,
    required this.description,
    required this.propertyType,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.latitude,
    required this.longitude,
    required this.rent,
    required this.securityDeposit,
    required this.utilitiesIncluded,
    this.utilitiesCost,
    required this.availableDate,
    required this.leaseTermMonths,
    required this.bedrooms,
    required this.bathrooms,
    required this.petsAllowed,
    required this.partiesAllowed,
    required this.smokingAllowed,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      listingType: json['listing_type'] as String? ?? 'property',
      description: json['description'] as String? ?? '',
      propertyType: json['property_type'] as String? ?? 'apartment',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      zipCode: json['zip_code'] as String? ?? '',
      latitude: (json['latitude'] as num? ?? 0).toDouble(),
      longitude: (json['longitude'] as num? ?? 0).toDouble(),
      rent: (json['rent'] as num? ?? 0).toDouble(),
      securityDeposit: (json['security_deposit'] as num? ?? 0).toDouble(),
      utilitiesIncluded: json['utilities_included'] as bool? ?? false,
      utilitiesCost: (json['utilities_cost'] as num?)?.toDouble(),
      availableDate: DateTime.parse(json['available_date'] as String? ?? DateTime.now().toIso8601String()),
      leaseTermMonths: json['lease_term_months'] as int? ?? 12,
      bedrooms: json['bedrooms'] as int? ?? 1,
      bathrooms: json['bathrooms'] as int? ?? 1,
      petsAllowed: json['pets_allowed'] as bool? ?? false,
      partiesAllowed: json['parties_allowed'] as bool? ?? false,
      smokingAllowed: json['smoking_allowed'] as bool? ?? false,
      userId: json['user_id'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'listing_type': listingType,
      'description': description,
      'property_type': propertyType,
      'address': address,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'latitude': latitude,
      'longitude': longitude,
      'rent': rent,
      'security_deposit': securityDeposit,
      'utilities_included': utilitiesIncluded,
      'utilities_cost': utilitiesCost,
      'available_date': availableDate.toIso8601String().split('T').first,
      'lease_term_months': leaseTermMonths,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'pets_allowed': petsAllowed,
      'parties_allowed': partiesAllowed,
      'smoking_allowed': smokingAllowed,
    };
  }
}