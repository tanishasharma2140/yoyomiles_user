import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yoyomiles/main.dart';
import 'package:yoyomiles/res/constant_color.dart';

class ConstLoader extends StatelessWidget {
  const ConstLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return  Container(
      height: screenHeight,
      width: screenWidth,
      color: Colors.black54,
      child: Center(
        child: Container(
            padding: EdgeInsets.all(8),
            height: screenHeight * 0.10,
            width: screenWidth * 0.60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: PortColor.grey,width: 0.7),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                const CupertinoActivityIndicator(radius: 16),
                SizedBox(width: 20),
                Text(
                  "Loading...",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                )
              ],
            )
        ),
      ),
    );
  }
}
