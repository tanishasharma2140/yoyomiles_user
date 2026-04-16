import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class DriverRideViewModel extends ChangeNotifier {
  IO.Socket? _socket;

  Map<String, dynamic>? _currentRideData;
  Map<String, dynamic>? _driverData;
  LatLng? _driverLocation;

  int _rideStatus = 0;
  int _payMode = 1;
  String _otp = "";
  bool _isSearching = true;
  List<dynamic> _stops = [];

  String? _currentOrderId;
  bool _isListening = false;

  Map<String, dynamic>? get currentRideData => _currentRideData;
  Map<String, dynamic>? get driverData => _driverData;
  LatLng? get driverLocation => _driverLocation;
  int get rideStatus => _rideStatus;
  int get payMode => _payMode;
  String get otp => _otp;
  bool get isSearching => _isSearching;
  List<dynamic> get stops => _stops;

  static const String _baseUrl = "https://dev.yoyomiles.com/";

  void startListening(String orderId, String userId) {
    if (_isListening && _currentOrderId == orderId) {
      print("⚠️ Already listening for order: $orderId");
      return;
    }

    _currentOrderId = orderId;
    _isListening = true;
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
    });

    _socket!.on('ORDER_UPDATE', (data) {
      print("TYPE: ${data.runtimeType}");
      print("DATA: $data");
      final incomingOrderId = data['id']?.toString() ?? '';
      if (incomingOrderId != orderId) return;
      _handleOrderUpdate(data);
    });

    _socket!.on('DRIVER_LOCATION_UPDATE', (loc) {
      print("🚖 Driver Location update received: $loc");
      try {
        Map<String, dynamic> locData;
        if (loc is String) {
          locData = jsonDecode(loc);
        } else {
          locData = Map<String, dynamic>.from(loc);
        }

        double? lat = double.tryParse(locData['lat']?.toString() ?? locData['latitude']?.toString() ?? '');
        double? lng = double.tryParse(locData['lng']?.toString() ?? locData['longitude']?.toString() ?? '');

        if (lat != null && lng != null) {
          _driverLocation = LatLng(lat, lng);
          notifyListeners();
        }
      } catch (e) {
        print("❌ Error parsing driver location: $e");
      }
    });

    _socket!.connect();
  }

  void setInitialData(Map<String, dynamic> orderData) {
    _currentRideData = {
      ...orderData,
      'document_id': orderData['document_id']?.toString() ?? '',
    };
    _rideStatus = int.tryParse(orderData['ride_status']?.toString() ?? '0') ?? 0;
    _payMode = int.tryParse(orderData['paymode']?.toString() ?? '1') ?? 1;
    _otp = orderData['otp']?.toString() ?? "";
    _stops = orderData['stops'] != null ? List.from(orderData['stops']) : [];
    _isSearching = true;
    _driverData = null;
    _driverLocation = null;
    notifyListeners();
  }

  void _handleOrderUpdate(dynamic data) {
    try {
      final Map<String, dynamic> orderMap = Map<String, dynamic>.from(data);

      final newStatus = int.tryParse(orderMap['ride_status']?.toString() ?? '0') ?? 0;
      final newPayMode = int.tryParse(orderMap['paymode']?.toString() ?? '1') ?? 1;
      final newOtp = orderMap['otp']?.toString() ?? "";


      final newStops = safeList(orderMap['stops']);

      orderMap['document_id'] = orderMap['id']?.toString() ?? '';

      Map<String, dynamic>? newDriverData;
      if (orderMap['driver_id'] != null) {
        newDriverData = {
          'driver_id': orderMap['driver_id'],
          'driver_name': orderMap['driver_name'] ?? '',
          'phone': orderMap['driver_phone']?.toString() ?? '',
          'vehicle_no': orderMap['vehicle_no'] ?? '',
          'vehicle_type_name': orderMap['driver_vehicle_type'] ?? '',
          'owner_selfie': orderMap['owner_selfie'] ?? '',
        };

        double? dLat = double.tryParse(orderMap['driver_lat']?.toString() ?? '');
        double? dLng = double.tryParse(orderMap['driver_lng']?.toString() ?? '');
        if (dLat != null && dLng != null) {
          _driverLocation = LatLng(dLat, dLng);
        }
      }

      _currentRideData = orderMap;
      _rideStatus = newStatus;
      _payMode = newPayMode;
      _otp = newOtp;
      _stops = newStops;
      _driverData = newDriverData;
      _isSearching = (newDriverData == null && newStatus == 0);

      notifyListeners();
    } catch (e) {
      print("❌ Error parsing ORDER_UPDATE: $e");
    }
  }

  List<dynamic> safeList(dynamic value) {
    if (value == null) return [];

    if (value is String) {
      try {
        final decoded = jsonDecode(value);
        return decoded is List ? List.from(decoded) : [];
      } catch (e) {
        print("❌ safeList decode error: $e");
        return [];
      }
    }

    if (value is List) {
      return List.from(value);
    }

    return [];
  }

  // void _handleOrderUpdate(dynamic data) {
  //   try {
  //     final Map<String, dynamic> orderMap = Map<String, dynamic>.from(data);
  //
  //     final newStatus = int.tryParse(orderMap['ride_status']?.toString() ?? '0') ?? 0;
  //     final newPayMode = int.tryParse(orderMap['paymode']?.toString() ?? '1') ?? 1;
  //     final newOtp = orderMap['otp']?.toString() ?? "";
  //     final newStops = orderMap['stops'] != null ? List.from(orderMap['stops']) : [];
  //
  //     orderMap['document_id'] = orderMap['id']?.toString() ?? '';
  //
  //     Map<String, dynamic>? newDriverData;
  //     if (orderMap['driver_id'] != null) {
  //       newDriverData = {
  //         'driver_id': orderMap['driver_id'],
  //         'driver_name': orderMap['driver_name'] ?? '',
  //         'phone': orderMap['driver_phone']?.toString() ?? '',
  //         'vehicle_no': orderMap['vehicle_no'] ?? '',
  //         'vehicle_type_name': orderMap['driver_vehicle_type'] ?? '',
  //         'owner_selfie': orderMap['owner_selfie'] ?? '',
  //         'vehicle_image': orderMap['vehicle_image'] ?? '',
  //       };
  //
  //       double? dLat = double.tryParse(orderMap['driver_lat']?.toString() ?? '');
  //       double? dLng = double.tryParse(orderMap['driver_lng']?.toString() ?? '');
  //       if (dLat != null && dLng != null) {
  //         _driverLocation = LatLng(dLat, dLng);
  //       }
  //     }
  //
  //     _currentRideData = orderMap;
  //     _rideStatus = newStatus;
  //     _payMode = newPayMode;
  //     _otp = newOtp;
  //     _stops = newStops;
  //     _driverData = newDriverData;
  //     _isSearching = (newDriverData == null && newStatus == 0);
  //
  //     notifyListeners();
  //   } catch (e) {
  //     print("❌ Error parsing ORDER_UPDATE: $e");
  //   }
  // }

  void stopListening() {
    _isListening = false;
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
