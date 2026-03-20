import 'dart:math';

class LocationCalculator {
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000;

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      double km = meters / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
  }

  static bool isWithinRange(double lat1, double lon1, double lat2, double lon2, double rangeMeters) {
    double distance = calculateDistance(lat1, lon1, lat2, lon2);
    return distance <= rangeMeters;
  }
}