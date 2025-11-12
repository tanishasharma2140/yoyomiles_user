import 'package:flutter/material.dart';
import 'package:port_karo/res/constant_color.dart';
import 'package:port_karo/res/constant_text.dart';

class DriverInfoCard extends StatelessWidget {
  final String name;
  final String phone;
  final String vehicleNumber;
  final String vehicleType;
  final String imageUrl;

  const DriverInfoCard({
    super.key,
    required this.name,
    required this.phone,
    required this.vehicleNumber,
    required this.vehicleType,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PortColor.white,
        borderRadius: BorderRadius.circular(12),
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
          // ✅ Driver Image
          CircleAvatar(
            radius: 24,
            backgroundImage: imageUrl.startsWith('http')
                ? NetworkImage(imageUrl)
                : AssetImage(imageUrl) as ImageProvider,
          ),

          const SizedBox(width: 12),

          // ✅ Driver Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextConst(
                  title: "$vehicleType - $vehicleNumber",
                  fontWeight: FontWeight.bold,
                  size: 15,
                ),

                SizedBox(height: 4),

                Row(
                  children: [
                    TextConst(
                      title: name,
                      color: PortColor.blackLight,
                    ),

                    SizedBox(width: screenWidth * 0.02),

                    TextConst(
                      title: "• $phone",
                      color: PortColor.blackLight,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ✅ Call Button
          Container(
            height: 35,
            width: 35,
            decoration: BoxDecoration(
              color: PortColor.gold.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.call,
                color: PortColor.black,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
