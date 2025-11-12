import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:port_karo/model/active_ride_model.dart';
import 'package:port_karo/repo/active_ride_repo.dart';

class ActiveRideViewModel with ChangeNotifier {
  final _activeRideRepo = ActiveRideRepo();

  bool _loading = false;
  bool get loading => _loading;

  ActiveRideModel? _activeRideModel;
  ActiveRideModel? get activeRideModel => _activeRideModel;

  StreamSubscription<QuerySnapshot>? _rideListener;

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void setModelData(ActiveRideModel value) {
    _activeRideModel = value;
    notifyListeners();
  }

  Future<void> activeRideApi(String userId) async {
    setLoading(true);
    try {
      final value = await _activeRideRepo.activeRideApi(userId);
      debugPrint('🚀 activeRideApi response: $value');

      if (value.status == 200) {
        setModelData(value);
      }
    } catch (error) {
      if (kDebugMode) print('❌ activeRideApi error: $error');
    } finally {
      setLoading(false);
    }
  }

  /// 🎧 Firestore Listener
  void listenToActiveRide(String userId) {
    debugPrint("👂 Starting listener for active rides of user: $userId");

    // Cancel old listener first
    cancelRideListener();

    _rideListener = FirebaseFirestore.instance
        .collection('order')
        .where('userid', isEqualTo: userId) // keep same type as in Firestore
        .where('ride_status', isEqualTo: 1) // match Firestore type
        .snapshots()
        .listen((snapshot) {
      debugPrint("📡 Firestore listener triggered. Docs: ${snapshot.docs.length}");

      if (snapshot.docs.isNotEmpty) {
        final rideDoc = snapshot.docs.first;
        final rideData = rideDoc.data();
        final rideId = rideDoc.id;

        debugPrint("✅ Active ride found: $rideId, data: $rideData");

        _activeRideModel = ActiveRideModel.fromJson({
          "data": rideData,
          "document_id": rideId,
        });
        notifyListeners();
      } else {
        debugPrint("❌ No active ride found for user: $userId");
        _activeRideModel = null;
        notifyListeners();
      }
    }, onError: (error) {
      debugPrint("🔥 Firestore listener error: $error");
    });
  }

  void cancelRideListener() {
    debugPrint("🛑 Stopping active ride listener...");
    _rideListener?.cancel();
    _rideListener = null;
  }
}
