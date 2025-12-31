import 'package:flutter/foundation.dart';
import 'package:yoyomiles/helper/helper/network/base_api_services.dart';
import 'package:yoyomiles/helper/helper/network/network_api_services.dart';
import 'package:yoyomiles/model/otp_count_model.dart';
import 'package:yoyomiles/res/api_url.dart';
class OtpCountRepo {
  final BaseApiServices _apiServices = NetworkApiServices();
  Future<OtpCountModel> otpCountApi() async {
    try {
      dynamic response =
      await _apiServices.getGetApiResponse(ApiUrl.countOtpUrl);
      return OtpCountModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during otpCountAPi: $e');
      }
      rethrow;
    }
  }
}
