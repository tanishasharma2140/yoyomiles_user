import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:port_karo/res/app_fonts.dart';
import 'package:port_karo/res/constant_color.dart';
import 'package:port_karo/res/constant_text.dart';

class InternetCheckerService {
  static final InternetCheckerService _instance =
      InternetCheckerService._internal();
  factory InternetCheckerService() => _instance;
  InternetCheckerService._internal();

  bool _isPageVisible = false;
  BuildContext? _pageContext;

  void startMonitoring(BuildContext context) {
    Connectivity().onConnectivityChanged.listen((result) async {
      final hasInternet = await _checkInternetStatus();

      if (!hasInternet) {
        _showFullScreenPage(
          context,
          "You've lost connection",
          "Please check your mobile data or Wifi and make sure you are connected to the internet",
        );
      } else {
        if (_isPageVisible && _pageContext != null) {
          Navigator.of(_pageContext!, rootNavigator: true).pop();
          _isPageVisible = false;
          _pageContext = null;
        }
      }
    });
  }

  Future<bool> _checkInternetStatus() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }

  void _showFullScreenPage(BuildContext context, String title, String message) {
    if (_isPageVisible) return;

    _isPageVisible = true;

    Navigator.of(context, rootNavigator: true)
        .push(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (_, __, ___) => WillPopScope(
              onWillPop: () async => false,
              child: Scaffold(
                backgroundColor: Colors.white,
                body: SafeArea(
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset("assets/lostnetwork.gif",height: 200,width: 200,),
                        const SizedBox(height: 24),
                        TextConst(
                          title: title,
                          fontFamily: AppFonts.kanitReg,
                          fontWeight: FontWeight.w600,
                          color: PortColor.black,
                          size: 18,
                        ),
                        const SizedBox(height: 16),
                        TextConst(
                          title: message,
                          textAlign: TextAlign.center,
                          fontFamily: AppFonts.poppinsReg,
                          color: PortColor.blackLight,
                          size: 13,
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
        .then((_) {
          _isPageVisible = false;
          _pageContext = null;
        });

    _pageContext = context;
  }
}
