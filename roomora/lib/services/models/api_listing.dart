class ApiListing {
  final String id;
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
  final String userId;
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
    String parseDate(String? dateString) {
      if (dateString == null || dateString.isEmpty) {
        return DateTime.now().toIso8601String();
      }
      return dateString;
    }

    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.parse(value);
      return 0.0;
    }

    return ApiListing(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      listingType: json['listing_type'] ?? json['listingType'] ?? '',
      description: json['description'] ?? '',
      propertyType: json['property_type'] ?? json['propertyType'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zip_code'] ?? json['zipCode'] ?? '',
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      rent: parseDouble(json['rent']),
      securityDeposit: parseDouble(json['security_deposit'] ?? json['securityDeposit']),
      utilitiesIncluded: json['utilities_included'] ?? json['utilitiesIncluded'] ?? false,
      utilitiesCost: json['utilities_cost'] != null ? parseDouble(json['utilities_cost']) : null,
      availableDate: json['available_date'] ?? json['availableDate'] ?? '',
      leaseTermMonths: json['lease_term_months'] ?? json['leaseTermMonths'] ?? 0,
      bedrooms: json['bedrooms'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
      petsAllowed: json['pets_allowed'] ?? json['petsAllowed'] ?? false,
      partiesAllowed: json['parties_allowed'] ?? json['partiesAllowed'] ?? false,
      smokingAllowed: json['smoking_allowed'] ?? json['smokingAllowed'] ?? false,
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      createdAt: parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: parseDate(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'listing': {
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
      }
    };
  }
}