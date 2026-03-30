import 'package:flutter/foundation.dart';
import 'package:yoyomiles/helper/helper/network/base_api_services.dart';
import 'package:yoyomiles/helper/helper/network/network_api_services.dart';
import 'package:yoyomiles/model/settings_model.dart';
import 'package:yoyomiles/res/api_url.dart';
class SettingRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<SettingsModel> settingApi(dynamic data) async {
    try {
      dynamic response =
      await _apiServices.getGetApiResponse(ApiUrl.settingsUrl+ data);
      return SettingsModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during settingAPi: $e');
      }
      rethrow;
    }
  }
}