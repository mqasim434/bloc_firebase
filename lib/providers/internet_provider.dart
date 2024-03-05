import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
enum ConnectivityStatus { Connected, Disconnected }

class InternetProvider {
  final StreamController<ConnectivityStatus> _statusController =
  StreamController<ConnectivityStatus>.broadcast();

  InternetProvider() {
    Connectivity().onConnectivityChanged.listen((result) {
      _statusController.add(_getStatusFromResult(result));
    });
  }

  Stream<ConnectivityStatus> get statusStream => _statusController.stream;

  ConnectivityStatus _getStatusFromResult(ConnectivityResult result) {
    return result == ConnectivityResult.none
        ? ConnectivityStatus.Disconnected
        : ConnectivityStatus.Connected;
  }

  void dispose() {
    _statusController.close();
  }
}
