import 'package:flutter/material.dart';
import 'package:port_karo/utils/routes/routes.dart';
import 'package:port_karo/view/auth/login_page.dart';
import 'package:port_karo/view/auth/otp_page.dart';
import 'package:port_karo/view/auth/register_page.dart';
import 'package:port_karo/view/bottom_nav_bar.dart';
import 'package:port_karo/view/driver_searching/driver_searching_screen.dart';
import 'package:port_karo/view/home/rating_feedback_screen.dart';
import 'package:port_karo/view/order/widgets/goods_type_screen.dart';
import 'package:port_karo/view/splash_screen.dart';
class Routers {
   static WidgetBuilder generateRoute(String routeName) {
      switch (routeName) {
         case RoutesName.splash:
            return (context) => const SplashScreen();
         case RoutesName.login:
            return (context) => const LoginPage();
         case RoutesName.bottomNavBar:
            return (context) => const BottomNavigationPage();
         case RoutesName.otp:
            return (context) => const OtpPage();
         case RoutesName.register:
            return (context) => const RegisterPage();
         case RoutesName.goodsType:
            return (context) => const GoodsTypeScreen();
         case RoutesName.ratingFeedback:
            return (context) => const RatingsFeedbackScreen();
         case RoutesName.driverSearching:
            return (context) => const DriverSearchingScreen();
         default:
            return (context) => const Scaffold(
               body: Center(
                  child: Text(
                     'No Route Found!',
                     style: TextStyle(
                         fontSize: 18,
                         fontWeight: FontWeight.w600,
                         color: Colors.black),
                  ),
               ),
            );
      }
   }
}