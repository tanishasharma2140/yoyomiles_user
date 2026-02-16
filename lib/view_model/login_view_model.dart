import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yoyomiles/l10n/app_localizations.dart';
import 'package:yoyomiles/main.dart';
import 'package:yoyomiles/repo/login_repo.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/res/constant_text.dart';
import 'package:yoyomiles/utils/routes/routes.dart';
import 'package:yoyomiles/utils/utils.dart';
import 'package:yoyomiles/view/auth/otp_page.dart';
import 'package:yoyomiles/view/auth/register_page.dart';
import 'package:yoyomiles/view/bottom_nav_bar.dart';
import 'package:yoyomiles/view_model/otp_count_view_model.dart';
import 'package:yoyomiles/view_model/user_view_model.dart';

class AuthViewModel with ChangeNotifier {
  final TextEditingController phoneController = TextEditingController();

  final _loginRepo = AuthRepository();

  bool _loading = false;
  bool get loading => _loading;

  bool _sendingOtp = false;
  bool get sendingOtp => _sendingOtp;

  bool _verifyingOtp = false;
  bool get verifyingOtp => _verifyingOtp;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  setSendingOtp(bool value) {
    _sendingOtp = value;
    notifyListeners();
  }

  setVerifyingOtp(bool value) {
    _verifyingOtp = value;
    notifyListeners();
  }

  Future<void> loginApi(BuildContext context) async {
    setLoading(true);


    final Map<String, dynamic> data = {
      "phone": phoneController.text,
      "fcm": fcmToken,
    };

    try {
      final value = await _loginRepo.loginApi(data);
      setLoading(false);

      /// 🟢 REGISTERED USER
      if (value['success'] == true) {
        if (value['status'] == 2) {
          _showPopup(context);
          return;
        }

        // ✅ SAVE USER ID
        final userId = value['user_id'].toString();
        final userVm = UserViewModel();
        await userVm.saveUser(userId);

        Utils.showSuccessMessage(context, value['message']);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const BottomNavigationPage()),
              (route) => false,
        );
        return;
      }

      /// 🔴 NOT REGISTERED USER
      if (value['message'] == "Mobile number not found.") {
        Utils.showErrorMessage(context, value['message']);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RegisterPage(
              mobile: phoneController.text,
            ),
          ),
        );
        return;
      }

      /// 🔴 OTHER FAILURE
      Utils.showErrorMessage(
        context,
        value['message'] ?? "Something went wrong",
      );
    } catch (error) {
      setLoading(false);
      if (kDebugMode) {
        print('❌ Login API error: $error');
      }
      Utils.showErrorMessage(context, "Server error");
    }
  }


  void _showPopup(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: PortColor.white,
          title: TextConst(
            title: loc.account_suspicion,
            color: PortColor.red,
            textAlign: TextAlign.center,
          ),
          content:  Text(
            loc.account_is_suspected,
            style: TextStyle(
                color: Color(0xFF721C24),
                fontSize: 16,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: PortColor.red,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: PortColor.white,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child:  Center(
                  child: Text(
                    loc.oK,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  Future<void> otpSentApi(String mobile, BuildContext context) async {
    setLoading(true);
    try {
      final value = await _loginRepo.sendOtpApi(mobile.toString());

      setLoading(false);
      if (value['error'].toString() == "200") {
        Utils.showSuccessMessage(context, value['msg']);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpPage(mobile: mobile),
          ),
        );
        Utils.showSuccessMessage(context, value['msg'] ?? 'OTP sent successfully');
        Provider.of<OtpCountViewModel>(context,listen: false).otpCountApi(context);
      } else {
        Utils.showErrorMessage(context, value['msg']);
      }
    } catch (error, stackTrace) {
      setSendingOtp(false);
      if (kDebugMode) {
        print('Send OTP error: $error');
      }
    }
  }

  Future<void> otpReSentApi(String phoneNumber, BuildContext context) async {
    setLoading(true);
    try {
      final value = await _loginRepo.sendOtpApi(phoneNumber);

      setLoading(false);
      if (value['error'].toString() == "200") {
        Utils.showSuccessMessage(context, value['msg'] ?? 'OTP resent successfully');
        Provider.of<OtpCountViewModel>(context,listen: false).otpCountApi(context);
      }  else {
        Utils.showErrorMessage(value['msg'], 'Failed to resend OTP');
      }
    } catch (e) {
      setLoading(false);
      if (kDebugMode) print('otpReSentApi error: $e');
      Utils.showErrorMessage(context,'Something went wrong',);
    }
  }

  Future<void> verifyOtpApi(dynamic phone, dynamic otp, BuildContext context) async {
    try {
      setVerifyingOtp(true);
      final value = await _loginRepo.verifyOtpApi(phone, otp);
      setVerifyingOtp(false);

      if (value['error'].toString() == "200") {
        Utils.showSuccessMessage(context,  value['msg'] ?? 'OTP verified');
        loginApi(context);
      } else {
        Utils.showErrorMessage(context, value['msg']);
      }
    } catch (error, stackTrace) {
      setVerifyingOtp(false);
      if (kDebugMode) {
        print('Verify OTP error: $error');
      }
    }
  }
}