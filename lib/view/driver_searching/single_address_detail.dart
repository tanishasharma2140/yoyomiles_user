import 'package:flutter/material.dart';
import 'package:port_karo/res/app_fonts.dart';
import 'package:port_karo/res/constant_color.dart';

class SingleAddressDetail extends StatelessWidget {
  final String name;
  final String phone;
  final String address;

  const SingleAddressDetail({
    super.key,
    required this.name,
    required this.phone,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                fontFamily: AppFonts.kanitReg,
                color: PortColor.gold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "• $phone",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontFamily: AppFonts.kanitReg,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          address,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
            fontFamily: AppFonts.kanitReg,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
