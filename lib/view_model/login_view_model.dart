import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:port_karo/repo/login_repo.dart';
import 'package:port_karo/res/constant_color.dart';
import 'package:port_karo/res/constant_text.dart';
import 'package:port_karo/utils/routes/routes.dart';
import 'package:port_karo/utils/utils.dart';
import 'package:port_karo/view/bottom_nav_bar.dart';
import 'package:port_karo/view_model/user_view_model.dart';

class AuthViewModel with ChangeNotifier {
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

  Future<void> loginApi(dynamic mobile, String fcmToken, context) async {
    setLoading(true);
    Map data = {
      "phone": mobile,
      "fcm": fcmToken
    };

    _loginRepo.loginApi(data).then((value) {
      if (value['success'] == true) {
        setLoading(false);
        if (value['status'] == 2) {
          _showPopup(context);
          return;
        } else {
          Navigator.pushNamed(context, RoutesName.otp, arguments: {
            "mobileNumber": mobile,
            "userId": value["user_id"].toString(),
          });
        }
      } else {
        Navigator.pushNamed(context, RoutesName.register, arguments: {'mobileNumber': mobile});
        setLoading(false);
      }
    }).onError((error, stackTrace) {
      setLoading(false);
      if (kDebugMode) {
        Utils.showErrorMessage(context, 'error: $error');
        print('error: $error');
      }
    });
  }

  void _showPopup(BuildContext context) {
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
            title: 'Account Suspicion Alert!',
            color: PortColor.red,
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'Your account is suspected. Please contact the admin for more details.',
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
                child: const Center(
                  child: Text(
                    'OK',
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

  Future<void> sendOtpApi(dynamic mobile, BuildContext context) async {
    try {
      setSendingOtp(true);
      final value = await _loginRepo.sendOtpApi(mobile.toString());
      setSendingOtp(false);

      if (value['error'].toString() == "200") {
        Utils.showSuccessMessage(context, value['msg']);
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

  Future<void> verifyOtpApi(dynamic phone, dynamic otp, dynamic userId, BuildContext context) async {
    try {
      setVerifyingOtp(true);
      final value = await _loginRepo.verifyOtpApi(phone, otp);
      setVerifyingOtp(false);

      if (value['error'].toString() == "200") {
        UserViewModel userViewModel = UserViewModel();
        userViewModel.saveUser(userId);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const BottomNavigationPage()),
              (context) => false,
        );
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