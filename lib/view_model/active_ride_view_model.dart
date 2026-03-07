import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:yoyomiles/model/active_ride_model.dart';
import 'package:yoyomiles/repo/active_ride_repo.dart';

class ActiveRideViewModel with ChangeNotifier {
  final _activeRideRepo = ActiveRideRepo();

  bool _loading = false;
  bool get loading => _loading;

  ActiveRideModel? _activeRideModel;
  ActiveRideModel? get activeRideModel => _activeRideModel;


  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void setModelData(ActiveRideModel? value) {
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
        debugPrint("🟢 Active Ride Found");

      } else {
        debugPrint("⚠ No active ride found");
        _activeRideModel = null;
        notifyListeners();
      }

    } catch (error) {
      debugPrint("❌ activeRideApi exception: $error");
    } finally {
      setLoading(false);
    }
  }


}
