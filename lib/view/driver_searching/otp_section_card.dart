import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yoyomiles/res/app_fonts.dart';
import 'package:yoyomiles/res/constant_text.dart';

class OtpSectionCard extends StatelessWidget {
  final String otp;

  const OtpSectionCard({
    super.key,
    required this.otp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ✅ Lock Icon + Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),

              TextConst(
                title: "Your Trip OTP",
                color: Colors.blue,
                fontWeight: FontWeight.w600,
                size: 16,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ✅ OTP Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue),
            ),
            child: Text(
              otp,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
                fontFamily: AppFonts.kanitReg,
                letterSpacing: 4,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ✅ Instruction Text
          Text(
            "Share this OTP with driver at pickup time",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.blue[700],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
