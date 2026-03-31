import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:yoyomiles/generated/assets.dart';
import 'package:yoyomiles/res/constant_color.dart';

class ConstWithPolylineMap extends StatefulWidget {
  final double? height;
  final ValueChanged<String>? onAddressFetched;
  final List<Map<String, dynamic>>? data;
  final int? rideStatus;
  final bool? backIconAllowed;
  final LatLng? driverLocation;

  const ConstWithPolylineMap({
    super.key,
    this.height,
    this.onAddressFetched,
    this.data,
    this.rideStatus,
    this.backIconAllowed = true,
    this.driverLocation,
  });

  @override
  State<ConstWithPolylineMap> createState() => _ConstWithPolylineMapState();
}

class _ConstWithPolylineMapState extends State<ConstWithPolylineMap> {
  GoogleMapController? mapController;
  final Completer<GoogleMapController> completer = Completer();
  final LatLng _initialPosition = LatLng(26.8467, 80.9462);
  LatLng? _currentPosition;

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  int? _previousRideStatus;
  LatLng? _previousDriverLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _addBookingMarkers();
    _previousRideStatus = widget.rideStatus;
    _previousDriverLocation = widget.driverLocation;
  }

  @override
  void didUpdateWidget(ConstWithPolylineMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    bool shouldUpdateRoute = false;

    if (oldWidget.rideStatus != widget.rideStatus || oldWidget.data != widget.data) {
      _previousRideStatus = widget.rideStatus;
      shouldUpdateRoute = true;
    }

    if (widget.driverLocation != null && widget.driverLocation != _previousDriverLocation) {
      _previousDriverLocation = widget.driverLocation;
      _updateDriverMarker(widget.driverLocation!);
      shouldUpdateRoute = true; 
    }

    if (shouldUpdateRoute) {
      _updatePolylinesBasedOnStatus();
    }
  }

  Future<void> _updateDriverMarker(LatLng position) async {
    final driverIcon = await resizeMarkerIcon(Assets.assetsTruck, 80);
    setState(() {
      _markers.removeWhere((m) => m.markerId.value == "driverMarker");
      _markers.add(
        Marker(
          markerId: const MarkerId("driverMarker"),
          position: position,
          icon: driverIcon,
          anchor: const Offset(0.5, 0.5),
          infoWindow: const InfoWindow(title: "Driver"),
        ),
      );
    });
  }

  Future<void> moveCameraOnPolyline(List<LatLng> points) async {
    if (points.isEmpty) return;
    final GoogleMapController controller = await completer.future;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (var p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    try {
      await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));
    } catch (e) {
      await controller.animateCamera(CameraUpdate.newLatLngZoom(points.first, 14));
    }
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition();
    _currentPosition = LatLng(position.latitude, position.longitude);

    final currentIcon = await resizeMarkerIcon(Assets.assetsHueCurrent, 85);

    setState(() {
      _markers.add(Marker(
        markerId: const MarkerId("currentLocation"),
        position: _currentPosition!,
        icon: currentIcon,
      ));
    });

    _fetchAddress(position.latitude, position.longitude);
    _updatePolylinesBasedOnStatus();
  }

  Future<void> _fetchAddress(double latitude, double longitude) async {
    const String apiKey = 'AIzaSyB0mG3CGok9-9RZau5J_VThUP4OTbQ_SFM';
    final url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          widget.onAddressFetched?.call(data['results'][0]['formatted_address']);
        }
      }
    } catch (e) {}
  }

  Future<List<LatLng>> _getRoutePoints(LatLng origin, LatLng destination) async {
    const String apiKey = 'AIzaSyB0mG3CGok9-9RZau5J_VThUP4OTbQ_SFM';
    final url = 'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return _decodePolyline(data['routes'][0]['overview_polyline']['points']);
        }
      }
    } catch (e) {}
    return [];
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length, lat = 0, lng = 0;
    while (index < len) {
      int b, shift = 0, result = 0;
      do { b = encoded.codeUnitAt(index++) - 63; result |= (b & 0x1F) << shift; shift += 5; } while (b >= 0x20);
      lat += ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      shift = 0; result = 0;
      do { b = encoded.codeUnitAt(index++) - 63; result |= (b & 0x1F) << shift; shift += 5; } while (b >= 0x20);
      lng += ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      polyline.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return polyline;
  }

  double? _safeToDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  void _updatePolylinesBasedOnStatus() {
    if (widget.data == null || widget.data!.isEmpty) return;
    _drawPolylinesBasedOnStatus(widget.data!.first);
  }

  Future<void> _drawPolylinesBasedOnStatus(Map<String, dynamic> booking) async {
    if (widget.rideStatus == null) return;

    LatLng? pickupLatLng;
    LatLng? dropLatLng;

    // Coordination extraction based on multiple possible keys
    double? pLat = _safeToDouble(booking['pickup_latitute'] ?? booking['pickup_lat']);
    double? pLng = _safeToDouble(booking['pick_longitude'] ?? booking['pickup_lng']);
    double? dLat = _safeToDouble(booking['drop_latitute'] ?? booking['drop_lat']);
    double? dLng = _safeToDouble(booking['drop_logitute'] ?? booking['drop_lng']);

    if (pLat != null && pLng != null) pickupLatLng = LatLng(pLat, pLng);
    if (dLat != null && dLng != null) dropLatLng = LatLng(dLat, dLng);

    final driverPos = widget.driverLocation ?? _currentPosition;
    List<LatLng> points = [];
    Color polyColor = PortColor.gold;
    String polyId = "route";

    if (widget.rideStatus! >= 1 && widget.rideStatus! <= 3) {
      if (driverPos != null && pickupLatLng != null) {
        points = await _getRoutePoints(driverPos, pickupLatLng);
        polyColor = PortColor.gold;
        polyId = "driver_to_pickup";
      }
    } else if (widget.rideStatus == 4) {
      if (driverPos != null && dropLatLng != null) {
        points = await _getRoutePoints(driverPos, dropLatLng);
        polyColor = PortColor.buttonBlue;
        polyId = "driver_to_drop";
      }
    } else if (widget.rideStatus! >= 5) {
      if (pickupLatLng != null && dropLatLng != null) {
        points = await _getRoutePoints(pickupLatLng, dropLatLng);
        polyColor = Colors.green;
        polyId = "pickup_to_drop";
      }
    }

    if (points.isNotEmpty) {
      setState(() {
        _polylines.clear();
        _polylines.add(Polyline(
          polylineId: PolylineId(polyId),
          points: points,
          color: polyColor,
          width: 5,
        ));
      });
      await moveCameraOnPolyline(points);
    }
  }

  Future<BitmapDescriptor> resizeMarkerIcon(String assetPath, int targetWidth) async {
    final ByteData data = await rootBundle.load(assetPath);
    final ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: targetWidth);
    final ui.FrameInfo fi = await codec.getNextFrame();
    final ByteData? byteData = await fi.image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  Future<void> _addBookingMarkers() async {
    if (widget.data == null || widget.data!.isEmpty) return;
    final booking = widget.data!.first;

    double? pLat = _safeToDouble(booking['pickup_latitute'] ?? booking['pickup_lat']);
    double? pLng = _safeToDouble(booking['pick_longitude'] ?? booking['pickup_lng']);
    double? dLat = _safeToDouble(booking['drop_latitute'] ?? booking['drop_lat']);
    double? dLng = _safeToDouble(booking['drop_logitute'] ?? booking['drop_lng']);

    final pickupIcon = await resizeMarkerIcon(Assets.assetsPicupYoyo, 65);
    final dropIcon = await resizeMarkerIcon(Assets.assetsDropYoyo, 65);

    setState(() {
      if (pLat != null && pLng != null) {
        _markers.add(Marker(markerId: const MarkerId("pickup"), position: LatLng(pLat, pLng), icon: pickupIcon));
      }
      if (dLat != null && dLng != null) {
        _markers.add(Marker(markerId: const MarkerId("drop"), position: LatLng(dLat, dLng), icon: dropIcon));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: (controller) {
        mapController = controller;
        if (!completer.isCompleted) completer.complete(controller);
        _updatePolylinesBasedOnStatus();
      },
      initialCameraPosition: CameraPosition(target: widget.driverLocation ?? _initialPosition, zoom: 12),
      myLocationEnabled: true,
      markers: _markers,
      polylines: _polylines,
      zoomControlsEnabled: false,
    );
  }
}
