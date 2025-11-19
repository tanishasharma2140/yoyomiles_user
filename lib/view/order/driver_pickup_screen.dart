import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yoyomiles/res/app_fonts.dart';

class DriverPickupScreen extends StatefulWidget {
  const DriverPickupScreen({super.key});

  @override
  _DriverPickupScreenState createState() => _DriverPickupScreenState();
}

class _DriverPickupScreenState extends State<DriverPickupScreen> with SingleTickerProviderStateMixin {
  GoogleMapController? mapController;
  PolylinePoints polylinePoints = PolylinePoints(apiKey: 'AIzaSyANhzkw-SjvdzDvyPsUBDFmvEHfI9b8QqA');
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  // Single AnimationController for all animations
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<int> _driverPositionAnimation;

  // Sample coordinates
  static const LatLng sourceLocation = LatLng(26.8467, 80.9462);
  static const LatLng destination = LatLng(26.8500, 80.9500);

  BitmapDescriptor? sourceIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? driverIcon;

  bool _isPanelExpanded = false;
  int _currentDriverIndex = 0;
  LatLng _currentDriverPosition = const LatLng(26.8480, 80.9470);
  Timer? _driverTimer;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    setCustomMapPin();
    getPolyline();
    _startDriverAnimation();
  }

  void _initAnimations() {
    // Single AnimationController for panel animations only
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<double>(
      begin: 0.45,
      end: 0.85,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void _startDriverAnimation() {
    // Use Timer instead of AnimationController for driver movement
    int totalSteps = polylineCoordinates.length;
    int currentStep = 0;
    const duration = Duration(seconds: 30);
    const interval = Duration(milliseconds: 300); // Update every 300ms

    _driverTimer = Timer.periodic(interval, (timer) {
      if (currentStep < totalSteps) {
        setState(() {
          _currentDriverIndex = currentStep;
          _currentDriverPosition = polylineCoordinates[currentStep];

          // Move camera to follow driver
          if (mapController != null) {
            mapController!.animateCamera(
              CameraUpdate.newLatLng(_currentDriverPosition),
            );
          }
        });
        currentStep++;
      } else {
        timer.cancel();
      }
    });
  }

  void _togglePanel() {
    setState(() {
      _isPanelExpanded = !_isPanelExpanded;
      if (_isPanelExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void setCustomMapPin() async {
    // Use default markers for simplicity
    sourceIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    destinationIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    driverIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
  }

  void getPolyline() async {
    // Generate more points for smoother animation
    polylineCoordinates = [
      sourceLocation,
      const LatLng(26.8468, 80.9463),
      const LatLng(26.8469, 80.9464),
      const LatLng(26.8470, 80.9465),
      const LatLng(26.8471, 80.9466),
      const LatLng(26.8472, 80.9467),
      const LatLng(26.8473, 80.9468),
      const LatLng(26.8474, 80.9469),
      const LatLng(26.8475, 80.9470),
      const LatLng(26.8476, 80.9471),
      const LatLng(26.8477, 80.9472),
      const LatLng(26.8478, 80.9473),
      const LatLng(26.8479, 80.9474),
      const LatLng(26.8480, 80.9475),
      const LatLng(26.8481, 80.9476),
      const LatLng(26.8482, 80.9477),
      const LatLng(26.8483, 80.9478),
      const LatLng(26.8484, 80.9479),
      const LatLng(26.8485, 80.9480),
      const LatLng(26.8486, 80.9481),
      const LatLng(26.8487, 80.9482),
      const LatLng(26.8488, 80.9483),
      const LatLng(26.8489, 80.9484),
      const LatLng(26.8490, 80.9485),
      const LatLng(26.8491, 80.9486),
      const LatLng(26.8492, 80.9487),
      const LatLng(26.8493, 80.9488),
      const LatLng(26.8494, 80.9489),
      const LatLng(26.8495, 80.9490),
      const LatLng(26.8496, 80.9491),
      const LatLng(26.8497, 80.9492),
      const LatLng(26.8498, 80.9493),
      const LatLng(26.8499, 80.9494),
      destination
    ];
    _addPolyLine();

    // Restart driver animation with new coordinates
    _driverTimer?.cancel();
    _startDriverAnimation();
  }

  _addPolyLine() {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: const Color(0xFF3366FF),
      points: polylineCoordinates,
      width: 5,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  @override
  void dispose() {
    _animationController.dispose();
    _driverTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Map Section
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: sourceLocation,
                zoom: 15,
              ),
              onMapCreated: (controller) {
                setState(() {
                  mapController = controller;
                });
              },
              markers: _buildMapMarkers(),
              polylines: Set<Polyline>.of(polylines.values),
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              myLocationEnabled: false,
            ),
          ),

          // Gradient Overlay at top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Header Section
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Back Button
                  _buildGlassButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  // Time Indicator
                  _buildTimeIndicator(),
                  const Spacer(),
                  // Refresh Button
                  _buildGlassButton(
                    icon: Icons.refresh_rounded,
                    onTap: () => getPolyline(),
                  ),
                ],
              ),
            ),
          ),

          // Driver Floating Card
          Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            left: 16,
            child: _buildDriverFloatingCard(),
          ),

          // Live Tracking Indicator
          Positioned(
            top: MediaQuery.of(context).padding.top + 150,
            right: 16,
            child: _buildLiveTrackingIndicator(),
          ),

          // Bottom Details Panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomPanel(),
          ),
        ],
      ),
    );
  }

  Set<Marker> _buildMapMarkers() {
    return {
      Marker(
        markerId: const MarkerId('source'),
        position: sourceLocation,
        icon: sourceIcon ?? BitmapDescriptor.defaultMarker,
        infoWindow: const InfoWindow(title: 'Pickup Location'),
        anchor: const Offset(0.5, 0.5),
      ),
      Marker(
        markerId: const MarkerId('destination'),
        position: destination,
        icon: destinationIcon ?? BitmapDescriptor.defaultMarker,
        infoWindow: const InfoWindow(title: 'Destination'),
        anchor: const Offset(0.5, 0.5),
      ),
      Marker(
        markerId: const MarkerId('driver'),
        position: _currentDriverPosition,
        icon: driverIcon ?? BitmapDescriptor.defaultMarker,
        infoWindow: const InfoWindow(title: 'Driver - Vikash Mishra'),
        rotation: _calculateBearing(),
        anchor: const Offset(0.5, 0.5),
      ),
    };
  }

  double _calculateBearing() {
    if (_currentDriverIndex == 0 || _currentDriverIndex >= polylineCoordinates.length - 1) {
      return 0;
    }

    LatLng current = polylineCoordinates[_currentDriverIndex];
    LatLng next = polylineCoordinates[_currentDriverIndex + 1];

    double lat1 = current.latitude * (pi / 180);
    double lon1 = current.longitude * (pi / 180);
    double lat2 = next.latitude * (pi / 180);
    double lon2 = next.longitude * (pi / 180);

    double dLon = lon2 - lon1;

    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);

    double bearing = atan2(y, x) * (180 / pi);
    return (bearing + 360) % 360;
  }

  Widget _buildLiveTrackingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pulsing dot
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'LIVE',
            style: TextStyle(
              fontFamily: AppFonts.poppinsReg,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassButton({required IconData icon, required VoidCallback onTap}) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: Colors.black87),
        onPressed: onTap,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildTimeIndicator() {
    // Calculate progress based on driver position
    double progress = _currentDriverIndex / (polylineCoordinates.length - 1);
    int totalSeconds = 30;
    int remainingSeconds = ((1 - progress) * totalSeconds).round();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time_rounded, size: 16, color: Colors.orange[700]),
          const SizedBox(width: 4),
          Text(
            '$remainingSeconds min',
            style: TextStyle(
              fontFamily: AppFonts.poppinsReg,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverFloatingCard() {
    return AnimatedOpacity(
      opacity: _fadeAnimation.value,
      duration: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Driver Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue[400]!, Colors.blue[600]!],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            // Driver Info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vikash Mishra',
                  style: TextStyle(
                    fontFamily: AppFonts.kanitReg,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Tata Ace · UP-32-RN-8677',
                  style: TextStyle(
                    fontFamily: AppFonts.poppinsReg,
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                // Progress text
                Text(
                  '${((_currentDriverIndex / (polylineCoordinates.length - 1)) * 100).toStringAsFixed(0)}% completed',
                  style: TextStyle(
                    fontFamily: AppFonts.poppinsReg,
                    fontSize: 10,
                    color: Colors.green[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: MediaQuery.of(context).size.height * _slideAnimation.value,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: GestureDetector(
                      onTap: _togglePanel,
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Trip Progress
                  _buildTripProgress(),
                  const SizedBox(height: 24),

                  // Customer Info Section
                  _buildCustomerInfo(),
                  const SizedBox(height: 24),

                  // Payment Section
                  _buildPaymentSection(),
                  const SizedBox(height: 24),

                  // Action Buttons
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTripProgress() {
    double progress = _currentDriverIndex / (polylineCoordinates.length - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trip in Progress',
          style: TextStyle(
            fontFamily: AppFonts.kanitReg,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 8),
        Text(
          '${((1 - progress) * 30).round()} minutes remaining • ${(progress * 8.2).toStringAsFixed(1)} KM covered',
          style: TextStyle(
            fontFamily: AppFonts.poppinsReg,
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // Pickup Location
          _buildLocationRow(
            icon: Icons.location_on_rounded,
            iconColor: Colors.red[400]!,
            title: 'Niranjan Sharma · 8423953286',
            subtitle: 'Naya Khera, Jankipuram Extension, Lucknow, Kh...',
            showEdit: true,
          ),
          const SizedBox(height: 12),
          // Divider
          Container(height: 1, color: Colors.grey[200]),
          const SizedBox(height: 12),
          // Dropoff Location
          _buildLocationRow(
            icon: Icons.location_on_rounded,
            iconColor: Colors.green[400]!,
            title: 'hello · 9632586963',
            subtitle: 'nirah nir, Lucknow, Uttar Pradesh, India',
            showEdit: false,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool showEdit,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: AppFonts.poppinsReg,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: AppFonts.poppinsReg,
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        if (showEdit)
          Text(
            'Edit',
            style: TextStyle(
              fontFamily: AppFonts.poppinsReg,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blue[600]!,
            ),
          ),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment',
                style: TextStyle(
                  fontFamily: AppFonts.kanitReg,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[100]!),
                ),
                child: Text(
                  'Cash',
                  style: TextStyle(
                    fontFamily: AppFonts.poppinsReg,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[700]!,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹677',
                style: TextStyle(
                  fontFamily: AppFonts.kanitReg,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.green[600]!,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.workspace_premium_rounded, size: 16, color: Colors.amber[700]),
                const SizedBox(width: 4),
                Text(
                  'You\'ll receive 12 coins on this order!',
                  style: TextStyle(
                    fontFamily: AppFonts.poppinsReg,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.amber[700]!,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            // Contact support
          },
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Facing issue in this order? ',
                  style: TextStyle(
                    fontFamily: AppFonts.poppinsReg,
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                TextSpan(
                  text: 'Contact Support',
                  style: TextStyle(
                    fontFamily: AppFonts.poppinsReg,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[600]!,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.red[400]!, Colors.red[600]!],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              // Cancel trip
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Cancel Trip',
              style: TextStyle(
                fontFamily: AppFonts.poppinsReg,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}