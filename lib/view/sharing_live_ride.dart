// // ignore_for_file: deprecated_member_use
//
// import 'dart:async';
// import 'dart:convert';
// import 'dart:math';
// import 'dart:ui' as ui;
//
// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:flutter/services.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'package:socket_io_client/socket_io_client.dart' as IO;
//
// // ─────────────────────────────────────────────────────────────────────────────
// // SECURITY: Inject keys via env / build args — never hardcode in production.
// // Pass --dart-define=GOOGLE_MAPS_KEY=xxx --dart-define=SOCKET_URL=xxx
// // ─────────────────────────────────────────────────────────────────────────────
// const String _kGoogleApiKey  = String.fromEnvironment(
//   'GOOGLE_MAPS_KEY',
//   defaultValue: 'AIzaSyB0mG3CGok9-9RZau5J_VThUP4OTbQ_SFM', // replace at build time
// );
// const String _kSocketBaseUrl = String.fromEnvironment(
//   'SOCKET_URL',
//   defaultValue: 'https://dev.yoyomiles.com/',
// );
//
// // ─────────────────────────────────────────────────────────────────────────────
// // KALMAN FILTER  (1-D, applied per lat & lng independently)
// // ─────────────────────────────────────────────────────────────────────────────
// class _KalmanFilter {
//   double _estimate;
//   double _errorEstimate;
//   final double _errorMeasure;
//   final double _q; // process noise
//
//   _KalmanFilter({
//     required double initial,
//     double errorEstimate  = 1.0,
//     double errorMeasure   = 3.0,
//     double processNoise   = 0.008,
//   })  : _estimate      = initial,
//         _errorEstimate = errorEstimate,
//         _errorMeasure  = errorMeasure,
//         _q             = processNoise;
//
//   double filter(double measurement) {
//     // Predict
//     _errorEstimate += _q;
//     // Update
//     final kg = _errorEstimate / (_errorEstimate + _errorMeasure);
//     _estimate      += kg * (measurement - _estimate);
//     _errorEstimate  = (1 - kg) * _errorEstimate;
//     return _estimate;
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // GPS SMOOTHER  – combines Kalman + speed-gate + jitter threshold
// // ─────────────────────────────────────────────────────────────────────────────
// class _GpsSmoother {
//   _KalmanFilter? _kfLat;
//   _KalmanFilter? _kfLng;
//   LatLng? _lastAccepted;
//   DateTime? _lastTime;
//
//   static const double _maxSpeedMs       = 55.6; // ~200 km/h hard cap
//   static const double _jitterMeters     = 2.5;  // ignore sub-2.5 m noise
//   static const double _teleportMeters   = 300;  // reset filter on teleport
//
//   LatLng? smooth(double rawLat, double rawLng) {
//     final now = DateTime.now();
//
//     // Bootstrap
//     if (_kfLat == null) {
//       _kfLat = _KalmanFilter(initial: rawLat);
//       _kfLng = _KalmanFilter(initial: rawLng);
//       _lastAccepted = LatLng(rawLat, rawLng);
//       _lastTime     = now;
//       return _lastAccepted;
//     }
//
//     final candidate = LatLng(rawLat, rawLng);
//     final dist = _haversine(_lastAccepted!, candidate);
//     final dt   = now.difference(_lastTime!).inMilliseconds / 1000.0;
//
//     // Teleport guard — reset filter
//     if (dist > _teleportMeters) {
//       _kfLat = _KalmanFilter(initial: rawLat);
//       _kfLng = _KalmanFilter(initial: rawLng);
//       _lastAccepted = candidate;
//       _lastTime     = now;
//       return candidate;
//     }
//
//     // Speed gate
//     if (dt > 0 && dist / dt > _maxSpeedMs) return null; // reject
//
//     // Jitter gate
//     if (dist < _jitterMeters) return null; // no meaningful movement
//
//     final sLat = _kfLat!.filter(rawLat);
//     final sLng = _kfLng!.filter(rawLng);
//     final smoothed = LatLng(sLat, sLng);
//     _lastAccepted = smoothed;
//     _lastTime     = now;
//     return smoothed;
//   }
//
//   static double _haversine(LatLng a, LatLng b) {
//     const R = 6371000.0;
//     final dLat = (b.latitude  - a.latitude)  * pi / 180;
//     final dLng = (b.longitude - a.longitude) * pi / 180;
//     final h = sin(dLat / 2) * sin(dLat / 2) +
//         cos(a.latitude * pi / 180) *
//             cos(b.latitude * pi / 180) *
//             sin(dLng / 2) *
//             sin(dLng / 2);
//     return 2 * R * asin(sqrt(h));
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // POLYLINE SNAPPER
// // Snaps a raw LatLng to the nearest point on the polyline path and returns
// // the index of the best segment start so we can trim the passed portion.
// // ─────────────────────────────────────────────────────────────────────────────
// class _PolySolver {
//   static const double _earthR = 6371000.0;
//
//   /// Returns (snappedPosition, nearestSegmentIndex, fractionAlongSegment)
//   static ({LatLng pos, int seg, double t}) snap(
//       LatLng raw, List<LatLng> poly) {
//     if (poly.length < 2) return (pos: raw, seg: 0, t: 0);
//
//     double bestDist = double.infinity;
//     LatLng bestPt   = poly.first;
//     int    bestSeg  = 0;
//     double bestT    = 0;
//
//     for (int i = 0; i < poly.length - 1; i++) {
//       final r = _closestOnSegment(raw, poly[i], poly[i + 1]);
//       if (r.dist < bestDist) {
//         bestDist = r.dist;
//         bestPt   = r.pt;
//         bestSeg  = i;
//         bestT    = r.t;
//       }
//     }
//     return (pos: bestPt, seg: bestSeg, t: bestT);
//   }
//
//   static ({LatLng pt, double dist, double t}) _closestOnSegment(
//       LatLng p, LatLng a, LatLng b) {
//     final ax = a.longitude, ay = a.latitude;
//     final bx = b.longitude, by = b.latitude;
//     final px = p.longitude, py = p.latitude;
//
//     final dx = bx - ax, dy = by - ay;
//     final lenSq = dx * dx + dy * dy;
//
//     double t = 0;
//     if (lenSq > 0) {
//       t = ((px - ax) * dx + (py - ay) * dy) / lenSq;
//       t = t.clamp(0.0, 1.0);
//     }
//
//     final cx = ax + t * dx;
//     final cy = ay + t * dy;
//     final closest = LatLng(cy, cx);
//     final d = _haversine(p, closest);
//     return (pt: closest, dist: d, t: t);
//   }
//
//   static double _haversine(LatLng a, LatLng b) {
//     final dLat = (b.latitude  - a.latitude)  * pi / 180;
//     final dLng = (b.longitude - a.longitude) * pi / 180;
//     final h = sin(dLat / 2) * sin(dLat / 2) +
//         cos(a.latitude * pi / 180) *
//             cos(b.latitude * pi / 180) *
//             sin(dLng / 2) *
//             sin(dLng / 2);
//     return 2 * _earthR * asin(sqrt(h));
//   }
//
//   /// Distance in metres between two points
//   static double dist(LatLng a, LatLng b) => _haversine(a, b);
//
//   /// Bearing in degrees [0, 360)
//   static double bearing(LatLng from, LatLng to) {
//     final lat1 = from.latitude  * pi / 180;
//     final lat2 = to.latitude    * pi / 180;
//     final dLng = (to.longitude - from.longitude) * pi / 180;
//     return (atan2(sin(dLng) * cos(lat2),
//         cos(lat1) * sin(lat2) -
//             sin(lat1) * cos(lat2) * cos(dLng)) *
//         180 /
//         pi +
//         360) %
//         360;
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // DRIVER ANIMATOR
// // Moves the driver marker along the polyline at realistic speed,
// // updating position every frame via a Ticker (no AnimationController overhead).
// // ─────────────────────────────────────────────────────────────────────────────
// class _DriverAnimator {
//   final void Function(LatLng pos, double bearing) onUpdate;
//   final TickerProvider vsync;
//
//   Ticker?        _ticker;
//   List<LatLng>   _polyline  = [];
//   int            _segIdx    = 0;    // current segment
//   double         _segT      = 0;    // fraction along current segment [0,1]
//   double         _speedMs   = 10;   // m/s
//   LatLng?        _lastPos;
//   double         _bearing   = 0;
//
//   _DriverAnimator({required this.onUpdate, required this.vsync});
//
//   void updateTarget(LatLng target, List<LatLng> polyline) {
//     if (polyline.length < 2) {
//       _directMove(target);
//       return;
//     }
//     _polyline = polyline;
//
//     // Snap target onto polyline
//     final snap = _PolySolver.snap(target, polyline);
//     _segIdx = snap.seg;
//     _segT   = snap.t;
//
//     _ensureTicker();
//   }
//
//   void _directMove(LatLng target) {
//     if (_lastPos != null) {
//       _bearing = _PolySolver.bearing(_lastPos!, target);
//     }
//     _lastPos = target;
//     onUpdate(target, _bearing);
//   }
//
//   void _ensureTicker() {
//     _ticker ??= vsync.createTicker(_tick)..start();
//   }
//
//   Duration? _lastElapsed;
//
//   void _tick(Duration elapsed) {
//     if (_polyline.length < 2) return;
//
//     final dt = _lastElapsed == null
//         ? 0.016
//         : (elapsed - _lastElapsed!).inMilliseconds / 1000.0;
//     _lastElapsed = elapsed;
//
//     var distLeft = _speedMs * dt.clamp(0.0, 0.1); // max 100 ms step
//
//     while (distLeft > 0 && _segIdx < _polyline.length - 1) {
//       final a   = _polyline[_segIdx];
//       final b   = _polyline[_segIdx + 1];
//       final seg = _PolySolver.dist(a, b);
//       if (seg <= 0) { _segIdx++; continue; }
//
//       final remaining = seg * (1.0 - _segT);
//       if (distLeft >= remaining) {
//         distLeft -= remaining;
//         _segIdx++;
//         _segT = 0;
//       } else {
//         _segT += distLeft / seg;
//         distLeft = 0;
//       }
//     }
//
//     if (_segIdx >= _polyline.length - 1) {
//       _segIdx = _polyline.length - 2;
//       _segT   = 1.0;
//     }
//
//     final a = _polyline[_segIdx];
//     final b = _polyline[_segIdx + 1];
//     final pos = LatLng(
//       a.latitude  + (_segT) * (b.latitude  - a.latitude),
//       a.longitude + (_segT) * (b.longitude - a.longitude),
//     );
//
//     // Smooth bearing
//     final rawBearing = _PolySolver.bearing(a, b);
//     final diff = ((rawBearing - _bearing + 540) % 360) - 180;
//     _bearing = (_bearing + diff * 0.25 + 360) % 360; // lerp 25% per frame
//
//     _lastPos = pos;
//     onUpdate(pos, _bearing);
//   }
//
//   void setSpeed(double ms) => _speedMs = ms.clamp(1, 55);
//
//   void dispose() {
//     _ticker?.dispose();
//     _ticker = null;
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // RIDE STATUS
// // ─────────────────────────────────────────────────────────────────────────────
// enum _RideStatus { connecting, live, completed, error, noSignal }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // MAIN WIDGET
// // ─────────────────────────────────────────────────────────────────────────────
// class ShareLiveRide extends StatefulWidget {
//   final String trackingToken;
//   const ShareLiveRide({super.key, required this.trackingToken});
//
//   @override
//   State<ShareLiveRide> createState() => _ShareLiveRideState();
// }
//
// class _ShareLiveRideState extends State<ShareLiveRide>
//     with TickerProviderStateMixin {
//
//   // ── Map ────────────────────────────────────────────────────────────────────
//   final Completer<GoogleMapController> _mapCtrl = Completer();
//   bool _mapReady = false;
//
//   // ── Socket ─────────────────────────────────────────────────────────────────
//   IO.Socket?   _socket;
//   bool         _socketConnected = false;
//   int          _reconnectAttempts = 0;
//   static const int _maxReconnects = 7;
//   Timer?       _reconnectTimer;
//   Timer?       _noSignalTimer;
//
//   // ── GPS Smoother ───────────────────────────────────────────────────────────
//   final _GpsSmoother _smoother = _GpsSmoother();
//
//   // ── Driver Animator ────────────────────────────────────────────────────────
//   late final _DriverAnimator _animator;
//   LatLng?  _driverPos;
//   double   _driverBearing = 0;
//
//   // ── Tracking data ──────────────────────────────────────────────────────────
//   String        _driverName    = '';
//   String        _vehicleNo     = '';
//   String        _pickupAddress = '';
//   String        _dropAddress   = '';
//   LatLng?       _pickupLatLng;
//   LatLng?       _dropLatLng;
//   int           _vehicleType   = 1;
//   List<dynamic> _stops         = [];
//
//   // ── Map layers ─────────────────────────────────────────────────────────────
//   List<LatLng>        _routePoints    = [];
//   List<LatLng>        _passedPoints   = [];
//   Set<Polyline>       _polylines      = {};
//   Map<MarkerId, Marker> _markers      = {};
//
//   // ── UI state ───────────────────────────────────────────────────────────────
//   _RideStatus  _status     = _RideStatus.connecting;
//   String       _errorMsg   = '';
//   bool         _cameraLock = true; // auto-follow driver
//
//   // ── Camera ─────────────────────────────────────────────────────────────────
//   double       _cameraZoom = 15.5;
//   LatLng?      _lastCamTarget;
//   Timer?       _camThrottle;
//
//   // ── Animations ─────────────────────────────────────────────────────────────
//   late final AnimationController _entryCtrl;
//   late final Animation<Offset>   _entrySlide;
//   late final Animation<double>   _entryFade;
//
//   late final AnimationController _pulseCtrl;
//   late final Animation<double>   _pulseAnim;
//
//   // ── Custom icons (cached) ──────────────────────────────────────────────────
//   final Map<int, BitmapDescriptor> _vehicleIcons = {};
//
//   // ── Polyline API retry ─────────────────────────────────────────────────────
//   int    _polyRetry  = 0;
//   static const int _maxPolyRetry = 3;
//
//   // ─────────────────────────────────────────────────────────────────────────
//   @override
//   void initState() {
//     super.initState();
//
//     _animator = _DriverAnimator(
//       vsync: this,
//       onUpdate: _onAnimatorUpdate,
//     );
//
//     _entryCtrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 700));
//     _entrySlide =
//         Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
//             CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
//     _entryFade  = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
//
//     _pulseCtrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 1100))
//       ..repeat(reverse: true);
//     _pulseAnim = Tween<double>(begin: 0.25, end: 1.0)
//         .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
//
//     _loadVehicleIcons().then((_) {
//       _connectSocket();
//       Future.delayed(
//           const Duration(milliseconds: 300), _entryCtrl.forward);
//     });
//   }
//
//   // ── Animator callback — runs every Ticker frame ────────────────────────────
//   // We avoid setState here; instead we update marker in-place and
//   // schedule a single post-frame marker map swap.
//   void _onAnimatorUpdate(LatLng pos, double bearing) {
//     _driverPos     = pos;
//     _driverBearing = bearing;
//
//     final newMarker = _buildDriverMarker(pos, bearing);
//
//     // Swap the marker map without calling setState (avoids full rebuild)
//     // Use a microtask to batch updates from rapid Ticker ticks.
//     scheduleMicrotask(() {
//       if (!mounted) return;
//       final updated = Map<MarkerId, Marker>.from(_markers);
//       updated[const MarkerId('driver')] = newMarker;
//       setState(() => _markers = updated);
//     });
//
//     if (_cameraLock) _throttledCameraFollow(pos);
//   }
//
//   // ── Camera: throttle to max 10 fps to prevent jitter ─────────────────────
//   void _throttledCameraFollow(LatLng pos) {
//     if (_camThrottle?.isActive ?? false) return;
//     _camThrottle = Timer(const Duration(milliseconds: 100), () async {
//       if (!mounted || !_mapReady) return;
//       if (_lastCamTarget != null &&
//           _PolySolver.dist(_lastCamTarget!, pos) < 3) return; // sub-3 m skip
//       _lastCamTarget = pos;
//       try {
//         final ctrl = await _mapCtrl.future;
//         ctrl.animateCamera(CameraUpdate.newCameraPosition(
//           CameraPosition(target: pos, zoom: _cameraZoom, bearing: _driverBearing),
//         ));
//       } catch (_) {}
//     });
//   }
//
//   // ── Vehicle icons ──────────────────────────────────────────────────────────
//   Future<BitmapDescriptor> _emojiToBitmap(String emoji, double size) async {
//     final rec    = ui.PictureRecorder();
//     final canvas = Canvas(rec);
//     final tp     = TextPainter(
//       text: TextSpan(
//           text: emoji, style: TextStyle(fontSize: size * 0.72, height: 1)),
//       textDirection: TextDirection.ltr,
//     )..layout();
//     tp.paint(canvas, Offset((size - tp.width) / 2, (size - tp.height) / 2));
//     final img   = await rec.endRecording().toImage(size.toInt(), size.toInt());
//     final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
//     return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
//   }
//
//   Future<void> _loadVehicleIcons() async {
//     _vehicleIcons[1] = await _emojiToBitmap('🚖', 72);
//     _vehicleIcons[2] = await _emojiToBitmap('🛵', 72);
//     _vehicleIcons[3] = await _emojiToBitmap('🛺', 72);
//     _vehicleIcons[4] = await _emojiToBitmap('🚚', 72);
//   }
//
//   BitmapDescriptor get _currentIcon =>
//       _vehicleIcons[_vehicleType] ?? BitmapDescriptor.defaultMarker;
//
//   // ── Vehicle metadata ───────────────────────────────────────────────────────
//   String get _vehicleLabel {
//     const m = {1:'Cab', 2:'Bike', 3:'Auto', 4:'Pickup'};
//     return m[_vehicleType] ?? 'Vehicle';
//   }
//
//   IconData get _vehicleIconData {
//     const m = <int, IconData>{
//       1: Icons.local_taxi_rounded,
//       2: Icons.two_wheeler_rounded,
//       3: Icons.electric_rickshaw_rounded,
//       4: Icons.local_shipping_rounded,
//     };
//     return m[_vehicleType] ?? Icons.directions_car_rounded;
//   }
//
//   Color get _vehicleColor {
//     const m = <int, Color>{
//       1: Color(0xFFFFB800),
//       2: Color(0xFFFF6B35),
//       3: Color(0xFF00B894),
//       4: Color(0xFF6C63FF),
//     };
//     return m[_vehicleType] ?? const Color(0xFFFFB800);
//   }
//
//   // ── SOCKET ─────────────────────────────────────────────────────────────────
//   void _connectSocket() {
//     _socket?.dispose();
//
//     _socket = IO.io(
//       _kSocketBaseUrl,
//       IO.OptionBuilder()
//           .setTransports(['websocket', 'polling'])
//           .disableAutoConnect()
//           .enableReconnection()
//           .setReconnectionAttempts(_maxReconnects)
//           .setReconnectionDelay(2000)
//           .setTimeout(10000)
//           .build(),
//     );
//
//     // Register all listeners BEFORE connect to avoid duplicates
//     _socket!
//       ..onConnect(_onSocketConnect)
//       ..on('TRACKING_JOINED', _onTrackingJoined)
//       ..on('TRACKING_DATA',   _onTrackingData)
//       ..on('LIVE_LOCATION',   _onLiveLocation)
//       ..on('RIDE_COMPLETED',  _onRideCompleted)
//       ..on('TRACKING_ERROR',  _onTrackingError)
//       ..onReconnect(_onReconnect)
//       ..onDisconnect(_onSocketDisconnect)
//       ..onConnectError(_onConnectError)
//       ..connect();
//   }
//
//   void _onSocketConnect(_) {
//     debugPrint('✅ Socket connected: ${_socket!.id}');
//     _socketConnected = true;
//     _reconnectAttempts = 0;
//     _reconnectTimer?.cancel();
//     _socket!.emit('JOIN_TRACKING', {'token': widget.trackingToken});
//   }
//
//   void _onTrackingJoined(_) {
//     if (mounted) setState(() => _status = _RideStatus.live);
//     _resetNoSignalTimer();
//   }
//
//   void _onReconnect(_) {
//     debugPrint('🔄 Socket reconnected');
//     _socketConnected = true;
//     _socket!.emit('JOIN_TRACKING', {'token': widget.trackingToken});
//   }
//
//   void _onSocketDisconnect(_) {
//     debugPrint('⚠️  Socket disconnected');
//     _socketConnected = false;
//     if (mounted && _status != _RideStatus.completed) {
//       setState(() => _status = _RideStatus.noSignal);
//     }
//   }
//
//   void _onConnectError(dynamic err) {
//     debugPrint('❌ Socket connect error: $err');
//     _scheduleManualReconnect();
//   }
//
//   void _scheduleManualReconnect() {
//     if (_reconnectAttempts >= _maxReconnects) {
//       if (mounted) {
//         setState(() {
//           _status   = _RideStatus.error;
//           _errorMsg = 'Unable to connect after $_maxReconnects attempts.';
//         });
//       }
//       return;
//     }
//     final delay = Duration(seconds: min(2 << _reconnectAttempts, 30));
//     _reconnectAttempts++;
//     _reconnectTimer?.cancel();
//     _reconnectTimer = Timer(delay, _connectSocket);
//   }
//
//   void _onTrackingError(dynamic data) {
//     if (mounted) {
//       setState(() {
//         _status   = _RideStatus.error;
//         _errorMsg = data['message']?.toString() ?? 'Tracking error occurred';
//       });
//     }
//   }
//
//   void _onRideCompleted(_) {
//     if (mounted) setState(() => _status = _RideStatus.completed);
//   }
//
//   // ── No-signal watchdog: 30 s without location → show warning ──────────────
//   void _resetNoSignalTimer() {
//     _noSignalTimer?.cancel();
//     _noSignalTimer = Timer(const Duration(seconds: 30), () {
//       if (mounted && _status == _RideStatus.live) {
//         setState(() => _status = _RideStatus.noSignal);
//       }
//     });
//   }
//
//   // ── TRACKING_DATA ──────────────────────────────────────────────────────────
//   void _onTrackingData(dynamic raw) {
//     try {
//       final d = raw as Map;
//
//       final pickLat = _parseDouble(d['pickup_latitute'])
//           ?? _parseDouble(d['pickup_lattitude']);
//       final pickLng = _parseDouble(d['pick_longitude']);
//       final dropLat = _parseDouble(d['drop_latitute'])
//           ?? _parseDouble(d['drop_lattitude']);
//       final dropLng = _parseDouble(d['drop_logitute'])
//           ?? _parseDouble(d['drop_logitude']);
//
//       setState(() {
//         _driverName    = d['driver_name']?.toString()    ?? '';
//         _vehicleNo     = d['vehicle_no']?.toString()     ?? '';
//         _pickupAddress = d['pickup_address']?.toString() ?? '';
//         _dropAddress   = d['drop_address']?.toString()   ?? '';
//         _vehicleType   = int.tryParse(d['vehicle_type']?.toString() ?? '1') ?? 1;
//         _stops         = d['stops'] is List ? d['stops'] as List : [];
//         if (pickLat != null && pickLng != null)
//           _pickupLatLng = LatLng(pickLat, pickLng);
//         if (dropLat != null && dropLng != null)
//           _dropLatLng = LatLng(dropLat, dropLng);
//       });
//
//       _rebuildStaticMarkers();
//       _fetchRoutePolyline();
//     } catch (e) {
//       debugPrint('❌ TRACKING_DATA parse error: $e');
//     }
//   }
//
//   // ── LIVE_LOCATION ──────────────────────────────────────────────────────────
//   void _onLiveLocation(dynamic raw) {
//     final lat = _parseDouble(raw['latitude']);
//     final lng = _parseDouble(raw['longitude']);
//     if (lat == null || lng == null) return;
//
//     _resetNoSignalTimer();
//     if (mounted && _status == _RideStatus.noSignal) {
//       setState(() => _status = _RideStatus.live);
//     }
//
//     final smoothed = _smoother.smooth(lat, lng);
//     if (smoothed == null) return; // rejected by filter
//
//     // Estimate speed from raw speed field, fallback 10 m/s
//     final speed = _parseDouble(raw['speed']) ?? 10.0;
//     _animator.setSpeed(speed);
//
//     _animator.updateTarget(smoothed, _routePoints);
//
//     // Update passed (greyed) portion of polyline if snapped
//     if (_routePoints.length >= 2 && _driverPos != null) {
//       _updatePassedPolyline();
//     }
//   }
//
//   void _updatePassedPolyline() {
//     final snap  = _PolySolver.snap(_driverPos!, _routePoints);
//     final passed = [
//       ..._routePoints.sublist(0, snap.seg + 1),
//       snap.pos,
//     ];
//     if (mounted) {
//       setState(() {
//         _passedPoints = passed;
//         _polylines    = _buildPolylines();
//       });
//     }
//   }
//
//   // ── Marker builders ────────────────────────────────────────────────────────
//   Marker _buildDriverMarker(LatLng pos, double bearing) => Marker(
//     markerId: const MarkerId('driver'),
//     position: pos,
//     icon: _currentIcon,
//     anchor: const Offset(0.5, 0.5),
//     rotation: bearing,
//     flat: true,
//     zIndex: 3,
//     infoWindow: InfoWindow(
//       title: _driverName.isNotEmpty ? _driverName : 'Driver',
//       snippet: _vehicleNo,
//     ),
//   );
//
//   void _rebuildStaticMarkers() {
//     final m = Map<MarkerId, Marker>.from(_markers);
//     if (_pickupLatLng != null) {
//       m[const MarkerId('pickup')] = Marker(
//         markerId: const MarkerId('pickup'),
//         position: _pickupLatLng!,
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
//         zIndex: 2,
//         infoWindow: InfoWindow(title: 'Pickup', snippet: _pickupAddress),
//       );
//     }
//     if (_dropLatLng != null) {
//       m[const MarkerId('drop')] = Marker(
//         markerId: const MarkerId('drop'),
//         position: _dropLatLng!,
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//         zIndex: 2,
//         infoWindow: InfoWindow(title: 'Drop', snippet: _dropAddress),
//       );
//     }
//     setState(() => _markers = m);
//   }
//
//   // ── Polyline builders ──────────────────────────────────────────────────────
//   Set<Polyline> _buildPolylines() {
//     final set = <Polyline>{};
//     if (_passedPoints.length >= 2) {
//       set.add(Polyline(
//         polylineId: const PolylineId('passed'),
//         points: _passedPoints,
//         color: const Color(0xFF3D5AFE).withOpacity(0.30),
//         width: 5,
//         jointType: JointType.round,
//         startCap: Cap.roundCap,
//         endCap: Cap.roundCap,
//         zIndex: 0,
//       ));
//     }
//     if (_routePoints.length >= 2) {
//       final remaining = _passedPoints.isEmpty
//           ? _routePoints
//           : [_passedPoints.last, ..._routePoints.sublist(_passedPoints.length - 1)];
//       if (remaining.length >= 2) {
//         set.add(Polyline(
//           polylineId: const PolylineId('route'),
//           points: remaining,
//           color: const Color(0xFF3D5AFE),
//           width: 5,
//           jointType: JointType.round,
//           startCap: Cap.roundCap,
//           endCap: Cap.roundCap,
//           zIndex: 1,
//         ));
//       }
//     }
//     return set;
//   }
//
//   // ── Directions API with exponential-backoff retry ──────────────────────────
//   Future<void> _fetchRoutePolyline() async {
//     if (_pickupLatLng == null || _dropLatLng == null) return;
//     _polyRetry = 0;
//     await _tryFetchPolyline();
//   }
//
//   Future<void> _tryFetchPolyline() async {
//     String wpParam = '';
//     if (_stops.isNotEmpty) {
//       final wp = _stops
//           .where((s) => s['latitude'] != null && s['longitude'] != null)
//           .map((s) => '${s['latitude']},${s['longitude']}')
//           .join('|');
//       if (wp.isNotEmpty) wpParam = '&waypoints=optimize:true|$wp';
//     }
//
//     final url = Uri.parse(
//         'https://maps.googleapis.com/maps/api/directions/json'
//             '?origin=${_pickupLatLng!.latitude},${_pickupLatLng!.longitude}'
//             '&destination=${_dropLatLng!.latitude},${_dropLatLng!.longitude}'
//             '$wpParam'
//             '&key=$_kGoogleApiKey');
//
//     try {
//       final res = await http
//           .get(url)
//           .timeout(const Duration(seconds: 10));
//
//       if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
//
//       final data = json.decode(res.body) as Map;
//       final routes = data['routes'] as List;
//       if (routes.isEmpty) throw Exception('No routes returned');
//
//       final decoded =
//       _decodePolyline(routes[0]['overview_polyline']['points'] as String);
//
//       setState(() {
//         _routePoints  = decoded;
//         _passedPoints = [];
//         _polylines    = _buildPolylines();
//       });
//
//       _fitBounds(decoded);
//     } catch (e) {
//       debugPrint('❌ Polyline fetch error: $e (attempt $_polyRetry)');
//       if (_polyRetry < _maxPolyRetry) {
//         _polyRetry++;
//         final delay = Duration(seconds: 1 << _polyRetry);
//         Future.delayed(delay, _tryFetchPolyline);
//       } else {
//         // Fallback: straight line
//         setState(() {
//           _routePoints  = [_pickupLatLng!, _dropLatLng!];
//           _passedPoints = [];
//           _polylines    = _buildPolylines();
//         });
//       }
//     }
//   }
//
//   // ── Polyline decoder ───────────────────────────────────────────────────────
//   List<LatLng> _decodePolyline(String encoded) {
//     final pts = <LatLng>[];
//     int i = 0, lat = 0, lng = 0;
//     while (i < encoded.length) {
//       int b, shift = 0, result = 0;
//       do {
//         b = encoded.codeUnitAt(i++) - 63;
//         result |= (b & 0x1F) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//       lat += (result & 1) != 0 ? ~(result >> 1) : result >> 1;
//       shift = result = 0;
//       do {
//         b = encoded.codeUnitAt(i++) - 63;
//         result |= (b & 0x1F) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//       lng += (result & 1) != 0 ? ~(result >> 1) : result >> 1;
//       pts.add(LatLng(lat / 1e5, lng / 1e5));
//     }
//     return pts;
//   }
//
//   // ── Camera helpers ─────────────────────────────────────────────────────────
//   Future<void> _fitBounds(List<LatLng> pts) async {
//     if (pts.isEmpty || !_mapReady) return;
//     double minLat = pts.first.latitude,  maxLat = pts.first.latitude;
//     double minLng = pts.first.longitude, maxLng = pts.first.longitude;
//     for (final p in pts) {
//       if (p.latitude  < minLat) minLat = p.latitude;
//       if (p.latitude  > maxLat) maxLat = p.latitude;
//       if (p.longitude < minLng) minLng = p.longitude;
//       if (p.longitude > maxLng) maxLng = p.longitude;
//     }
//     try {
//       final c = await _mapCtrl.future;
//       c.animateCamera(CameraUpdate.newLatLngBounds(
//           LatLngBounds(
//             southwest: LatLng(minLat - 0.002, minLng - 0.002),
//             northeast: LatLng(maxLat + 0.002, maxLng + 0.002),
//           ),
//           72));
//     } catch (_) {}
//   }
//
//   // ── Helpers ────────────────────────────────────────────────────────────────
//   static double? _parseDouble(dynamic v) =>
//       v == null ? null : double.tryParse(v.toString());
//
//   @override
//   void dispose() {
//     _reconnectTimer?.cancel();
//     _noSignalTimer?.cancel();
//     _camThrottle?.cancel();
//     _socket?.off('TRACKING_JOINED');
//     _socket?.off('TRACKING_DATA');
//     _socket?.off('LIVE_LOCATION');
//     _socket?.off('RIDE_COMPLETED');
//     _socket?.off('TRACKING_ERROR');
//     _socket?.disconnect();
//     _socket?.dispose();
//     _animator.dispose();
//     _entryCtrl.dispose();
//     _pulseCtrl.dispose();
//     super.dispose();
//   }
//
//   // ══════════════════════════════════════════════════════════════════════════
//   // BUILD
//   // ══════════════════════════════════════════════════════════════════════════
//   @override
//   Widget build(BuildContext context) {
//     final mq    = MediaQuery.of(context);
//     final color = _vehicleColor;
//
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle.dark,
//       child: Scaffold(
//         backgroundColor: const Color(0xFFF7F8FC),
//         body: Column(
//           children: [
//             // ── MAP ──────────────────────────────────────────────────────
//             Expanded(
//               child: _MapSection(
//                 mapCtrl:     _mapCtrl,
//                 markers:     _markers.values.toSet(),
//                 polylines:   _polylines,
//                 topPadding:  mq.padding.top,
//                 status:      _status,
//                 errorMsg:    _errorMsg,
//                 accentColor: color,
//                 onMapReady:  () => setState(() => _mapReady = true),
//                 onZoomChange: (z) => _cameraZoom = z,
//                 cameraLock:  _cameraLock,
//                 onLockToggle: () => setState(() => _cameraLock = !_cameraLock),
//               ),
//             ),
//
//             // ── BOTTOM CARD ──────────────────────────────────────────────
//             SlideTransition(
//               position: _entrySlide,
//               child: FadeTransition(
//                 opacity: _entryFade,
//                 child: _BottomCard(
//                   vehicleLabel: _vehicleLabel,
//                   vehicleIcon:  _vehicleIconData,
//                   vehicleColor: color,
//                   driverName:   _driverName,
//                   vehicleNo:    _vehicleNo,
//                   pickupAddr:   _pickupAddress.isNotEmpty
//                       ? _pickupAddress : 'Pickup location',
//                   dropAddr:     _dropAddress.isNotEmpty
//                       ? _dropAddress : 'Drop location',
//                   status:       _status,
//                   pulseAnim:    _pulseAnim,
//                   bottomInset:  mq.padding.bottom,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ══════════════════════════════════════════════════════════════════════════════
// // MAP SECTION
// // ══════════════════════════════════════════════════════════════════════════════
// class _MapSection extends StatelessWidget {
//   final Completer<GoogleMapController> mapCtrl;
//   final Set<Marker>                    markers;
//   final Set<Polyline>                  polylines;
//   final double                         topPadding;
//   final _RideStatus                    status;
//   final String                         errorMsg;
//   final Color                          accentColor;
//   final VoidCallback                   onMapReady;
//   final ValueChanged<double>           onZoomChange;
//   final bool                           cameraLock;
//   final VoidCallback                   onLockToggle;
//
//   const _MapSection({
//     required this.mapCtrl,
//     required this.markers,
//     required this.polylines,
//     required this.topPadding,
//     required this.status,
//     required this.errorMsg,
//     required this.accentColor,
//     required this.onMapReady,
//     required this.onZoomChange,
//     required this.cameraLock,
//     required this.onLockToggle,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         // ── Map ──────────────────────────────────────────────────────────
//         GoogleMap(
//           initialCameraPosition: const CameraPosition(
//               target: LatLng(26.9036, 80.9408), zoom: 13.5),
//           markers:                 markers,
//           polylines:               polylines,
//           onMapCreated:            (c) {
//             if (!mapCtrl.isCompleted) mapCtrl.complete(c);
//             onMapReady();
//           },
//           onCameraMove:            (pos) => onZoomChange(pos.zoom),
//           myLocationButtonEnabled: false,
//           zoomControlsEnabled:     false,
//           compassEnabled:          false,
//           buildingsEnabled:        true,
//           padding:                 EdgeInsets.only(top: topPadding),
//         ),
//
//         // ── Status overlays ───────────────────────────────────────────────
//         if (status == _RideStatus.connecting)
//           _LoadingOverlay(color: accentColor),
//
//         if (status == _RideStatus.completed)
//           const _CompletedBanner(),
//
//         if (status == _RideStatus.error)
//           Positioned(
//             top: topPadding + 12,
//             left: 16, right: 16,
//             child: _StatusBanner(
//               message: errorMsg.isNotEmpty
//                   ? errorMsg : 'Unable to reach tracking server.',
//               isError: true,
//             ),
//           ),
//
//         if (status == _RideStatus.noSignal)
//           Positioned(
//             top: topPadding + 12,
//             left: 16, right: 16,
//             child: const _StatusBanner(
//               message: 'Waiting for driver location…',
//               isError: false,
//             ),
//           ),
//
//         // ── Camera lock FAB ───────────────────────────────────────────────
//         Positioned(
//           bottom: 16,
//           right: 16,
//           child: _CamLockFab(locked: cameraLock, onTap: onLockToggle),
//         ),
//       ],
//     );
//   }
// }
//
// // ── Loading overlay ────────────────────────────────────────────────────────
// class _LoadingOverlay extends StatelessWidget {
//   final Color color;
//   const _LoadingOverlay({required this.color});
//
//   @override
//   Widget build(BuildContext context) {
//     return Positioned.fill(
//       child: Container(
//         color: Colors.white.withOpacity(0.65),
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               SizedBox(
//                 width: 48, height: 48,
//                 child: CircularProgressIndicator(
//                     color: color, strokeWidth: 3),
//               ),
//               const SizedBox(height: 14),
//               const Text('Connecting to driver…',
//                   style: TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF1A1D2E))),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ── Ride completed banner ──────────────────────────────────────────────────
// class _CompletedBanner extends StatelessWidget {
//   const _CompletedBanner();
//
//   @override
//   Widget build(BuildContext context) {
//     return Positioned.fill(
//       child: Container(
//         color: Colors.black.withOpacity(0.45),
//         child: Center(
//           child: Container(
//             margin: const EdgeInsets.symmetric(horizontal: 32),
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                     color: Colors.black.withOpacity(0.12),
//                     blurRadius: 24,
//                     offset: const Offset(0, 8)),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   width: 64, height: 64,
//                   decoration: const BoxDecoration(
//                       color: Color(0xFFE6FBF0),
//                       shape: BoxShape.circle),
//                   child: const Icon(Icons.check_circle_outline_rounded,
//                       color: Color(0xFF00C853), size: 34),
//                 ),
//                 const SizedBox(height: 16),
//                 const Text('Ride Completed',
//                     style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w800,
//                         color: Color(0xFF1A1D2E))),
//                 const SizedBox(height: 6),
//                 const Text('You have safely reached your destination.',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                         fontSize: 13,
//                         color: Color(0xFF6B7280))),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ── Status banner (error / no-signal) ─────────────────────────────────────
// class _StatusBanner extends StatelessWidget {
//   final String message;
//   final bool   isError;
//   const _StatusBanner({required this.message, required this.isError});
//
//   @override
//   Widget build(BuildContext context) {
//     final clr = isError ? Colors.red : Colors.orange;
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: clr.shade200),
//         boxShadow: [
//           BoxShadow(
//               color: clr.withOpacity(0.08),
//               blurRadius: 12,
//               offset: const Offset(0, 4))
//         ],
//       ),
//       child: Row(children: [
//         Container(
//           padding: const EdgeInsets.all(6),
//           decoration: BoxDecoration(
//               color: clr.shade50, shape: BoxShape.circle),
//           child: Icon(
//               isError
//                   ? Icons.error_outline_rounded
//                   : Icons.wifi_off_rounded,
//               color: clr.shade400,
//               size: 18),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Text(message,
//               style: TextStyle(
//                   color: clr.shade700,
//                   fontSize: 13,
//                   fontWeight: FontWeight.w500)),
//         ),
//       ]),
//     );
//   }
// }
//
// // ── Camera lock FAB ────────────────────────────────────────────────────────
// class _CamLockFab extends StatelessWidget {
//   final bool locked;
//   final VoidCallback onTap;
//   const _CamLockFab({required this.locked, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 250),
//         width: 44, height: 44,
//         decoration: BoxDecoration(
//           color: locked ? const Color(0xFF3D5AFE) : Colors.white,
//           shape: BoxShape.circle,
//           boxShadow: [
//             BoxShadow(
//                 color: Colors.black.withOpacity(0.14),
//                 blurRadius: 12,
//                 offset: const Offset(0, 4))
//           ],
//         ),
//         child: Icon(
//             locked ? Icons.gps_fixed_rounded : Icons.gps_not_fixed_rounded,
//             color: locked ? Colors.white : const Color(0xFF6B7280),
//             size: 20),
//       ),
//     );
//   }
// }
//
// // ══════════════════════════════════════════════════════════════════════════════
// // BOTTOM CARD
// // ══════════════════════════════════════════════════════════════════════════════
// class _BottomCard extends StatelessWidget {
//   final String              vehicleLabel;
//   final IconData            vehicleIcon;
//   final Color               vehicleColor;
//   final String              driverName;
//   final String              vehicleNo;
//   final String              pickupAddr;
//   final String              dropAddr;
//   final _RideStatus         status;
//   final Animation<double>   pulseAnim;
//   final double              bottomInset;
//
//   const _BottomCard({
//     required this.vehicleLabel,
//     required this.vehicleIcon,
//     required this.vehicleColor,
//     required this.driverName,
//     required this.vehicleNo,
//     required this.pickupAddr,
//     required this.dropAddr,
//     required this.status,
//     required this.pulseAnim,
//     required this.bottomInset,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
//         boxShadow: [
//           BoxShadow(
//               color: Color(0x1A000000),
//               blurRadius: 24,
//               offset: Offset(0, -8))
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // drag handle
//           Center(
//             child: Container(
//               margin: const EdgeInsets.only(top: 10),
//               width: 40, height: 4,
//               decoration: BoxDecoration(
//                   color: const Color(0xFFE2E5F0),
//                   borderRadius: BorderRadius.circular(99)),
//             ),
//           ),
//           const SizedBox(height: 18),
//
//           // Vehicle badge + live pill
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Row(children: [
//               _VehicleBadge(
//                   label: vehicleLabel,
//                   icon: vehicleIcon,
//                   color: vehicleColor),
//               const Spacer(),
//               if (status == _RideStatus.live)
//                 _LivePill(pulse: pulseAnim)
//               else if (status == _RideStatus.completed)
//                 _StatusChip(
//                     label: 'Completed',
//                     bg: const Color(0xFFE6FBF0),
//                     fg: const Color(0xFF00A846),
//                     icon: Icons.check_circle_outline_rounded)
//               else if (status == _RideStatus.noSignal)
//                   _StatusChip(
//                       label: 'No Signal',
//                       bg: const Color(0xFFFFF3E0),
//                       fg: const Color(0xFFE65100),
//                       icon: Icons.wifi_off_rounded),
//             ]),
//           ),
//           const SizedBox(height: 16),
//
//           // Driver card
//           if (driverName.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: _DriverCard(
//                   name: driverName,
//                   vehicleNo: vehicleNo,
//                   vehicleIcon: vehicleIcon,
//                   vehicleColor: vehicleColor),
//             ),
//
//           if (driverName.isNotEmpty) const SizedBox(height: 14),
//
//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 20),
//             child: Divider(height: 1, color: Color(0xFFF0F2F8)),
//           ),
//           const SizedBox(height: 14),
//
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: _RouteRow(pickup: pickupAddr, drop: dropAddr),
//           ),
//
//           SizedBox(height: 18 + bottomInset),
//         ],
//       ),
//     );
//   }
// }
//
// // ── STATUS CHIP ────────────────────────────────────────────────────────────
// class _StatusChip extends StatelessWidget {
//   final String   label;
//   final Color    bg, fg;
//   final IconData icon;
//   const _StatusChip(
//       {required this.label,
//         required this.bg,
//         required this.fg,
//         required this.icon});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//           color: bg,
//           borderRadius: BorderRadius.circular(30),
//           border: Border.all(color: fg.withOpacity(0.25))),
//       child: Row(mainAxisSize: MainAxisSize.min, children: [
//         Icon(icon, size: 13, color: fg),
//         const SizedBox(width: 5),
//         Text(label,
//             style: TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w700,
//                 color: fg,
//                 letterSpacing: 0.3)),
//       ]),
//     );
//   }
// }
//
// // ── VEHICLE BADGE ──────────────────────────────────────────────────────────
// class _VehicleBadge extends StatelessWidget {
//   final String   label;
//   final IconData icon;
//   final Color    color;
//   const _VehicleBadge(
//       {required this.label, required this.icon, required this.color});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.09),
//         borderRadius: BorderRadius.circular(30),
//         border: Border.all(color: color.withOpacity(0.22)),
//       ),
//       child: Row(mainAxisSize: MainAxisSize.min, children: [
//         Icon(icon, size: 15, color: color),
//         const SizedBox(width: 6),
//         Text(label,
//             style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w700,
//                 color: color,
//                 letterSpacing: 0.2)),
//       ]),
//     );
//   }
// }
//
// // ── LIVE PILL ──────────────────────────────────────────────────────────────
// class _LivePill extends StatelessWidget {
//   final Animation<double> pulse;
//   const _LivePill({required this.pulse});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: const Color(0xFFE6FBF0),
//         borderRadius: BorderRadius.circular(30),
//         border: Border.all(
//             color: const Color(0xFF00C853).withOpacity(0.28)),
//       ),
//       child: Row(mainAxisSize: MainAxisSize.min, children: [
//         AnimatedBuilder(
//           animation: pulse,
//           builder: (_, __) => Opacity(
//             opacity: pulse.value,
//             child: Container(
//                 width: 7, height: 7,
//                 decoration: const BoxDecoration(
//                     color: Color(0xFF00C853), shape: BoxShape.circle)),
//           ),
//         ),
//         const SizedBox(width: 6),
//         const Text('LIVE',
//             style: TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w800,
//                 color: Color(0xFF00A846),
//                 letterSpacing: 0.9)),
//       ]),
//     );
//   }
// }
//
// // ── DRIVER CARD ────────────────────────────────────────────────────────────
// class _DriverCard extends StatelessWidget {
//   final String   name;
//   final String   vehicleNo;
//   final IconData vehicleIcon;
//   final Color    vehicleColor;
//
//   const _DriverCard({
//     required this.name,
//     required this.vehicleNo,
//     required this.vehicleIcon,
//     required this.vehicleColor,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF7F8FC),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: const Color(0xFFEAECF4)),
//       ),
//       child: Row(children: [
//         Container(
//           width: 48, height: 48,
//           decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: vehicleColor.withOpacity(0.10),
//               border: Border.all(
//                   color: vehicleColor.withOpacity(0.28), width: 1.5)),
//           child: Icon(vehicleIcon, color: vehicleColor, size: 22),
//         ),
//         const SizedBox(width: 14),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(name,
//                   style: const TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w700,
//                       color: Color(0xFF1A1D2E),
//                       letterSpacing: -0.2)),
//               const SizedBox(height: 4),
//               Row(children: [
//                 const Icon(Icons.drive_eta_outlined,
//                     size: 13, color: Color(0xFF9299B2)),
//                 const SizedBox(width: 4),
//                 Text(vehicleNo,
//                     style: const TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF9299B2),
//                         letterSpacing: 0.3)),
//               ]),
//             ],
//           ),
//         ),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: const Color(0xFFDDE1EC)),
//             boxShadow: [
//               BoxShadow(
//                   color: Colors.black.withOpacity(0.04),
//                   blurRadius: 6,
//                   offset: const Offset(0, 2))
//             ],
//           ),
//           child: Text(vehicleNo,
//               style: const TextStyle(
//                   fontSize: 11,
//                   fontWeight: FontWeight.w800,
//                   color: Color(0xFF1A1D2E),
//                   letterSpacing: 1.1)),
//         ),
//       ]),
//     );
//   }
// }
//
// // ── ROUTE ROW ──────────────────────────────────────────────────────────────
// class _RouteRow extends StatelessWidget {
//   final String pickup;
//   final String drop;
//   const _RouteRow({required this.pickup, required this.drop});
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       Column(children: [
//         const SizedBox(height: 2),
//         Container(
//           width: 11, height: 11,
//           decoration: BoxDecoration(
//               color: const Color(0xFF00C853),
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(
//                     color: const Color(0xFF00C853).withOpacity(0.38),
//                     blurRadius: 7,
//                     spreadRadius: 1)
//               ]),
//         ),
//         Container(
//           width: 2, height: 28,
//           margin: const EdgeInsets.symmetric(vertical: 3),
//           decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(2),
//               gradient: const LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [Color(0xFF00C853), Color(0xFFFF1744)])),
//         ),
//         Container(
//           width: 11, height: 11,
//           decoration: BoxDecoration(
//               color: const Color(0xFFFF1744),
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(
//                     color: const Color(0xFFFF1744).withOpacity(0.38),
//                     blurRadius: 7,
//                     spreadRadius: 1)
//               ]),
//         ),
//       ]),
//       const SizedBox(width: 14),
//       Expanded(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(pickup,
//                 style: const TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF1A1D2E),
//                     height: 1.3),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis),
//             const SizedBox(height: 20),
//             Text(drop,
//                 style: const TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF1A1D2E),
//                     height: 1.3),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis),
//           ],
//         ),
//       ),
//     ]);
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ShareLiveRide extends StatefulWidget {
  final String trackingToken;
  const ShareLiveRide({super.key, required this.trackingToken});

  @override
  State<ShareLiveRide> createState() => _ShareLiveRideState();
}

class _ShareLiveRideState extends State<ShareLiveRide>
    with TickerProviderStateMixin {
  // ── Constants ──────────────────────────────────────────────────────────────
  // SECURITY: do not hardcode API keys in source. Provide via:
  // - `--dart-define=GOOGLE_MAPS_API_KEY=...` for builds, or
  // - platform-specific secrets (Android manifest placeholders, iOS xcconfig).
  // Keeping this in a single file per request, but still avoiding hardcoded key.
  static const String? _googleApiKey =
  String.fromEnvironment('AIzaSyB0mG3CGok9-9RZau5J_VThUP4OTbQ_SFM');
  static const String _socketBaseUrl = 'https://dev.yoyomiles.com/';

  // ── Tuning knobs ───────────────────────────────────────────────────────────
  static const Duration _noLocationTimeout = Duration(seconds: 18);
  static const double _maxReasonableSpeedMps = 55.0; // ~198 km/h (teleport guard)
  static const double _maxSnapDistanceMeters = 60.0; // if further, likely off-route
  static const double _minAnimationDurationMs = 240;
  static const double _maxAnimationDurationMs = 4500;
  static const double _cameraUpdateMinIntervalMs = 220;
  static const double _bearingSmoothing = 0.18; // 0..1 (higher = snappier)

  // ── Map ────────────────────────────────────────────────────────────────────
  final Completer<GoogleMapController> _mapController = Completer();

  // ── Socket ─────────────────────────────────────────────────────────────────
  IO.Socket? _socket;
  bool _socketConnecting = false;
  bool _disposed = false;
  int _socketJoinAttempt = 0;
  Timer? _reconnectTimer;

  // ── Tracking data ──────────────────────────────────────────────────────────
  String        _driverName    = '';
  String        _vehicleNo     = '';
  String        _pickupAddress = '';
  String        _dropAddress   = '';
  LatLng?       _pickupLatLng;
  LatLng?       _dropLatLng;
  int           _vehicleType   = 1; // 1=cab 2=bike 3=auto 4=pickup
  List<dynamic> _stops         = [];

  // ── Map layers ─────────────────────────────────────────────────────────────
  List<LatLng> _routePoints = [];
  late final _RouteIndex _routeIndex = _RouteIndex();
  final ValueNotifier<Set<Polyline>> _polylinesVN = ValueNotifier<Set<Polyline>>(<Polyline>{});
  final ValueNotifier<Set<Marker>> _markersVN = ValueNotifier<Set<Marker>>(<Marker>{});

  // Keep lightweight marker state without rebuilding entire widget tree.
  Marker? _pickupMarker;
  Marker? _dropMarker;
  Marker? _driverMarker;

  // ── Driver smooth animation ────────────────────────────────────────────────
  LatLng? _driverLatLng; // snapped + filtered position used for rendering
  LatLng? _driverRawLatLng; // last raw input for debugging/guards
  double _driverBearing = 0;
  DateTime? _lastLocationAt;
  Timer? _noLocationTimer;

  AnimationController? _moveController;
  _RouteMotionPlan? _activeMotionPlan;

  // ── UI state ───────────────────────────────────────────────────────────────
  bool   _trackingJoined = false;
  bool   _hasError       = false;
  String _errorMsg       = '';
  bool   _isLoading      = true;
  bool _routeReady = false;
  bool _rideCompleted = false;
  bool _networkDegraded = false;

  // Camera behavior
  bool _followDriver = true;
  bool _userGestureInProgress = false;
  DateTime _lastCameraUpdate = DateTime.fromMillisecondsSinceEpoch(0);
  double? _lastKnownZoom;
  Timer? _resumeFollowTimer;

  // ── Animations ─────────────────────────────────────────────────────────────
  late AnimationController _entryController;
  late Animation<Offset>   _entrySlide;
  late Animation<double>   _entryFade;

  late AnimationController _pulseController;
  late Animation<double>   _pulseAnim;

  // ── Icons ──────────────────────────────────────────────────────────────────
  BitmapDescriptor? _cabIcon;    // type 1
  BitmapDescriptor? _bikeIcon;   // type 2
  BitmapDescriptor? _autoIcon;   // type 3
  BitmapDescriptor? _pickupIcon; // type 4

  // GPS filtering
  late final _KalmanLatLngFilter _gpsFilter = _KalmanLatLngFilter();
  final _ExpSmoother _bearingFilter = _ExpSmoother(alpha: _bearingSmoothing);

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650));
    _entrySlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic));
    _entryFade = CurvedAnimation(parent: _entryController, curve: Curves.easeOut);

    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.35, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _loadCustomIcons().then((_) {
      _connectSocket();
      Future.delayed(const Duration(milliseconds: 250), _entryController.forward);
    });

    _armNoLocationWatchdog();
  }

  // ── Emoji → BitmapDescriptor ───────────────────────────────────────────────
  /// Paints [emoji] onto a canvas and converts it to a map marker bitmap.
  Future<BitmapDescriptor> _emojiToBitmap(String emoji, double size) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final tp = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(fontSize: size * 0.75, height: 1),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(canvas, Offset((size - tp.width) / 2, (size - tp.height) / 2));

    final img = await recorder
        .endRecording()
        .toImage(size.toInt(), size.toInt());
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  Future<void> _loadCustomIcons() async {
    _cabIcon    = await _emojiToBitmap('🚖', 72); // type 1 – cab
    _bikeIcon   = await _emojiToBitmap('🛵', 72); // type 2 – 2-wheeler
    _autoIcon   = await _emojiToBitmap('🛺', 72); // type 3 – 3-wheeler
    _pickupIcon = await _emojiToBitmap('🚚', 72); // type 4 – pickup truck
  }

  // ── Vehicle helpers ────────────────────────────────────────────────────────
  BitmapDescriptor get _currentVehicleIcon {
    switch (_vehicleType) {
      case 1:  return _cabIcon    ?? BitmapDescriptor.defaultMarker;
      case 2:  return _bikeIcon   ?? BitmapDescriptor.defaultMarker;
      case 3:  return _autoIcon   ?? BitmapDescriptor.defaultMarker;
      case 4:  return _pickupIcon ?? BitmapDescriptor.defaultMarker;
      default: return _cabIcon    ?? BitmapDescriptor.defaultMarker;
    }
  }

  String get _vehicleLabel {
    switch (_vehicleType) {
      case 1:  return 'Cab';
      case 2:  return 'Bike';
      case 3:  return 'Auto';
      case 4:  return 'Pickup';
      default: return 'Vehicle';
    }
  }

  IconData get _vehicleIconData {
    switch (_vehicleType) {
      case 1:  return Icons.local_taxi_rounded;
      case 2:  return Icons.two_wheeler_rounded;
      case 3:  return Icons.electric_rickshaw_rounded;
      case 4:  return Icons.local_shipping_rounded;
      default: return Icons.directions_car_rounded;
    }
  }

  Color get _vehicleColor {
    switch (_vehicleType) {
      case 1:  return const Color(0xFFFFB800); // amber  – cab
      case 2:  return const Color(0xFFFF6B35); // orange – bike
      case 3:  return const Color(0xFF00B894); // teal   – auto
      case 4:  return const Color(0xFF6C63FF); // purple – pickup
      default: return const Color(0xFFFFB800);
    }
  }

  // ── Marker/Polyline notifiers (reduce rebuilds) ────────────────────────────
  void _emitMarkers() {
    // Build a minimal set, avoid unnecessary notifier updates.
    final next = <Marker>{
      if (_pickupMarker != null) _pickupMarker!,
      if (_dropMarker != null) _dropMarker!,
      if (_driverMarker != null) _driverMarker!,
    };

    final prev = _markersVN.value;
    if (prev.length == next.length) {
      // Quick shallow equality check on ids + positions.
      bool same = true;
      final prevById = {for (final m in prev) m.markerId.value: m};
      for (final m in next) {
        final old = prevById[m.markerId.value];
        if (old == null) {
          same = false;
          break;
        }
        final moved = _haversineMeters(old.position, m.position);
        final rotDelta = _angleDelta(old.rotation, m.rotation);
        if (moved > 0.2 || rotDelta > 0.5 || old.icon != m.icon) {
          same = false;
          break;
        }
      }
      if (same) return;
    }
    _markersVN.value = next;
  }

  void _armNoLocationWatchdog() {
    _noLocationTimer?.cancel();
    _noLocationTimer = Timer(_noLocationTimeout, () {
      if (_disposed || !mounted) return;
      if (_rideCompleted) return;
      // Don't hard-error; just surface a gentle banner and keep trying.
      setState(() {
        _networkDegraded = true;
      });
    });
  }

  void _onUserGesture() {
    _userGestureInProgress = true;
    _followDriver = false;
    _resumeFollowTimer?.cancel();
    _resumeFollowTimer = Timer(const Duration(seconds: 6), () {
      if (_disposed || !mounted) return;
      _userGestureInProgress = false;
      if (!_rideCompleted) _followDriver = true;
    });
  }

  Future<http.Response?> _retryHttpGet(
      Uri uri, {
        int maxAttempts = 4,
        Duration timeout = const Duration(seconds: 12),
      }) async {
    int attempt = 0;
    while (attempt < maxAttempts && !_disposed) {
      attempt++;
      try {
        final res = await http.get(uri).timeout(timeout);
        if (res.statusCode >= 200 && res.statusCode < 300) return res;
        // Retry only on transient-ish errors.
        if (res.statusCode < 500) return res;
      } catch (_) {
        // swallow and retry
      }
      final backoffMs = min(2500, (350 * pow(1.7, attempt)).toInt());
      await Future.delayed(Duration(milliseconds: backoffMs));
    }
    return null;
  }

  // ── Socket ─────────────────────────────────────────────────────────────────
  void _connectSocket() {
    if (_socketConnecting || _socket != null) return;
    _socketConnecting = true;

    final socket = IO.io(
      _socketBaseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableReconnection()
          .setReconnectionAttempts(999) // production: keep trying; we'll backoff join
          .setReconnectionDelay(500)
          .setReconnectionDelayMax(8000)
          .build(),
    );
    _socket = socket;

    void safeSetState(VoidCallback fn) {
      if (!_disposed && mounted) setState(fn);
    }

    void join() {
      if (_rideCompleted) return;
      final attempt = _socketJoinAttempt++;
      final delayMs = min(6000, 350 * pow(1.6, attempt)).toInt();
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(Duration(milliseconds: delayMs), () {
        if (_disposed) return;
        if (_socket?.connected == true) {
          _socket?.emit('JOIN_TRACKING', {'token': widget.trackingToken});
        }
      });
    }

    // Remove any potential duplicate listeners before attaching.
    socket.off('TRACKING_JOINED');
    socket.off('TRACKING_DATA');
    socket.off('LIVE_LOCATION');
    socket.off('TRACKING_ERROR');
    socket.off('RIDE_COMPLETED');

    socket.onConnect((_) {
      debugPrint('✅ Socket connected: ${socket.id}');
      _socketJoinAttempt = 0;
      _networkDegraded = false;
      safeSetState(() {});
      socket.emit('JOIN_TRACKING', {'token': widget.trackingToken});
    });

    socket.onDisconnect((_) {
      _networkDegraded = true;
      safeSetState(() {});
      join();
    });

    socket.onConnectError((err) {
      debugPrint('⚠️ Socket connect error: $err');
      _networkDegraded = true;
      safeSetState(() {});
      join();
    });

    socket.onError((err) {
      debugPrint('⚠️ Socket error: $err');
      _networkDegraded = true;
      safeSetState(() {});
    });

    socket.onReconnect((_) {
      _networkDegraded = false;
      safeSetState(() {});
      socket.emit('JOIN_TRACKING', {'token': widget.trackingToken});
    });

    socket.on('TRACKING_JOINED', (_) {
      safeSetState(() {
        _trackingJoined = true;
        _isLoading = false;
        _hasError = false;
        _errorMsg = '';
      });
    });

    socket.on('TRACKING_DATA', _handleTrackingData);
    socket.on('LIVE_LOCATION', _handleLiveLocation);

    socket.on('TRACKING_ERROR', (data) {
      safeSetState(() {
        _hasError = true;
        _errorMsg = data is Map ? (data['message']?.toString() ?? 'Tracking error occurred') : 'Tracking error occurred';
        _isLoading = false;
      });
    });

    socket.on('RIDE_COMPLETED', (_) {
      safeSetState(() {
        _rideCompleted = true;
        _followDriver = false;
      });
    });

    _socketConnecting = false;
  }

  // ── TRACKING_DATA ──────────────────────────────────────────────────────────
  void _handleTrackingData(dynamic data) {
    try {
      final pickLat = double.tryParse(data['pickup_latitute']?.toString() ?? '')
          ?? double.tryParse(data['pickup_lattitude']?.toString() ?? '');
      final pickLng = double.tryParse(data['pick_longitude']?.toString() ?? '');
      final dropLat = double.tryParse(data['drop_latitute']?.toString() ?? '')
          ?? double.tryParse(data['drop_lattitude']?.toString() ?? '');
      final dropLng = double.tryParse(data['drop_logitute']?.toString() ?? '')
          ?? double.tryParse(data['drop_logitude']?.toString() ?? '');

      setState(() {
        _driverName    = data['driver_name']    ?? '';
        _vehicleNo     = data['vehicle_no']     ?? '';
        _pickupAddress = data['pickup_address'] ?? '';
        _dropAddress   = data['drop_address']   ?? '';
        _vehicleType   =
            int.tryParse(data['vehicle_type']?.toString() ?? '1') ?? 1;
        _stops = data['stops'] ?? [];
        if (pickLat != null && pickLng != null) {
          _pickupLatLng = LatLng(pickLat, pickLng);
        }
        if (dropLat != null && dropLng != null) {
          _dropLatLng = LatLng(dropLat, dropLng);
        }
        final status = (data is Map ? data['status']?.toString() : null) ?? '';
        if (status.toUpperCase() == 'COMPLETED') {
          _rideCompleted = true;
          _followDriver = false;
        }
      });

      _setupStaticMarkers();
      _fetchRoutePolyline();
    } catch (e) {
      debugPrint('❌ TRACKING_DATA error: $e');
    }
  }

  // ── LIVE_LOCATION ──────────────────────────────────────────────────────────
  void _handleLiveLocation(dynamic data) {
    final lat = double.tryParse(data['latitude']?.toString()  ?? '');
    final lng = double.tryParse(data['longitude']?.toString() ?? '');
    if (lat == null || lng == null) return;

    _lastLocationAt = DateTime.now();
    _armNoLocationWatchdog();

    final raw = LatLng(lat, lng);
    _driverRawLatLng = raw;

    // Filter raw GPS first (reduce jitter).
    final filtered = _gpsFilter.filter(raw, timestamp: _lastLocationAt!);

    // If route available, snap to nearest point on polyline and ensure forward progress.
    LatLng candidate = filtered;
    double? snappedDist;
    if (_routeReady && _routeIndex.isReady) {
      final snap = _routeIndex.snapToRoute(candidate);
      candidate = snap.point;
      snappedDist = snap.distanceMeters;

      // If far away from the route, prefer filtered position (avoid hard snapping).
      if (snappedDist > _maxSnapDistanceMeters) {
        candidate = filtered;
        snappedDist = null;
      }
    }

    final prev = _driverLatLng;
    if (prev == null) {
      _driverLatLng = candidate;
      _driverBearing = _computeBearing(candidate, candidate);
      _updateDriverMarker(candidate, bearing: _driverBearing, force: true);
      _maybeFollowCamera(candidate, bearing: _driverBearing, force: true);
      return;
    }

    // Teleport / speed guard (based on straight distance as a cheap check).
    final now = _lastLocationAt!;
    final dt = max(0.2, _secondsSince(_routeIndex.lastUpdateAt ?? now, now));
    final d = _haversineMeters(prev, candidate);
    final spd = d / dt;
    if (spd > _maxReasonableSpeedMps && snappedDist == null) {
      // Ignore wild jumps if we couldn't confidently snap.
      debugPrint('⚠️ Ignoring location jump: ${spd.toStringAsFixed(1)} m/s');
      return;
    }

    // Compute target bearing based on route direction if possible.
    final targetBearing = _routeReady && _routeIndex.isReady
        ? _routeIndex.estimateBearingAt(candidate, fallbackFrom: prev)
        : _computeBearing(prev, candidate);
    _driverBearing = _bearingFilter.next(targetBearing);

    // Animate along polyline when route is ready; otherwise fallback to direct motion.
    if (_routeReady && _routeIndex.isReady) {
      final plan = _routeIndex.buildMotionPlan(from: prev, to: candidate, maxSnapMeters: _maxSnapDistanceMeters);
      _startMotionPlan(plan, targetBearing: _driverBearing, sourceTimestamp: now);
    } else {
      final plan = _RouteMotionPlan.fallbackLine(from: prev, to: candidate);
      _startMotionPlan(plan, targetBearing: _driverBearing, sourceTimestamp: now);
    }
  }

  // ── Production-grade movement + marker update ──────────────────────────────
  void _startMotionPlan(
      _RouteMotionPlan plan, {
        required double targetBearing,
        required DateTime sourceTimestamp,
      }) {
    if (_disposed) return;
    if (plan.points.length < 2) return;

    // Estimate speed from plan distance vs time between updates (fallback bounds).
    final dt = max(0.3, _secondsSince(_routeIndex.lastUpdateAt ?? sourceTimestamp, sourceTimestamp));
    _routeIndex.lastUpdateAt = sourceTimestamp;
    final distance = max(0.1, plan.totalDistanceMeters);
    final speedMps = (distance / dt).clamp(2.2, 22.0); // 8..80 km/h typical

    final durationMs = ((distance / speedMps) * 1000.0)
        .clamp(_minAnimationDurationMs, _maxAnimationDurationMs)
        .toInt();

    _activeMotionPlan = plan;

    _moveController?.stop();
    _moveController?.dispose();
    _moveController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs),
    );

    final controller = _moveController!;
    controller.addListener(() {
      final t = controller.value;
      final pos = plan.positionAt(t);
      _driverLatLng = pos;
      _updateDriverMarker(pos, bearing: targetBearing);
      _maybeFollowCamera(pos, bearing: targetBearing);
    });

    controller.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        final end = plan.points.last;
        _driverLatLng = end;
        _updateDriverMarker(end, bearing: targetBearing, force: true);
        _maybeFollowCamera(end, bearing: targetBearing, force: true);
      }
    });

    controller.forward();
  }

  void _updateDriverMarker(LatLng pos, {required double bearing, bool force = false}) {
    final newMarker = Marker(
      markerId: const MarkerId('driver'),
      position: pos,
      icon: _currentVehicleIcon,
      anchor: const Offset(0.5, 0.5),
      rotation: bearing,
      flat: true,
      zIndex: 3,
      infoWindow: InfoWindow(
        title: _driverName.isNotEmpty ? _driverName : 'Driver',
        snippet: _vehicleNo,
      ),
    );

    // Avoid broadcasting marker changes if they are visually identical-ish.
    if (!force && _driverMarker != null) {
      final old = _driverMarker!;
      final moved = _haversineMeters(old.position, pos);
      final rotDelta = _angleDelta(old.rotation, bearing);
      if (moved < 0.7 && rotDelta < 2.0 && old.icon == newMarker.icon) return;
    }

    _driverMarker = newMarker;
    _emitMarkers();
  }

  void _setupStaticMarkers() {
    if (_pickupLatLng != null) {
      _pickupMarker = Marker(
        markerId: const MarkerId('pickup'),
        position: _pickupLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        zIndex: 2,
        infoWindow: InfoWindow(title: 'Pickup', snippet: _pickupAddress),
      );
    }
    if (_dropLatLng != null) {
      _dropMarker = Marker(
        markerId: const MarkerId('drop'),
        position: _dropLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        zIndex: 2,
        infoWindow: InfoWindow(title: 'Drop', snippet: _dropAddress),
      );
    }
    _emitMarkers();
  }

  // ── Polyline ───────────────────────────────────────────────────────────────
  Future<void> _fetchRoutePolyline() async {
    if (_pickupLatLng == null || _dropLatLng == null) return;

    if (_googleApiKey == null || _googleApiKey!.trim().isEmpty) {
      setState(() {
        _hasError = true;
        _errorMsg =
        'Google Maps API key missing. Provide it using --dart-define=GOOGLE_MAPS_API_KEY=AIzaSyB0mG3CGok9-9RZau5J_VThUP4OTbQ_SFM';
        _isLoading = false;
      });
      return;
    }

    String wpParam = '';
    if (_stops.isNotEmpty) {
      final wp = _stops
          .map((s) => '${s['latitude']},${s['longitude']}')
          .join('|');
      wpParam = '&waypoints=$wp';
    }

    final url = 'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${_pickupLatLng!.latitude},${_pickupLatLng!.longitude}'
        '&destination=${_dropLatLng!.latitude},${_dropLatLng!.longitude}'
        '$wpParam&key=${Uri.encodeComponent(_googleApiKey!)}';

    try {
      final res = await _retryHttpGet(Uri.parse(url));
      if (res == null) throw Exception('Route request failed');
      final data = json.decode(res.body);
      final routes = (data['routes'] as List?) ?? const [];
      if (routes.isNotEmpty) {
        final encoded = routes[0]?['overview_polyline']?['points']?.toString() ?? '';
        final decoded = encoded.isNotEmpty ? _decodePolyline(encoded) : <LatLng>[];
        if (decoded.length < 2) throw Exception('Empty route polyline');

        _routePoints = decoded;
        _routeIndex.rebuild(decoded);
        _routeReady = true;

        _polylinesVN.value = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: decoded,
            color: const Color(0xFF3D5AFE),
            width: 5,
            jointType: JointType.round,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            zIndex: 1,
          ),
        };

        // Snap current driver (if present) to route immediately for accuracy.
        if (_driverLatLng != null && _routeIndex.isReady) {
          final snap = _routeIndex.snapToRoute(_driverLatLng!);
          if (snap.distanceMeters <= _maxSnapDistanceMeters) {
            _driverLatLng = snap.point;
            _updateDriverMarker(snap.point, bearing: _driverBearing, force: true);
          }
        }

        await _fitBounds(decoded);
        return;
      }
    } catch (_) {
      setState(() {
        _routePoints = [_pickupLatLng!, _dropLatLng!];
        _routeReady = false;
      });
      _polylinesVN.value = {
        Polyline(
          polylineId: const PolylineId('fallback'),
          points: _routePoints,
          color: const Color(0xFF3D5AFE),
          width: 5,
          zIndex: 1,
        ),
      };
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    final pts = <LatLng>[];
    int i = 0, lat = 0, lng = 0;
    while (i < encoded.length) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(i++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : result >> 1;
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(i++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : result >> 1;
      pts.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return pts;
  }

  Future<void> _fitBounds(List<LatLng> pts) async {
    if (pts.isEmpty) return;
    final c = await _mapController.future;
    double minLat = pts.first.latitude,  maxLat = pts.first.latitude;
    double minLng = pts.first.longitude, maxLng = pts.first.longitude;
    for (final p in pts) {
      if (p.latitude  < minLat) minLat = p.latitude;
      if (p.latitude  > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    c.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        80));
  }

  Future<void> _maybeFollowCamera(LatLng pos, {required double bearing, bool force = false}) async {
    if (!_followDriver || _rideCompleted) return;
    if (_userGestureInProgress) return;

    final now = DateTime.now();
    if (!force &&
        now.difference(_lastCameraUpdate).inMilliseconds <
            _cameraUpdateMinIntervalMs) {
      return;
    }
    _lastCameraUpdate = now;

    try {
      final c = await _mapController.future;
      final zoom = _lastKnownZoom ?? await c.getZoomLevel();
      _lastKnownZoom = zoom;

      final cam = CameraPosition(
        target: pos,
        zoom: zoom,
        bearing: bearing,
        tilt: 45,
      );
      await c.animateCamera(CameraUpdate.newCameraPosition(cam));
    } catch (_) {}
  }

  double _computeBearing(LatLng from, LatLng to) {
    final lat1 = from.latitude  * pi / 180;
    final lat2 = to.latitude    * pi / 180;
    final dLng = (to.longitude - from.longitude) * pi / 180;
    return (atan2(sin(dLng) * cos(lat2),
        cos(lat1) * sin(lat2) -
            sin(lat1) * cos(lat2) * cos(dLng)) *
        180 /
        pi +
        360) %
        360;
  }

  @override
  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _resumeFollowTimer?.cancel();
    _noLocationTimer?.cancel();
    try {
      _socket?.off('TRACKING_JOINED');
      _socket?.off('TRACKING_DATA');
      _socket?.off('LIVE_LOCATION');
      _socket?.off('TRACKING_ERROR');
      _socket?.off('RIDE_COMPLETED');
      _socket?.disconnect();
      _socket?.dispose();
    } catch (_) {}
    _moveController?.dispose();
    _entryController.dispose();
    _pulseController.dispose();
    _polylinesVN.dispose();
    _markersVN.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FC),
        body: Column(
          children: [
            // ── MAP ──────────────────────────────────────────────────────
            Expanded(
              child: _MapSection(
                mapController: _mapController,
                markersVN:     _markersVN,
                polylinesVN:   _polylinesVN,
                topPadding:    mq.padding.top,
                isLoading:     _isLoading,
                hasError:      _hasError,
                errorMsg:      _errorMsg,
                loadingColor:  _vehicleColor,
                networkDegraded: _networkDegraded,
                rideCompleted: _rideCompleted,
                onUserGesture: _onUserGesture,
              ),
            ),

            // ── BOTTOM CARD ──────────────────────────────────────────────
            SlideTransition(
              position: _entrySlide,
              child: FadeTransition(
                opacity: _entryFade,
                child: _BottomCard(
                  vehicleLabel: _vehicleLabel,
                  vehicleIcon:  _vehicleIconData,
                  vehicleColor: _vehicleColor,
                  driverName:   _driverName,
                  vehicleNo:    _vehicleNo,
                  pickupAddr:   _pickupAddress.isNotEmpty
                      ? _pickupAddress
                      : 'Pickup location',
                  dropAddr:     _dropAddress.isNotEmpty
                      ? _dropAddress
                      : 'Drop location',
                  isLive:       _trackingJoined,
                  pulseAnim:    _pulseAnim,
                  bottomInset:  mq.padding.bottom,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// MAP SECTION
// ══════════════════════════════════════════════════════════════════════════════
class _MapSection extends StatelessWidget {
  final Completer<GoogleMapController> mapController;
  final ValueListenable<Set<Marker>>   markersVN;
  final ValueListenable<Set<Polyline>> polylinesVN;
  final double                         topPadding;
  final bool                           isLoading;
  final bool                           hasError;
  final String                         errorMsg;
  final Color                          loadingColor;
  final bool                           networkDegraded;
  final bool                           rideCompleted;
  final VoidCallback                   onUserGesture;

  const _MapSection({
    required this.mapController,
    required this.markersVN,
    required this.polylinesVN,
    required this.topPadding,
    required this.isLoading,
    required this.hasError,
    required this.errorMsg,
    required this.loadingColor,
    required this.networkDegraded,
    required this.rideCompleted,
    required this.onUserGesture,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ValueListenableBuilder<Set<Polyline>>(
          valueListenable: polylinesVN,
          builder: (context, polylines, _) {
            return ValueListenableBuilder<Set<Marker>>(
              valueListenable: markersVN,
              builder: (context, markers, __) {
                return GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(26.9036, 80.9408),
                    zoom: 13.5,
                  ),
                  markers: markers,
                  polylines: polylines,
                  onMapCreated: (c) => mapController.complete(c),
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: false,
                  padding: EdgeInsets.only(top: topPadding),
                  onCameraMoveStarted: onUserGesture,
                );
              },
            );
          },
        ),

        // Loading overlay
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.6),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 46,
                      height: 46,
                      child: CircularProgressIndicator(
                          color: loadingColor, strokeWidth: 3),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Connecting to driver…',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1D2E)),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Error banner
        if (hasError)
          Positioned(
            top: topPadding + 12,
            left: 16,
            right: 16,
            child: _ErrorBanner(message: errorMsg),
          ),

        if (!hasError && networkDegraded)
          Positioned(
            top: topPadding + 12,
            left: 16,
            right: 16,
            child: const _InfoBanner(message: 'Network looks unstable. Reconnecting…'),
          ),

        if (rideCompleted)
          Positioned(
            top: topPadding + 56,
            left: 16,
            right: 16,
            child: const _InfoBanner(message: 'Ride completed'),
          ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// BOTTOM CARD
// ══════════════════════════════════════════════════════════════════════════════
class _BottomCard extends StatelessWidget {
  final String   vehicleLabel;
  final IconData vehicleIcon;
  final Color    vehicleColor;
  final String   driverName;
  final String   vehicleNo;
  final String   pickupAddr;
  final String   dropAddr;
  final bool     isLive;
  final Animation<double> pulseAnim;
  final double   bottomInset;

  const _BottomCard({
    required this.vehicleLabel,
    required this.vehicleIcon,
    required this.vehicleColor,
    required this.driverName,
    required this.vehicleNo,
    required this.pickupAddr,
    required this.dropAddr,
    required this.isLive,
    required this.pulseAnim,
    required this.bottomInset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E5F0),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Top row: vehicle badge + live pill
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _VehicleBadge(
                  label: vehicleLabel,
                  icon:  vehicleIcon,
                  color: vehicleColor,
                ),
                const Spacer(),
                if (isLive) _LivePill(pulse: pulseAnim),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Driver card
          if (driverName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _DriverCard(
                name:         driverName,
                vehicleNo:    vehicleNo,
                vehicleIcon:  vehicleIcon,
                vehicleColor: vehicleColor,
              ),
            ),

          if (driverName.isNotEmpty) const SizedBox(height: 16),

          // Divider
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(height: 1, color: Color(0xFFF0F2F8)),
          ),
          const SizedBox(height: 16),

          // Route
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _RouteRow(pickup: pickupAddr, drop: dropAddr),
          ),

          SizedBox(height: 20 + bottomInset),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SMALL WIDGETS
// ══════════════════════════════════════════════════════════════════════════════

class _VehicleBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _VehicleBadge(
      {required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 0.2)),
      ]),
    );
  }
}

class _LivePill extends StatelessWidget {
  final Animation<double> pulse;
  const _LivePill({required this.pulse});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE6FBF0),
        borderRadius: BorderRadius.circular(30),
        border:
        Border.all(color: const Color(0xFF00C853).withOpacity(0.28)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        AnimatedBuilder(
          animation: pulse,
          builder: (_, __) => Opacity(
            opacity: pulse.value,
            child: Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                  color: Color(0xFF00C853), shape: BoxShape.circle),
            ),
          ),
        ),
        const SizedBox(width: 6),
        const Text('LIVE',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF00A846),
                letterSpacing: 0.9)),
      ]),
    );
  }
}

class _DriverCard extends StatelessWidget {
  final String name;
  final String vehicleNo;
  final IconData vehicleIcon;
  final Color vehicleColor;

  const _DriverCard({
    required this.name,
    required this.vehicleNo,
    required this.vehicleIcon,
    required this.vehicleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAECF4)),
      ),
      child: Row(children: [
        // Icon avatar
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: vehicleColor.withOpacity(0.10),
            border: Border.all(
                color: vehicleColor.withOpacity(0.28), width: 1.5),
          ),
          child: Icon(vehicleIcon, color: vehicleColor, size: 22),
        ),
        const SizedBox(width: 14),

        // Name + vehicle no
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1D2E),
                        letterSpacing: -0.2)),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.drive_eta_outlined,
                      size: 13, color: Color(0xFF9299B2)),
                  const SizedBox(width: 4),
                  Text(vehicleNo,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF9299B2),
                          letterSpacing: 0.3)),
                ]),
              ]),
        ),

        // Number plate badge
        Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFDDE1EC)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Text(vehicleNo,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1D2E),
                  letterSpacing: 1.1)),
        ),
      ]),
    );
  }
}

class _RouteRow extends StatelessWidget {
  final String pickup;
  final String drop;
  const _RouteRow({required this.pickup, required this.drop});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Dot → line → dot
      Column(children: [
        const SizedBox(height: 2),
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
              color: const Color(0xFF00C853),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF00C853).withOpacity(0.38),
                    blurRadius: 7,
                    spreadRadius: 1)
              ]),
        ),
        Container(
          width: 2,
          height: 28,
          margin: const EdgeInsets.symmetric(vertical: 3),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF00C853), Color(0xFFFF1744)])),
        ),
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
              color: const Color(0xFFFF1744),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFFFF1744).withOpacity(0.38),
                    blurRadius: 7,
                    spreadRadius: 1)
              ]),
        ),
      ]),
      const SizedBox(width: 14),

      // Addresses
      Expanded(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(pickup,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1D2E),
                      height: 1.3),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 20),
              Text(drop,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1D2E),
                      height: 1.3),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ]),
      ),
    ]);
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.red.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              color: Colors.red.shade50, shape: BoxShape.circle),
          child: Icon(Icons.error_outline_rounded,
              color: Colors.red.shade400, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
            child: Text(message,
                style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.w500))),
      ]),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String message;
  const _InfoBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCBD2E5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFFF2F4FA),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.wifi_tethering_error_rounded,
                color: Color(0xFF667085), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF1A1D2E),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// INTERNAL HELPERS (single-file, production-oriented)
// ══════════════════════════════════════════════════════════════════════════════

extension _NumClamp on num {
  double clampDouble(double minV, double maxV) => toDouble().clamp(minV, maxV);
}

double _secondsSince(DateTime a, DateTime b) =>
    b.difference(a).inMilliseconds.abs() / 1000.0;

double _angleDelta(double a, double b) {
  final d = (a - b).abs() % 360;
  return d > 180 ? 360 - d : d;
}

double _haversineMeters(LatLng a, LatLng b) {
  const r = 6371000.0;
  final dLat = (b.latitude - a.latitude) * pi / 180;
  final dLon = (b.longitude - a.longitude) * pi / 180;
  final lat1 = a.latitude * pi / 180;
  final lat2 = b.latitude * pi / 180;
  final sinDLat = sin(dLat / 2);
  final sinDLon = sin(dLon / 2);
  final h = sinDLat * sinDLat + cos(lat1) * cos(lat2) * sinDLon * sinDLon;
  return 2 * r * asin(min(1, sqrt(h)));
}

class _ExpSmoother {
  final double alpha; // 0..1
  double? _y;
  _ExpSmoother({required this.alpha});

  double next(double x) {
    final y0 = _y;
    if (y0 == null) {
      _y = x;
      return x;
    }
    // Circular smoothing for angles.
    final a = y0 * pi / 180;
    final b = x * pi / 180;
    final sinY = (1 - alpha) * sin(a) + alpha * sin(b);
    final cosY = (1 - alpha) * cos(a) + alpha * cos(b);
    final out = (atan2(sinY, cosY) * 180 / pi + 360) % 360;
    _y = out;
    return out;
  }
}

class _Kalman1D {
  // Simple 1D Kalman filter for noisy measurements.
  // q: process noise, r: measurement noise
  final double q;
  final double r;
  double? _x;
  double _p = 1;

  _Kalman1D({this.q = 3e-6, this.r = 2e-5});

  double filter(double z) {
    if (_x == null) {
      _x = z;
      _p = 1;
      return z;
    }
    // Predict
    _p = _p + q;
    // Update
    final k = _p / (_p + r);
    _x = _x! + k * (z - _x!);
    _p = (1 - k) * _p;
    return _x!;
  }

  void reset() {
    _x = null;
    _p = 1;
  }
}

class _KalmanLatLngFilter {
  final _Kalman1D _lat = _Kalman1D();
  final _Kalman1D _lng = _Kalman1D();
  DateTime? _lastTs;

  LatLng filter(LatLng raw, {required DateTime timestamp}) {
    // If updates stall a lot, reset to avoid laggy over-smoothing.
    if (_lastTs != null &&
        timestamp.difference(_lastTs!).inSeconds > 20) {
      _lat.reset();
      _lng.reset();
    }
    _lastTs = timestamp;
    return LatLng(_lat.filter(raw.latitude), _lng.filter(raw.longitude));
  }
}

class _RouteSnapResult {
  final LatLng point;
  final int segmentIndex; // start index of segment in polyline
  final double t; // 0..1 along segment
  final double distanceMeters; // input point -> snapped point
  final double distanceAlongRouteMeters; // from start
  const _RouteSnapResult({
    required this.point,
    required this.segmentIndex,
    required this.t,
    required this.distanceMeters,
    required this.distanceAlongRouteMeters,
  });
}

class _RouteIndex {
  List<LatLng> _pts = const [];
  List<double> _cumDist = const []; // meters, same length as _pts
  bool get isReady => _pts.length >= 2 && _cumDist.length == _pts.length;
  DateTime? lastUpdateAt;

  void rebuild(List<LatLng> points) {
    _pts = List<LatLng>.unmodifiable(points);
    final cum = List<double>.filled(_pts.length, 0.0);
    double d = 0.0;
    for (int i = 1; i < _pts.length; i++) {
      d += _haversineMeters(_pts[i - 1], _pts[i]);
      cum[i] = d;
    }
    _cumDist = List<double>.unmodifiable(cum);
  }

  _RouteSnapResult snapToRoute(LatLng p) {
    if (!isReady) {
      return _RouteSnapResult(
        point: p,
        segmentIndex: 0,
        t: 0,
        distanceMeters: 0,
        distanceAlongRouteMeters: 0,
      );
    }

    // Equirectangular projection around point for local metric approximation.
    final lat0 = p.latitude * pi / 180;
    final cosLat0 = cos(lat0);

    double bestDist2 = double.infinity;
    int bestI = 0;
    double bestT = 0;
    Offset bestXY = Offset.zero;

    Offset toXY(LatLng ll) {
      final x = (ll.longitude - p.longitude) * 111320.0 * cosLat0;
      final y = (ll.latitude - p.latitude) * 110540.0;
      return Offset(x, y);
    }

    for (int i = 0; i < _pts.length - 1; i++) {
      final a = toXY(_pts[i]);
      final b = toXY(_pts[i + 1]);
      final ab = b - a;
      final ap = -a; // p is origin
      final abLen2 = ab.dx * ab.dx + ab.dy * ab.dy;
      double t = abLen2 == 0 ? 0 : ((ap.dx * ab.dx + ap.dy * ab.dy) / abLen2);
      t = t.clamp(0.0, 1.0);
      final proj = Offset(a.dx + ab.dx * t, a.dy + ab.dy * t);
      final dist2 = proj.dx * proj.dx + proj.dy * proj.dy;
      if (dist2 < bestDist2) {
        bestDist2 = dist2;
        bestI = i;
        bestT = t;
        bestXY = proj;
      }
    }

    // Convert back to LatLng.
    final dLon = bestXY.dx / (111320.0 * cosLat0);
    final dLat = bestXY.dy / 110540.0;
    final snapped = LatLng(p.latitude + dLat, p.longitude + dLon);

    final distMeters = sqrt(bestDist2);
    final along = _cumDist[bestI] +
        _haversineMeters(_pts[bestI], _pts[bestI + 1]) * bestT;

    return _RouteSnapResult(
      point: snapped,
      segmentIndex: bestI,
      t: bestT,
      distanceMeters: distMeters,
      distanceAlongRouteMeters: along,
    );
  }

  double estimateBearingAt(LatLng at, {required LatLng fallbackFrom}) {
    if (!isReady) return 0;
    final snap = snapToRoute(at);
    final i = snap.segmentIndex;
    final a = _pts[i];
    final b = _pts[min(i + 1, _pts.length - 1)];
    if (_haversineMeters(a, b) < 0.5) {
      return _computeBearingStatic(fallbackFrom, at);
    }
    return _computeBearingStatic(a, b);
  }

  _RouteMotionPlan buildMotionPlan({
    required LatLng from,
    required LatLng to,
    required double maxSnapMeters,
  }) {
    if (!isReady) return _RouteMotionPlan.fallbackLine(from: from, to: to);

    final sFrom = snapToRoute(from);
    final sTo = snapToRoute(to);
    if (sFrom.distanceMeters > maxSnapMeters || sTo.distanceMeters > maxSnapMeters) {
      return _RouteMotionPlan.fallbackLine(from: from, to: to);
    }

    // Ensure forward-ish progress; if target is behind slightly, still allow small moves.
    final startAlong = sFrom.distanceAlongRouteMeters;
    final endAlong = sTo.distanceAlongRouteMeters;

    if (endAlong <= startAlong + 1.0) {
      return _RouteMotionPlan(points: [sFrom.point, sTo.point]);
    }

    final points = <LatLng>[sFrom.point];

    // Add intermediate polyline vertices between snapped segments.
    int i = sFrom.segmentIndex + 1;
    final endI = sTo.segmentIndex;
    while (i <= endI && i < _pts.length) {
      points.add(_pts[i]);
      i++;
    }

    // Replace last with exact snapped-to point for accuracy.
    if (points.isNotEmpty) points[points.length - 1] = sTo.point;
    if (points.length < 2) points.add(sTo.point);

    return _RouteMotionPlan(points: _dedupeClose(points, minMeters: 0.4));
  }

  static List<LatLng> _dedupeClose(List<LatLng> pts, {required double minMeters}) {
    if (pts.length <= 2) return pts;
    final out = <LatLng>[pts.first];
    for (int i = 1; i < pts.length; i++) {
      if (_haversineMeters(out.last, pts[i]) >= minMeters) out.add(pts[i]);
    }
    if (out.length == 1) out.add(pts.last);
    return out;
  }
}

double _computeBearingStatic(LatLng from, LatLng to) {
  final lat1 = from.latitude * pi / 180;
  final lat2 = to.latitude * pi / 180;
  final dLng = (to.longitude - from.longitude) * pi / 180;
  return (atan2(
      sin(dLng) * cos(lat2),
      cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng)) *
      180 /
      pi +
      360) %
      360;
}

class _RouteMotionPlan {
  final List<LatLng> points;
  late final List<double> _cumDist;
  late final double totalDistanceMeters;

  _RouteMotionPlan({required this.points}) {
    _cumDist = List<double>.filled(points.length, 0.0);
    double d = 0.0;
    for (int i = 1; i < points.length; i++) {
      d += _haversineMeters(points[i - 1], points[i]);
      _cumDist[i] = d;
    }
    totalDistanceMeters = d;
  }

  factory _RouteMotionPlan.fallbackLine({required LatLng from, required LatLng to}) {
    return _RouteMotionPlan(points: [from, to]);
  }

  LatLng positionAt(double t) {
    if (points.length == 2) {
      return LatLng(
        points.first.latitude + (points.last.latitude - points.first.latitude) * t,
        points.first.longitude + (points.last.longitude - points.first.longitude) * t,
      );
    }

    final target = totalDistanceMeters * t.clamp(0.0, 1.0);
    int hi = _cumDist.length - 1;
    int lo = 0;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (_cumDist[mid] < target) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    final idx = max(1, lo);
    final prevDist = _cumDist[idx - 1];
    final segDist = max(0.0001, _cumDist[idx] - prevDist);
    final segT = ((target - prevDist) / segDist).clamp(0.0, 1.0);
    final a = points[idx - 1];
    final b = points[idx];
    return LatLng(
      a.latitude + (b.latitude - a.latitude) * segT,
      a.longitude + (b.longitude - a.longitude) * segT,
    );
  }
}