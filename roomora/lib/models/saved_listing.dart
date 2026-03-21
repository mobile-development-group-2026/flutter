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

  SavedListing({
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
      id: json['id'] ?? '',
      listingId: json['listing_id'] ?? '',
      title: json['title'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      visited: json['visited'] ?? false,
      savedAt: DateTime.parse(json['saved_at'] ?? DateTime.now().toIso8601String()),
      visitedAt: json['visited_at'] != null ? DateTime.parse(json['visited_at']) : null,
      distance: (json['distance'] ?? 100).toDouble(),
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
}