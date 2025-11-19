import 'package:flutter/material.dart';
import 'package:yoyomiles/main.dart';
import 'package:yoyomiles/res/app_fonts.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/res/constant_text.dart';
import 'package:yoyomiles/utils/routes/routes.dart';

class RatingsFeedbackScreen extends StatefulWidget {
  const RatingsFeedbackScreen({super.key});

  @override
  State<RatingsFeedbackScreen> createState() => _RatingsFeedbackScreenState();
}

class _RatingsFeedbackScreenState extends State<RatingsFeedbackScreen> {
  int _selectedRating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  bool _sameVehicleSelected = false;
  bool _goodBehaviorSelected = false;


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: PortColor.bg,
        body: Column(
          children: [
            SizedBox(height: topPadding),

            // Header
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.02,
              ),
              decoration: BoxDecoration(
                color: PortColor.white,
                border: Border(
                  bottom: BorderSide(
                    color: PortColor.gray,
                    width: screenWidth * 0.002,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: PortColor.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back,
                      color: PortColor.black,
                      size: screenHeight * 0.02,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  TextConst(
                    title: "Rate Your Experience",
                    color: PortColor.black,
                    fontFamily: AppFonts.kanitReg,
                    fontWeight: FontWeight.w600,
                    size: 16,
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ride Completion Info
                    _buildRideCompletionInfo(),

                    SizedBox(height: screenHeight * 0.04),

                    // Rating Section
                    _buildRatingSection(),

                    SizedBox(height: screenHeight * 0.04),

                    // Feedback Section
                    _buildFeedbackSection(),

                    SizedBox(height: screenHeight * 0.04),

                    // Survey Section
                    _buildSurveySection(),

                    SizedBox(height: screenHeight * 0.05),
                  ],
                ),
              ),
            ),

            // Submit Button
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.02,
              ),
              decoration: BoxDecoration(
                color: PortColor.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: (){
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
                  decoration: BoxDecoration(
                    color: PortColor.button,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: TextConst(
                      title: "Submit Feedback",
                      fontFamily: AppFonts.kanitReg,
                      color: PortColor.black,
                      fontWeight: FontWeight.w600,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideCompletionInfo() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.03,
      ),
      decoration: BoxDecoration(
        color: PortColor.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: screenHeight * 0.05,
          ),
          SizedBox(height: screenHeight * 0.02),
          TextConst(
            title: "Ride Completed Successfully!",
            fontFamily: AppFonts.kanitReg,
            fontWeight: FontWeight.w600,
            size: 18,
            color: PortColor.black,
          ),
          SizedBox(height: screenHeight * 0.01),
          TextConst(
            title: "Thank you for choosing Port Karo",
            fontFamily: AppFonts.kanitReg,
            color: Colors.grey.shade600,
            size: 14,
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.03,
      ),
      decoration: BoxDecoration(
        color: PortColor.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextConst(
            title: "Rate Your Captain",
            fontFamily: AppFonts.kanitReg,
            fontWeight: FontWeight.w600,
            size: 16,
            color: PortColor.black,
          ),
          SizedBox(height: screenHeight * 0.01),
          TextConst(
            title: "How was your experience with Captain Rajesh?",
            fontFamily: AppFonts.kanitReg,
            color: Colors.grey.shade600,
            size: 14,
          ),
          SizedBox(height: screenHeight * 0.03),

          // Star Ratings
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRating = index + 1;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                    child: Icon(
                      index < _selectedRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: screenHeight * 0.04,
                    ),
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),

          // Rating Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextConst(
                title: "Poor",
                fontFamily: AppFonts.kanitReg,
                color: Colors.grey.shade600,
                size: 12,
              ),
              TextConst(
                title: "Excellent",
                fontFamily: AppFonts.kanitReg,
                color: Colors.grey.shade600,
                size: 12,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.03,
      ),
      decoration: BoxDecoration(
        color: PortColor.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextConst(
            title: "Share Your Feedback",
            fontFamily: AppFonts.kanitReg,
            fontWeight: FontWeight.w600,
            size: 16,
            color: PortColor.black,
          ),
          SizedBox(height: screenHeight * 0.01),
          TextConst(
            title: "Help us improve our service",
            fontFamily: AppFonts.kanitReg,
            color: Colors.grey.shade600,
            size: 14,
          ),
          SizedBox(height: screenHeight * 0.02),

          // Feedback Text Field
          Container(
            decoration: BoxDecoration(
              color: PortColor.bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: PortColor.gray.withOpacity(0.3),
              ),
            ),
            child: TextField(
              controller: _feedbackController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Tell us about your experience...\nWhat did you like?\nAny suggestions for improvement?",
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontFamily: AppFonts.kanitReg,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(screenWidth * 0.04),
              ),
              style: TextStyle(
                fontFamily: AppFonts.kanitReg,
                fontSize: 14,
                color: PortColor.black,
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          TextConst(
            title: "Your feedback helps us serve you better",
            fontFamily: AppFonts.kanitReg,
            color: Colors.grey.shade500,
            size: 12,
          ),
        ],
      ),
    );
  }

  Widget _buildSurveySection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.03,
      ),
      decoration: BoxDecoration(
        color: PortColor.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextConst(
            title: "Quick Survey",
            fontFamily: AppFonts.kanitReg,
            fontWeight: FontWeight.w600,
            size: 16,
            color: PortColor.black,
          ),
          SizedBox(height: screenHeight * 0.01),
          TextConst(
            title: "Help us understand your preferences",
            fontFamily: AppFonts.kanitReg,
            color: Colors.grey.shade600,
            size: 14,
          ),
          SizedBox(height: screenHeight * 0.03),

          // Same Vehicle Question
          _buildSurveyQuestion(
            "Would you prefer the same vehicle for future rides?",
            _sameVehicleSelected,
                (value) {
              setState(() {
                _sameVehicleSelected = value!;
              });
            },
          ),

          SizedBox(height: screenHeight * 0.02),

          // Behavior Question
          _buildSurveyQuestion(
            "Was the captain's behavior professional?",
            _goodBehaviorSelected,
                (value) {
              setState(() {
                _goodBehaviorSelected = value!;
              });
            },
          ),

          SizedBox(height: screenHeight * 0.02),

          // Additional Info
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.03,
              vertical: screenHeight * 0.015,
            ),
            decoration: BoxDecoration(
              color: PortColor.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: PortColor.blue,
                  size: screenHeight * 0.018,
                ),
                SizedBox(width: screenWidth * 0.02),
                Expanded(
                  child: TextConst(
                    title: "Your responses help us match you with better captains",
                    fontFamily: AppFonts.kanitReg,
                    color: PortColor.blue,
                    size: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurveyQuestion(String question, bool isSelected, ValueChanged<bool?> onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.03,
        vertical: screenHeight * 0.02,
      ),
      decoration: BoxDecoration(
        color: PortColor.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: PortColor.gray.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextConst(
              title: question,
              fontFamily: AppFonts.kanitReg,
              color: PortColor.black,
              size: 14,
            ),
          ),
          SizedBox(width: screenWidth * 0.02),
          Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: isSelected,
              onChanged: onChanged,
              activeColor: PortColor.button,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}