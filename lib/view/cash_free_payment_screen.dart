import 'package:flutter/material.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:port_karo/model/cash_free_gateway_model.dart';
import 'package:port_karo/res/constant_color.dart';
import 'package:port_karo/view_model/call_back_view_model.dart';
import 'package:provider/provider.dart';

class CashfreePaymentScreen extends StatefulWidget {
  final String amount;
  final CashFreeGatewayModel data;

  const CashfreePaymentScreen({
    super.key,
    required this.amount,
    required this.data,
  });

  @override
  State<CashfreePaymentScreen> createState() => _CashfreePaymentScreenState();
}

class _CashfreePaymentScreenState extends State<CashfreePaymentScreen> {
  final CFPaymentGatewayService cfPaymentGatewayService =
      CFPaymentGatewayService();

  @override
  void initState() {
    super.initState();
    // Setup callbacks
    cfPaymentGatewayService.setCallback(
      (orderId) async {
        final callBackVm = Provider.of<CallBackViewModel>(
          context,
          listen: false,
        );
        await callBackVm.callBackApi(
          orderID: orderId,
          status: 1,
          context: context,
        );
      },
      (error, orderId) {
        _showMessage(
          "Payment Failed: ${error.getMessage()} (Order ID: $orderId)",
        );
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      startPayment();
    });
  }

  Future<void> startPayment() async {
    try {
      /// STEP 1: Get these from your backend
      /// Replace these with your backend-generated values
      String orderId = widget.data.data!.orderId.toString(); // from backend
      String paymentSessionId = widget.data.data!.paymentSessionId
          .toString(); // from backend

      /// STEP 2: Build session
      var session = CFSessionBuilder()
          .setEnvironment(
            CFEnvironment.SANDBOX,
          ) // Change to PRODUCTION in live mode
          .setOrderId(orderId)
          .setPaymentSessionId(paymentSessionId)
          .build();

      /// STEP 3: Build WebCheckout payment object
      var cfWebCheckout = CFWebCheckoutPaymentBuilder()
          .setSession(session)
          .build();

      /// STEP 4: Start payment
      cfPaymentGatewayService.doPayment(cfWebCheckout);
    } catch (e) {
      _showMessage("Error starting payment: $e");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: const Center(child: CircularProgressIndicator(color: PortColor.gold,)));
  }
}
