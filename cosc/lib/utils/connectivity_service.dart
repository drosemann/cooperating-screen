/// Network connectivity helper for the mobile client.
/// It reports whether the device is online and which transport is currently
/// available so the app can adjust call behavior and failover logic.
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final _connectivity = Connectivity();
  
  /// Get current connectivity status
  Future<ConnectivityStatus> getConnectivityStatus() async {
    final result = await _connectivity.checkConnectivity();
    
    if (result.contains(ConnectivityResult.mobile)) {
      return ConnectivityStatus.mobile;
    } else if (result.contains(ConnectivityResult.wifi)) {
      return ConnectivityStatus.wifi;
    } else if (result.contains(ConnectivityResult.ethernet)) {
      return ConnectivityStatus.ethernet;
    } else {
      return ConnectivityStatus.none;
    }
  }

  /// Stream connectivity changes
  Stream<ConnectivityStatus> get connectivityStream {
    return _connectivity.onConnectivityChanged.map((result) {
      if (result.contains(ConnectivityResult.mobile)) {
        return ConnectivityStatus.mobile;
      } else if (result.contains(ConnectivityResult.wifi)) {
        return ConnectivityStatus.wifi;
      } else if (result.contains(ConnectivityResult.ethernet)) {
        return ConnectivityStatus.ethernet;
      } else {
        return ConnectivityStatus.none;
      }
    });
  }

  /// Check if device is connected to internet
  Future<bool> hasConnection() async {
    final status = await getConnectivityStatus();
    return status != ConnectivityStatus.none;
  }
}

enum ConnectivityStatus { none, mobile, wifi, ethernet }
