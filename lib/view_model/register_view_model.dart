import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yoyomiles/repo/register_repo.dart';
import 'package:yoyomiles/utils/routes/routes.dart';
import 'package:yoyomiles/utils/utils.dart';
import 'package:yoyomiles/view/bottom_nav_bar.dart';
import 'package:yoyomiles/view_model/user_view_model.dart';

class RegisterViewModel with ChangeNotifier {
  final _registerRepo = RegisterRepository();
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
  Future<void> registerApi(dynamic firstname, dynamic lastname, dynamic email,
      dynamic mobileNumber, String value,String deviceId,String fcmToken,dynamic referralCode, context) async {
    setLoading(true);
    Map data = {
      "first_name": firstname,
      "last_name": lastname,
      "email": email,
      "type": value,
      "phone": mobileNumber,
      "device_id": deviceId,
      "fcm": fcmToken,
      "referral_code" : referralCode,
    };
    print(data);
    _registerRepo.registerApi(data).then((value) async {
      setLoading(false);
      if (value['status'] == 200) {
        Utils.showSuccessMessage(context, value["message"]);

        final userId = value["data"]["id"].toString();

        final userVm = UserViewModel();
        await userVm.saveUser(userId);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const BottomNavigationPage()),
              (route) => false,
        );
      }
      else {
        Utils.showErrorMessage(context, value["message"]);
      }
    }).onError((error, stackTrace) {
      setLoading(false);
      if (kDebugMode) {
        print('error: $error');
      }
      Utils.showErrorMessage(context, error.toString());
    });
  }
}
