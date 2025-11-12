// dart
// File: `lib/view/auth/otp_page.dart`
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:port_karo/generated/assets.dart';
import 'package:port_karo/main.dart';
import 'package:port_karo/res/app_fonts.dart';
import 'package:port_karo/res/constant_color.dart';
import 'package:port_karo/res/constant_text.dart';
import 'package:port_karo/utils/utils.dart';
import 'package:port_karo/view/auth/login_page.dart';
import 'package:port_karo/view_model/login_view_model.dart';
import 'package:provider/provider.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> with SingleTickerProviderStateMixin {
  bool _isButtonActive = false;
  late Timer _timer;
  int _remainingTime = 60;
  final TextEditingController _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Map arguments =
      ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      Provider.of<AuthViewModel>(
        context,
        listen: false,
      ).sendOtpApi(arguments["mobileNumber"], context);
    });
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOtp() {
    Map arguments =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final enteredOtp = _otpController.text.trim();
    if (enteredOtp.length == 4 && int.tryParse(enteredOtp) != null) {
      final loginViewModel = Provider.of<AuthViewModel>(context, listen: false);
      loginViewModel.verifyOtpApi(
        arguments["mobileNumber"],
        enteredOtp,
        arguments["userId"],
        context,
      );
    } else {
      Utils.showErrorMessage(context, "Please enter a valid 4-digit OTP.");
    }
  }

  @override
  Widget build(BuildContext context) {
    Map arguments =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final otp = Provider.of<AuthViewModel>(context);
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: PortColor.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.07,
              vertical: screenHeight * 0.08,
            ),
            child: Column(
              children: [
                Container(
                  height: screenHeight * 0.11,
                  width: screenWidth * 0.6,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(Assets.assetsYoyoMilesRemoveBg),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.015),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(
                      image: const AssetImage(Assets.assetsIndiaflagsquare),
                      height: screenHeight * 0.023,
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    TextConst(
                      title: arguments["mobileNumber"],
                      color: PortColor.black,
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      child: TextConst(
                        title: "CHANGE",
                        color: PortColor.gold,
                        fontFamily: AppFonts.kanitReg,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.03),
                TextConst(
                  textAlign: TextAlign.center,
                  title: "One Time Password (OTP) has been sent to this number",
                  color: PortColor.gray,
                  fontFamily: AppFonts.kanitReg,
                ),
                SizedBox(height: screenHeight * 0.08),
                TextField(
                  controller: _otpController,
                  decoration: InputDecoration(
                    hintText: "Enter OTP Manually",
                    counterText: '',
                    hintStyle: TextStyle(
                      color: Colors.black.withOpacity(0.3),
                      fontFamily: AppFonts.poppinsReg,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: PortColor.gray,
                        width: screenWidth * 0.001,
                      ),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: PortColor.gray, width: 1.0),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  cursorColor: Colors.black,
                  maxLength: 4,
                  style: const TextStyle(color: Colors.black),
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    setState(() {
                      _isButtonActive = value.length == 4;
                    });
                  },
                ),
                SizedBox(height: screenHeight * 0.02),
                GestureDetector(
                  onTap: _isButtonActive ? _verifyOtp : null,
                  child: Container(
                    height: screenHeight * 0.06,
                    decoration: BoxDecoration(
                      gradient: _isButtonActive
                          ? const LinearGradient(
                        colors: [
                          Color(0xFFFFD700),
                          PortColor.rapidSplash,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                          : LinearGradient(
                        colors: [
                          PortColor.gray.withOpacity(0.5),
                          PortColor.gray.withOpacity(0.3),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    alignment: Alignment.center,
                    child: otp.verifyingOtp
                        ? const CupertinoActivityIndicator(
                      radius: 14,
                      color: Colors.white,
                    )
                        : TextConst(
                      title: "Verify",
                      color: _isButtonActive ? Colors.black : Colors.black,
                      fontFamily: AppFonts.kanitReg,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.02),
                _remainingTime > 0
                    ? Text(
                  "Resend OTP in $_remainingTime seconds",
                  style: const TextStyle(color: Colors.black54),
                )
                    : GestureDetector(
                  onTap: () {
                    setState(() {
                      _remainingTime = 60;
                      _startTimer();
                    });
                  },
                  child: const TextConst(
                    title: "Resend OTP",
                    color: PortColor.gold,
                    fontFamily: AppFonts.poppinsReg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
