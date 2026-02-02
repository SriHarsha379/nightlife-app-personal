// import 'package:flutter/material.dart';

// enum ConnectionStatus { WiFi, Mobile, Offline }

// class ConnectionProvider extends ChangeNotifier {
//   ConnectionStatus _status = ConnectionStatus.Offline;
//   ConnectionStatus _previousStatus = ConnectionStatus.Offline;
//   bool _showReconnectedMessage = false;

//   ConnectionStatus get status => _status;
//   ConnectionStatus get previousStatus => _previousStatus;
//   bool get showReconnectedMessage => _showReconnectedMessage;

//   void initialize() {
//     // Check initial connectivity
//     _checkInitialConnectivity();

//     // Listen to connectivity changes
//     Connectivity().onConnectivityChanged.listen((result) {
//       updateConnectionStatus(result);
//     });
//   }

//   Future<void> _checkInitialConnectivity() async {
//     final result = await Connectivity().checkConnectivity();
//     updateConnectionStatus(result);
//   }

//   void updateConnectionStatus(ConnectivityResult result) {
//     _previousStatus = _status;

//     switch (result) {
//       case ConnectivityResult.wifi:
//         _status = ConnectionStatus.WiFi;
//         break;
//       case ConnectivityResult.mobile:
//         _status = ConnectionStatus.Mobile;
//         break;
//       case ConnectivityResult.none:
//         _status = ConnectionStatus.Offline;
//         break;
//       default:
//         _status = ConnectionStatus.Offline;
//         break;
//     }

//     // Show reconnected message if coming back from offline
//     if (_previousStatus == ConnectionStatus.Offline &&
//         (_status == ConnectionStatus.WiFi ||
//             _status == ConnectionStatus.Mobile)) {
//       _showReconnectedMessage = true;
//       // Hide the message after 3 seconds
//       Future.delayed(const Duration(seconds: 3), () {
//         _showReconnectedMessage = false;
//         notifyListeners();
//       });
//     } else {
//       _showReconnectedMessage = false;
//     }

//     notifyListeners();
//   }
// }
