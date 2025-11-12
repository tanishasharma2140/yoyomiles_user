// dart
// File: `lib/view_model/select_vehicles_view_model.dart`

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:port_karo/model/select_vehicles_model.dart';
import 'package:port_karo/repo/select_vehicles_repo.dart';
import 'package:port_karo/utils/utils.dart';

class SelectVehiclesViewModel with ChangeNotifier {
  final _selectVehicleRepo = SelectVehiclesRepo();

  SelectVehicleModel? _selectVehicleModel;
  SelectVehicleModel? get selectVehicleModel => _selectVehicleModel;

  bool _loading = false;
  bool get loading => _loading;
  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void setVehicleData(SelectVehicleModel value) {
    _selectVehicleModel = value;
    notifyListeners();
  }

  Future<void> selectVehicleApi(
      dynamic vehicleId,
      dynamic range,
      dynamic type,
      dynamic pickupLatitude,
      dynamic pickupLongitude,
      BuildContext context,
      ) async {
    Map<String, dynamic> data = {
      "vehicle_id": vehicleId,
      "range": range,
      "type": type,
      "pickup_latitude": pickupLatitude,
      "pickup_longitude": pickupLongitude,
    };

    print("dataceadfdwsw:${data}");

    setLoading(true);
    _selectVehicleRepo.selectVehicleApi(data).then((value) {
      setLoading(false);

      if (value.status == 200) {
        setVehicleData(value);
      } else {
        // 🧾 Show error message if API returns non-200 status
        final errorMsg = value.message ?? "Something went wrong!";
        if (kDebugMode) {
          print("⚠️ API Error: $errorMsg");
        }

        Utils.showErrorMessage(context, errorMsg);

      }
    }).onError((error, stackTrace) {
      setLoading(false);

      // 🧾 Handle runtime or network error
      if (kDebugMode) {
        print("❌ Exception: $error");
      }
      Utils.showErrorMessage(context, "An error occurred: $error");

    });
  }
}
