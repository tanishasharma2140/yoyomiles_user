// import 'package:flutter/material.dart';
// import 'package:yoyomiles/repo/change_pay_mode_repo.dart';
// import 'package:yoyomiles/utils/utils.dart';
//
// class ChangePayModeViewModel with ChangeNotifier {
//   final _changePayModeRepo = ChangePayModeRepo();
//   bool _loading = false;
//
//   bool get loading => _loading;
//
//   setLoading(bool value) {
//     _loading = value;
//     notifyListeners();
//   }
//
//   Future<void> changePayModeApi({
//     required BuildContext context,
//     required String orderId,
//     required int payMode,
//   }) async {
//     setLoading(true);
//
//     final Map data = {
//       "order_id": orderId,
//       "paymode": payMode,
//     };
//
//     final response = await _changePayModeRepo.changePayModeApi(data);
//     setLoading(false);
//
//     if (response != null && response['status'] == 200) {
//       Utils.showSuccessMessage(context, response['message']);
//       Navigator.pop(context); // close bottom sheet
//     } else {
//       Utils.showErrorMessage(context, "Failed to change payment mode");
//     }
//   }
//
//
// }
