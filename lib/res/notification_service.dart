import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:port_karo/view/driver_searching/driver_searching_screen.dart';
import 'package:port_karo/view/home/home.dart';

class NotificationService {
  final GlobalKey<NavigatorState> navigatorKey;
  NotificationService({required this.navigatorKey});

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // request notification permission
  Future<void> requestedNotificationPermission() async {
    await Permission.notification.request();
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('user granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('user provisional granted permission');
    } else {
      debugPrint(
        "notification permission denied\n please allow notification to recieve call's",
      );
      Future.delayed(Duration(seconds: 2), () {
        AppSettings.openAppSettings(type: AppSettingsType.notification);
      });
    }
  }

  Future<void> subscribeToNoticeTopic() async {
    await messaging.subscribeToTopic("notice");
    debugPrint("✅ Subscribed to NOTICE topic");
  }

  Future<void> unsubscribeFromNoticeTopic() async {
    await messaging.unsubscribeFromTopic("notice");
    debugPrint("❌ Unsubscribed from NOTICE topic");
  }


  // get fcm(device) token
  Future<String> getDeviceToken() async {
    // NotificationSettings settings =
    await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    String? token = await messaging.getToken();
    debugPrint("token:$token");
    return token!;
  }

  void initLocalNotification(
      BuildContext context,
      RemoteMessage massage,
      ) async {
    var androidInitSetting = AndroidInitializationSettings(
      "@mipmap/ic_launcher",
    );
    var iosInitSetting = DarwinInitializationSettings();

    var initializationSettings = InitializationSettings(
      android: androidInitSetting,
      iOS: iosInitSetting,
    );
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (payload) {
        handleMassage(massage);
      },
    );
  }

  // firebase init
  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((massage) {
      RemoteNotification? notification = massage.notification;
      AndroidNotification? android = massage.notification!.android;
      if (kDebugMode) {
        print("Notification title:${notification!.title}");
        print("Notification body:${notification.body}");
      }
      if (Platform.isAndroid) {
        initLocalNotification(context, massage);
        // handleMassage(context, massage);
        showNotification(massage);
      }
    });
  }

  // function to show notification
  Future<void> showNotification(RemoteMessage massage) async {
    // final player = FlutterRingtonePlayer();
    // player.playRingtone();
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      massage.notification!.android!.channelId.toString(),
      massage.notification!.android!.channelId.toString(),
      importance: Importance.high,
      showBadge: true,
      playSound: true,
    );
    // android setting
    AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      channel.id.toString(),
      channel.name.toString(),
      channelDescription: "Channel Description",
      importance: Importance.high,
      priority: Priority.high,
      fullScreenIntent: true,
      timeoutAfter: 60000,
      visibility: NotificationVisibility.public,
      playSound: true,
      sound: channel.sound,
    );
    // ios setting
    DarwinNotificationDetails darwinNotificationDetails =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    // marge-setting
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );
    //show notification
    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
        0,
        massage.notification!.title.toString(),
        massage.notification!.body.toString(),
        notificationDetails,
        payload: "send data",
      );
    });
  }

  // background and terminated
  Future<void> setupInteractMassage(BuildContext context) async {
    // background state
    FirebaseMessaging.onMessageOpenedApp.listen((massage) {
      handleMassage(massage);
    });
    // terminated state
    FirebaseMessaging.instance.getInitialMessage().then((
        RemoteMessage? massage,
        ) {
      if (massage != null && massage.data.isNotEmpty) {
        handleMassage(massage);
      }
    });
  }

  Future<void> handleMassage(RemoteMessage massage) async {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => DriverSearchingScreen(),
      ),
    );
  }
}

  // Future<void> handleMassage(RemoteMessage message) async {
  //   debugPrint("📩 Raw Notification data: ${message.data}");
  //
  //   // role check (admin ya employee)
  //   String? role = message.data['role'];
  //   if (role == null || role.isEmpty) {
  //     final userViewModel = UserViewModel();
  //     final savedRole = await userViewModel.getRole();
  //     if (savedRole == 1) {
  //       role = "admin";
  //     } else if (savedRole == 2) {
  //       role = "employee";
  //     }
  //   }
  //
  //   debugPrint("📩 Effective role: $role");
  //
  //   String? type = message.data['type'];
  //   debugPrint("📌 Notification type:$type");
  //
  //   if (navigatorKey.currentState == null) return;
  //   if (role == "admin") {
  //     if (type == "leave_request") {
  //       navigatorKey.currentState?.push(
  //         MaterialPageRoute(builder: (context) => EmpLeaveRequest()),
  //       );
  //     } else if (type == "notice") {
  //       navigatorKey.currentState?.push(
  //         MaterialPageRoute(builder: (context) => AddNoticeHistory()),
  //       );
  //     } else if (type == "break_request") {
  //       navigatorKey.currentState?.push(
  //         MaterialPageRoute(builder: (context) => BreakNotification()),
  //       );
  //     } else if (type == "asset_request") {
  //       navigatorKey.currentState?.push(
  //         MaterialPageRoute(builder: (context) => AssetsAssignApprovePage()),
  //       );
  //     } else {
  //       navigatorKey.currentState?.pushReplacement(
  //         MaterialPageRoute(builder: (context) => AdminDashboard()),
  //       );
  //     }
  //   } else if (role == "employee") {
  //     if (type == "leave_status") {
  //       navigatorKey.currentState?.push(
  //         MaterialPageRoute(builder: (context) => MyLeaveApp()),
  //       );
  //     } else if (type == "notice") {
  //       navigatorKey.currentState?.push(
  //         MaterialPageRoute(builder: (context) => EmpNoticeBoard()),
  //       );
  //     } else if (type == "break_status") {
  //       navigatorKey.currentState?.push(
  //         MaterialPageRoute(builder: (context) => BreakHistory()),
  //       );
  //     } else if (type == "project_assign") {
  //       navigatorKey.currentState?.push(
  //         MaterialPageRoute(builder: (context) => ProjectStatusPage()),
  //       );
  //     }else if (type == "asset_request_action") {
  //       navigatorKey.currentState?.push(
  //         MaterialPageRoute(builder: (context) => AssetsAssignFormPage()),
  //       );
  //     }
  //     else {
  //       navigatorKey.currentState?.pushReplacement(
  //         MaterialPageRoute(builder: (context) => EmployeeDashboard()),
  //       );
  //     }
  //   }
  //
  // }



