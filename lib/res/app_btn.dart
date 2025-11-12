import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:port_karo/res/app_fonts.dart';
import 'package:port_karo/res/constant_color.dart';
import 'package:port_karo/res/constant_text.dart';

class AppBtn extends StatelessWidget {
  final String title;
  final bool loading;
  final VoidCallback onTap;

  const AppBtn({
    super.key,
    required this.title,
    this.loading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: !loading ? onTap : null,
      child: Container(
        height: screenHeight * 0.06,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFD700), // golden yellow
             PortColor.rapidSplash, // bright yellow
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              spreadRadius: 0.5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: !loading
            ? TextConst(title:
          title,
         color: PortColor.black,
          fontFamily: AppFonts.kanitReg,
          fontWeight: FontWeight.w600,

        )
            : const CupertinoActivityIndicator(
          radius: 16,
          color: Colors.white,
        ),
      ),
    );
  }
}
