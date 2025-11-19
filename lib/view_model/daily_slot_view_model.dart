import 'package:flutter/foundation.dart';
import 'package:yoyomiles/model/daily_slot_model.dart';
import 'package:yoyomiles/repo/daily_slots_repo.dart';

class DailySlotViewModel with ChangeNotifier {
  final _dailySlotsRepo = DailySlotsRepo();
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  DailySlotModel? _dailySlotModel;
  DailySlotModel? get dailySlotModel => _dailySlotModel;

  setDailySlotData(DailySlotModel value) {
    _dailySlotModel = value;
    notifyListeners();
  }

  Future<void> dailySlotApi(String date) async {
    setLoading(true);
    try {
      final response = await _dailySlotsRepo.dailySlotApi(date);
      if (response.status == 200) {
        setDailySlotData(response);
      } else {
        setDailySlotData(response);
        debugPrint('Error: ${response.message}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in loanRequestApi: $e');
      }
    } finally {
      setLoading(false);
    }
  }
}
