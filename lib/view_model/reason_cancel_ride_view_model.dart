import 'package:flutter/foundation.dart';
import 'package:yoyomiles/model/reason_cancel_ride_model.dart';
import 'package:yoyomiles/repo/reason_cancel_ride_repo.dart';

class ReasonCancelRideViewModel with ChangeNotifier {
  final _reasonCancelRideRepo = ReasonCancelRideRepo();
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  ReasonCancelRideModel? _reasonCancelRideModel;
  ReasonCancelRideModel? get reasonCancelRideModel => _reasonCancelRideModel;

  setModelData(ReasonCancelRideModel value) {
    _reasonCancelRideModel = value;
    notifyListeners();
  }

  Future<void> reasonCancelApi(context) async {
    setLoading(true);
    try {
      final value = await _reasonCancelRideRepo.reasonCancelApi(context);

      if (value.status == true) {
        setModelData(value);
      }
    } catch (e) {
      if (kDebugMode) {
        print('error: $e');
      }
    } finally {
      setLoading(false);
    }
  }
}
