import '../../models/listing.dart';

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
    int parseInt(dynamic v) => v == null ? 0 : (v is int ? v : int.tryParse(v.toString()) ?? 0);
    double parseDouble(dynamic v) => v == null ? 0.0 : (v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0);
    bool parseBool(dynamic v) => v == null ? false : (v is bool ? v : v.toString() == 'true' || v.toString() == '1');

    return ApiListing(
      id: parseInt(json['id']),
      title: json['title']?.toString() ?? '',
      listingType: json['listing_type']?.toString() ?? 'property',
      description: json['description']?.toString() ?? '',
      propertyType: json['property_type']?.toString() ?? 'apartment',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      zipCode: json['zip_code']?.toString() ?? '',
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      rent: parseDouble(json['rent']),
      securityDeposit: parseDouble(json['security_deposit']),
      utilitiesIncluded: parseBool(json['utilities_included']),
      utilitiesCost: json['utilities_cost'] != null ? parseDouble(json['utilities_cost']) : null,
      availableDate: json['available_date']?.toString() ?? '',
      leaseTermMonths: parseInt(json['lease_term_months']),
      bedrooms: parseInt(json['bedrooms']),
      bathrooms: parseInt(json['bathrooms']),
      petsAllowed: parseBool(json['pets_allowed']),
      partiesAllowed: parseBool(json['parties_allowed']),
      smokingAllowed: parseBool(json['smoking_allowed']),
      userId: parseInt(json['user_id']),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
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

  Listing toListing() {
    return Listing(
      id: id,
      title: title,
      listingType: listingType,
      description: description,
      propertyType: propertyType,
      address: address,
      city: city,
      state: state,
      zipCode: zipCode,
      latitude: latitude,
      longitude: longitude,
      rent: rent,
      securityDeposit: securityDeposit,
      utilitiesIncluded: utilitiesIncluded,
      utilitiesCost: utilitiesCost,
      availableDate: DateTime.parse(availableDate),
      leaseTermMonths: leaseTermMonths,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      petsAllowed: petsAllowed,
      partiesAllowed: partiesAllowed,
      smokingAllowed: smokingAllowed,
      userId: userId,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  static ApiListing fromListing(Listing listing) {
    return ApiListing(
      id: listing.id,
      title: listing.title,
      listingType: listing.listingType,
      description: listing.description,
      propertyType: listing.propertyType,
      address: listing.address,
      city: listing.city,
      state: listing.state,
      zipCode: listing.zipCode,
      latitude: listing.latitude,
      longitude: listing.longitude,
      rent: listing.rent,
      securityDeposit: listing.securityDeposit,
      utilitiesIncluded: listing.utilitiesIncluded,
      utilitiesCost: listing.utilitiesCost,
      availableDate: listing.availableDate.toIso8601String().split('T').first,
      leaseTermMonths: listing.leaseTermMonths,
      bedrooms: listing.bedrooms,
      bathrooms: listing.bathrooms,
      petsAllowed: listing.petsAllowed,
      partiesAllowed: listing.partiesAllowed,
      smokingAllowed: listing.smokingAllowed,
      userId: listing.userId,
      createdAt: listing.createdAt.toIso8601String(),
      updatedAt: listing.updatedAt.toIso8601String(),
    );
  }
}