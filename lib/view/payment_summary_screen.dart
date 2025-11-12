import 'package:flutter/material.dart';
import 'package:port_karo/res/constant_color.dart';
import 'package:port_karo/res/constant_text.dart';
import 'package:port_karo/view_model/payment_view_model.dart';
import 'package:provider/provider.dart';

class PaymentSummaryScreen extends StatelessWidget {
  final double amount;
  final double distance;
  final String firebaseOrderId;

  const PaymentSummaryScreen({
    super.key,
    required this.amount,
    required this.distance, required this.firebaseOrderId,
  });

  @override
  Widget build(BuildContext context) {
    final payment = Provider.of<PaymentViewModel>(context);
    return Scaffold(
      backgroundColor: PortColor.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Payment Summary",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(Icons.verified, color: Colors.green, size: 80),
            ),
            const SizedBox(height: 20),
            Center(
              child: TextConst(
                title: "Ride Completed!",
                size: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const TextConst(
                        title: "Distance Travelled",
                        color: Colors.grey,
                        size: 16,
                      ),
                      TextConst(
                        title: "${distance.toStringAsFixed(2)} km",
                        fontWeight: FontWeight.w600,
                        size: 16,
                        color: PortColor.gold,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const TextConst(
                        title: "Amount",
                        color: Colors.grey,
                        size: 16,
                      ),
                      TextConst(
                        title: "₹ ${amount.toStringAsFixed(2)}",
                        fontWeight: FontWeight.bold,
                        size: 18,
                        color: PortColor.gold,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: PortColor.gold,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                 payment.paymentApi(context, amount.toStringAsFixed(2),firebaseOrderId);
                },
                child: const Text(
                  "Payment",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
//
// import 'package:flutter/material.dart';
// import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
// import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
// import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
// import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
// import 'package:provider/provider.dart';
// import 'package:share_ride/model/cashfree_gateway_model.dart';
// import 'package:share_ride/view_model/ride_payment_view_model.dart';
//
// class CashfreePaymentScreen extends StatefulWidget {
//   final CashFreeGatewayModel? data;
//   final String rideId;
//   final String driverId;
//   final String amount;
//
//   ///0-ride payment 1-admin online pay
//   const CashfreePaymentScreen({
//     super.key,
//     required this.data,
//     required this.rideId,
//     required this.driverId,
//     required this.amount,
//   });
//
//   @override
//   State<CashfreePaymentScreen> createState() => _CashfreePaymentScreenState();
// }
//
// class _CashfreePaymentScreenState extends State<CashfreePaymentScreen> {
//   final CFPaymentGatewayService cfPaymentGatewayService =
//   CFPaymentGatewayService();
//
//   @override
//   void initState() {
//     super.initState();
//     // Setup callbacks
//     cfPaymentGatewayService.setCallback(
//           (orderId) async {
//         _showMessage("Payment Success for Order ID: $orderId");
//         final paymentProvider = Provider.of<RidePaymentViewModel>(
//           context,
//           listen: false,
//         );
//         await paymentProvider.ridePaymentUserApi(
//           context,
//           int.parse(widget.rideId),
//           int.parse(widget.driverId),
//           double.parse(widget.amount).toInt(),
//           1,
//           1,
//           orderId.toString(),
//         );
//       },
//           (error, orderId) {
//         _showMessage(
//           "Payment Failed: ${error.getMessage()} (Order ID: $orderId)",
//         );
//       },
//     );
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       startPayment();
//     });
//   }
//
//   Future<void> startPayment() async {
//     try {
//       /// STEP 1: Get these from your backend
//       /// Replace these with your backend-generated values
//       String orderId = widget.data!.data!.orderId.toString(); // from backend
//       String paymentSessionId = widget.data!.data!.paymentSessionId
//           .toString(); // from backend
//
//       /// STEP 2: Build session
//       var session = CFSessionBuilder()
//           .setEnvironment(
//         CFEnvironment.SANDBOX,
//       ) // Change to PRODUCTION in live mode
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
//     return Scaffold(body: const Center(child: CircularProgressIndicator()));
//   }
// }