import 'package:app_links/app_links.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yoyomiles/controller/language_controller.dart';
import 'package:yoyomiles/firebase_options.dart';
import 'package:yoyomiles/l10n/app_localizations.dart';
import 'package:yoyomiles/res/app_constant.dart';
import 'package:yoyomiles/res/notification_service.dart';
import 'package:yoyomiles/services/internet_checker_service.dart';
import 'package:yoyomiles/utils/routes/routes.dart';
import 'package:yoyomiles/utils/routes/routes_name.dart';
import 'package:yoyomiles/view_model/active_ride_view_model.dart';
import 'package:yoyomiles/view_model/add_address_view_model.dart';
import 'package:yoyomiles/view_model/add_money_callback_view_model.dart';
import 'package:yoyomiles/view_model/add_wallet_view_model.dart';
import 'package:yoyomiles/view_model/address_delete_view_model.dart';
import 'package:yoyomiles/view_model/address_show_view_model.dart';
import 'package:yoyomiles/view_model/apply_coupon_view_model.dart';
import 'package:yoyomiles/view_model/call_back_view_model.dart';
import 'package:yoyomiles/view_model/claim_reward_view_model.dart';
import 'package:yoyomiles/view_model/contact_list_view_model.dart';
import 'package:yoyomiles/view_model/coupon_list_view_model.dart';
import 'package:yoyomiles/view_model/daily_slot_view_model.dart';
import 'package:yoyomiles/view_model/driver_rating_view_model.dart';
import 'package:yoyomiles/view_model/driver_ride_view_model.dart';
import 'package:yoyomiles/view_model/final_summary_view_model.dart';
import 'package:yoyomiles/view_model/goods_type_view_model.dart';
import 'package:yoyomiles/view_model/gst_percentage_view_model.dart';
import 'package:yoyomiles/view_model/help_and_support_view_model.dart';
import 'package:yoyomiles/view_model/login_view_model.dart';
import 'package:yoyomiles/view_model/moving_detail_view_model.dart';
import 'package:yoyomiles/view_model/on_boarding_view_model.dart';
import 'package:yoyomiles/view_model/order_view_model.dart';
import 'package:yoyomiles/view_model/otp_count_view_model.dart';
import 'package:yoyomiles/view_model/packer_mover_call_back_viewmodel.dart';
import 'package:yoyomiles/view_model/packer_mover_order_history_view_model.dart';
import 'package:yoyomiles/view_model/packer_mover_terms_view_model.dart';
import 'package:yoyomiles/view_model/packer_mover_view_model.dart';
import 'package:yoyomiles/view_model/payment_view_model.dart';
import 'package:yoyomiles/view_model/policy_view_model.dart';
import 'package:yoyomiles/view_model/port_banner_view_model.dart';
import 'package:yoyomiles/view_model/proceed_order_view_model.dart';
import 'package:yoyomiles/view_model/profile_update_view_model.dart';
import 'package:yoyomiles/view_model/profile_view_model.dart';
import 'package:yoyomiles/view_model/reason_cancel_ride_view_model.dart';
import 'package:yoyomiles/view_model/register_view_model.dart';
import 'package:yoyomiles/view_model/requirement_view_model.dart';
import 'package:yoyomiles/view_model/reward_view_model.dart';
import 'package:yoyomiles/view_model/save_selected_item_view_model.dart';
import 'package:yoyomiles/view_model/select_vehicles_view_model.dart';
import 'package:yoyomiles/view_model/service_type_view_model.dart';
import 'package:yoyomiles/view_model/update_ride_status_view_model.dart';
import 'package:yoyomiles/view_model/user_history_view_model.dart';
import 'package:yoyomiles/view_model/user_transaction_view_model.dart';
import 'package:yoyomiles/view_model/vehicle_loading_view_model.dart';
import 'package:yoyomiles/view_model/wallet_history_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:async';



final FacebookAppEvents facebookAppEvents = FacebookAppEvents();
String? fcmToken;
String? globalReferralCode;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
Map<String, dynamic>? pendingDeepLinkData;



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences sp = await SharedPreferences.getInstance();
  final String languageCode = sp.getString('language_code') ?? '';

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  facebookAppEvents.setAdvertiserTracking(enabled: true);
  // return;
  runApp( MyApp(
    locale: languageCode,
  ));
}



double screenHeight = 0.0;
double screenWidth = 0.0;
double topPadding = 0.0;
double bottomPadding = 0.0;

class MyApp extends StatefulWidget {
  final String locale;
  const MyApp({super.key, required this.locale});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final notificationService = NotificationService(navigatorKey: navigatorKey);
  final InternetCheckerService _internetCheckerService =
  InternetCheckerService();

  void checkPendingNavigation(context) {
    if (pendingDeepLinkData != null) {

      WidgetsBinding.instance.addPostFrameCallback((_) {

        navigatorKey.currentState?.pushNamed(
          RoutesName.deliveryByTruck,
          arguments: pendingDeepLinkData,
        );

        pendingDeepLinkData = null;

      });
    }
  }

  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();

    notificationService.requestedNotificationPermission();
    initFCM();
    notificationService.firebaseInit(context);
    notificationService.setupInteractMassage(context);

    initDeepLinks(); // 🔥 Deep link init

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _internetCheckerService
          .startMonitoring(navigatorKey.currentContext!);
    });
  }

  void initFCM() async {
    NotificationSettings settings =
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus ==
        AuthorizationStatus.authorized) {
      String? token = await FirebaseMessaging.instance.getToken();
      if (kDebugMode) print("FCM TOKEN = $token");
    }
  }

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  // ===============================
  // 🔥 DEEP LINK LOGIC START
  // ===============================

  Future<void> initDeepLinks() async {
    try {
      final Uri? initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        // Cold start pe thoda zyada wait karo
        await Future.delayed(const Duration(milliseconds: 300));
        handleUri(initialUri);
      }
    } catch (e) {
      print("Initial link error: $e");
    }

    _linkSubscription = _appLinks.uriLinkStream.listen((Uri uri) {
      handleUri(uri);
    }, onError: (err) {
      print("Stream link error: $err");
    });
  }

  void handleUri(Uri uri) async {
    print("Received URI: $uri");

    double? lat;
    double? lng;

    if (uri.scheme == "geo") {
      final coords = uri.path.split(",");
      if (coords.length >= 2) {
        lat = double.tryParse(coords[0]);
        lng = double.tryParse(coords[1]);
      }
    }

    if (uri.queryParameters.containsKey("q")) {
      final q = uri.queryParameters["q"];
      if (q != null && q.contains(",")) {
        final parts = q.split(",");
        lat = double.tryParse(parts[0]);
        lng = double.tryParse(parts[1]);
      }
    }

    if (lat != null && lng != null) {
      pendingDeepLinkData = {
        "latitude": lat,
        "longitude": lng,
      };
    }
  }



  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  // ===============================
  // 🔥 DEEP LINK LOGIC END
  // ===============================

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    topPadding = MediaQuery.of(context).padding.top;
    bottomPadding = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarDividerColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context)=> RegisterViewModel()),
          ChangeNotifierProvider(create: (context)=> ProfileViewModel()),
          ChangeNotifierProvider(create: (context)=> AuthViewModel()),
          ChangeNotifierProvider(create: (context)=> ProfileUpdateViewModel()),
          ChangeNotifierProvider(create: (context)=> OrderViewModel()),
          ChangeNotifierProvider(create: (context)=> SelectVehiclesViewModel()),
          ChangeNotifierProvider(create: (context)=> ServiceTypeViewModel()),
          ChangeNotifierProvider(create: (context)=> AddAddressViewModel()),
          ChangeNotifierProvider(create: (context)=> AddressShowViewModel()),
          ChangeNotifierProvider(create: (context)=> AddressDeleteViewModel()),
          ChangeNotifierProvider(create: (context)=> HelpAndSupportViewModel()),
          ChangeNotifierProvider(create: (context)=> UserHistoryViewModel()),
          ChangeNotifierProvider(create: (context)=> AddWalletViewModel()),
          ChangeNotifierProvider(create: (context)=> WalletHistoryViewModel()),
          ChangeNotifierProvider(create: (context)=> PortBannerViewModel()),
          ChangeNotifierProvider(create: (context)=> OnBoardingViewModel()),
          ChangeNotifierProvider(create: (context)=> GoodsTypeViewModel()),
          ChangeNotifierProvider(create: (context)=> PackerMoverViewModel()),
          ChangeNotifierProvider(create: (context)=> CouponListViewModel()),
          ChangeNotifierProvider(create: (context)=> PolicyViewModel()),
          ChangeNotifierProvider(create: (context)=> ApplyCouponViewModel()),
          ChangeNotifierProvider(create: (context)=> RequirementViewModel()),
          ChangeNotifierProvider(create: (context)=> ActiveRideViewModel()),
          ChangeNotifierProvider(create: (context)=> UpdateRideStatusViewModel()),
          ChangeNotifierProvider(create: (context)=> PaymentViewModel()),
          ChangeNotifierProvider(create: (context)=> CallBackViewModel()),
          ChangeNotifierProvider(create: (context)=> DriverRatingViewModel()),
          ChangeNotifierProvider(create: (context)=> SaveSelectedItemViewModel()),
          ChangeNotifierProvider(create: (context)=> ReasonCancelRideViewModel()),
          ChangeNotifierProvider(create: (context)=> FinalSummaryViewModel()),
          ChangeNotifierProvider(create: (context)=> DailySlotViewModel()),
          ChangeNotifierProvider(create: (context)=> MovingDetailsViewModel()),
          ChangeNotifierProvider(create: (context)=> ProceedOrderViewModel()),
          ChangeNotifierProvider(create: (context)=> PackerMoverCallBackViewmodel()),
          // ChangeNotifierProvider(create: (context)=> PackerMoverPaymentViewModel()),
          ChangeNotifierProvider(create: (context)=> PackerMoverOrderHistoryViewModel()),
          ChangeNotifierProvider(create: (context)=> PackerMoverTermsViewModel()),
          ChangeNotifierProvider(create: (context)=> ContactListViewModel()),
          // ChangeNotifierProvider(create: (context)=> AddMoneyPaymentViewModel()),
          ChangeNotifierProvider(create: (context)=> AddMoneyCallbackViewModel()),
          ChangeNotifierProvider(create: (context)=> UserTransactionViewModel()),
          ChangeNotifierProvider(create: (context)=> OtpCountViewModel()),
          // ChangeNotifierProvider(create: (context)=> ChangePayModeViewModel()),
          ChangeNotifierProvider(create: (context)=> VehicleLoadingViewModel()),
          ChangeNotifierProvider(create: (context)=> RewardViewModel()),
          ChangeNotifierProvider(create: (context)=> ClaimRewardViewModel()),
          ChangeNotifierProvider(create: (context)=> DriverRideViewModel()),
          ChangeNotifierProvider(create: (context)=> GstPercentageViewModel()),
          ChangeNotifierProvider(create: (context)=> LanguageController()),

        ],
        child: Consumer<LanguageController>(
          builder: (context, provider, child) {
            return MaterialApp(
              navigatorKey: navigatorKey,
              debugShowCheckedModeBanner: false,
              initialRoute: RoutesName.splash,
              onGenerateRoute: (settings) {
                if (settings.name != null) {
                  return MaterialPageRoute(
                    builder: Routers.generateRoute(settings.name!),
                    settings: settings,
                  );
                }
                return null;
              },

              builder: (context, child) {
                checkPendingNavigation(context);
                return child!;
              },
              title: AppConstant.appName,
              locale: provider.appLocale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate
              ],
              supportedLocales: const [
                Locale('en'),
                Locale('hi'),
              ],
              theme: ThemeData(
                colorScheme:
                ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                useMaterial3: true,
              ),

            );
          },
        ),
      ),
    );
  }
}