// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:yoyomiles/model/cash_free_gateway_model.dart';
// import 'package:yoyomiles/repo/add_money_payment_repo.dart';
// import 'package:yoyomiles/utils/utils.dart';
// import 'package:yoyomiles/view/payment/add_money_cashfree_screen.dart'
//     show AddMoneyCashfreeScreen;
// import 'package:yoyomiles/view_model/user_view_model.dart';
//
// class AddMoneyPaymentViewModel with ChangeNotifier {
//   final _addMoneyPaymentRepo = AddMoneyPaymentRepo();
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
//   Future<void> paymentApi(
//     context,
//     String amount,
//     dynamic firebaseOrderId,
//   ) async {
//     setLoading(true);
//     UserViewModel userViewModel = UserViewModel();
//     String? userId = await userViewModel.getUser();
//     Map data = {
//       "userid": userId,
//       "user_type":
//           5, // usertype = 1 user , usertype = 2 driver // usertype = 4 packer mover // user_type = 5 AddMoney
//       "amount": amount,
//       "firebase_order_id": firebaseOrderId,
//     };
//     print("🎁🎁🎁🎁🎁🎁");
//     print(data);
//
//     _addMoneyPaymentRepo
//         .paymentApi(data)
//         .then((value) async {
//           setLoading(false);
//           if (value.status == true) {
//             Utils.showSuccessMessage(context, value.message.toString());
//             setModelData(value);
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) =>
//                     AddMoneyCashfreeScreen(data: value, amount: amount),
//               ),
//             );
//           } else {
//             Utils.showErrorMessage(context, value.message.toString());
//           }
//         })
//         .onError((error, stackTrace) {
//           setLoading(false);
//           if (kDebugMode) {
//             print('error: $error');
//           }
//         });
//   }
// }
