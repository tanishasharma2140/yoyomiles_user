import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

// ─────────────────────────────────────────────────────────────────────────────
// SECURITY: Inject keys via env / build args — never hardcode in production.
// ─────────────────────────────────────────────────────────────────────────────
const String _kGoogleApiKey = String.fromEnvironment(
  'GOOGLE_MAPS_KEY',
  defaultValue: 'AIzaSyB0mG3CGok9-9RZau5J_VThUP4OTbQ_SFM',
);
const String _kSocketBaseUrl = String.fromEnvironment(
  'SOCKET_URL',
  defaultValue: 'https://dev.yoyomiles.com/',
);

// ─────────────────────────────────────────────────────────────────────────────
// KALMAN FILTER
// ─────────────────────────────────────────────────────────────────────────────
class _KalmanFilter {
  double _estimate;
  double _errorEstimate;
  final double _errorMeasure;
  final double _q;

  _KalmanFilter({
    required double initial,
    double errorEstimate = 1.0,
    double errorMeasure = 3.0,
    double processNoise = 0.008,
  })  : _estimate = initial,
        _errorEstimate = errorEstimate,
        _errorMeasure = errorMeasure,
        _q = processNoise;

  double filter(double measurement) {
    _errorEstimate += _q;
    final kg = _errorEstimate / (_errorEstimate + _errorMeasure);
    _estimate += kg * (measurement - _estimate);
    _errorEstimate = (1 - kg) * _errorEstimate;
    return _estimate;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GPS SMOOTHER
// ─────────────────────────────────────────────────────────────────────────────
class _GpsSmoother {
  _KalmanFilter? _kfLat;
  _KalmanFilter? _kfLng;
  LatLng? _lastAccepted;
  DateTime? _lastTime;

  static const double _maxSpeedMs = 55.6;
  static const double _jitterMeters = 2.5;
  static const double _teleportMeters = 300;

  LatLng? smooth(double rawLat, double rawLng) {
    final now = DateTime.now();

    if (_kfLat == null) {
      _kfLat = _KalmanFilter(initial: rawLat);
      _kfLng = _KalmanFilter(initial: rawLng);
      _lastAccepted = LatLng(rawLat, rawLng);
      _lastTime = now;
      return _lastAccepted;
    }

    final candidate = LatLng(rawLat, rawLng);
    final dist = _haversine(_lastAccepted!, candidate);
    final dt = now.difference(_lastTime!).inMilliseconds / 1000.0;

    if (dist > _teleportMeters) {
      _kfLat = _KalmanFilter(initial: rawLat);
      _kfLng = _KalmanFilter(initial: rawLng);
      _lastAccepted = candidate;
      _lastTime = now;
      return candidate;
    }

    if (dt > 0 && dist / dt > _maxSpeedMs) return null;
    if (dist < _jitterMeters) return null;

    final sLat = _kfLat!.filter(rawLat);
    final sLng = _kfLng!.filter(rawLng);
    final smoothed = LatLng(sLat, sLng);
    _lastAccepted = smoothed;
    _lastTime = now;
    return smoothed;
  }

  static double _haversine(LatLng a, LatLng b) {
    const R = 6371000.0;
    final dLat = (b.latitude - a.latitude) * pi / 180;
    final dLng = (b.longitude - a.longitude) * pi / 180;
    final h = sin(dLat / 2) * sin(dLat / 2) +
        cos(a.latitude * pi / 180) *
            cos(b.latitude * pi / 180) *
            sin(dLng / 2) *
            sin(dLng / 2);
    return 2 * R * asin(sqrt(h));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// POLYLINE SNAPPER
// ─────────────────────────────────────────────────────────────────────────────
class _PolySolver {
  static const double _earthR = 6371000.0;

  static ({LatLng pos, int seg, double t}) snap(
      LatLng raw, List<LatLng> poly) {
    if (poly.length < 2) return (pos: raw, seg: 0, t: 0);

    double bestDist = double.infinity;
    LatLng bestPt = poly.first;
    int bestSeg = 0;
    double bestT = 0;

    for (int i = 0; i < poly.length - 1; i++) {
      final r = _closestOnSegment(raw, poly[i], poly[i + 1]);
      if (r.dist < bestDist) {
        bestDist = r.dist;
        bestPt = r.pt;
        bestSeg = i;
        bestT = r.t;
      }
    }
    return (pos: bestPt, seg: bestSeg, t: bestT);
  }

  static ({LatLng pt, double dist, double t}) _closestOnSegment(
      LatLng p, LatLng a, LatLng b) {
    final ax = a.longitude, ay = a.latitude;
    final bx = b.longitude, by = b.latitude;
    final px = p.longitude, py = p.latitude;

    final dx = bx - ax, dy = by - ay;
    final lenSq = dx * dx + dy * dy;

    double t = 0;
    if (lenSq > 0) {
      t = ((px - ax) * dx + (py - ay) * dy) / lenSq;
      t = t.clamp(0.0, 1.0);
    }

    final cx = ax + t * dx;
    final cy = ay + t * dy;
    final closest = LatLng(cy, cx);
    final d = _haversine(p, closest);
    return (pt: closest, dist: d, t: t);
  }

  static double _haversine(LatLng a, LatLng b) {
    final dLat = (b.latitude - a.latitude) * pi / 180;
    final dLng = (b.longitude - a.longitude) * pi / 180;
    final h = sin(dLat / 2) * sin(dLat / 2) +
        cos(a.latitude * pi / 180) *
            cos(b.latitude * pi / 180) *
            sin(dLng / 2) *
            sin(dLng / 2);
    return 2 * _earthR * asin(sqrt(h));
  }

  static double dist(LatLng a, LatLng b) => _haversine(a, b);

  static double bearing(LatLng from, LatLng to) {
    final lat1 = from.latitude * pi / 180;
    final lat2 = to.latitude * pi / 180;
    final dLng = (to.longitude - from.longitude) * pi / 180;
    return (atan2(
        sin(dLng) * cos(lat2),
        cos(lat1) * sin(lat2) -
            sin(lat1) * cos(lat2) * cos(dLng)) *
        180 /
        pi +
        360) %
        360;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DRIVER ANIMATOR v2
// Vehicle SIRF tab chalegi jab LIVE_LOCATION update aaye.
// Pahunchne ke baad RUKI rahegi — agla update aane tak.
// ─────────────────────────────────────────────────────────────────────────────
class _DriverAnimator {
  final void Function(LatLng pos, double bearing) onUpdate;
  final TickerProvider vsync;

  Ticker? _ticker;
  LatLng? _fromPos;
  LatLng? _toPos;
  double _bearing = 0;
  double _progress = 1.0;
  double _stepPerMs = 0;
  int? _lastTickMs;

  _DriverAnimator({required this.onUpdate, required this.vsync});

  void moveTo(LatLng target, double speedMs) {
    if (_fromPos == null) {
      _fromPos = target;
      _toPos = target;
      _progress = 1.0;
      onUpdate(target, _bearing);
      debugPrint('🚗 Animator: FIRST position set → $target');
      return;
    }

    final dist = _PolySolver.dist(_fromPos!, target);
    if (dist < 1.0) {
      debugPrint('🚗 Animator: Distance too small (${dist.toStringAsFixed(2)}m) — skipping');
      return;
    }

    final rawBearing = _PolySolver.bearing(_fromPos!, target);
    final diff = ((rawBearing - _bearing + 540) % 360) - 180;
    _bearing = (_bearing + diff * 0.4 + 360) % 360;

    _toPos = target;
    _progress = 0.0;

    final durationMs =
    (dist / speedMs.clamp(1.0, 55.0) * 1000).clamp(500.0, 3000.0);
    _stepPerMs = 1.0 / durationMs;

    debugPrint(
        '🚗 Animator: Moving → $target | dist=${dist.toStringAsFixed(1)}m | duration=${durationMs.toStringAsFixed(0)}ms');

    _lastTickMs = null;
    _ensureTicker();
  }

  void _ensureTicker() {
    if (_ticker == null) {
      _ticker = vsync.createTicker(_tick)..start();
    } else if (!_ticker!.isActive) {
      _ticker!.start();
    }
  }

  void _tick(Duration elapsed) {
    if (_fromPos == null || _toPos == null || _progress >= 1.0) {
      _ticker?.stop();
      return;
    }

    final nowMs = elapsed.inMilliseconds;
    final dtMs = _lastTickMs == null ? 16 : (nowMs - _lastTickMs!);
    _lastTickMs = nowMs;

    _progress = (_progress + _stepPerMs * dtMs).clamp(0.0, 1.0);

    final lat = _fromPos!.latitude +
        (_toPos!.latitude - _fromPos!.latitude) * _progress;
    final lng = _fromPos!.longitude +
        (_toPos!.longitude - _fromPos!.longitude) * _progress;
    final pos = LatLng(lat, lng);

    onUpdate(pos, _bearing);

    if (_progress >= 1.0) {
      _fromPos = _toPos;
      _ticker?.stop();
      debugPrint('🚗 Animator: Reached target — vehicle stopped');
    }
  }

  void dispose() {
    _ticker?.dispose();
    _ticker = null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STOP MODEL
// ─────────────────────────────────────────────────────────────────────────────
class _StopPoint {
  final int index;
  final LatLng position;
  final String address;

  const _StopPoint({
    required this.index,
    required this.position,
    required this.address,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// RIDE STATUS
// ─────────────────────────────────────────────────────────────────────────────
enum _RideStatus { connecting, live, completed, error, noSignal }

// ─────────────────────────────────────────────────────────────────────────────
// MAIN WIDGET
// ─────────────────────────────────────────────────────────────────────────────
class ShareLiveRide extends StatefulWidget {
  final String trackingToken;
  const ShareLiveRide({super.key, required this.trackingToken});

  @override
  State<ShareLiveRide> createState() => _ShareLiveRideState();
}

class _ShareLiveRideState extends State<ShareLiveRide>
    with TickerProviderStateMixin {

  // ── Map ────────────────────────────────────────────────────────────────────
  final Completer<GoogleMapController> _mapCtrl = Completer();
  bool _mapReady = false;

  // ── Socket ─────────────────────────────────────────────────────────────────
  IO.Socket? _socket;
  bool _socketConnected = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnects = 7;
  Timer? _reconnectTimer;
  Timer? _noSignalTimer;

  // ── GPS Smoother ───────────────────────────────────────────────────────────
  final _GpsSmoother _smoother = _GpsSmoother();

  // ── Driver Animator ────────────────────────────────────────────────────────
  late final _DriverAnimator _animator;
  LatLng? _driverPos;
  double _driverBearing = 0;

  // ── Tracking data ──────────────────────────────────────────────────────────
  String _driverName = '';
  String _vehicleNo = '';
  String _pickupAddress = '';
  String _dropAddress = '';
  LatLng? _pickupLatLng;
  LatLng? _dropLatLng;
  int _vehicleType = 1;

  // ── Parsed stops ───────────────────────────────────────────────────────────
  List<_StopPoint> _parsedStops = [];

  // ── Map layers ─────────────────────────────────────────────────────────────
  // Full decoded polyline from Directions API
  List<LatLng> _routePoints = [];
  // Index into _routePoints where driver currently is (snap result)
  int _snapSegIdx = 0;
  LatLng? _snapPos;

  Set<Polyline> _polylines = {};
  Map<MarkerId, Marker> _markers = {};

  // ── Stop icons cache ───────────────────────────────────────────────────────
  // We generate numbered circle icons for stops
  final Map<int, BitmapDescriptor> _stopIcons = {};

  // ── UI state ───────────────────────────────────────────────────────────────
  _RideStatus _status = _RideStatus.connecting;
  String _errorMsg = '';
  bool _cameraLock = true;

  // ── Camera ─────────────────────────────────────────────────────────────────
  double _cameraZoom = 15.5;
  LatLng? _lastCamTarget;
  Timer? _camThrottle;

  // ── Animations ─────────────────────────────────────────────────────────────
  late final AnimationController _entryCtrl;
  late final Animation<Offset> _entrySlide;
  late final Animation<double> _entryFade;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  // ── Custom vehicle icons ───────────────────────────────────────────────────
  final Map<int, BitmapDescriptor> _vehicleIcons = {};

  // ── Polyline API retry ─────────────────────────────────────────────────────
  int _polyRetry = 0;
  static const int _maxPolyRetry = 3;

  // ── Location update counter ────────────────────────────────────────────────
  int _locationUpdateCount = 0;

  @override
  void initState() {
    super.initState();

    _animator = _DriverAnimator(
      vsync: this,
      onUpdate: _onAnimatorUpdate,
    );

    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _entrySlide =
        Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
            CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
    _entryFade =
        CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.25, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _loadVehicleIcons().then((_) {
      _connectSocket();
      Future.delayed(const Duration(milliseconds: 300), _entryCtrl.forward);
    });
  }

  // ── Animator callback ──────────────────────────────────────────────────────
  void _onAnimatorUpdate(LatLng pos, double bearing) {
    _driverPos = pos;
    _driverBearing = bearing;

    // Snap driver pos onto route & recalc polylines
    if (_routePoints.length >= 2) {
      final snap = _PolySolver.snap(pos, _routePoints);
      _snapSegIdx = snap.seg;
      _snapPos = snap.pos;
    }

    final newMarker = _buildDriverMarker(pos, bearing);

    scheduleMicrotask(() {
      if (!mounted) return;
      final updated = Map<MarkerId, Marker>.from(_markers);
      updated[const MarkerId('driver')] = newMarker;
      setState(() {
        _markers = updated;
        // Rebuild polylines so passed portion updates every frame
        _polylines = _buildPolylines();
      });
    });

    if (_cameraLock) _throttledCameraFollow(pos);
  }

  // ── Camera throttle ────────────────────────────────────────────────────────
  void _throttledCameraFollow(LatLng pos) {
    if (_camThrottle?.isActive ?? false) return;
    _camThrottle = Timer(const Duration(milliseconds: 100), () async {
      if (!mounted || !_mapReady) return;
      if (_lastCamTarget != null &&
          _PolySolver.dist(_lastCamTarget!, pos) < 3) return;
      _lastCamTarget = pos;
      try {
        final ctrl = await _mapCtrl.future;
        ctrl.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              target: pos, zoom: _cameraZoom, bearing: _driverBearing),
        ));
      } catch (_) {}
    });
  }

  // ── Vehicle icons ──────────────────────────────────────────────────────────
  Future<BitmapDescriptor> _emojiToBitmap(String emoji, double size) async {
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec);
    final tp = TextPainter(
      text: TextSpan(
          text: emoji, style: TextStyle(fontSize: size * 0.72, height: 1)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((size - tp.width) / 2, (size - tp.height) / 2));
    final img = await rec.endRecording().toImage(size.toInt(), size.toInt());
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  /// Generates a numbered circle bitmap for stop markers
  Future<BitmapDescriptor> _stopNumberBitmap(int number) async {
    const double size = 72;
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec);

    // Outer shadow circle
    final shadowPaint = Paint()
      ..color = const Color(0x33FF6B35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(const Offset(size / 2, size / 2), 26, shadowPaint);

    // White ring
    final ringPaint = Paint()..color = Colors.white;
    canvas.drawCircle(const Offset(size / 2, size / 2), 24, ringPaint);

    // Filled circle
    final fillPaint = Paint()..color = const Color(0xFFFF6B35);
    canvas.drawCircle(const Offset(size / 2, size / 2), 20, fillPaint);

    // Number text
    final tp = TextPainter(
      text: TextSpan(
        text: '$number',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset((size - tp.width) / 2, (size - tp.height) / 2),
    );

    final img = await rec.endRecording().toImage(size.toInt(), size.toInt());
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  Future<void> _loadVehicleIcons() async {
    _vehicleIcons[1] = await _emojiToBitmap('🚖', 72);
    _vehicleIcons[2] = await _emojiToBitmap('🛵', 72);
    _vehicleIcons[3] = await _emojiToBitmap('🛺', 72);
    _vehicleIcons[4] = await _emojiToBitmap('🚚', 72);
  }

  /// Lazily loads stop icon for number [n], caches it
  Future<BitmapDescriptor> _getStopIcon(int n) async {
    if (_stopIcons.containsKey(n)) return _stopIcons[n]!;
    final icon = await _stopNumberBitmap(n);
    _stopIcons[n] = icon;
    return icon;
  }

  BitmapDescriptor get _currentIcon =>
      _vehicleIcons[_vehicleType] ?? BitmapDescriptor.defaultMarker;

  String get _vehicleLabel {
    const m = {1: 'Cab', 2: 'Bike', 3: 'Auto', 4: 'Pickup'};
    return m[_vehicleType] ?? 'Vehicle';
  }

  IconData get _vehicleIconData {
    const m = <int, IconData>{
      1: Icons.local_taxi_rounded,
      2: Icons.two_wheeler_rounded,
      3: Icons.electric_rickshaw_rounded,
      4: Icons.local_shipping_rounded,
    };
    return m[_vehicleType] ?? Icons.directions_car_rounded;
  }

  Color get _vehicleColor {
    const m = <int, Color>{
      1: Color(0xFFFFB800),
      2: Color(0xFFFF6B35),
      3: Color(0xFF00B894),
      4: Color(0xFF6C63FF),
    };
    return m[_vehicleType] ?? const Color(0xFFFFB800);
  }

  // ── SOCKET ─────────────────────────────────────────────────────────────────
  void _connectSocket() {
    _socket?.dispose();

    _socket = IO.io(
      _kSocketBaseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(_maxReconnects)
          .setReconnectionDelay(2000)
          .setTimeout(10000)
          .build(),
    );

    _socket!
      ..onConnect(_onSocketConnect)
      ..on('TRACKING_JOINED', _onTrackingJoined)
      ..on('TRACKING_DATA', _onTrackingData)
      ..on('LIVE_LOCATION', _onLiveLocation)
      ..on('RIDE_COMPLETED', _onRideCompleted)
      ..on('TRACKING_ERROR', _onTrackingError)
      ..onReconnect(_onReconnect)
      ..onDisconnect(_onSocketDisconnect)
      ..onConnectError(_onConnectError)
      ..connect();
  }

  void _onSocketConnect(_) {
    debugPrint('✅ Socket connected: ${_socket!.id}');
    _socketConnected = true;
    _reconnectAttempts = 0;
    _reconnectTimer?.cancel();
    _socket!.emit('JOIN_TRACKING', {'token': widget.trackingToken});
  }

  void _onTrackingJoined(_) {
    debugPrint('✅ TRACKING_JOINED received');
    if (mounted) setState(() => _status = _RideStatus.live);
    _resetNoSignalTimer();
  }

  void _onReconnect(_) {
    debugPrint('🔄 Socket reconnected');
    _socketConnected = true;
    _socket!.emit('JOIN_TRACKING', {'token': widget.trackingToken});
  }

  void _onSocketDisconnect(_) {
    debugPrint('⚠️  Socket disconnected');
    _socketConnected = false;
    if (mounted && _status != _RideStatus.completed) {
      setState(() => _status = _RideStatus.noSignal);
    }
  }

  void _onConnectError(dynamic err) {
    debugPrint('❌ Socket connect error: $err');
    _scheduleManualReconnect();
  }

  void _scheduleManualReconnect() {
    if (_reconnectAttempts >= _maxReconnects) {
      if (mounted) {
        setState(() {
          _status = _RideStatus.error;
          _errorMsg = 'Unable to connect after $_maxReconnects attempts.';
        });
      }
      return;
    }
    final delay = Duration(seconds: min(2 << _reconnectAttempts, 30));
    _reconnectAttempts++;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, _connectSocket);
  }

  void _onTrackingError(dynamic data) {
    if (mounted) {
      setState(() {
        _status = _RideStatus.error;
        _errorMsg = data['message']?.toString() ?? 'Tracking error occurred';
      });
    }
  }

  void _onRideCompleted(_) {
    debugPrint('🏁 RIDE_COMPLETED received');
    if (mounted) setState(() => _status = _RideStatus.completed);
  }

  // ── No-signal watchdog ─────────────────────────────────────────────────────
  void _resetNoSignalTimer() {
    _noSignalTimer?.cancel();
    _noSignalTimer = Timer(const Duration(seconds: 30), () {
      if (mounted && _status == _RideStatus.live) {
        debugPrint('⚠️  No location for 30s — switching to noSignal');
        setState(() => _status = _RideStatus.noSignal);
      }
    });
  }

  // ── TRACKING_DATA ──────────────────────────────────────────────────────────
  void _onTrackingData(dynamic raw) {
    print("🔥 TRACKING_DATA FULL DATA => $raw");  // 👈 add this
    try {
      final d = raw as Map;

      final pickLat = _parseDouble(d['pickup_latitute']) ??
          _parseDouble(d['pickup_lattitude']);
      final pickLng = _parseDouble(d['pick_longitude']);
      final dropLat = _parseDouble(d['drop_latitute']) ??
          _parseDouble(d['drop_lattitude']);
      final dropLng = _parseDouble(d['drop_logitute']) ??
          _parseDouble(d['drop_logitude']);

      // ── Parse stops ─────────────────────────────────────────────────────
      final rawStops = d['stops'];
      final List<_StopPoint> newStops = [];
      if (rawStops is List && rawStops.isNotEmpty) {
        for (int i = 0; i < rawStops.length; i++) {
          final s = rawStops[i];
          final lat = _parseDouble(s['latitude']);
          final lng = _parseDouble(s['longitude']);
          if (lat != null && lng != null) {
            newStops.add(_StopPoint(
              index: i + 1,
              position: LatLng(lat, lng),
              address: s['address']?.toString() ??
                  s['location']?.toString() ??
                  'Stop ${i + 1}',
            ));
          }
        }
      }

      debugPrint(
          '📦 TRACKING_DATA: driver=${d['driver_name']} vehicle=${d['vehicle_no']} stops=${newStops.length}');

      setState(() {
        _driverName = d['driver_name']?.toString() ?? '';
        _vehicleNo = d['vehicle_no']?.toString() ?? '';
        _pickupAddress = d['pickup_address']?.toString() ?? '';
        _dropAddress = d['drop_address']?.toString() ?? '';
        _vehicleType =
            int.tryParse(d['vehicle_wheeler']?.toString() ?? '1') ?? 1;
        _parsedStops = newStops;
        if (pickLat != null && pickLng != null)
          _pickupLatLng = LatLng(pickLat, pickLng);
        if (dropLat != null && dropLng != null)
          _dropLatLng = LatLng(dropLat, dropLng);
      });

      _rebuildStaticMarkers();
      _fetchRoutePolyline();
    } catch (e) {
      debugPrint('❌ TRACKING_DATA parse error: $e');
    }
  }

  // ── LIVE_LOCATION ──────────────────────────────────────────────────────────
  void _onLiveLocation(dynamic raw) {
    print("📍 LIVE_LOCATION FULL DATA => $raw");
    _locationUpdateCount++;
    final lat = _parseDouble(raw['latitude']);
    final lng = _parseDouble(raw['longitude']);
    final speed = _parseDouble(raw['speed']) ?? 10.0;
    final now = DateTime.now().toIso8601String();


    debugPrint(
      '📍 [#$_locationUpdateCount] LIVE_LOCATION | '
          'lat=$lat, lng=$lng, speed=${speed.toStringAsFixed(1)} m/s | time=$now',
    );

    if (lat == null || lng == null) {
      debugPrint('⚠️  [#$_locationUpdateCount] lat/lng null — skipping');
      return;
    }

    _resetNoSignalTimer();
    if (mounted && _status == _RideStatus.noSignal) {
      setState(() => _status = _RideStatus.live);
    }

    final smoothed = _smoother.smooth(lat, lng);
    if (smoothed == null) {
      debugPrint('🚫 [#$_locationUpdateCount] GPS smoother rejected');
      return;
    }

    debugPrint(
        '✅ [#$_locationUpdateCount] Accepted → ${smoothed.latitude.toStringAsFixed(6)}, ${smoothed.longitude.toStringAsFixed(6)}');

    _animator.moveTo(smoothed, speed);
  }

  // ── Marker builders ────────────────────────────────────────────────────────
  Marker _buildDriverMarker(LatLng pos, double bearing) => Marker(
    markerId: const MarkerId('driver'),
    position: pos,
    icon: _currentIcon,
    anchor: const Offset(0.5, 0.5),
    rotation: bearing,
    flat: true,
    zIndex: 3,
    infoWindow: InfoWindow(
      title: _driverName.isNotEmpty ? _driverName : 'Driver',
      snippet: _vehicleNo,
    ),
  );

  /// Rebuilds pickup, drop, and stop markers.
  /// Called after TRACKING_DATA received.
  void _rebuildStaticMarkers() async {
    final m = Map<MarkerId, Marker>.from(_markers);

    // Remove old stop markers
    m.removeWhere((id, _) => id.value.startsWith('stop_'));

    // Pickup
    if (_pickupLatLng != null) {
      m[const MarkerId('pickup')] = Marker(
        markerId: const MarkerId('pickup'),
        position: _pickupLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        zIndex: 2,
        infoWindow: InfoWindow(title: 'Pickup', snippet: _pickupAddress),
      );
    }

    // Drop
    if (_dropLatLng != null) {
      m[const MarkerId('drop')] = Marker(
        markerId: const MarkerId('drop'),
        position: _dropLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        zIndex: 2,
        infoWindow: InfoWindow(title: 'Drop', snippet: _dropAddress),
      );
    }

    // ── Stop markers ─────────────────────────────────────────────────────
    // Only add if _parsedStops is non-empty
    for (final stop in _parsedStops) {
      final icon = await _getStopIcon(stop.index);
      final id = MarkerId('stop_${stop.index}');
      m[id] = Marker(
        markerId: id,
        position: stop.position,
        icon: icon,
        anchor: const Offset(0.5, 0.5),
        zIndex: 2,
        infoWindow: InfoWindow(
          title: 'Stop ${stop.index}',
          snippet: stop.address,
        ),
      );
    }

    if (mounted) setState(() => _markers = m);
  }

  // ── Polyline builders ──────────────────────────────────────────────────────
  // Passed portion  = from start up to driver's snapped position (grey/faded)
  // Remaining portion = from driver's snapped position to end (blue, full)
  Set<Polyline> _buildPolylines() {
    final set = <Polyline>{};
    if (_routePoints.length < 2) return set;

    // If we have a snap position, split there
    if (_snapPos != null && _snapSegIdx < _routePoints.length - 1) {
      // Passed: routePoints[0 .. snapSegIdx] + snapPos
      final passed = [
        ..._routePoints.sublist(0, _snapSegIdx + 1),
        _snapPos!,
      ];

      // Remaining: snapPos + routePoints[snapSegIdx+1 .. end]
      final remaining = [
        _snapPos!,
        ..._routePoints.sublist(_snapSegIdx + 1),
      ];

      if (passed.length >= 2) {
        set.add(Polyline(
          polylineId: const PolylineId('passed'),
          points: passed,
          color: const Color(0xFF3D5AFE).withOpacity(0.25),
          width: 5,
          jointType: JointType.round,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          zIndex: 0,
        ));
      }

      if (remaining.length >= 2) {
        set.add(Polyline(
          polylineId: const PolylineId('route'),
          points: remaining,
          color: const Color(0xFF3D5AFE),
          width: 5,
          jointType: JointType.round,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          zIndex: 1,
        ));
      }
    } else {
      // No snap yet — show full route
      set.add(Polyline(
        polylineId: const PolylineId('route'),
        points: _routePoints,
        color: const Color(0xFF3D5AFE),
        width: 5,
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        zIndex: 1,
      ));
    }

    return set;
  }

  // ── Directions API with stops as waypoints ─────────────────────────────────
  Future<void> _fetchRoutePolyline() async {
    if (_pickupLatLng == null || _dropLatLng == null) return;
    _polyRetry = 0;
    await _tryFetchPolyline();
  }

  Future<void> _tryFetchPolyline() async {
    // Build waypoints from parsed stops
    String wpParam = '';
    if (_parsedStops.isNotEmpty) {
      final wp = _parsedStops
          .map((s) => '${s.position.latitude},${s.position.longitude}')
          .join('|');
      wpParam = '&waypoints=optimize:false|$wp';
    }

    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
            '?origin=${_pickupLatLng!.latitude},${_pickupLatLng!.longitude}'
            '&destination=${_dropLatLng!.latitude},${_dropLatLng!.longitude}'
            '$wpParam'
            '&key=$_kGoogleApiKey');

    try {
      final res = await http.get(url).timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');

      final data = json.decode(res.body) as Map;
      final routes = data['routes'] as List;
      if (routes.isEmpty) throw Exception('No routes returned');

      final decoded =
      _decodePolyline(routes[0]['overview_polyline']['points'] as String);

      debugPrint('🗺️  Polyline fetched: ${decoded.length} points');

      setState(() {
        _routePoints = decoded;
        _snapPos = null;
        _snapSegIdx = 0;
        _polylines = _buildPolylines();
      });

      _fitBounds(decoded);
    } catch (e) {
      debugPrint('❌ Polyline fetch error: $e (attempt $_polyRetry)');
      if (_polyRetry < _maxPolyRetry) {
        _polyRetry++;
        final delay = Duration(seconds: 1 << _polyRetry);
        Future.delayed(delay, _tryFetchPolyline);
      } else {
        // Fallback: straight line pickup → stops → drop
        final fallback = [
          if (_pickupLatLng != null) _pickupLatLng!,
          ..._parsedStops.map((s) => s.position),
          if (_dropLatLng != null) _dropLatLng!,
        ];
        setState(() {
          _routePoints = fallback;
          _snapPos = null;
          _snapSegIdx = 0;
          _polylines = _buildPolylines();
        });
      }
    }
  }

  // ── Polyline decoder ───────────────────────────────────────────────────────
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
      shift = result = 0;
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

  // ── Camera helpers ─────────────────────────────────────────────────────────
  Future<void> _fitBounds(List<LatLng> pts) async {
    if (pts.isEmpty || !_mapReady) return;
    double minLat = pts.first.latitude, maxLat = pts.first.latitude;
    double minLng = pts.first.longitude, maxLng = pts.first.longitude;
    for (final p in pts) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    try {
      final c = await _mapCtrl.future;
      c.animateCamera(CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat - 0.002, minLng - 0.002),
            northeast: LatLng(maxLat + 0.002, maxLng + 0.002),
          ),
          72));
    } catch (_) {}
  }

  static double? _parseDouble(dynamic v) =>
      v == null ? null : double.tryParse(v.toString());

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _noSignalTimer?.cancel();
    _camThrottle?.cancel();
    _socket?.off('TRACKING_JOINED');
    _socket?.off('TRACKING_DATA');
    _socket?.off('LIVE_LOCATION');
    _socket?.off('RIDE_COMPLETED');
    _socket?.off('TRACKING_ERROR');
    _socket?.disconnect();
    _socket?.dispose();
    _animator.dispose();
    _entryCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final color = _vehicleColor;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FC),
        body: Column(
          children: [
            Expanded(
              child: _MapSection(
                mapCtrl: _mapCtrl,
                markers: _markers.values.toSet(),
                polylines: _polylines,
                topPadding: mq.padding.top,
                status: _status,
                errorMsg: _errorMsg,
                accentColor: color,
                onMapReady: () => setState(() => _mapReady = true),
                onZoomChange: (z) => _cameraZoom = z,
                cameraLock: _cameraLock,
                onLockToggle: () =>
                    setState(() => _cameraLock = !_cameraLock),
              ),
            ),
            SlideTransition(
              position: _entrySlide,
              child: FadeTransition(
                opacity: _entryFade,
                child: _BottomCard(
                  vehicleLabel: _vehicleLabel,
                  vehicleIcon: _vehicleIconData,
                  vehicleColor: color,
                  driverName: _driverName,
                  vehicleNo: _vehicleNo,
                  pickupAddr: _pickupAddress.isNotEmpty
                      ? _pickupAddress
                      : 'Pickup location',
                  dropAddr: _dropAddress.isNotEmpty
                      ? _dropAddress
                      : 'Drop location',
                  stops: _parsedStops,
                  status: _status,
                  pulseAnim: _pulseAnim,
                  bottomInset: mq.padding.bottom,
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
  final Completer<GoogleMapController> mapCtrl;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final double topPadding;
  final _RideStatus status;
  final String errorMsg;
  final Color accentColor;
  final VoidCallback onMapReady;
  final ValueChanged<double> onZoomChange;
  final bool cameraLock;
  final VoidCallback onLockToggle;

  const _MapSection({
    required this.mapCtrl,
    required this.markers,
    required this.polylines,
    required this.topPadding,
    required this.status,
    required this.errorMsg,
    required this.accentColor,
    required this.onMapReady,
    required this.onZoomChange,
    required this.cameraLock,
    required this.onLockToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(
              target: LatLng(26.9036, 80.9408), zoom: 13.5),
          markers: markers,
          polylines: polylines,
          onMapCreated: (c) {
            if (!mapCtrl.isCompleted) mapCtrl.complete(c);
            onMapReady();
          },
          onCameraMove: (pos) => onZoomChange(pos.zoom),
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          compassEnabled: false,
          buildingsEnabled: true,
          padding: EdgeInsets.only(top: topPadding),
        ),
        if (status == _RideStatus.connecting)
          _LoadingOverlay(color: accentColor),
        if (status == _RideStatus.completed) const _CompletedBanner(),
        if (status == _RideStatus.error)
          Positioned(
            top: topPadding + 12,
            left: 16,
            right: 16,
            child: _StatusBanner(
              message: errorMsg.isNotEmpty
                  ? errorMsg
                  : 'Unable to reach tracking server.',
              isError: true,
            ),
          ),
        if (status == _RideStatus.noSignal)
          Positioned(
            top: topPadding + 12,
            left: 16,
            right: 16,
            child: const _StatusBanner(
              message: 'Waiting for driver location…',
              isError: false,
            ),
          ),
        Positioned(
          bottom: 16,
          right: 16,
          child: _CamLockFab(locked: cameraLock, onTap: onLockToggle),
        ),
      ],
    );
  }
}

// ── Loading overlay ────────────────────────────────────────────────────────
class _LoadingOverlay extends StatelessWidget {
  final Color color;
  const _LoadingOverlay({required this.color});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.white.withOpacity(0.65),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child:
                CircularProgressIndicator(color: color, strokeWidth: 3),
              ),
              const SizedBox(height: 14),
              const Text('Connecting to driver…',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1D2E))),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Ride completed banner ──────────────────────────────────────────────────
class _CompletedBanner extends StatelessWidget {
  const _CompletedBanner();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.45),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                      color: Color(0xFFE6FBF0), shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle_outline_rounded,
                      color: Color(0xFF00C853), size: 34),
                ),
                const SizedBox(height: 16),
                const Text('Ride Completed',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1D2E))),
                const SizedBox(height: 6),
                const Text('You have safely reached your destination.',
                    textAlign: TextAlign.center,
                    style:
                    TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Status banner ──────────────────────────────────────────────────────────
class _StatusBanner extends StatelessWidget {
  final String message;
  final bool isError;
  const _StatusBanner({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    final clr = isError ? Colors.red : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: clr.shade200),
        boxShadow: [
          BoxShadow(
              color: clr.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration:
          BoxDecoration(color: clr.shade50, shape: BoxShape.circle),
          child: Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.wifi_off_rounded,
              color: clr.shade400,
              size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(message,
              style: TextStyle(
                  color: clr.shade700,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ),
      ]),
    );
  }
}

// ── Camera lock FAB ────────────────────────────────────────────────────────
class _CamLockFab extends StatelessWidget {
  final bool locked;
  final VoidCallback onTap;
  const _CamLockFab({required this.locked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: locked ? const Color(0xFF3D5AFE) : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.14),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Icon(
            locked
                ? Icons.gps_fixed_rounded
                : Icons.gps_not_fixed_rounded,
            color: locked ? Colors.white : const Color(0xFF6B7280),
            size: 20),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// BOTTOM CARD
// ══════════════════════════════════════════════════════════════════════════════
class _BottomCard extends StatelessWidget {
  final String vehicleLabel;
  final IconData vehicleIcon;
  final Color vehicleColor;
  final String driverName;
  final String vehicleNo;
  final String pickupAddr;
  final String dropAddr;
  final List<_StopPoint> stops;
  final _RideStatus status;
  final Animation<double> pulseAnim;
  final double bottomInset;

  const _BottomCard({
    required this.vehicleLabel,
    required this.vehicleIcon,
    required this.vehicleColor,
    required this.driverName,
    required this.vehicleNo,
    required this.pickupAddr,
    required this.dropAddr,
    required this.stops,
    required this.status,
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
              offset: Offset(0, -8))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFFE2E5F0),
                  borderRadius: BorderRadius.circular(99)),
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              _VehicleBadge(
                  label: vehicleLabel,
                  icon: vehicleIcon,
                  color: vehicleColor),
              const Spacer(),
              if (status == _RideStatus.live)
                _LivePill(pulse: pulseAnim)
              else if (status == _RideStatus.completed)
                _StatusChip(
                    label: 'Completed',
                    bg: const Color(0xFFE6FBF0),
                    fg: const Color(0xFF00A846),
                    icon: Icons.check_circle_outline_rounded)
              else if (status == _RideStatus.noSignal)
                  _StatusChip(
                      label: 'No Signal',
                      bg: const Color(0xFFFFF3E0),
                      fg: const Color(0xFFE65100),
                      icon: Icons.wifi_off_rounded),
            ]),
          ),
          const SizedBox(height: 16),
          if (driverName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _DriverCard(
                  name: driverName,
                  vehicleNo: vehicleNo,
                  vehicleIcon: vehicleIcon,
                  vehicleColor: vehicleColor),
            ),
          if (driverName.isNotEmpty) const SizedBox(height: 14),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(height: 1, color: Color(0xFFF0F2F8)),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _RouteRow(
              pickup: pickupAddr,
              drop: dropAddr,
              stops: stops,
            ),
          ),
          SizedBox(height: 18 + bottomInset),
        ],
      ),
    );
  }
}

// ── STATUS CHIP ────────────────────────────────────────────────────────────
class _StatusChip extends StatelessWidget {
  final String label;
  final Color bg, fg;
  final IconData icon;
  const _StatusChip(
      {required this.label,
        required this.bg,
        required this.fg,
        required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: fg.withOpacity(0.25))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: fg),
        const SizedBox(width: 5),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: fg,
                letterSpacing: 0.3)),
      ]),
    );
  }
}

// ── VEHICLE BADGE ──────────────────────────────────────────────────────────
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

// ── LIVE PILL ──────────────────────────────────────────────────────────────
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
        border: Border.all(color: const Color(0xFF00C853).withOpacity(0.28)),
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
                    color: Color(0xFF00C853), shape: BoxShape.circle)),
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

// ── DRIVER CARD ────────────────────────────────────────────────────────────
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
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: vehicleColor.withOpacity(0.10),
              border: Border.all(
                  color: vehicleColor.withOpacity(0.28), width: 1.5)),
          child: Icon(vehicleIcon, color: vehicleColor, size: 22),
        ),
        const SizedBox(width: 14),
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
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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

// ── ROUTE ROW — now with stops in between ─────────────────────────────────
class _RouteRow extends StatelessWidget {
  final String pickup;
  final String drop;
  final List<_StopPoint> stops;

  const _RouteRow({
    required this.pickup,
    required this.drop,
    required this.stops,
  });

  @override
  Widget build(BuildContext context) {
    // Build combined list: pickup → stops (if any) → drop
    final items = <({String label, String address, _RowItemType type, int? stopNum})>[
      (label: 'Pickup', address: pickup, type: _RowItemType.pickup, stopNum: null),
      ...stops.map((s) => (
      label: 'Stop ${s.index}',
      address: s.address,
      type: _RowItemType.stop,
      stopNum: s.index,
      )),
      (label: 'Drop', address: drop, type: _RowItemType.drop, stopNum: null),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Left timeline column ─────────────────────────────────────────
        Column(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              _TimelineDot(type: items[i].type, stopNum: items[i].stopNum),
              if (i < items.length - 1)
                Container(
                  width: 2,
                  height: 26,
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _dotColor(items[i].type),
                        _dotColor(items[i + 1].type),
                      ],
                    ),
                  ),
                ),
            ],
          ],
        ),
        const SizedBox(width: 14),
        // ── Right label column ───────────────────────────────────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < items.length; i++) ...[
                Padding(
                  // Vertically centre label with dot (dot height = 11)
                  padding: EdgeInsets.only(top: i == 0 ? 0 : 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (items[i].type == _RowItemType.stop)
                        Text(
                          items[i].label,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFF6B35),
                            letterSpacing: 0.3,
                          ),
                        ),
                      Text(
                        items[i].address,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1D2E),
                            height: 1.3),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (i < items.length - 1) const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Color _dotColor(_RowItemType type) {
    switch (type) {
      case _RowItemType.pickup:
        return const Color(0xFF00C853);
      case _RowItemType.stop:
        return const Color(0xFFFF6B35);
      case _RowItemType.drop:
        return const Color(0xFFFF1744);
    }
  }
}

enum _RowItemType { pickup, stop, drop }

// ── Timeline dot widget ────────────────────────────────────────────────────
class _TimelineDot extends StatelessWidget {
  final _RowItemType type;
  final int? stopNum;
  const _TimelineDot({required this.type, this.stopNum});

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case _RowItemType.pickup:
        return Container(
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
        );

      case _RowItemType.stop:
        return Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B35),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFFFF6B35).withOpacity(0.35),
                  blurRadius: 6,
                  spreadRadius: 1)
            ],
          ),
          child: Center(
            child: Text(
              '${stopNum ?? ''}',
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1,
              ),
            ),
          ),
        );

      case _RowItemType.drop:
        return Container(
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
        );
    }
  }
}