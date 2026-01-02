import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:paytmpayments_allinonesdk/paytmpayments_allinonesdk.dart';
import 'package:yoyomiles/model/paytm_gateway_model.dart';
import 'package:yoyomiles/repo/payment_repo.dart';
import 'package:yoyomiles/utils/utils.dart';
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
  bool isStaging = true;
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
        mid: "NUMvXT15573436842854",
        orderId: model.data!.orderId!,
        txnToken: model.data!.txnToken!,
        amount: model.data!.amount.toString(),
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

      /// ✅ SUCCESS
      if (response != null &&
          response["STATUS"] == "TXN_SUCCESS") {

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

