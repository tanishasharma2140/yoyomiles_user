import 'package:flutter/material.dart';
import 'package:port_karo/res/constant_color.dart';
import 'package:port_karo/res/services.dart';
import '../generated/assets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  Services services = Services();

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Scale (zoom in)
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    // Slide (from bottom to center)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    // After 3 seconds → go to next screen
    Future.delayed(const Duration(seconds: 2), () {
      services.checkAuthentication(context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          decoration:  BoxDecoration(
      color: PortColor.rapidSplash,
          ),
          child: Center(
            child: SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.25, // bigger height
                  width: MediaQuery.of(context).size.width * 0.65,   // bigger width
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(Assets.assetsYoyoMilesRemoveBg),
                      fit: BoxFit.contain, // maintain aspect ratio
                    ),
                  ),
                ),

              ),
            ),
          ),
        ),
      ),
    );
  }
}
