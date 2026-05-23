class LocationAlert {
  final String id;
  final String listingId;
  final String listingTitle;
  final String message;
  final DateTime timestamp;
  final bool read;
  final double distance;
  final String address;

  const LocationAlert({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    required this.message,
    required this.timestamp,
    required this.read,
    required this.distance,
    required this.address,
  });

  factory LocationAlert.fromJson(Map<String, dynamic> json) {
    return LocationAlert(
      id: json['id'] as String? ?? '',
      listingId: json['listing_id'] as String? ?? '',
      listingTitle: json['listing_title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      read: json['read'] as bool? ?? false,
      distance: (json['distance'] as num? ?? 0).toDouble(),
      address: json['address'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listing_id': listingId,
      'listing_title': listingTitle,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'read': read,
      'distance': distance,
      'address': address,
    };
  }

  LocationAlert copyWith({
    String? id,
    String? listingId,
    String? listingTitle,
    String? message,
    DateTime? timestamp,
    bool? read,
    double? distance,
    String? address,
  }) {
    return LocationAlert(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
      listingTitle: listingTitle ?? this.listingTitle,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      read: read ?? this.read,
      distance: distance ?? this.distance,
      address: address ?? this.address,
    );
  }

  LocationAlert markAsRead() {
    return LocationAlert(
      id: id,
      listingId: listingId,
      listingTitle: listingTitle,
      message: message,
      timestamp: timestamp,
      read: true,
      distance: distance,
      address: address,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationAlert &&
        other.id == id &&
        other.listingId == listingId &&
        other.listingTitle == listingTitle &&
        other.message == message &&
        other.timestamp == timestamp &&
        other.read == read &&
        other.distance == distance &&
        other.address == address;
  }

  @override
  int get hashCode => Object.hash(
    id,
    listingId,
    listingTitle,
    message,
    timestamp,
    read,
    distance,
    address,
  );
}