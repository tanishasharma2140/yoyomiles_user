import 'package:flutter/foundation.dart';
import 'package:port_karo/helper/helper/network/base_api_services.dart';
import 'package:port_karo/helper/helper/network/network_api_services.dart';
import 'package:port_karo/model/port_banner_model.dart';
import 'package:port_karo/res/api_url.dart';
class PortBannerRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<PortBannerModel> portBannerApi() async {
    try {
      dynamic response =
      await _apiServices.getGetApiResponse(ApiUrl.portBannerUrl);
      return PortBannerModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during portBannerApi: $e');
      }
      rethrow;
    }
  }
}