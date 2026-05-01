import 'package:flutter/foundation.dart';
import 'package:yoyomiles/model/cancel_reason_model.dart';
import 'package:yoyomiles/repo/cab_cancel_reason_repo.dart';

class CancelReasonViewModel with ChangeNotifier {
  final _cabCancelReasonRepo = CabCancelReasonRepo();

  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  CancelReasonModel? _cancelReasonModel;
  CancelReasonModel? get cancelReasonModel => _cancelReasonModel;

  setCabCancelReasonData(CancelReasonModel value) {
    _cancelReasonModel = value;
    notifyListeners();
  }

  Future<void> cancelReasonApi(String date) async {
    setLoading(true);
    try {
      final response = await _cabCancelReasonRepo.cancelReasonApi(date);
      if (response.status == true) {
        setCabCancelReasonData(response);
      } else {
        setCabCancelReasonData(response);
        debugPrint('Error: ${response.message}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in cabCancelReasonApi: $e');
      }
    } finally {
      setLoading(false);
    }
  }
}
