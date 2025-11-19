import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:yoyomiles/generated/assets.dart';
import 'package:yoyomiles/main.dart';
import 'package:yoyomiles/res/app_btn.dart';
import 'package:yoyomiles/res/app_fonts.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/res/constant_text.dart';
import 'package:yoyomiles/view_model/order_view_model.dart';
import 'package:yoyomiles/view_model/select_vehicles_view_model.dart';
import 'package:yoyomiles/view_model/service_type_view_model.dart';
import 'package:provider/provider.dart';

class RideMapScreen extends StatefulWidget {
  final String pickupLocation;
  final String dropLocation;
  final double? pickupLat;
  final double? pickupLng;
  final double? dropLat;
  final double? dropLng;

  const RideMapScreen({
    super.key,
    required this.pickupLocation,
    required this.dropLocation,
    this.pickupLat,
    this.pickupLng,
    this.dropLat,
    this.dropLng,
  });

  @override
  State<RideMapScreen> createState() => _RideMapScreenState();
}

class _RideMapScreenState extends State<RideMapScreen> {
  late GoogleMapController mapController;
  Set<Polyline> polylines = {};
  Set<Marker> markers = {};
  bool isLoading = true;
  double distance = 0.0;
  List<Map<String, dynamic>> vehicles = [];
  int selectedPayment = 1; // default = online

  @override
  void initState() {
    super.initState();
    print("📍 Received Coordinates:");
    print("Pickup - Lat: ${widget.pickupLat}, Lng: ${widget.pickupLng}");
    print("Drop - Lat: ${widget.dropLat}, Lng: ${widget.dropLng}");
    _initializeMap();
  }

  // Calculate distance between two LatLng points in kilometers
  double _calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    double lat1 = start.latitude * (3.141592653589793 / 180);
    double lon1 = start.longitude * (3.141592653589793 / 180);
    double lat2 = end.latitude * (3.141592653589793 / 180);
    double lon2 = end.longitude * (3.141592653589793 / 180);

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  Future<BitmapDescriptor> resizeMarkerIcon(String assetPath, int targetWidth) async {
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();

    final ui.Codec codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: targetWidth,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();

    final ByteData? byteData =
    await fi.image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List resizedBytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(resizedBytes);
  }


  // Fetch vehicles from API
  Future<void> _fetchVehicles() async {
    // if (isFetchingVehicles) return;
    //
    // setState(() {
    //   isFetchingVehicles = true;
    // });

    try {
      final serviceTypeViewModel = Provider.of<ServiceTypeViewModel>(
        context,
        listen: false,
      );
      final selectVehiclesViewModel = Provider.of<SelectVehiclesViewModel>(
        context,
        listen: false,
      );

      // Call the API with calculated distance
      await selectVehiclesViewModel.selectVehicleApi(
        serviceTypeViewModel.selectedVehicleId!,
        distance.toStringAsFixed(2),
        serviceTypeViewModel.selectedVehicleType!,
        widget.pickupLat,
        widget.pickupLng,
        context,
      );

      // Get the vehicles data from ViewModel
      if (selectVehiclesViewModel.selectVehicleModel != null &&
          selectVehiclesViewModel.selectVehicleModel!.data != null) {
        setState(() {
          vehicles = selectVehiclesViewModel.selectVehicleModel!.data!
              .map((vehicle) => {
            'vehicle_id': vehicle.vehicleId,
            'vehicle_name': vehicle.vehicleName,
            'body_detail': vehicle.bodyDetail,
            'vehicle_image': vehicle.vehicleImage,
            'amount': vehicle.amount,
            'selected_status': vehicle.selectedStatus,
            'type': vehicle.type,
            'comment': vehicle.comment,
            'vehicle_body_details_id': vehicle.vehicleBodyDetailsId,
            'vehicle_body_types_id': vehicle.vehicleBodyTypesId,
          })
              .toList();
        });

        print("✅ Vehicles fetched successfully: ${vehicles.length} vehicles");
      } else {
        print("❌ No vehicles data found");
        // Fallback to sample data if API fails
        // _setSampleVehicles();
      }
    } catch (e) {
      print("❌ Error fetching vehicles: $e");
      // _setSampleVehicles();
    } finally {
      setState(() {
        // isFetchingVehicles = false;
      });
    }
  }

  Future<void> _initializeMap() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Use provided coordinates or convert from addresses
      LatLng pickupLatLng;
      LatLng dropLatLng;

      if (widget.pickupLat != null && widget.pickupLng != null) {
        pickupLatLng = LatLng(widget.pickupLat!, widget.pickupLng!);
      } else {
        pickupLatLng = await _getLatLngFromAddress(widget.pickupLocation) ??
            const LatLng(26.8467, 80.9462);
      }

      if (widget.dropLat != null && widget.dropLng != null) {
        dropLatLng = LatLng(widget.dropLat!, widget.dropLng!);
      } else {
        dropLatLng = await _getLatLngFromAddress(widget.dropLocation) ??
            const LatLng(26.8500, 80.9500);
      }

      print("📍 Using Coordinates:");
      print("Pickup: $pickupLatLng");
      print("Drop: $dropLatLng");

      // Calculate distance
      distance = _calculateDistance(pickupLatLng, dropLatLng);
      print("📍 Calculated Distance: ${distance.toStringAsFixed(2)} km");
      final pickupIcon = await resizeMarkerIcon(
        Assets.assetsRedLocationPin,
        80, // marker width → change size here
      );

      final dropIcon = await resizeMarkerIcon(
        Assets.assetsPicupYoyo,
        65,
      );

// Add markers
      markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: pickupLatLng,
          icon: pickupIcon,
          infoWindow: InfoWindow(title: 'Pickup: ${widget.pickupLocation}'),
        ),
      );

      markers.add(
        Marker(
          markerId: const MarkerId('drop'),
          position: dropLatLng,
          icon: dropIcon,
          infoWindow: InfoWindow(title: 'Drop: ${widget.dropLocation}'),
        ),
      );


      // Get real route polyline
      List<LatLng> routePoints = await _getRoutePoints(pickupLatLng, dropLatLng);

      if (routePoints.isNotEmpty) {
        polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            color: PortColor.containerBlue,
            width: 4,
            points: routePoints,
          ),
        );

        _moveCameraToRoute(routePoints);
      } else {
        // Fallback: straight line
        polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            color: PortColor.containerBlue,
            width: 4,
            points: [pickupLatLng, dropLatLng],
          ),
        );

        _moveCameraToPoints([pickupLatLng, dropLatLng]);
      }

      // Fetch vehicles after map is initialized
      await _fetchVehicles();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error initializing map: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<LatLng?> _getLatLngFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
    } catch (e) {
      print('Error converting address to LatLng: $e');
    }
    return null;
  }

  Future<List<LatLng>> _getRoutePoints(LatLng origin, LatLng destination) async {
    const String apiKey = 'AIzaSyANhzkw-SjvdzDvyPsUBDFmvEHfI9b8QqA';
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['routes'] != null && data['routes'].isNotEmpty) {
          final polyline = data['routes'][0]['overview_polyline']['points'];
          return _decodePolyline(polyline);
        }
      }
    } catch (e) {
      print("Error fetching route points: $e");
    }
    return [];
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polyline.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return polyline;
  }

  void _moveCameraToRoute(List<LatLng> points) {
    if (points.isEmpty) return;

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
      mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    } catch (e) {
      mapController.animateCamera(CameraUpdate.newLatLngZoom(points.first, 12));
    }
  }

  void _moveCameraToPoints(List<LatLng> points) {
    if (points.isEmpty) return;

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
      mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    } catch (e) {
      mapController.animateCamera(CameraUpdate.newLatLngZoom(points.first, 12));
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectVehicleVm = Provider.of<SelectVehiclesViewModel>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Map Section - 50% of screen
          Expanded(
            flex: 1,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(26.8484, 80.9481),
                    zoom: 12,
                  ),
                  markers: markers,
                  polylines: polylines,
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),

                // Back Button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ),
                ),

                // Distance Info
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '${distance.toStringAsFixed(1)} km',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[700],
                        fontFamily: AppFonts.kanitReg,
                      ),
                    ),
                  ),
                ),

                if (isLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Vehicle List Section - 50% of screen
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextConst(
                                title: 'Choose a ride',
                                size: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.pickupLocation} to ${widget.dropLocation}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontFamily: AppFonts.kanitReg,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Distance: ${distance.toStringAsFixed(1)} km',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.green[600],
                                  fontFamily: AppFonts.kanitReg,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.info_outline,
                          color: Colors.grey[500],
                        ),
                      ],
                    ),
                  ),

                  // Vehicle List
                  Expanded(
                    child: selectVehicleVm.loading
                        ? const Center(
                      child: CupertinoActivityIndicator(
                        radius: 14,
                      ),
                    )
                        : vehicles.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.car_repair,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No vehicles available",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontFamily: AppFonts.kanitReg,
                            ),
                          ),
                        ],
                      ),
                    )
                        : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: vehicles.length,
                      itemBuilder: (context, index) {
                        final vehicle = vehicles[index];
                        return _buildVehicleCard(vehicle);
                      },
                    ),
                  )

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(Map<String, dynamic> vehicle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: vehicle['vehicle_image'] != null
              ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              vehicle['vehicle_image'],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.directions_car,
                  color: Colors.blue[600],
                  size: 30,
                );
              },
            ),
          )
              : Icon(
            Icons.directions_car,
            color: Colors.blue[600],
            size: 30,
          ),
        ),
        title: Text(
          vehicle['vehicle_name'] ?? 'Vehicle',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: AppFonts.kanitReg,
          ),
        ),
        subtitle: Text(
          vehicle['body_detail'] ?? '',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontFamily: AppFonts.kanitReg,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${vehicle['amount'] ?? '0'}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontFamily: AppFonts.kanitReg,
              ),
            ),
            Text(
              'Approx. fare',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
                fontFamily: AppFonts.kanitReg,
              ),
            ),
          ],
        ),
        onTap: () {
          _showVehicleConfirmation(vehicle);
        },
      ),
    );
  }

  void _showVehicleConfirmation(Map<String, dynamic> vehicle) {
    final orderViewModel = Provider.of<OrderViewModel>(context, listen: false);
    final serviceTypeViewModel = Provider.of<ServiceTypeViewModel>(
      context,
      listen: false,
    );

    // Reset payment selection every time sheet opens
    selectedPayment = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateBottom) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              height: screenHeight * 0.64,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag Bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      "Confirm ${vehicle['vehicle_name'] ?? 'Ride'}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFonts.kanitReg,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Vehicle Info Row
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: vehicle['vehicle_image'] != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              vehicle['vehicle_image'],
                              fit: BoxFit.cover,
                            ),
                          )
                              : Icon(Icons.directions_car,
                              color: Colors.blue[600]),
                        ),
                        const SizedBox(width: 12),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vehicle['vehicle_name'] ?? 'Vehicle',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: AppFonts.kanitReg,
                              ),
                            ),
                            Text(
                              vehicle['body_detail'] ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontFamily: AppFonts.kanitReg,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        Text(
                          "₹${vehicle['amount'] ?? '0'}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppFonts.kanitReg,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Route Details
                    Text(
                      "Route Details",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFonts.kanitReg,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Container(
                              width: 2,
                              height: 30,
                              color: Colors.grey[300],
                            ),
                            Icon(Icons.location_on,
                                size: 16, color: Colors.red[400]),
                          ],
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.pickupLocation,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 24),
                              Text(widget.dropLocation,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 16),

                    Text(
                      "Distance: ${distance.toStringAsFixed(1)} km",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[600],
                        fontFamily: AppFonts.kanitReg,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ⭐ PAYMENT MODE SECTION ⭐
                    Text(
                      "Payment Mode",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFonts.kanitReg,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // ONLINE
                        // ONLINE PAYMENT
                        Row(
                          children: [
                            Radio<int>(
                              value: 2,   // ⭐ Online = 2
                              groupValue: selectedPayment,
                              onChanged: (value) {
                                setStateBottom(() {
                                  selectedPayment = value!;
                                });
                              },
                              activeColor: PortColor.gold,
                            ),
                            Text(
                              "Online Payment",
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),

// CASH ON DELIVERY
                        Row(
                          children: [
                            Radio<int>(
                              value: 1,   // ⭐ COD = 1
                              groupValue: selectedPayment,
                              onChanged: (value) {
                                setStateBottom(() {
                                  selectedPayment = value!;
                                });
                              },
                              activeColor: PortColor.gold,
                            ),
                            Text(
                              "Cash on Delivery",
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),

                      ],
                    ),
                     SizedBox(height: screenHeight*0.01,),
              Consumer<OrderViewModel>(
                builder: (context, orderViewModel, child) {
                  return GestureDetector(
                    onTap: () {
                      if (!orderViewModel.loading) {
                        orderViewModel.orderApi(
                          vehicle["vehicle_id"],
                          widget.pickupLocation,
                          widget.dropLocation,
                          widget.dropLat,
                          widget.dropLng,
                          widget.pickupLat,
                          widget.pickupLng,
                          "",
                          "",
                          "",
                          "",
                          vehicle["amount"],
                          distance.toStringAsFixed(1),
                          selectedPayment,
                          [],
                          serviceTypeViewModel.selectedVehicleType,
                          "",
                          "",
                          "",
                          vehicle['vehicle_body_details_id'],
                          vehicle["vehicle_body_types_id"],
                          context,
                        );
                      }
                    },
                    child: Container(
                      height: screenHeight * 0.06,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: PortColor.gold,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: orderViewModel.loading
                          ? CupertinoActivityIndicator(
                        radius: 12,
                        color: Colors.white,
                      )
                          : Text(
                        "Continue Ride",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: AppFonts.kanitReg,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),


              ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _handleRideConfirmation(Map<String, dynamic> vehicle) {
    print('Ride confirmed: ${vehicle['vehicle_name']}');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${vehicle['vehicle_name']} ride confirmed!'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate to next screen or process the booking
  }
}