class ApiListing {
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
  final String availableDate;
  final int leaseTermMonths;
  final int bedrooms;
  final int bathrooms;
  final bool petsAllowed;
  final bool partiesAllowed;
  final bool smokingAllowed;
  final int userId;
  final String createdAt;
  final String updatedAt;

  ApiListing({
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

  factory ApiListing.fromJson(Map<String, dynamic> json) {
    return ApiListing(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      listingType: json['listing_type'] ?? 'property',
      description: json['description'] ?? '',
      propertyType: json['property_type'] ?? 'apartment',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zip_code'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      rent: (json['rent'] ?? 0).toDouble(),
      securityDeposit: (json['security_deposit'] ?? 0).toDouble(),
      utilitiesIncluded: json['utilities_included'] ?? false,
      utilitiesCost: json['utilities_cost']?.toDouble(),
      availableDate: json['available_date'] ?? '',
      leaseTermMonths: json['lease_term_months'] ?? 12,
      bedrooms: json['bedrooms'] ?? 1,
      bathrooms: json['bathrooms'] ?? 1,
      petsAllowed: json['pets_allowed'] ?? false,
      partiesAllowed: json['parties_allowed'] ?? false,
      smokingAllowed: json['smoking_allowed'] ?? false,
      userId: json['user_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
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
      'available_date': availableDate,
      'lease_term_months': leaseTermMonths,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'pets_allowed': petsAllowed,
      'parties_allowed': partiesAllowed,
      'smoking_allowed': smokingAllowed,
    };
  }
}