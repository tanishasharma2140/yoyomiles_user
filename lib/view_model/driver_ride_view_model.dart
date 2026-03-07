// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
//
// class DriverRideViewModel extends ChangeNotifier {
//   Map<String, dynamic>? _currentRideData;
//   Map<String, dynamic>? _driverData;
//   StreamSubscription<DocumentSnapshot>? _rideSubscription;
//   StreamSubscription<DocumentSnapshot>? _driverSubscription;
//   bool _isListening = false;
//
//   Map<String, dynamic>? get currentRideData => _currentRideData;
//   Map<String, dynamic>? get driverData => _driverData;
//   bool get isListening => _isListening;
//
//   // 🔥 START LISTENING TO RIDE UPDATES
//   void startListening(String orderId) {
//     if (_isListening) {
//       print("⚠️ Already listening to order: $orderId");
//       return;
//     }
//
//     print("🎧 Starting listener for order: $orderId");
//     _isListening = true;
//
//     _rideSubscription = FirebaseFirestore.instance
//         .collection('order')
//         .doc(orderId)
//         .snapshots()
//         .listen(
//           (DocumentSnapshot snapshot) {
//         print("🔔 Ride data update received at: ${DateTime.now()}");
//
//         if (snapshot.exists && snapshot.data() != null) {
//           final data = snapshot.data() as Map<String, dynamic>;
//
//           // Update ride data
//           _currentRideData = {
//             'id': orderId,
//             'document_id': orderId,
//             'sender_name': data['sender_name'],
//             'sender_phone': data['sender_phone'],
//             'reciver_name': data['reciver_name'],
//             'reciver_phone': data['reciver_phone'],
//             'pickup_address': data['pickup_address'],
//             'drop_address': data['drop_address'],
//             'pickup_latitute': data['pickup_latitute'],
//             'pick_longitude': data['pick_longitude'],
//             'drop_latitute': data['drop_latitute'],
//             'drop_logitute': data['drop_logitute'],
//             'rideStatus': data['ride_status'] ?? 0,
//             'payMode': data['paymode'] ?? 1,
//             'amount': data['amount'] ?? 0,
//             'distance': data['distance'] ?? 0,
//             'accepted_driver_id': data['accepted_driver_id'],
//             'otp': data['otp']?.toString() ?? 'N/A',
//             'order_type': data['order_type'] ?? 1,
//           };
//
//           print("""
// 📊 RIDE DATA UPDATED:
//    - Ride Status: ${_currentRideData!['rideStatus']}
//    - PayMode: ${_currentRideData!['payMode']}
//    - Driver ID: ${_currentRideData!['accepted_driver_id']}
//    - OTP: ${_currentRideData!['otp']}
//               """);
//
//           notifyListeners();
//
//           // 🔥 Start driver listener if driver assigned
//           final driverId = data['accepted_driver_id'];
//           if (driverId != null && driverId != 0) {
//             _startDriverListener(driverId.toString());
//           } else {
//             _stopDriverListener();
//             _driverData = null;
//           }
//         } else {
//           print("⚠️ Ride snapshot doesn't exist");
//           _currentRideData = null;
//           notifyListeners();
//         }
//       },
//       onError: (error) {
//         print("❌ Ride listener error: $error");
//       },
//     );
//   }
//
//   // 🔥 LISTEN TO DRIVER DATA
//   void _startDriverListener(String driverId) {
//     // Cancel existing driver listener
//     _driverSubscription?.cancel();
//
//     print("👤 Starting driver listener for ID: $driverId");
//
//     _driverSubscription = FirebaseFirestore.instance
//         .collection('driver')
//         .doc(driverId)
//         .snapshots()
//         .listen(
//           (DocumentSnapshot snapshot) {
//         print("🔔 Driver data update received");
//
//         if (snapshot.exists && snapshot.data() != null) {
//           _driverData = snapshot.data() as Map<String, dynamic>;
//
//           print("""
// 👤 DRIVER DATA UPDATED:
//    - Name: ${_driverData!['driver_name']}
//    - Phone: ${_driverData!['phone']}
//    - Vehicle: ${_driverData!['vehicle_no']}
//               """);
//
//           notifyListeners();
//         } else {
//           print("⚠️ Driver snapshot doesn't exist");
//           _driverData = null;
//           notifyListeners();
//         }
//       },
//       onError: (error) {
//         print("❌ Driver listener error: $error");
//       },
//     );
//   }
//
//   // 🔥 STOP DRIVER LISTENER
//   void _stopDriverListener() {
//     _driverSubscription?.cancel();
//     _driverSubscription = null;
//     print("🛑 Driver listener stopped");
//   }
//
//   // 🔥 STOP ALL LISTENERS
//   void stopListening() {
//     print("🛑 Stopping all listeners");
//     _rideSubscription?.cancel();
//     _driverSubscription?.cancel();
//     _rideSubscription = null;
//     _driverSubscription = null;
//     _isListening = false;
//     _currentRideData = null;
//     _driverData = null;
//     notifyListeners();
//   }
//
//   @override
//   void dispose() {
//     print("🗑️ Disposing DriverRideViewModel");
//     stopListening();
//     super.dispose();
//   }
//
//   // 🔥 HELPER METHODS
//   int get rideStatus => _currentRideData?['rideStatus'] ?? 0;
//   int get payMode => _currentRideData?['payMode'] ?? 1;
//   String get otp => _currentRideData?['otp'] ?? 'N/A';
//   dynamic get driverId => _currentRideData?['accepted_driver_id'];
//
//   bool get isDriverAssigned => driverId != null && driverId != 0;
//   bool get isSearching => !isDriverAssigned && rideStatus == 0;
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class DriverRideViewModel extends ChangeNotifier {
  IO.Socket? _socket;

  Map<String, dynamic>? _currentRideData;
  Map<String, dynamic>? _driverData;

  int _rideStatus = 0;
  int _payMode = 1;
  String _otp = "";
  bool _isSearching = true;

  String? _currentOrderId;
  bool _isListening = false;

  // ─── Getters ───────────────────────────────────────────────
  Map<String, dynamic>? get currentRideData => _currentRideData;
  Map<String, dynamic>? get driverData => _driverData;
  int get rideStatus => _rideStatus;
  int get payMode => _payMode;
  String get otp => _otp;
  bool get isSearching => _isSearching;

  // ─── Constants ─────────────────────────────────────────────
  static const String _baseUrl = "https://yoyo.codescarts.com/";

  // ─── Start Listening ───────────────────────────────────────
  void startListening(String orderId, String userId) {
    if (_isListening && _currentOrderId == orderId) {
      print("⚠️ Already listening for order: $orderId");
      return;
    }

    _currentOrderId = orderId;
    _isListening = true;

    print("🔌 Connecting socket — orderId: $orderId | userId: $userId");
    _connectSocket(orderId, userId);
  }

  void _connectSocket(String orderId, String userId) {
    _socket?.disconnect();
    _socket?.dispose();

    _socket = IO.io(
      _baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setTimeout(20000)
          .build(),
    );

    _socket!.onConnect((_) {
      print("✅ Socket connected: ${_socket!.id}");

      _socket!.emit("JOIN_USER", userId);
      print("📤 Emitted JOIN_USER: $userId");
    });

    _socket!.on('JOIN_CONFIRMED', (data) {
      print("✅ Join Confirmed: $data");
    });

    _socket!.on('ORDER_UPDATE', (data) {
      print("🔥 ORDER_UPDATE EVENT FIRED: $data");
      // ✅ Sirf apna order process karo
      final incomingOrderId = data['id']?.toString() ?? '';
      if (incomingOrderId != orderId) {
        print("⚠️ Ignoring ORDER_UPDATE for different order: $incomingOrderId");
        return;
      }
      print("📦 ORDER_UPDATE for our order: $orderId");
      _handleOrderUpdate(data);
    });

    _socket!.on('DRIVER_LOCATION_UPDATE', (loc) {
      print("🚖 Driver Location: $loc");
    });

    _socket!.onDisconnect((_) {
      print("❌ Socket disconnected");
    });

    _socket!.onConnectError((err) {
      print("❌ Socket connect error: $err");
    });

    _socket!.connect();
  }
  // ─── Initial data set karo jab socket connect ho raha ho ───
  void setInitialData(Map<String, dynamic> orderData) {
    _currentRideData = {
      ...orderData,
      'document_id': orderData['document_id']?.toString() ?? '',
    };
    _rideStatus = 0;
    _payMode = int.tryParse(orderData['paymode']?.toString() ?? '1') ?? 1;
    _otp = orderData['otp']?.toString() ?? "";
    _isSearching = true;
    _driverData = null;

    print("📋 Initial data set: ${_currentRideData?['document_id']}");
    notifyListeners();
  }

  // ─── Connect Socket ────────────────────────────────────────
  // void _connectSocket(String orderId) {
  //   // Disconnect old socket if any
  //   _socket?.disconnect();
  //   _socket?.dispose();
  //
  //   _socket = IO.io(
  //     _baseUrl,
  //     IO.OptionBuilder()
  //         .setTransports(['websocket', 'polling'])
  //         .enableReconnection()
  //         .setReconnectionAttempts(10)
  //         .setTimeout(20000)
  //         .build(),
  //   );
  //
  //   // ── on connect → join user room using orderId or userId
  //   _socket!.onConnect((_) {
  //     print("✅ Socket connected: ${_socket!.id}");
  //
  //     // JOIN_USER emit — socket HTML test mein userId se join tha
  //     // Yahan orderId ke andar userId available hona chahiye
  //     // Agar alag field hai toh wahan se lena
  //     _socket!.emit("JOIN_USER", orderId);
  //     print("📤 Emitted JOIN_USER: $orderId");
  //   });
  //
  //   // ── JOIN_CONFIRMED
  //   _socket!.on('JOIN_CONFIRMED', (data) {
  //     print("✅ Join Confirmed: $data");
  //   });
  //
  //   // ── ORDER_UPDATE — yahi Firebase ka replacement hai
  //   _socket!.on('ORDER_UPDATE', (data) {
  //     print("📦 ORDER_UPDATE received");
  //     _handleOrderUpdate(data);
  //   });
  //
  //   // ── DRIVER_LOCATION_UPDATE
  //   _socket!.on('DRIVER_LOCATION_UPDATE', (loc) {
  //     print("🚖 Driver Location: $loc");
  //     // Location update chahiye toh separate ViewModel ya callback se handle karo
  //   });
  //
  //   // ── Disconnect
  //   _socket!.onDisconnect((_) {
  //     print("❌ Socket disconnected");
  //   });
  //
  //   // ── Error
  //   _socket!.onConnectError((err) {
  //     print("❌ Socket connect error: $err");
  //   });
  //
  //   _socket!.connect();
  // }

  // ─── Handle ORDER_UPDATE (same logic jo Firebase mein thi) ─
  void _handleOrderUpdate(dynamic data) {
    try {
      print("📦 RAW ORDER_UPDATE DATA: $data");
      final Map<String, dynamic> orderMap = Map<String, dynamic>.from(data);

      // ── ride_status parse
      final newStatus = int.tryParse(
        orderMap['ride_status']?.toString() ?? '0',
      ) ??
          0;

      // ── paymode parse
      final newPayMode = int.tryParse(
        orderMap['paymode']?.toString() ?? '1',
      ) ??
          1;

      // ── OTP parse
      final newOtp = orderMap['otp']?.toString() ?? "";

      // ── document_id inject (socket data mein 'id' aata hai)
      orderMap['document_id'] = orderMap['id']?.toString() ?? '';

      // ── Driver info extract
      // Jab driver assign hota hai tab driver_name, driver_phone, vehicle_no aata hai
      Map<String, dynamic>? newDriverData;

      if (orderMap['driver_id'] != null &&
          orderMap['driver_name'] != null) {
        newDriverData = {
          'driver_name': orderMap['driver_name'] ?? '',
          'phone': orderMap['driver_phone']?.toString() ?? '',
          'vehicle_no': orderMap['vehicle_no'] ?? '',
          'vehicle_type_name': orderMap['driver_vehicle_type'] ?? '',
          'owner_selfie': orderMap['driver_selfie'] ?? '',
        };
      }

      // ── isSearching logic same as Firebase
      final searching = newDriverData == null && newStatus == 0;

      // ── State update
      _currentRideData = orderMap;
      _rideStatus = newStatus;
      _payMode = newPayMode;
      _otp = newOtp;
      _driverData = newDriverData;
      _isSearching = searching;

      print("🔄 Status: $_rideStatus | PayMode: $_payMode | Searching: $_isSearching");

      notifyListeners();
    } catch (e) {
      print("❌ Error parsing ORDER_UPDATE: $e");
    }
  }

  // ─── Stop Listening ────────────────────────────────────────
  void stopListening() {
    print("🛑 Stopping socket listener");
    _isListening = false;
    _currentOrderId = null;
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;

    // Reset state
    _currentRideData = null;
    _driverData = null;
    _rideStatus = 0;
    _payMode = 1;
    _otp = "";
    _isSearching = true;

    notifyListeners();
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}