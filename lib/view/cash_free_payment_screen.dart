// import 'package:flutter/material.dart';
// import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
// import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
// import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
// import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
// import 'package:yoyomiles/model/cash_free_gateway_model.dart';
// import 'package:yoyomiles/res/constant_color.dart';
// import 'package:yoyomiles/view_model/call_back_view_model.dart';
// import 'package:provider/provider.dart';
//
// class CashfreePaymentScreen extends StatefulWidget {
//   final String amount;
//   final CashFreeGatewayModel data;
//
//   const CashfreePaymentScreen({
//     super.key,
//     required this.amount,
//     required this.data,
//   });
//
//   @override
//   State<CashfreePaymentScreen> createState() => _CashfreePaymentScreenState();
// }
//
// class _CashfreePaymentScreenState extends State<CashfreePaymentScreen> {
//   final CFPaymentGatewayService cfPaymentGatewayService =
//       CFPaymentGatewayService();
//
//   @override
//   void initState() {
//     super.initState();
//     // Setup callbacks
//     cfPaymentGatewayService.setCallback(
//       (orderId) async {
//         final callBackVm = Provider.of<CallBackViewModel>(
//           context,
//           listen: false,
//         );
//         await callBackVm.callBackApi(
//           orderID: orderId,
//           status: 1,
//           context: context,
//         );
//       },
//       (error, orderId) {
//         _showMessage(
//           "Payment Failed: ${error.getMessage()} (Order ID: $orderId)",
//         );
//       },
//     );
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       startPayment();
//     });
//   }
//
//   Future<void> startPayment() async {
//     try {
//       /// STEP 1: Get these from your backend
//       /// Replace these with your backend-generated values
//       String orderId = widget.data.data!.orderId.toString(); // from backend
//       String paymentSessionId = widget.data.data!.paymentSessionId
//           .toString(); // from backend
//
//       /// STEP 2: Build session
//       var session = CFSessionBuilder()
//           .setEnvironment(
//             CFEnvironment.SANDBOX,
//           ) // Change to PRODUCTION in live mode
//           .setOrderId(orderId)
//           .setPaymentSessionId(paymentSessionId)
//           .build();
//
//       /// STEP 3: Build WebCheckout payment object
//       var cfWebCheckout = CFWebCheckoutPaymentBuilder()
//           .setSession(session)
//           .build();
//
//       /// STEP 4: Start payment
//       cfPaymentGatewayService.doPayment(cfWebCheckout);
//     } catch (e) {
//       _showMessage("Error starting payment: $e");
//     }
//   }
//
//   void _showMessage(String message) {
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text(message)));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(body: const Center(child: CircularProgressIndicator(color: PortColor.gold,)));
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paytmpayments_allinonesdk/paytmpayments_allinonesdk.dart';

class PaytmPaymentScreen extends StatefulWidget {
  final String orderId;
  final String txnToken;
  final String amount;

  const PaytmPaymentScreen({
    super.key,
    required this.orderId,
    required this.txnToken,
    required this.amount,
  });

  @override
  State<PaytmPaymentScreen> createState() => _PaytmPaymentScreenState();
}

class _PaytmPaymentScreenState extends State<PaytmPaymentScreen> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();

    /// 🔥 Thoda delay — same as PaytmTesting
    Future.delayed(const Duration(milliseconds: 300), _startTransaction);
  }

  Future<void> _startTransaction() async {
    if (_isProcessing) return;
    _isProcessing = true;

    /// ✅ Amount format must be xx.xx
    final String formattedAmount =
    double.parse(widget.amount).toStringAsFixed(2);

    /// ✅ SAME callback jo PaytmTesting me hota hai
    const String callbackUrl =  "";

    try {
      final result = await PaytmPaymentsAllinonesdk().startTransaction(
        "NUMvXT15573436842854", // MID
        widget.orderId,
        formattedAmount,
        widget.txnToken,
        callbackUrl,
        true,  // isStaging
        false, // restrictAppInvoke
        true,  // enableAssist
      );

      debugPrint("PAYTM RESULT => $result");

      if (result != null && result['STATUS'] == 'TXN_SUCCESS') {
        Navigator.pop(context, true); // ✅ payment success
      } else {
        Navigator.pop(context, false); // ❌ failed / cancelled
      }
    } on PlatformException catch (e) {
      debugPrint("PAYTM ERROR => ${e.message}");
      Navigator.pop(context, false);
    } catch (e) {
      debugPrint("PAYTM EXCEPTION => $e");
      Navigator.pop(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}




