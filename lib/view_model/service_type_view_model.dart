import 'package:flutter/foundation.dart';
import 'package:yoyomiles/model/service_type_model.dart';
import 'package:yoyomiles/repo/service_type_repo.dart';

class ServiceTypeViewModel with ChangeNotifier {
  final _serviceTypeRepo = ServiceTypeRepo();

  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  ServiceTypeModel? _serviceTypeModel;
  ServiceTypeModel? get serviceTypeModel => _serviceTypeModel;

  setModelData(ServiceTypeModel value) {
    _serviceTypeModel = value;
    notifyListeners();
  }

  // ✅ Selected Vehicle ID
  String? _selectedVehicleId;
  String? get selectedVehicleId => _selectedVehicleId;

  void setSelectedVehicleId(String id) {
    _selectedVehicleId = id;
    notifyListeners();
  }

  // ✅ Selected Vehicle Type (NEW)
  int? _selectedVehicleType;
  int? get selectedVehicleType => _selectedVehicleType;

  void setSelectedVehicleType(int type) {
    _selectedVehicleType = type;
    notifyListeners();
  }

  // ✅ API Call
  Future<void> serviceTypeApi() async {
    setLoading(true);
    try {
      final response = await _serviceTypeRepo.serviceTypeApi();
      if (response.status == 200) {
        setModelData(response);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in serviceTypeApi: $e');
      }
    } finally {
      setLoading(false);
    }
  }
}
