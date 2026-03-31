import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:yoyomiles/main.dart';
import 'package:yoyomiles/res/app_fonts.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/res/constant_text.dart';
import 'package:yoyomiles/view/order/widgets/stop_search_page.dart';
import 'package:yoyomiles/view_model/order_view_model.dart';
import 'package:provider/provider.dart';

// ─────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────
class StopItem {
  String? name;
  String? address;
  String? phone;
  double? latitude;
  double? longitude;

  StopItem({this.name, this.address, this.phone, this.latitude, this.longitude});
}

// ─────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────
class AddStopsPage extends StatefulWidget {
  const AddStopsPage({super.key});

  @override
  State<AddStopsPage> createState() => _AddStopsPageState();
}

class _AddStopsPageState extends State<AddStopsPage> {
  static const String _apiKey = "AIzaSyB0mG3CGok9-9RZau5J_VThUP4OTbQ_SFM";

  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _mapPolylineLoading = false;

  List<StopItem> _middleStops = [];
  late StopItem pickupStop;
  late StopItem dropStop;
  bool _dataReady = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_dataReady) return;
    _dataReady = true;

    final vm = Provider.of<OrderViewModel>(context, listen: false);

    pickupStop = StopItem(
      name: vm.pickupData?["name"]?.toString(),
      address: vm.pickupData?["address"]?.toString(),
      phone: vm.pickupData?["phone"]?.toString(),
      latitude: double.tryParse(vm.pickupData?["latitude"].toString() ?? ""),
      longitude: double.tryParse(vm.pickupData?["longitude"].toString() ?? ""),
    );

    dropStop = StopItem(
      name: vm.dropData?["name"]?.toString(),
      address: vm.dropData?["address"]?.toString(),
      phone: vm.dropData?["phone"]?.toString(),
      latitude: double.tryParse(vm.dropData?["latitude"].toString() ?? ""),
      longitude: double.tryParse(vm.dropData?["longitude"].toString() ?? ""),
    );

    // If there are existing stops in VM, load them
    if (vm.stops.isNotEmpty) {
      _middleStops = vm.stops.map((s) => StopItem(
        name: s["name"],
        address: s["address"],
        phone: s["phone"],
        latitude: double.tryParse(s["latitude"].toString()),
        longitude: double.tryParse(s["longitude"].toString()),
      )).toList();
    }

    _refreshMapData();
  }

  // ── Google Directions road polyline ──────────
  Future<List<LatLng>> _getDirectionsPolyline(List<LatLng> waypoints) async {
    if (waypoints.length < 2) return [];

    final origin = waypoints.first;
    final destination = waypoints.last;

    String waypointsParam = '';
    if (waypoints.length > 2) {
      final mid = waypoints.sublist(1, waypoints.length - 1);
      waypointsParam =
      '&waypoints=${mid.map((p) => '${p.latitude},${p.longitude}').join('|')}';
    }

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
          '?origin=${origin.latitude},${origin.longitude}'
          '&destination=${destination.latitude},${destination.longitude}'
          '$waypointsParam'
          '&mode=driving'
          '&key=$_apiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final encoded =
          data['routes'][0]['overview_polyline']['points'] as String;
          return _decodePolyline(encoded);
        }
      }
    } catch (e) {
      debugPrint('Directions error: $e');
    }
    return [];
  }

  List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0;
    final int len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0, b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  Future<void> _refreshMapData() async {
    setState(() => _mapPolylineLoading = true);

    final Set<Marker> markers = {};
    final List<LatLng> allWaypoints = [];

    // Pickup
    if (pickupStop.latitude != null && pickupStop.longitude != null) {
      final ll = LatLng(pickupStop.latitude!, pickupStop.longitude!);
      allWaypoints.add(ll);
      markers.add(Marker(
        markerId: const MarkerId('pickup'),
        position: ll,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
    }

    // Middle stops
    for (int i = 0; i < _middleStops.length; i++) {
      final s = _middleStops[i];
      if (s.latitude != null && s.longitude != null) {
        final ll = LatLng(s.latitude!, s.longitude!);
        allWaypoints.add(ll);
        markers.add(Marker(
          markerId: MarkerId('stop_$i'),
          position: ll,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        ));
      }
    }

    // Drop
    if (dropStop.latitude != null && dropStop.longitude != null) {
      final ll = LatLng(dropStop.latitude!, dropStop.longitude!);
      allWaypoints.add(ll);
      markers.add(Marker(
        markerId: const MarkerId('drop'),
        position: ll,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    }

    final roadPoints = await _getDirectionsPolyline(allWaypoints);

    final Set<Polyline> polylines = {};
    if (roadPoints.isNotEmpty) {
      polylines.add(Polyline(
        polylineId:  PolylineId('road_route'),
        color: PortColor.gold,
        width: 3,
        points: roadPoints,
      ));
    }

    if (!mounted) return;
    setState(() {
      _markers = markers;
      _polylines = polylines;
      _mapPolylineLoading = false;
    });

    if (allWaypoints.length >= 2 && _mapController != null) {
      _fitCamera(allWaypoints);
    }
  }

  void _fitCamera(List<LatLng> points) {
    double minLat = points.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    double maxLat = points.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    double minLng = points.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    double maxLng = points.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat - 0.01, minLng - 0.01),
          northeast: LatLng(maxLat + 0.01, maxLng + 0.01),
        ),
        60,
      ),
    );
  }

  LatLng get _initialCameraTarget {
    if (pickupStop.latitude != null && pickupStop.longitude != null) {
      return LatLng(pickupStop.latitude!, pickupStop.longitude!);
    }
    return const LatLng(26.8467, 80.9462);
  }

  // ── Open StopSearchPage ───────────────────────
  Future<void> _openStopSearch(int stopNumber) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => StopSearchPage(stopNumber: stopNumber),
      ),
    );

    if (result != null && mounted) {
      final newStop = StopItem(
        name: result['name']?.toString(),
        address: result['address']?.toString(),
        phone: result['phone']?.toString(),
        latitude: result['latitude'] as double?,
        longitude: result['longitude'] as double?,
      );

      setState(() {
        final emptyIndex = _middleStops.indexWhere((s) => s.address == null);
        if (emptyIndex != -1) {
          _middleStops[emptyIndex] = newStop;
        } else {
          _middleStops.add(newStop);
        }
      });

      await _refreshMapData();
    }
  }

  // ── Build ─────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: PortColor.white,
        body: Column(
          children: [
            // ── Stops Panel ──
            Container(
              color: PortColor.white,
              padding: EdgeInsets.only(top: screenHeight * 0.055),
              child: Column(
                children: [
                  // Back + title
                  Padding(
                    padding: EdgeInsets.only(
                        left: screenWidth * 0.02, bottom: screenHeight * 0.005),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          onPressed: () => Navigator.pop(context),
                        ),
                        TextConst(title:
                          'Add Stops',
                          size: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),

                  // Pickup (fixed)
                  _buildFixedRow(
                    indicator: const CircleAvatar(
                        radius: 8, backgroundColor: Colors.green),
                    name: pickupStop.name ?? 'Pickup',
                    phone: pickupStop.phone ?? '',
                    address: pickupStop.address ?? '',
                  ),

                  // Middle stops
                  ...List.generate(_middleStops.length, (i) {
                    return _buildMiddleStopRow(i, _middleStops[i]);
                  }),

                  // Drop (fixed, badge = 1)
                  _buildFixedRow(
                    indicator: _badge(1, Colors.red),
                    name: dropStop.name ?? 'Drop',
                    phone: dropStop.phone ?? '',
                    address: dropStop.address ?? '',
                  ),

                  // ADD STOP button (max 3 stops)
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenHeight * 0.01),
                    child: GestureDetector(
                      onTap: _middleStops.length >= 3
                          ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Maximum 3 stops allowed'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                          : () => _openStopSearch(_middleStops.length + 1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                                color: _middleStops.length >= 3
                                    ? Colors.grey.shade400
                                    : PortColor.gold,
                                shape: BoxShape.circle),
                            child: const Icon(Icons.add,
                                color: Colors.white, size: 20),
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          Text(
                            _middleStops.length >= 3
                                ? 'Max 3 Stops Reached'
                                : 'ADD STOP',
                            style: TextStyle(
                              color: _middleStops.length >= 3
                                  ? Colors.grey.shade400
                                  : PortColor.gold,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              fontFamily: AppFonts.kanitReg,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Map ──
            Expanded(
              child: Stack(
                children: [
                  GoogleMap(
                    onMapCreated: (c) {
                      _mapController = c;
                      Future.delayed(const Duration(milliseconds: 400), () {
                        final pts = <LatLng>[];
                        if (pickupStop.latitude != null)
                          pts.add(LatLng(
                              pickupStop.latitude!, pickupStop.longitude!));
                        if (dropStop.latitude != null)
                          pts.add(
                              LatLng(dropStop.latitude!, dropStop.longitude!));
                        if (pts.length >= 2) _fitCamera(pts);
                      });
                    },
                    initialCameraPosition: CameraPosition(
                        target: _initialCameraTarget, zoom: 12),
                    markers: _markers,
                    polylines: _polylines,
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                  ),
                  if (_mapPolylineLoading)
                    const Center(
                        child: CircularProgressIndicator(color: PortColor.blue)),
                ],
              ),
            ),

            // ── Select Vehicle button ──
            Container(
              width: screenWidth,
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.015),
              color: PortColor.white,
              child: ElevatedButton(
                onPressed: () {
                  final vm = Provider.of<OrderViewModel>(context, listen: false);
                  List<Map<String, dynamic>> stopsToSave = _middleStops
                      .where((s) => s.address != null)
                      .map((s) => {
                    "name": s.name,
                    "address": s.address,
                    "phone": s.phone,
                    "latitude": s.latitude,
                    "longitude": s.longitude,
                  }).toList();

                  vm.setStops(stopsToSave);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: PortColor.gold,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                  EdgeInsets.symmetric(vertical: screenHeight * 0.018),
                ),
                child: TextConst(
                  title:
                  'Select Vehicle',
                  fontFamily: AppFonts.kanitReg,
                  color: PortColor.black,
                  size: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────

  Widget _buildFixedRow({
    required Widget indicator,
    required String name,
    required String phone,
    required String address,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04, vertical: screenHeight * 0.005),
      child: Row(
        children: [
          indicator,
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: _addressCard(
                name: name, phone: phone, address: address, showClose: false),
          ),
        ],
      ),
    );
  }

  Widget _buildMiddleStopRow(int index, StopItem stop) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04, vertical: screenHeight * 0.005),
      child: Row(
        children: [
          _badge(index + 2, Colors.red),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: stop.address != null
                ? _addressCard(
              name: stop.name ?? '',
              phone: stop.phone ?? '',
              address: stop.address!,
              showClose: true,
              onClose: () {
                setState(() => _middleStops.removeAt(index));
                _refreshMapData();
              },
            )
                : GestureDetector(
              onTap: () => _openStopSearch(index + 1),
              child: _emptyCard(index + 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(int number, Color color) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(
        child: Text('$number',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _addressCard({
    required String name,
    required String phone,
    required String address,
    required bool showClose,
    VoidCallback? onClose,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  phone.isNotEmpty ? '$name · $phone' : name,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      fontFamily: AppFonts.kanitReg),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (address.isNotEmpty)
                  Text(
                    address,
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontFamily: AppFonts.poppinsReg),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (showClose && onClose != null)
            GestureDetector(
                onTap: onClose,
                child:
                Icon(Icons.close, size: 18, color: Colors.grey.shade500))
          else
            Icon(Icons.drag_handle, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _emptyCard(int stopNumber) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Where is your Stop $stopNumber?',
              style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 13,
                  fontFamily: AppFonts.poppinsReg),
            ),
          ),
          Icon(Icons.drag_handle, color: Colors.grey.shade400),
        ],
      ),
    );
  }
}
