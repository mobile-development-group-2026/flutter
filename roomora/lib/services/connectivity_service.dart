import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal() {
    _setupListeners();
    _initConnectivity();
  }
  Future<void> _initConnectivity() async {
    _isConnected = await checkConnection();
  }
  final Connectivity _connectivity = Connectivity();
  final _controller = StreamController<bool>.broadcast();
  Stream<bool> get onConnectivityChanged => _controller.stream;

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  void _setupListeners() {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _isConnected = !results.contains(ConnectivityResult.none);
      _controller.add(_isConnected);
    });
  }

  Future<bool> checkConnection() async {
    final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    _isConnected = !results.contains(ConnectivityResult.none);
    return _isConnected;
  }

  void dispose() {
    _controller.close();
  }
}