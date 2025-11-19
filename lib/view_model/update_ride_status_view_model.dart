import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yoyomiles/repo/update_ride_status_repo.dart';
import 'package:yoyomiles/utils/utils.dart';
import 'package:yoyomiles/view/bottom_nav_bar.dart';
import 'package:yoyomiles/view/home/home.dart';


class UpdateRideStatusViewModel with ChangeNotifier {
  final _updateRideStatusRepo = UpdateRideStatusRepo();
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<void> updateRideApi(context, String id, String rideStatus) async {
    setLoading(true);

    Map data = {"id": id, "ride_status": rideStatus};

    _updateRideStatusRepo.updateRideApi(data).then((value) async {
      setLoading(false);
      if (value['success'] == true) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>BottomNavigationPage()),    (route) => false,);
        Utils.showSuccessMessage(context, value["message"]);
      } else {
        Utils.showErrorMessage(context, value["message"]);
      }
    }).onError((error, stackTrace) {
      setLoading(false);
      if (kDebugMode) {
        print('error: $error');
      }
    });
  }
}
