import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yoyomiles/model/otp_count_model.dart';
import 'package:yoyomiles/repo/otp_count_repo.dart';
import 'package:yoyomiles/utils/utils.dart';

class OtpCountViewModel with ChangeNotifier {
  final OtpCountRepo _otpCountRepo = OtpCountRepo();

  bool _loading = false;
  bool get loading => _loading;

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  OtpCountModel? _otpCountModel;
  OtpCountModel? get otpCountModel => _otpCountModel;

  void setOtpCountModelData(OtpCountModel value) {
    _otpCountModel = value;
    notifyListeners();
  }

  /// 🔹 API CALL
  Future<void> otpCountApi(BuildContext context) async {
    setLoading(true);

    try {
      final response = await _otpCountRepo.otpCountApi();

      if (response.success == true) {
        setOtpCountModelData(response);
      } else {
        Utils.showErrorMessage(
          context,
          response.message ?? "Something went wrong",
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in OtpCount API: $e');
      }
      Utils.showErrorMessage(context, "Unable to fetch OTP count");
    } finally {
      setLoading(false);
    }
  }
}
