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
import 'package:yoyomiles/view/sharing_live_ride.dart';
import 'package:yoyomiles/view/splash_screen.dart';
class Routers {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {

      case RoutesName.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );

      case RoutesName.login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );

      case RoutesName.register:
        return MaterialPageRoute(
          builder: (_) => const RegisterPage(),
        );

      case RoutesName.bottomNavBar:
        return MaterialPageRoute(
          builder: (_) => const BottomNavigationPage(),
        );

      case RoutesName.goodsType:
        return MaterialPageRoute(
          builder: (_) => const GoodsTypeScreen(),
        );

      case RoutesName.ratingFeedback:
        return MaterialPageRoute(
          builder: (_) => const RatingsFeedbackScreen(),
        );

      case RoutesName.driverSearching:
        return MaterialPageRoute(
          builder: (_) => const DriverSearchingScreen(),
        );

      case RoutesName.deliveryByTruck:
        return MaterialPageRoute(
          builder: (_) => const DeliverByTruck(),
        );

      case RoutesName.shareLiveRide:
        final args = settings.arguments as Map;
        return MaterialPageRoute(
          builder: (_) => ShareLiveRide(
            trackingToken: args['token'],
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: Text("Loading...")),
          ),
        );
    }
  }
}