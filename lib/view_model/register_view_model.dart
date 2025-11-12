import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:port_karo/repo/register_repo.dart';
import 'package:port_karo/utils/routes/routes.dart';
import 'package:port_karo/utils/utils.dart';

class RegisterViewModel with ChangeNotifier {
  final _registerRepo = RegisterRepository();
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
  Future<void> registerApi(dynamic firstname, dynamic lastname, dynamic email,
      dynamic mobileNumber, String value,String deviceId,String fcmToken, context) async {
    setLoading(true);
    Map data = {
      "first_name": firstname,
      "last_name": lastname,
      "email": email,
      "type": value,
      "phone": mobileNumber,
      "device_id": deviceId,
      "fcm": fcmToken,
    };
    print(data);
    _registerRepo.registerApi(data).then((value) async {
      setLoading(false);
      if (value['status'] == 200) {
        print(value);
        Utils.showSuccessMessage(context, value["message"]);
        Navigator.pushNamed(context, RoutesName.otp,arguments: {"mobileNumber": mobileNumber,"userId":value["data"]["id"].toString(),});
      } else {
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
