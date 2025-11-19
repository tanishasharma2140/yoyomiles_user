import 'package:flutter/material.dart';
import 'package:yoyomiles/res/constant_color.dart';

class CoinSplashScreen extends StatefulWidget {
  @override
  _CoinSplashScreenState createState() => _CoinSplashScreenState();
}

class _CoinSplashScreenState extends State<CoinSplashScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: PortColor.white,
      body: Center(
        child: Image(image: AssetImage("assets/coinrewardremov.png"),
         )


        ),
      );

  }
}
