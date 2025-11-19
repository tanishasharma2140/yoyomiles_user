import 'package:flutter/material.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/view/driver_searching/dotted_line_painter.dart';
import 'package:yoyomiles/view/driver_searching/single_address_detail.dart';

class AddressCard extends StatelessWidget {
  final String senderName;
  final String senderPhone;
  final String senderAddress;

  final String receiverName;
  final String receiverPhone;
  final String receiverAddress;

  const AddressCard({
    super.key,
    required this.senderName,
    required this.senderPhone,
    required this.senderAddress,
    required this.receiverName,
    required this.receiverPhone,
    required this.receiverAddress,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PortColor.white,
        border: Border.all(color: PortColor.grey),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Circles + Dotted Line
              Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                    child: const Icon(Icons.arrow_upward,
                        color: Colors.white, size: 14),
                  ),
                  Container(
                    width: 2,
                    height: 50,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: CustomPaint(painter: DottedLinePainter()),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    child: const Icon(Icons.arrow_downward,
                        color: Colors.white, size: 14),
                  ),
                ],
              ),

              const SizedBox(width: 16),

              // ✅ Address Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleAddressDetail(
                      name: senderName,
                      phone: senderPhone,
                      address: senderAddress,
                    ),
                    const SizedBox(height: 12),
                    SingleAddressDetail(
                      name: receiverName,
                      phone: receiverPhone,
                      address: receiverAddress,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.02),
        ],
      ),
    );
  }
}
