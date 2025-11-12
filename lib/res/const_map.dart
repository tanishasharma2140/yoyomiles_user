import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ConstMap extends StatefulWidget {
  final double? height;
  final ValueChanged<String>? onAddressFetched;
  final ValueChanged<LatLng>? onLatLngFetched;
  final bool backIconAllowed;

  const ConstMap({
    super.key,
    this.height,
    this.onAddressFetched,
    this.onLatLngFetched,  this.backIconAllowed = true,
  });

  @override
  State<ConstMap> createState() => _ConstMapState();
}

class _ConstMapState extends State<ConstMap> {
  GoogleMapController? mapController;
  final LatLng _initialPosition = LatLng(26.8467, 80.9462);
  LatLng? _currentPosition;
  Marker? _currentLocationMarker;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    _currentPosition = LatLng(position.latitude, position.longitude);

    _currentLocationMarker = Marker(
      markerId: MarkerId("currentLocation"),
      position: _currentPosition!,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    // Pass the LatLng back to the parent widget
    widget.onLatLngFetched?.call(_currentPosition!);

    setState(() {});

    _fetchAddress(position.latitude, position.longitude);

    if (mapController != null) {
      mapController!.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentPosition!, zoom: 15),
      ));
    }
  }

  Future<void> _fetchAddress(double latitude, double longitude) async {
    const String apiKey = 'AIzaSyANhzkw-SjvdzDvyPsUBDFmvEHfI9b8QqA';
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final address = data['results'][0]['formatted_address'];
          widget.onAddressFetched?.call(address);
        }
      } else {
        if (kDebugMode) {
          print('Failed to fetch address: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching address: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: widget.height ?? MediaQuery.of(context).size.height,
          child: GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
              if (_currentPosition != null) {
                mapController!.animateCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(target: _currentPosition!, zoom: 15),
                ));
              }
            },
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 10,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            markers: _currentLocationMarker != null
                ? {_currentLocationMarker!}
                : {},
          ),
        ),
        if(widget.backIconAllowed)
        Positioned(
          top: 40.0,
          left: 10.0,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
