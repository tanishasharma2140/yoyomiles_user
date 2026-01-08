import 'package:flutter/foundation.dart';
import 'package:yoyomiles/model/vehicle_loading_model.dart';
import 'package:yoyomiles/repo/vehicle_loading_repo.dart';

class VehicleLoadingViewModel with ChangeNotifier {
  final _vehicleLoadingRepo = VehicleLoadingRepo();
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  VehicleLoadingModel? _vehicleLoadingModel;
  VehicleLoadingModel? get vehicleLoadingModel => _vehicleLoadingModel;

  setModelData(VehicleLoadingModel value) {
    _vehicleLoadingModel = value;
    notifyListeners();
  }

  Future<void> vehicleLoadingApi(String vehicleType) async {
    setLoading(true);
    try {
      final response = await _vehicleLoadingRepo.vehicleLoadingApi(vehicleType);
      if (response.success == true) {
        setModelData(response);
      } else {
        setModelData(response);
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
