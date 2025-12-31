// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:yoyomiles/model/cash_free_gateway_model.dart';
// import 'package:yoyomiles/repo/packer_mover_payment_repo.dart';
// import 'package:yoyomiles/utils/utils.dart';
// import 'package:yoyomiles/view/cash_free_payment_screen.dart';
// import 'package:yoyomiles/view/packer_mover_cashfree_screen.dart';
// import 'package:yoyomiles/view_model/user_view_model.dart';
//
// class PackerMoverPaymentViewModel with ChangeNotifier {
//   final _packerMoverPaymentRepo = PackerMoverPaymentRepo();
//   bool _loading = false;
//   bool get loading => _loading;
//
//   setLoading(bool value) {
//     _loading = value;
//     notifyListeners();
//   }
//
//   CashFreeGatewayModel? _cashFreeGatewayModel;
//   CashFreeGatewayModel? get cashFreeGatewayModel => _cashFreeGatewayModel;
//
//   setModelData(CashFreeGatewayModel value) {
//     _cashFreeGatewayModel = value;
//     notifyListeners();
//   }
//
//   Future<void> paymentApi(context, String amount,dynamic firebaseOrderId) async {
//     setLoading(true);
//     UserViewModel userViewModel = UserViewModel();
//     String? userId = await userViewModel.getUser();
//     Map data = {
//       "userid": userId,
//       "user_type": 4, // usertype = 1 user , usertype = 2 driver // usertype = 4 packer mover
//       "amount": amount,
//       "firebase_order_id": firebaseOrderId
//     };
//     print("🎁🎁🎁🎁🎁🎁");
//     print(data);
//
//     _packerMoverPaymentRepo
//         .paymentApi(data)
//         .then((value) async {
//       setLoading(false);
//       if (value.status == true) {
//         Utils.showSuccessMessage(context, value.message.toString());
//         setModelData(value);
//         Navigator.push(context, MaterialPageRoute(builder: (context)=> PackerMoverCashfreeScreen(data: value, amount: amount,)));
//       } else {
//         Utils.showErrorMessage(context, value.message.toString());
//       }
//     })
//         .onError((error, stackTrace) {
//       setLoading(false);
//       if (kDebugMode) {
//         print('error: $error');
//       }
//     });
//   }
// }
