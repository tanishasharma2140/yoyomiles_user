import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DriverRideViewModel extends ChangeNotifier {
  Map<String, dynamic>? _currentRideData;
  Map<String, dynamic>? _driverData;
  StreamSubscription<DocumentSnapshot>? _rideSubscription;
  StreamSubscription<DocumentSnapshot>? _driverSubscription;
  bool _isListening = false;

  Map<String, dynamic>? get currentRideData => _currentRideData;
  Map<String, dynamic>? get driverData => _driverData;
  bool get isListening => _isListening;

  // 🔥 START LISTENING TO RIDE UPDATES
  void startListening(String orderId) {
    if (_isListening) {
      print("⚠️ Already listening to order: $orderId");
      return;
    }

    print("🎧 Starting listener for order: $orderId");
    _isListening = true;

    _rideSubscription = FirebaseFirestore.instance
        .collection('order')
        .doc(orderId)
        .snapshots()
        .listen(
          (DocumentSnapshot snapshot) {
        print("🔔 Ride data update received at: ${DateTime.now()}");

        if (snapshot.exists && snapshot.data() != null) {
          final data = snapshot.data() as Map<String, dynamic>;

          // Update ride data
          _currentRideData = {
            'id': orderId,
            'document_id': orderId,
            'sender_name': data['sender_name'],
            'sender_phone': data['sender_phone'],
            'reciver_name': data['reciver_name'],
            'reciver_phone': data['reciver_phone'],
            'pickup_address': data['pickup_address'],
            'drop_address': data['drop_address'],
            'pickup_latitute': data['pickup_latitute'],
            'pick_longitude': data['pick_longitude'],
            'drop_latitute': data['drop_latitute'],
            'drop_logitute': data['drop_logitute'],
            'rideStatus': data['ride_status'] ?? 0,
            'payMode': data['paymode'] ?? 1,
            'amount': data['amount'] ?? 0,
            'distance': data['distance'] ?? 0,
            'accepted_driver_id': data['accepted_driver_id'],
            'otp': data['otp']?.toString() ?? 'N/A',
            'order_type': data['order_type'] ?? 1,
          };

          print("""
📊 RIDE DATA UPDATED:
   - Ride Status: ${_currentRideData!['rideStatus']}
   - PayMode: ${_currentRideData!['payMode']}
   - Driver ID: ${_currentRideData!['accepted_driver_id']}
   - OTP: ${_currentRideData!['otp']}
              """);

          notifyListeners();

          // 🔥 Start driver listener if driver assigned
          final driverId = data['accepted_driver_id'];
          if (driverId != null && driverId != 0) {
            _startDriverListener(driverId.toString());
          } else {
            _stopDriverListener();
            _driverData = null;
          }
        } else {
          print("⚠️ Ride snapshot doesn't exist");
          _currentRideData = null;
          notifyListeners();
        }
      },
      onError: (error) {
        print("❌ Ride listener error: $error");
      },
    );
  }

  // 🔥 LISTEN TO DRIVER DATA
  void _startDriverListener(String driverId) {
    // Cancel existing driver listener
    _driverSubscription?.cancel();

    print("👤 Starting driver listener for ID: $driverId");

    _driverSubscription = FirebaseFirestore.instance
        .collection('driver')
        .doc(driverId)
        .snapshots()
        .listen(
          (DocumentSnapshot snapshot) {
        print("🔔 Driver data update received");

        if (snapshot.exists && snapshot.data() != null) {
          _driverData = snapshot.data() as Map<String, dynamic>;

          print("""
👤 DRIVER DATA UPDATED:
   - Name: ${_driverData!['driver_name']}
   - Phone: ${_driverData!['phone']}
   - Vehicle: ${_driverData!['vehicle_no']}
              """);

          notifyListeners();
        } else {
          print("⚠️ Driver snapshot doesn't exist");
          _driverData = null;
          notifyListeners();
        }
      },
      onError: (error) {
        print("❌ Driver listener error: $error");
      },
    );
  }

  // 🔥 STOP DRIVER LISTENER
  void _stopDriverListener() {
    _driverSubscription?.cancel();
    _driverSubscription = null;
    print("🛑 Driver listener stopped");
  }

  // 🔥 STOP ALL LISTENERS
  void stopListening() {
    print("🛑 Stopping all listeners");
    _rideSubscription?.cancel();
    _driverSubscription?.cancel();
    _rideSubscription = null;
    _driverSubscription = null;
    _isListening = false;
    _currentRideData = null;
    _driverData = null;
    notifyListeners();
  }

  @override
  void dispose() {
    print("🗑️ Disposing DriverRideViewModel");
    stopListening();
    super.dispose();
  }

  // 🔥 HELPER METHODS
  int get rideStatus => _currentRideData?['rideStatus'] ?? 0;
  int get payMode => _currentRideData?['payMode'] ?? 1;
  String get otp => _currentRideData?['otp'] ?? 'N/A';
  dynamic get driverId => _currentRideData?['accepted_driver_id'];

  bool get isDriverAssigned => driverId != null && driverId != 0;
  bool get isSearching => !isDriverAssigned && rideStatus == 0;
}