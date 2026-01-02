import 'package:flutter/material.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/res/constant_text.dart';
import 'package:yoyomiles/view_model/payment_view_model.dart';
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
                 payment.paymentApi(1, amount.toStringAsFixed(2),firebaseOrderId,context);
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
