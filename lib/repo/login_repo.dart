import 'package:flutter/foundation.dart';
import 'package:yoyomiles/helper/helper/network/base_api_services.dart';
import 'package:yoyomiles/helper/helper/network/network_api_services.dart';
import 'package:yoyomiles/res/api_url.dart';
class AuthRepository {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<dynamic> loginApi(dynamic data) async {

    try {
      dynamic response =
      await _apiServices.getPostApiResponse(ApiUrl.loginUrl, data);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during loginApi: $e');
      }
      rethrow;
    }
  }
  Future<dynamic> sendOtpApi(dynamic mobile) async {
    try {
      dynamic response =
      await _apiServices.getGetApiResponse('${ApiUrl.sendOtpUrl}$mobile');
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during loginApi: $e');
      }
      rethrow;
    }
  }
  Future<dynamic> verifyOtpApi(dynamic phone , dynamic otp) async {
    try {
      dynamic response =
      await _apiServices.getGetApiResponse('${ApiUrl.verifyOtpUrl}$phone&otp=$otp');
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during loginApi: $e');
      }
      rethrow;
    }
  }


}