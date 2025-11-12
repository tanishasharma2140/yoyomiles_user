import 'package:flutter/material.dart';
import 'package:port_karo/main.dart';
import 'package:port_karo/res/constant_color.dart';

class CouponSuccessPopup extends StatefulWidget {
  final Map<String, dynamic> response;
  final String couponCode;
  final VoidCallback onContinue;

  const CouponSuccessPopup({
    super.key,
    required this.response,
    required this.couponCode,
    required this.onContinue,
  });

  @override
  State<CouponSuccessPopup> createState() => _CouponSuccessPopupState();
}

class _CouponSuccessPopupState extends State<CouponSuccessPopup> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _closePopup() {
    Navigator.of(context).pop();
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    final discountAmount = widget.response['data']['discount']?.toString() ?? '0';
    final finalAmount = widget.response['data']['final_amount']?.toString() ?? '0';

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.05),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              Icon(
                Icons.check_circle,
                color: PortColor.gold,
                size: screenWidth * 0.15,
              ),

              SizedBox(height: screenHeight * 0.02),

              // Success Message
              Text(
                'Coupon Applied!',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              // Coupon Code
              Text(
                widget.couponCode.toUpperCase(),
                style: TextStyle(
                  color: PortColor.gold,
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              // Discount Details
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    // Discount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Discount:',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: screenWidth * 0.038,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Text(
                          '₹$discountAmount',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: screenWidth * 0.038,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.015),

                    Divider(height: 1, color: Colors.grey[300]),

                    SizedBox(height: screenHeight * 0.015),

                    // Final Amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Final Amount:',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: screenWidth * 0.038,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Text(
                          '₹$finalAmount',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: screenWidth * 0.038,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _closePopup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PortColor.gold,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'CONTINUE',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}