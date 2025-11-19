import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:yoyomiles/main.dart';
import 'package:yoyomiles/res/app_fonts.dart';
import 'package:yoyomiles/res/constant_color.dart';

class CityToggle extends StatefulWidget {
  final String pickupLocation;
  final String dropLocation;
  final Function(bool)? onSelectionChanged;
  final bool? initialSelection;

  const CityToggle({
    super.key,
    required this.pickupLocation,
    required this.dropLocation,
    this.onSelectionChanged,
    this.initialSelection,
  });

  @override
  _CityToggleState createState() => _CityToggleState();
}

class _CityToggleState extends State<CityToggle> {
  // 🔹 WITHIN CITY SELECTED BY DEFAULT
  bool isWithinCitySelected = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Set default value from parent or use true as default
    isWithinCitySelected = widget.initialSelection ?? true;
  }

  @override
  void didUpdateWidget(covariant CityToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSelection != oldWidget.initialSelection) {
      setState(() {
        isWithinCitySelected = widget.initialSelection ?? true;
      });
    }
  }

  void _handleCityTypeSelection(bool isWithinCity) {
    setState(() {
      isWithinCitySelected = isWithinCity;
    });
    widget.onSelectionChanged?.call(isWithinCity);

    // Show selection confirmation
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: PortColor.grey,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              // 🟦 Within City - SELECTED BY DEFAULT
              Expanded(
                child: GestureDetector(
                  onTap: () => _handleCityTypeSelection(true),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                    decoration: BoxDecoration(
                      color: isWithinCitySelected
                          ? PortColor.button
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        "Within City",
                        style: TextStyle(
                          color: isWithinCitySelected ? Colors.black : Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFonts.kanitReg,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: GestureDetector(
                  onTap: () => _handleCityTypeSelection(false),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                    decoration: BoxDecoration(
                      color: !isWithinCitySelected
                          ? PortColor.button
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        "Between Cities",
                        style: TextStyle(
                          color: !isWithinCitySelected ? Colors.black : Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFonts.kanitReg,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

      ],
    );
  }
}