import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  StreamSubscription<Position>? _positionSubscription;
  Position? _currentPosition;
  final List<Function(Position)> _listeners = [];

  Future<bool> requestPermissions() async {
    PermissionStatus locationPermission = await Permission.location.request();
    PermissionStatus notificationPermission = await Permission.notification.request();
    
    return locationPermission.isGranted && notificationPermission.isGranted;
  }

  Future<bool> checkPermissions() async {
    PermissionStatus locationPermission = await Permission.location.status;
    PermissionStatus notificationPermission = await Permission.notification.status;
    
    return locationPermission.isGranted && notificationPermission.isGranted;
  }

  Future<Position?> getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      Position position = await Geolocator.getCurrentPosition();
      
      _currentPosition = position;
      return position;
    } catch (e) {
      return null;
    }
  }

  void startListening(Function(Position) onPositionChanged) {
    _listeners.add(onPositionChanged);
    
    if (_positionSubscription != null) return;

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 50,
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      _currentPosition = position;
      for (var listener in _listeners) {
        listener(position);
      }
    });
  }

  void stopListening() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _listeners.clear();
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  Position? get currentPosition => _currentPosition;
}