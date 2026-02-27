import 'package:flutter/material.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/utils/routes/routes.dart';
import 'package:yoyomiles/view/auth/login_page.dart';
import 'package:yoyomiles/view/auth/otp_page.dart';
import 'package:yoyomiles/view/auth/register_page.dart';
import 'package:yoyomiles/view/bottom_nav_bar.dart';
import 'package:yoyomiles/view/driver_searching/driver_searching_screen.dart';
import 'package:yoyomiles/view/home/rating_feedback_screen.dart';
import 'package:yoyomiles/view/home/widgets/pickup/deliver_by_truck.dart';
import 'package:yoyomiles/view/order/widgets/goods_type_screen.dart';
import 'package:yoyomiles/view/splash_screen.dart';
class Routers {
   static WidgetBuilder generateRoute(String routeName) {
      switch (routeName) {
         case RoutesName.splash:
            return (context) => const SplashScreen();
         case RoutesName.login:
            return (context) => const LoginPage();
        case RoutesName.register:
          return (context) => const RegisterPage();
         case RoutesName.bottomNavBar:
            return (context) => const BottomNavigationPage();
         case RoutesName.goodsType:
            return (context) => const GoodsTypeScreen();
         case RoutesName.ratingFeedback:
            return (context) => const RatingsFeedbackScreen();
         case RoutesName.driverSearching:
            return (context) => const DriverSearchingScreen();
        case RoutesName.deliveryByTruck:
          return (context) => const DeliverByTruck();
        default:
          return (context) => const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 3,
                    color: PortColor.gold,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Loading...",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          );
      }
   }
}