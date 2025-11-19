import 'package:flutter/material.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/res/constant_text.dart';

class CollectPaymentDialog extends StatelessWidget {
  const CollectPaymentDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: PortColor.gold, width: 2),
      ),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 8,
      shadowColor: Colors.black26,

      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green[100]!, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_on, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            TextConst(
              title: "Reached Destination",
              size: 16,
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ],
        ),
      ),

      content: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.payment, color: PortColor.grey, size: 14),
            const SizedBox(width: 6),
            TextConst(
              title: "Make Payment of Trip",
              color: PortColor.blackLight,
              size: 12,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }
}
