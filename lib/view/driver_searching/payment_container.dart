import 'package:flutter/material.dart';
import 'package:port_karo/res/app_fonts.dart';
import 'package:port_karo/res/constant_color.dart';
import 'package:port_karo/res/constant_text.dart';

class PaymentContainer extends StatelessWidget {
  final int payMode;
  final dynamic amount;     // int ya string dono ho sakta hai
  final String iconAsset;   // image asset path
  final String Function(int) getPaymentMethodText;

  const PaymentContainer({
    super.key,
    required this.payMode,
    required this.amount,
    required this.iconAsset,
    required this.getPaymentMethodText,
  });

  @override
  Widget build(BuildContext context) {
    final paymentMethod = getPaymentMethodText(payMode);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PortColor.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PortColor.grey),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(iconAsset, height: 50, width: 50),
          const SizedBox(width: 12),

          // Payment text details
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextConst(
                title: paymentMethod,
                size: 16,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: 4),
              Text(
                "Payment method",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontFamily: AppFonts.kanitReg,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Total Amount
          Text(
            "₹ $amount",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: PortColor.gold,
              fontFamily: AppFonts.kanitReg,
            ),
          ),
        ],
      ),
    );
  }
}
