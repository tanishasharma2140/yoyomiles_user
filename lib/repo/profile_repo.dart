import 'package:flutter/foundation.dart';
import 'package:yoyomiles/helper/helper/network/base_api_services.dart';
import 'package:yoyomiles/helper/helper/network/network_api_services.dart';
import 'package:yoyomiles/model/profile_model.dart';
import 'package:yoyomiles/res/api_url.dart';
class ProfileRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<ProfileModel> profileApi(String userId, String fcm) async {
    try {
      String url = "${ApiUrl.profileUrl}$userId?fcm=$fcm";

      dynamic response = await _apiServices.getGetApiResponse(url);
      return ProfileModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during profileApi: $e');
      }
      rethrow;
    }
  }
}