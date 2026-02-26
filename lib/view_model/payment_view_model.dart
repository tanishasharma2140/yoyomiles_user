import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:paytmpayments_allinonesdk/paytmpayments_allinonesdk.dart';
import 'package:provider/provider.dart';
import 'package:yoyomiles/model/paytm_gateway_model.dart';
import 'package:yoyomiles/repo/payment_repo.dart';
import 'package:yoyomiles/utils/utils.dart';
import 'package:yoyomiles/view_model/update_ride_status_view_model.dart';
import 'package:yoyomiles/view_model/user_view_model.dart';

class PaymentViewModel with ChangeNotifier {
  PaymentViewModel() {
    debugPrint("PaymentViewModel instance CREATED");
  }

  final _paymentRepo = PaymentRepo();

  bool _loading = false;
  bool get loading => _loading;

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  /// Paytm config (default)
  bool isStaging = false;
  bool restrictAppInvoke = false;
  bool enableAssist = true;

  String result = '';

  PaytmGatewayModel? _paytmGatewayModel;
  PaytmGatewayModel? get paytmGatewayModel => _paytmGatewayModel;

  void setModelData(PaytmGatewayModel value) {
    _paytmGatewayModel = value;
    notifyListeners();
  }

  Future<void> paymentApi(
      dynamic userType,
      String amount,
      dynamic firebaseOrderId,
      context,
      ) async {
    setLoading(true);

    debugPrint("====== paymentApi() CALLED ======");
    debugPrint("restrictAppInvoke BEFORE API : $restrictAppInvoke");
    debugPrint("================================");

    try {
      final userViewModel = UserViewModel();
      final String? userId = await userViewModel.getUser();

      final Map<String, dynamic> data = {
        "userid": userId,
        "user_type": userType,
        "amount": amount,
        "firebase_order_id": firebaseOrderId,
      };

      final PaytmGatewayModel model =
      await _paymentRepo.paymentApi(data);

      setLoading(false);

      if (model.status != true || model.data == null) {
        Utils.showErrorMessage(
          context,
          model.message ?? "Payment failed",
        );
        return;
      }

      setModelData(model);
      Utils.showSuccessMessage(context, model.message ?? "");

      /// 🔥 ENSURE TRUE BEFORE SDK CALL
      restrictAppInvoke = true;

      await _startPaytmTransaction(
        mid: "YoYoMi53319403184444",
        orderId: model.data!.orderId!,
        txnToken: model.data!.txnToken!,
        amount: model.data!.amount.toString(),
        userType: userType,
        firebaseOrderId: firebaseOrderId.toString(),
        callbackUrl: "https://admin.yoyomiles.com/api/paytm/callback",
        context: context,
      );
    } catch (e) {
      setLoading(false);
      debugPrint("❌ Payment API error: $e");
    }
  }

  /// ================= PAYTM SDK =================
  Future<void> _startPaytmTransaction({
    required String mid,
    required String orderId,
    required String txnToken,
    required String amount,
    required String callbackUrl,
    required BuildContext context,
    required dynamic userType,
    required String firebaseOrderId,
  }) async {
    try {
      final formattedAmount =
      double.parse(amount).toStringAsFixed(2);

      final response =
      await PaytmPaymentsAllinonesdk().startTransaction(
        mid,
        orderId,
        formattedAmount,
        txnToken,
        callbackUrl,
        isStaging,
        restrictAppInvoke,
        enableAssist,
      );


      debugPrint("PAYTM RESPONSE => $response");

      if (response != null &&
          response["STATUS"] == "TXN_SUCCESS") {

        if (userType == 1) {
          final updateRideStatusVm =
          Provider.of<UpdateRideStatusViewModel>(
            context,
            listen: false,
          );

          updateRideStatusVm.updateRideApi(
            context,
            firebaseOrderId, // ✅ REAL ORDER ID
            "6", // or "5" as per flow
          );
        }


        Navigator.pushNamedAndRemoveUntil(
          context,
          "/bottomNavBar",
              (route) => false,
        );
      }

      /// ❌ FAILED / CANCELLED
      else {
        Utils.showErrorMessage(
          context,
          response?["RESPMSG"] ?? "Payment Failed",
        );
      }
    } on PlatformException catch (e) {
      Utils.showErrorMessage(context, e.message ?? "Payment Error");
    } catch (e) {
      Utils.showErrorMessage(context, e.toString());
    }
  }



}