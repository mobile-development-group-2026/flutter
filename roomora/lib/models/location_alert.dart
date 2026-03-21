class LocationAlert {
  final String id;
  final String listingId;
  final String listingTitle;
  final String message;
  final DateTime timestamp;
  final bool read;
  final double distance;
  final String address;

  LocationAlert({
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
      id: json['id'] ?? '',
      listingId: json['listing_id'] ?? '',
      listingTitle: json['listing_title'] ?? '',
      message: json['message'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      read: json['read'] ?? false,
      distance: (json['distance'] ?? 0).toDouble(),
      address: json['address'] ?? '',
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
}