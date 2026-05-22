class SavedListing {
  final String id;
  final String listingId;
  final String title;
  final String address;
  final double latitude;
  final double longitude;
  final bool visited;
  final DateTime savedAt;
  final DateTime? visitedAt;
  final double distance;

  const SavedListing({
    required this.id,
    required this.listingId,
    required this.title,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.visited,
    required this.savedAt,
    this.visitedAt,
    this.distance = 100,
  });

  factory SavedListing.fromJson(Map<String, dynamic> json) {
    return SavedListing(
      id: json['id'] as String? ?? '',
      listingId: json['listing_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num? ?? 0).toDouble(),
      longitude: (json['longitude'] as num? ?? 0).toDouble(),
      visited: json['visited'] as bool? ?? false,
      savedAt: json['saved_at'] != null
          ? DateTime.parse(json['saved_at'] as String)
          : DateTime.now(),
      visitedAt: json['visited_at'] != null
          ? DateTime.parse(json['visited_at'] as String)
          : null,
      distance: (json['distance'] as num? ?? 100).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listing_id': listingId,
      'title': title,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'visited': visited,
      'saved_at': savedAt.toIso8601String(),
      'visited_at': visitedAt?.toIso8601String(),
      'distance': distance,
    };
  }

  SavedListing copyWith({
    String? id,
    String? listingId,
    String? title,
    String? address,
    double? latitude,
    double? longitude,
    bool? visited,
    DateTime? savedAt,
    DateTime? visitedAt,
    double? distance,
  }) {
    return SavedListing(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
      title: title ?? this.title,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      visited: visited ?? this.visited,
      savedAt: savedAt ?? this.savedAt,
      visitedAt: visitedAt ?? this.visitedAt,
      distance: distance ?? this.distance,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SavedListing &&
        other.id == id &&
        other.listingId == listingId &&
        other.title == title &&
        other.address == address &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.visited == visited &&
        other.savedAt == savedAt &&
        other.visitedAt == visitedAt &&
        other.distance == distance;
  }

  @override
  int get hashCode => Object.hash(
    id,
    listingId,
    title,
    address,
    latitude,
    longitude,
    visited,
    savedAt,
    visitedAt,
    distance,
  );
}